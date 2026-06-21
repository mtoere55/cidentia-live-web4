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
