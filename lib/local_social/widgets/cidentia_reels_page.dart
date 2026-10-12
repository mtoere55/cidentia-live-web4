import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../auth/cidentia_session_scope.dart';

const _apiBase = String.fromEnvironment(
  'CIDENTIA_LIVE_API_BASE_URL',
  defaultValue: 'https://api.cidentia.live',
);

/// Real, edge-to-edge Reels viewer. The old preview is preserved separately.
/// Public feed data comes from Cidentia-Live-Backend, never from mock posts.
class CidentiaReelsPage extends StatefulWidget {
  const CidentiaReelsPage({super.key});

  @override
  State<CidentiaReelsPage> createState() => _CidentiaReelsPageState();
}

class _ReelSource {
  const _ReelSource({
    required this.id,
    required this.author,
    required this.caption,
    this.videoUrl,
    this.localFile,
  });

  final String id;
  final String author;
  final String caption;
  final String? videoUrl;
  final XFile? localFile;
  bool get isLocal => localFile != null;
}

class _CidentiaReelsPageState extends State<CidentiaReelsPage> {
  final PageController _pages = PageController();
  final List<_ReelSource> _reels = [];
  int _current = 0;
  bool _loading = false;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Uri _uri(String route) => Uri.parse(_apiBase.replaceFirst(RegExp(r'/+$'), '') + route);

  Future<void> _refreshFeed() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(_uri('/api/social/feed?limit=30'));
      final body = jsonDecode(response.body);
      if (response.statusCode != 200 || body is! Map || body['ok'] != true) {
        throw const FormatException('Akis sunucusu henuz hazir degil.');
      }
      final rows = body['items'];
      if (rows is! List) throw const FormatException('Akis formati gecersiz.');
      final remote = <_ReelSource>[];
      for (final row in rows.take(30)) {
        if (row is! Map) continue;
        final mediaId = row['mediaAssetId'] ?? row['mediaId'];
        final id = row['reelId'] ?? row['id'];
        if (mediaId is! String || id is! String) continue;

        // Authorization and short-lived media URL are decided by the backend.
        final urlResponse = await http.post(
          _uri('/api/media/read-url'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': mediaId}),
        );
        if (urlResponse.statusCode != 200) continue;
        final urlBody = jsonDecode(urlResponse.body);
        if (urlBody is! Map || urlBody['signedMediaReadUrl'] is! String) continue;
        remote.add(
          _ReelSource(
            id: id,
            author: (row['ownerDisplayName'] ?? row['ownerCid'] ?? 'Cidentia').toString(),
            caption: (row['caption'] ?? '').toString(),
            videoUrl: urlBody['signedMediaReadUrl'] as String,
          ),
        );
      }
      if (!mounted) return;
      final local = _reels.where((reel) => reel.isLocal).toList();
      setState(() {
        _reels
          ..clear()
          ..addAll(local)
          ..addAll(remote);
        _current = 0;
      });
      if (_pages.hasClients) _pages.jumpToPage(0);
      if (rows.isNotEmpty && remote.isEmpty && local.isEmpty) {
        setState(() {
          _error = 'Videolar bulundu ancak oynatma izinli medya adresi alinamadi. Cidentia oturumunu kontrol edin.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Reels sunucusuna ulasilamadi. Cihazdan video secerek oynaticiyi deneyebilirsiniz.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectVideo() async {
    try {
      final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (picked == null || !mounted) return;
      final size = await picked.length();
      if (size == 0) throw const FormatException('Secilen video bos.');
      setState(() {
        _reels.insert(
          0,
          _ReelSource(
            id: 'local-' + DateTime.now().microsecondsSinceEpoch.toString(),
            author: 'Cihazim',
            caption: 'Yerel video onizlemesi - henuz yayinlanmadi',
            localFile: picked,
          ),
        );
        _current = 0;
        _error = null;
      });
      if (_pages.hasClients) _pages.jumpToPage(0);
    } catch (_) {
      _notice('Video secilemedi. Dosya erisimini ve MP4 bicimini kontrol edin.');
    }
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _requestCaption() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reel yayinla'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 2200,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Videonu anlat...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgec'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Devam'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _publish(_ReelSource reel) async {
    final file = reel.localFile;
    if (file == null || _uploading) return;
    if (CidentiaSessionScope.maybeOf(context)?.hasVerifiedCid != true) {
      _notice('Video yayinlamak icin dogrulanmis CID oturumu gerekiyor.');
      return;
    }
    if (!file.name.toLowerCase().endsWith('.mp4')) {
      _notice('Ilk surumde MP4 destekleniyor. Diger bicimler icin donusturme gerekli.');
      return;
    }
    final caption = await _requestCaption();
    if (caption == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final size = await file.length();
      final uploadResponse = await http.post(
        _uri('/api/upload/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': file.name,
          'mimeType': 'video/mp4',
          'surface': 'reel',
          'byteLength': size,
        }),
      );
      final grant = jsonDecode(uploadResponse.body);
      if (grant is! Map || uploadResponse.statusCode != 200 || grant['ok'] != true) {
        throw const FormatException('Yukleme izni verilmedi. Sunucu oturumunu kontrol edin.');
      }
      final uploadUrl = grant['uploadUrl'];
      final objectKey = grant['storageObjectKey'];
      final bucket = grant['storageBucket'];
      if (uploadUrl is! String || objectKey is! String || bucket is! String) {
        throw const FormatException('Sunucu eksik yukleme bilgisi gonderdi.');
      }

      // Stream the file rather than loading a large video into memory.
      final request = http.StreamedRequest('PUT', Uri.parse(uploadUrl))
        ..headers['Content-Type'] = 'video/mp4'
        ..contentLength = size;
      final client = http.Client();
      try {
        final sending = client.send(request);
        await request.sink.addStream(file.openRead());
        await request.sink.close();
        final result = await sending;
        if (result.statusCode < 200 || result.statusCode >= 300) {
          throw const FormatException('Video depoya yuklenemedi.');
        }
      } finally {
        client.close();
      }

      final publishResponse = await http.post(
        _uri('/api/posts/publish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mode': 'reel',
          'storageObjectKey': objectKey,
          'storageBucket': bucket,
          'mimeType': 'video/mp4',
          'byteLength': size,
          'caption': caption,
        }),
      );
      final published = jsonDecode(publishResponse.body);
      if (publishResponse.statusCode != 200 ||
          published is! Map ||
          published['ok'] != true) {
        throw const FormatException('Video yuklendi ancak paylasim tamamlanmadi.');
      }
      _notice('Video yayinlandi. Akis yenileniyor.');
      await _refreshFeed();
    } catch (error) {
      _notice(error is FormatException ? error.message : 'Video aktarimi basarisiz oldu. Lutfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _like(_ReelSource reel) async {
    if (reel.isLocal) return;
    try {
      final response = await http.post(
        _uri('/api/social/reel-action'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reelId': reel.id, 'action': 'like'}),
      );
      if (response.statusCode == 200) {
        _notice('Begenildi.');
      } else {
        _notice('Begenmek icin oturum acmaniz veya sunucuyu etkinlestirmeniz gerekiyor.');
      }
    } catch (_) {
      _notice('Begeni gonderilemedi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: _reels.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.movie_outlined, color: Colors.white, size: 62),
                        const SizedBox(height: 16),
                        Text(
                          _loading ? 'Reels yukleniyor...' : (_error ?? 'Henuz yayinda video yok.'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _selectVideo,
                          icon: const Icon(Icons.video_library_outlined),
                          label: const Text('Galeriden video sec'),
                        ),
                        TextButton(
                          onPressed: _loading ? null : _refreshFeed,
                          child: const Text('Tekrar dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : PageView.builder(
                  controller: _pages,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (value) => setState(() => _current = value),
                  itemCount: _reels.length,
                  itemBuilder: (context, index) {
                    final reel = _reels[index];
                    return _ReelVideo(
                      key: ValueKey(reel.id),
                      reel: reel,
                      active: index == _current,
                      uploading: _uploading,
                      onPublish: () => _publish(reel),
                      onLike: () => _like(reel),
                    );
                  },
                ),
        ),
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Text('Reels', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                IconButton(
                  tooltip: 'Yenile',
                  onPressed: _loading ? null : _refreshFeed,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Galeriden video sec',
                  onPressed: _selectVideo,
                  icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReelVideo extends StatefulWidget {
  const _ReelVideo({
    super.key,
    required this.reel,
    required this.active,
    required this.uploading,
    required this.onPublish,
    required this.onLike,
  });

  final _ReelSource reel;
  final bool active;
  final bool uploading;
  final VoidCallback onPublish;
  final VoidCallback onLike;

  @override
  State<_ReelVideo> createState() => _ReelVideoState();
}

class _ReelVideoState extends State<_ReelVideo> {
  late final VideoPlayerController _video;
  bool _ready = false;
  bool _mute = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final file = widget.reel.localFile;
    _video = file != null
        ? (kIsWeb
            ? VideoPlayerController.networkUrl(Uri.parse(file.path))
            : VideoPlayerController.file(File(file.path)))
        : VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl!));
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _video.initialize();
      await _video.setLooping(true);
      if (!mounted) return;
      setState(() => _ready = true);
      if (widget.active) await _video.play();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didUpdateWidget(covariant _ReelVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_ready || oldWidget.active == widget.active) return;
    if (widget.active) {
      _video.play();
    } else {
      _video.pause();
    }
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_ready) return;
    if (_video.value.isPlaying) {
      _video.pause();
    } else {
      _video.play();
    }
    setState(() {});
  }

  Future<void> _toggleMute() async {
    _mute = !_mute;
    await _video.setVolume(_mute ? 0 : 1);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: ColoredBox(
            color: Colors.black,
            child: _ready
                ? ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _video.value.size.width,
                        height: _video.value.size.height,
                        child: VideoPlayer(_video),
                      ),
                    ),
                  )
                : Center(
                    child: _failed
                        ? const Text('Video oynatilamadi.', style: TextStyle(color: Colors.white))
                        : const CircularProgressIndicator(),
                  ),
          ),
        ),
        if (_ready)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(_video, allowScrubbing: true),
          ),
        Positioned(
          left: 18,
          bottom: 40,
          right: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.reel.author, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.reel.caption, maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white)),
              if (widget.reel.isLocal) ...[
                const SizedBox(height: 8),
                const Text('SADECE BU CIHAZDA', style: TextStyle(color: Colors.amber, fontSize: 11)),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: widget.uploading ? null : widget.onPublish,
                  child: Text(widget.uploading ? 'Yukleniyor...' : 'Reel yayinla'),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: 46,
          right: 12,
          child: Column(
            children: [
              IconButton(
                onPressed: widget.reel.isLocal ? null : widget.onLike,
                icon: const Icon(Icons.favorite_border, color: Colors.white, size: 30),
                tooltip: 'Begen',
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: _ready ? _toggleMute : null,
                icon: Icon(_mute ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 29),
                tooltip: 'Ses',
              ),
              const SizedBox(height: 12),
              IconButton(
                onPressed: _ready ? _togglePlay : null,
                icon: Icon(_ready && _video.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, size: 29),
                tooltip: 'Oynat / durdur',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
