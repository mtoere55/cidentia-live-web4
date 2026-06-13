'use strict';

const assert = require('node:assert/strict');

const sendHandler = require('../api/cidendb/otp/send');
const verifyHandler = require('../api/cidendb/otp/verify');

function makeResponse() {
  const headers = {};
  return {
    statusCode: 0,
    body: '',
    headers,
    setHeader(name, value) {
      headers[String(name).toLowerCase()] = value;
    },
    end(value) {
      this.body = value === undefined ? '' : String(value);
    },
    json() {
      return this.body ? JSON.parse(this.body) : {};
    },
  };
}

async function call(handler, options = {}) {
  const req = {
    method: options.method || 'POST',
    headers: options.headers || {},
    body: options.body || {},
  };
  const res = makeResponse();
  await handler(req, res);
  return res;
}

function resetEnv() {
  delete process.env.CIDENDB_BRIDGE_ENABLED;
  delete process.env.CIDENDB_CONTRACT_CONFIRMED;
  delete process.env.CIDENDB_UPSTREAM_BASE;
  delete process.env.CIDENTIA_ALLOWED_ORIGIN;
}

async function assertDisabledGuard(handler, label) {
  resetEnv();
  let fetchCalled = false;
  const originalFetch = global.fetch;
  global.fetch = async () => {
    fetchCalled = true;
    throw new Error('fetch must not be called while bridge is disabled');
  };

  try {
    const res = await call(handler, {body: {identifier: 'safe@example.com'}});
    const payload = res.json();

    assert.equal(res.statusCode, 503, `${label} disabled status`);
    assert.equal(payload.ok, false, `${label} disabled ok=false`);
    assert.equal(
      payload.code,
      'CIDENDB_BRIDGE_DISABLED',
      `${label} disabled code`,
    );
    assert.equal(fetchCalled, false, `${label} disabled no upstream fetch`);
  } finally {
    global.fetch = originalFetch;
  }
}

async function assertContractGuard(handler, label) {
  resetEnv();
  process.env.CIDENDB_BRIDGE_ENABLED = 'true';

  let fetchCalled = false;
  const originalFetch = global.fetch;
  global.fetch = async () => {
    fetchCalled = true;
    throw new Error('fetch must not be called before contract is confirmed');
  };

  try {
    const res = await call(handler, {body: {identifier: 'safe@example.com'}});
    const payload = res.json();

    assert.equal(res.statusCode, 503, `${label} contract status`);
    assert.equal(payload.ok, false, `${label} contract ok=false`);
    assert.equal(
      payload.code,
      'CIDENDB_CONTRACT_NOT_CONFIRMED',
      `${label} contract code`,
    );
    assert.equal(fetchCalled, false, `${label} contract no upstream fetch`);
  } finally {
    global.fetch = originalFetch;
  }
}

async function assertMethodGuard() {
  resetEnv();
  const res = await call(sendHandler, {method: 'GET'});
  const payload = res.json();

  assert.equal(res.statusCode, 405, 'GET status');
  assert.equal(payload.ok, false, 'GET ok=false');
  assert.equal(payload.code, 'CIDENDB_METHOD_NOT_ALLOWED', 'GET code');
}

async function main() {
  await assertMethodGuard();
  await assertDisabledGuard(sendHandler, 'send');
  await assertDisabledGuard(verifyHandler, 'verify');
  await assertContractGuard(sendHandler, 'send');
  await assertContractGuard(verifyHandler, 'verify');

  resetEnv();
  console.log('M4C backend guard check passed. No live CidenDB fetch was opened.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
