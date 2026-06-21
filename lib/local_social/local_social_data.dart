import 'package:flutter/material.dart';

class LocalPost {
  const LocalPost({
    required this.author,
    required this.handle,
    required this.time,
    required this.caption,
    required this.accent,
    required this.likes,
    required this.comments,
  });

  final String author;
  final String handle;
  final String time;
  final String caption;
  final List<Color> accent;
  final String likes;
  final String comments;
}

class ServerBackedPostBoundary {
  const ServerBackedPostBoundary({
    required this.feedRoute,
    required this.reelsRoute,
    required this.profilePostsRoute,
    required this.status,
  });

  final String feedRoute;
  final String reelsRoute;
  final String profilePostsRoute;
  final String status;
}

const cidentiaPostBoundary = ServerBackedPostBoundary(
  feedRoute: 'GET /api/feed',
  reelsRoute: 'GET /api/reels',
  profilePostsRoute: 'GET /api/profile/posts',
  status: '503 guarded - server-backed post model locked',
);

class LivePermissionStateModel {
  const LivePermissionStateModel({
    required this.camera,
    required this.microphone,
    required this.screenCapture,
  });

  final String camera;
  final String microphone;
  final String screenCapture;
}

class LiveSourceStateModel {
  const LiveSourceStateModel({
    required this.sourceId,
    required this.type,
    required this.label,
    required this.status,
    required this.permissionStatus,
  });

  final String sourceId;
  final String type;
  final String label;
  final String status;
  final String permissionStatus;
}

class LiveDestinationStateModel {
  const LiveDestinationStateModel({
    required this.destinationId,
    required this.type,
    required this.displayName,
    required this.status,
    required this.credentialStatus,
  });

  final String destinationId;
  final String type;
  final String displayName;
  final String status;
  final String credentialStatus;
}

class LiveGuestStateModel {
  const LiveGuestStateModel({
    required this.guestId,
    required this.displayName,
    required this.role,
    required this.status,
  });

  final String guestId;
  final String displayName;
  final String role;
  final String status;
}

class LiveReplayStateModel {
  const LiveReplayStateModel({
    required this.replayId,
    required this.status,
    required this.mediaId,
    required this.postId,
  });

  final String replayId;
  final String status;
  final String mediaId;
  final String postId;
}

class LiveSessionStateModel {
  const LiveSessionStateModel({
    required this.liveSessionId,
    required this.ownerCid,
    required this.title,
    required this.mode,
    required this.status,
    required this.viewerCount,
    required this.permissions,
    required this.sources,
    required this.destinations,
    required this.guests,
    required this.replay,
    required this.routeStatus,
  });

  final String liveSessionId;
  final String ownerCid;
  final String title;
  final String mode;
  final String status;
  final int viewerCount;
  final LivePermissionStateModel permissions;
  final List<LiveSourceStateModel> sources;
  final List<LiveDestinationStateModel> destinations;
  final List<LiveGuestStateModel> guests;
  final LiveReplayStateModel replay;
  final String routeStatus;
}

const cidentiaLiveSessionBoundary = LiveSessionStateModel(
  liveSessionId: 'local-preview-live-session',
  ownerCid: 'verified-cid-required',
  title: 'Cidentia.Live guarded live session preview',
  mode: 'normal',
  status: 'guarded_disabled',
  viewerCount: 0,
  permissions: LivePermissionStateModel(
    camera: 'locked_no_camera_permission',
    microphone: 'locked_no_record_audio_permission',
    screenCapture: 'locked_no_capture_permission',
  ),
  sources: [
    LiveSourceStateModel(
      sourceId: 'camera-preview',
      type: 'camera',
      label: 'Camera',
      status: 'preview_only',
      permissionStatus: 'permission_locked',
    ),
    LiveSourceStateModel(
      sourceId: 'screen-preview',
      type: 'screen',
      label: 'Screen Share',
      status: 'preview_only',
      permissionStatus: 'capture_locked',
    ),
  ],
  destinations: [
    LiveDestinationStateModel(
      destinationId: 'custom-rtmp-preview',
      type: 'custom_rtmp',
      displayName: 'Custom RTMP',
      status: 'connection_locked',
      credentialStatus: 'no_stream_key_stored',
    ),
  ],
  guests: [
    LiveGuestStateModel(
      guestId: 'guest-preview-slot',
      displayName: 'Guest slot',
      role: 'guest',
      status: 'invite_locked',
    ),
  ],
  replay: LiveReplayStateModel(
    replayId: 'replay-preview',
    status: 'recording_locked',
    mediaId: 'not_created',
    postId: 'not_published',
  ),
  routeStatus: '503 guarded - live session model locked',
);

const localPosts = [
  LocalPost(
    author: 'Mira Studio',
    handle: '@mira.studio',
    time: '18m',
    caption:
        'Cidentia.Live local social flow is ready. First a stable shell, then verified CID and wallet layers.',
    accent: [Color(0xFFE879F9), Color(0xFFEC4899), Color(0xFFF97316)],
    likes: '12.8K',
    comments: '384',
  ),
  LocalPost(
    author: 'Web4 Lab',
    handle: '@web4.lab',
    time: '2h',
    caption:
        'Feed, Reels, Chats and Profile open with local data. The same shell will grow when the backend boundary is connected.',
    accent: [Color(0xFF60A5FA), Color(0xFF06B6D4), Color(0xFF14B8A6)],
    likes: '8.1K',
    comments: '211',
  ),
  LocalPost(
    author: 'Creator Node',
    handle: '@creator.node',
    time: '1d',
    caption:
        'This is not the final design phase. The goal is to build a safe Cidentia.Live working base before real connections.',
    accent: [Color(0xFFA78BFA), Color(0xFF6366F1), Color(0xFF0EA5E9)],
    likes: '4.6K',
    comments: '97',
  ),
];

class LocalStory {
  const LocalStory({
    required this.label,
    required this.color,
    this.isCreate = false,
  });

  final String label;
  final Color color;
  final bool isCreate;
}

const localStories = [
  LocalStory(label: 'You', color: Colors.pinkAccent, isCreate: true),
  LocalStory(label: 'Mira', color: Colors.orangeAccent),
  LocalStory(label: 'Web4', color: Colors.cyanAccent),
  LocalStory(label: 'Node', color: Colors.purpleAccent),
  LocalStory(label: 'Live', color: Colors.lightGreenAccent),
  LocalStory(label: 'Market', color: Colors.amberAccent),
  LocalStory(label: 'Truth', color: Colors.blueAccent),
];

class LocalChat {
  const LocalChat({
    required this.name,
    required this.message,
    required this.time,
  });

  final String name;
  final String message;
  final String time;
}

const localChats = [
  LocalChat(
    name: 'Mira Studio',
    message: 'Local preview is ready.',
    time: '2m',
  ),
  LocalChat(
    name: 'Web4 Lab',
    message: 'Backend will be connected later.',
    time: '21m',
  ),
  LocalChat(
    name: 'Creator Node',
    message: 'Profile screen is using demo data.',
    time: '1h',
  ),
  LocalChat(
    name: 'Market Intel',
    message: 'Wallet area will come later.',
    time: '4h',
  ),
  LocalChat(
    name: 'Truth Scanner',
    message: 'Proof layer is planned.',
    time: '1d',
  ),
];
