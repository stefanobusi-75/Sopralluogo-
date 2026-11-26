// Rapporto di Sopralluogo - funzionamento offline
const CACHE = 'sopralluogo-202611261003';
const FILES = ['./', 'index.html', 'manifest.webmanifest', 'icon-192.png', 'icon-512.png', 'icon-maskable-512.png', 'apple-touch-icon.png'];
self.addEventListener('install', (e) => { e.waitUntil(caches.open(CACHE).then((c) => c.addAll(FILES)).then(() => self.skipWaiting())); });
self.addEventListener('activate', (e) => { e.waitUntil(caches.keys().then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', (e) => {
  if (e.request.method !== 'GET') return;
  const same = new URL(e.request.url).origin === location.origin;
  if (same) {
    // prima la rete (per ricevere gli aggiornamenti), poi la copia salvata
    e.respondWith(fetch(e.request).then((r) => { const c = r.clone(); caches.open(CACHE).then((k) => k.put(e.request, c)); return r; }).catch(() => caches.match(e.request, { ignoreSearch: true }).then((r) => r || caches.match('index.html'))));
  } else {
    // caratteri grafici: copia salvata se c'è
    e.respondWith(caches.match(e.request).then((r) => r || fetch(e.request).then((n) => { const c = n.clone(); caches.open(CACHE).then((k) => k.put(e.request, c)); return n; })));
  }
});
