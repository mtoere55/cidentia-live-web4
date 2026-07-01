import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_instagram_offline_first_clone/local_social/local_social_app.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(const LocalSocialApp());
}
