import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
const root = path.resolve(import.meta.dirname, '../dist');
const types = {'.html':'text/html; charset=utf-8','.css':'text/css','.js':'text/javascript','.svg':'image/svg+xml','.png':'image/png','.xml':'application/xml','.txt':'text/plain'};
http.createServer((req,res)=>{
  const urlPath = decodeURIComponent(req.url.split('?')[0]);
  let file = path.join(root, urlPath);
  if (urlPath.endsWith('/')) file = path.join(file,'index.html');
  if (!path.extname(file)) file = path.join(file,'index.html');
  if (!fs.existsSync(file)) file = path.join(root,'404.html');
  res.writeHead(file.endsWith('404.html') ? 404 : 200, {'Content-Type':types[path.extname(file)]||'application/octet-stream'});
  fs.createReadStream(file).pipe(res);
}).listen(4173,()=>console.log('MILCHECK preview: http://127.0.0.1:4173'));
