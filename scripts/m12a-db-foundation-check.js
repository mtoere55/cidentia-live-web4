'use strict';

const fs = require('fs');
const path = require('path');
const { loadDatabaseContract } = require('../server/db/databaseContract');

const migrationPath = path.join(
  __dirname,
  '..',
  'server',
  'db',
  'migrations',
  '001_m12a_social_media_foundation.sql',
);

const sql = fs.readFileSync(migrationPath, 'utf8');
const requiredMarkers = [
  'CREATE TABLE IF NOT EXISTS cidentia_profiles',
  'CREATE TABLE IF NOT EXISTS cidentia_media_assets',
  'CREATE TABLE IF NOT EXISTS cidentia_posts',
  'CREATE TABLE IF NOT EXISTS cidentia_reels',
  'CREATE TABLE IF NOT EXISTS cidentia_comments',
  'CREATE TABLE IF NOT EXISTS cidentia_likes',
  'CREATE TABLE IF NOT EXISTS cidentia_follows',
];

const missing = requiredMarkers.filter((marker) => !sql.includes(marker));
const contract = loadDatabaseContract({});

if (missing.length > 0) {
  console.error(JSON.stringify({ ok: false, missing }, null, 2));
  process.exit(1);
}

console.log(
  JSON.stringify(
    {
      ok: true,
      migrationPath,
      tablesDefined: requiredMarkers.length,
      dbConnected: contract.dbConnected,
      migrationExecuted: contract.migrationExecuted,
      writeLocked: contract.locked.writeLocked,
      secretsExposed: contract.secretsExposed,
    },
    null,
    2,
  ),
);
