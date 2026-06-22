-- M12A Cidentia.Live real DB foundation
-- This migration defines the target schema shape.
-- Do not run automatically from Flutter or chat.
-- Execute only from the backend/VPS migration process after DB env is ready.

CREATE TABLE IF NOT EXISTS cidentia_profiles (
  id UUID PRIMARY KEY,
  owner_cid TEXT NOT NULL UNIQUE,
  display_name TEXT,
  email TEXT,
  bio TEXT,
  avatar_media_id UUID,
  cover_media_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cidentia_media_assets (
  id UUID PRIMARY KEY,
  owner_cid TEXT NOT NULL,
  owner_display_name_snapshot TEXT,
  media_surface TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  byte_size BIGINT NOT NULL,
  storage_bucket TEXT NOT NULL,
  storage_object_key TEXT NOT NULL,
  visibility TEXT NOT NULL DEFAULT 'private',
  moderation_status TEXT NOT NULL DEFAULT 'pending',
  upload_source TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cidentia_posts (
  id UUID PRIMARY KEY,
  owner_cid TEXT NOT NULL,
  media_id UUID REFERENCES cidentia_media_assets(id),
  caption TEXT,
  visibility TEXT NOT NULL DEFAULT 'public',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cidentia_reels (
  id UUID PRIMARY KEY,
  owner_cid TEXT NOT NULL,
  media_id UUID REFERENCES cidentia_media_assets(id),
  caption TEXT,
  visibility TEXT NOT NULL DEFAULT 'public',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cidentia_comments (
  id UUID PRIMARY KEY,
  post_id UUID REFERENCES cidentia_posts(id),
  owner_cid TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cidentia_likes (
  id UUID PRIMARY KEY,
  target_type TEXT NOT NULL,
  target_id UUID NOT NULL,
  owner_cid TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (target_type, target_id, owner_cid)
);

CREATE TABLE IF NOT EXISTS cidentia_follows (
  id UUID PRIMARY KEY,
  follower_cid TEXT NOT NULL,
  followed_cid TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (follower_cid, followed_cid)
);
