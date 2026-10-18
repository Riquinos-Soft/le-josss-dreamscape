const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

(async () => {
  const listeners = {}, messages = [];
  const notice = {hidden: true}, status = {}, reconnect = {};
  const frame = {contentWindow: {postMessage: value => messages.push(value)}};
  const nodes = {'#game': frame, '#connection': notice, '#connection-status': status,
    '#reconnect': reconnect, '#ticket-auth': {elements: {csrfmiddlewaretoken: {value: 'test-csrf'}}}};
  let timeout;
  const origin = 'https://game.example';
  const context = {document: {querySelector: key => nodes[key]}, location: {origin},
    window: {addEventListener: (kind, listener) => {listeners[kind] = listener;}},
    fetch: async () => ({ok: true, status: 200, json: async () => ({ticket: 'ephemeral', socket_url: 'wss://game.example/ws/'})}),
    setTimeout: callback => {timeout = callback; return 1;}, clearTimeout: () => {timeout = null;}};
  vm.runInNewContext(fs.readFileSync('backend/accounts/static/accounts/play.js', 'utf8'), context);
  const emit = type => listeners.message({origin, source: frame.contentWindow,
    data: {channel: 'dreamscape-account', type}});
  const flush = () => new Promise(resolve => setImmediate(resolve));
  emit('ready');
  await flush();
  assert.equal(notice.hidden, true, 'startup must not show a connecting banner');
  assert.equal(messages[0].type, 'connect');
  emit('joined');
  assert.equal(timeout, null);
  emit('error');
  assert.equal(notice.hidden, false, 'failure must remain visible');
  assert.equal(reconnect.hidden, false);
  await reconnect.onclick();
  assert.equal(notice.hidden, true, 'reconnect must not show a loading banner');
  timeout();
  assert.equal(notice.hidden, false, 'timeout retains actionable feedback');
  emit('joined');
  assert.equal(notice.hidden, true);
  console.log('PASS: quiet startup/reconnect, joined cleanup and actionable errors/timeouts.');
})().catch(error => {console.error(error); process.exitCode = 1;});
