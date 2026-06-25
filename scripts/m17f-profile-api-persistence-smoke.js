'use strict';

const { createDatabaseClient } = require('../server/db/databaseClient');
const profileMeHandler = require('../api/profile/me');
const profileUpdateHandler = require('../api/profile/update');

function envTrue(key) {
  return process.env[key] === 'true' || process.env[key] === '1';
}

function requireSmokeGate() {
  const required = [
    'CIDENTIA_PROFILE_API_PERSISTENCE_SMOKE',
    'CIDENTIA_DATABASE_ENABLED',
    'CIDENTIA_DATABASE_QUERY_ENABLED',
  ];

  const missing = required.filter((key) => !envTrue(key));

  if (missing.length > 0) {
    return Object.freeze({
      ok: false,
      code: 'M17F_SMOKE_GATES_DISABLED',
      missing,
      profileUpdated: false,
      profileRead: false,
      routeUpdateOk: false,
      routeReadOk: false,
      cleanupDone: false,
      dbConnected: false,
      queryEnabled: false,
      secretsExposed: false,
    });
  }

  if (
    typeof process.env.CIDENTIA_DATABASE_URL !== 'string' ||
    process.env.CIDENTIA_DATABASE_URL.trim().length === 0
  ) {
    return Object.freeze({
      ok: false,
      code: 'DATABASE_URL_MISSING',
      profileUpdated: false,
      profileRead: false,
      routeUpdateOk: false,
      routeReadOk: false,
      cleanupDone: false,
      dbConnected: false,
      queryEnabled: false,
      secretsExposed: false,
    });
  }

  return Object.freeze({
    ok: true,
    code: 'M17F_SMOKE_GATES_READY',
  });
}

function createMockResponse() {
  const state = {
    statusCode: 200,
    payload: null,
  };

  return {
    state,
    status(code) {
      state.statusCode = code;
      return this;
    },
    json(payload) {
      state.payload = payload;
      return this;
    },
  };
}

async function callProfileUpdate(ownerCid, body) {
  const req = {
    method: 'POST',
    headers: {
      'x-cidentia-cid': ownerCid,
    },
    body: {
      ownerCid,
      ...body,
    },
  };

  const res = createMockResponse();
  await profileUpdateHandler(req, res);
  return res.state;
}

async function callProfileMe(ownerCid) {
  const req = {
    method: 'GET',
    headers: {
      'x-cidentia-cid': ownerCid,
    },
  };

  const res = createMockResponse();
  await profileMeHandler(req, res);
  return res.state;
}

async function main() {
  const gate = requireSmokeGate();

  if (!gate.ok) {
    console.log(JSON.stringify(gate, null, 2));
    process.exitCode = 1;
    return;
  }

  const ownerCid = 'Cid-M17F-Profile-Api-Smoke';
  const db = createDatabaseClient(process.env);
  let cleanupDone = false;

  try {
    await db.query('DELETE FROM cidentia_profiles WHERE owner_cid = $1', [
      ownerCid,
    ]);

    const update = await callProfileUpdate(ownerCid, {
      displayName: 'M17F Profile API Smoke',
      email: 'm17f-smoke@cidentia.live',
      bio: 'M17F guarded profile API route persistence smoke',
      avatarMediaId: '',
      coverMediaId: '',
    });

    const read = await callProfileMe(ownerCid);

    const profile = read.payload && read.payload.profile;

    const routeUpdateOk =
      update.statusCode === 200 &&
      update.payload &&
      update.payload.code === 'PROFILE_WRITE_OK' &&
      update.payload.profileUpdated === true;

    const routeReadOk =
      read.statusCode === 200 &&
      read.payload &&
      read.payload.code === 'PROFILE_READ_OK' &&
      read.payload.profileRead === true &&
      profile &&
      profile.ownerCid === ownerCid &&
      profile.displayName === 'M17F Profile API Smoke';

    const cleanup = await db.query(
      'DELETE FROM cidentia_profiles WHERE owner_cid = $1',
      [ownerCid],
    );
    cleanupDone = cleanup.rowCount === 1;

    const report = Object.freeze({
      ok: routeUpdateOk && routeReadOk && cleanupDone,
      code: 'M17F_PROFILE_API_PERSISTENCE_OK',
      ownerCid,
      updateStatusCode: update.statusCode,
      readStatusCode: read.statusCode,
      updateCode: update.payload && update.payload.code,
      readCode: read.payload && read.payload.code,
      profileUpdated: Boolean(update.payload && update.payload.profileUpdated),
      profileRead: Boolean(read.payload && read.payload.profileRead),
      routeUpdateOk,
      routeReadOk,
      cleanupDone,
      dbConnected: true,
      queryEnabled: true,
      secretsExposed: false,
      publicRouteDefaultOpened: false,
      flutterPersistenceOpened: false,
    });

    console.log(JSON.stringify(report, null, 2));

    if (!report.ok) {
      process.exitCode = 1;
    }
  } finally {
    if (!cleanupDone) {
      await db.query('DELETE FROM cidentia_profiles WHERE owner_cid = $1', [
        ownerCid,
      ]);
    }

    await db.close();
  }
}

main().catch((error) => {
  console.error({
    ok: false,
    code: 'M17F_PROFILE_API_PERSISTENCE_SMOKE_FAILED',
    message: error.message,
    secretsExposed: false,
  });
  process.exitCode = 1;
});
