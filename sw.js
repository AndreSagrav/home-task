const CACHE='mh-v6';
const ASSETS=['./'];

self.addEventListener('install',e=>{
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).then(()=>self.skipWaiting()));
});

self.addEventListener('activate',e=>{
  e.waitUntil(
    caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k))))
    .then(()=>self.clients.claim())
  );
});

self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET')return;
  e.respondWith(
    fetch(e.request).then(r=>{
      if(r&&r.status===200){
        const clone=r.clone();
        caches.open(CACHE).then(c=>c.put(e.request,clone));
      }
      return r;
    }).catch(()=>caches.match(e.request).then(r=>r||new Response('Offline',{status:503})))
  );
});

// ══════════ PUSH NOTIFICATIONS ══════════
self.addEventListener('push',e=>{
  if(!e.data)return;
  try{
    const n=e.data.json();
    e.waitUntil(self.registration.showNotification(n.title||'Mi Hogar',{
      body:n.body||'',
      icon:n.icon||'/icon-192.png',
      badge:n.badge||'/icon-192.png',
      tag:n.tag||'mh-'+Date.now(),
      data:n.data||{},
      vibrate:[200,100,200],
      requireInteraction: false
    }));
  }catch(err){
    e.waitUntil(self.registration.showNotification('Mi Hogar',{body:e.data.text()}));
  }
});

self.addEventListener('notificationclick',e=>{
  e.notification.close();
  e.waitUntil(clients.matchAll({type:'window'}).then(cs=>{
    if(cs.length){cs[0].focus();}
    else{clients.openWindow('/');}
  }));
});

// Detectar cambio de conexión
self.addEventListener('message',e=>{
  if(e.data==='CHECK_ONLINE'){
    fetch('/').then(()=>e.source.postMessage({type:'SW_BACK_ONLINE'}))
              .catch(()=>e.source.postMessage({type:'SW_OFFLINE'}));
  }
});
