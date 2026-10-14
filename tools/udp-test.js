// Prints what the WaveShare plugin sends over UDP. Run: node tools/udp-test.js (stop server.js first, both use port 7778)
const dgram = require('dgram');
const decks = {};
const sock = dgram.createSocket('udp4');
sock.on('message', b => {
  if (b.length < 12 || b.toString('latin1', 0, 4) !== 'VDJW' || b[4] !== 1) return;
  const deck = b[6], id = b.readUInt32LE(8);
  let d = decks[deck];
  if (!d || d.id !== id) d = decks[deck] = { id, got: null, pos: 0, sr: 1, total: 0, scanned: 0, pkts: 0 };
  d.pkts++;
  if (b[5] === 1) {
    [d.pos, d.sr, d.total, d.scanned] = [12, 16, 20, 24].map(o => b.readUInt32LE(o));
    if (!d.got || d.got.length !== d.total) d.got = new Uint8Array(d.total);
  } else if (b[5] === 2 && d.got) {
    const start = b.readUInt32LE(12), n = b.readUInt16LE(16);
    d.got.fill(1, start, Math.min(d.total, start + n));
  }
});
setInterval(() => {
  for (const [deck, d] of Object.entries(decks)) {
    const got = d.got ? d.got.reduce((a, x) => a + x, 0) : 0;
    console.log(`deck ${deck}  skladba #${d.id}  pozícia ${(d.pos / d.sr).toFixed(2)} s  spočítané ${d.scanned}/${d.total}  prijaté ${got}/${d.total}  paketov ${d.pkts}`);
  }
}, 1000);
sock.bind(7778, '127.0.0.1', () => console.log('Počúvam na 127.0.0.1:7778'));
