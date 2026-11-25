import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '..');
const src = path.join(root, 'src');
const dist = path.join(root, 'dist');
const routes = ['', 'simulation', 'bmi', 'criteria', 'grades', 'guide', 'faq', 'about', 'privacy', 'terms'];
const origin = 'https://leejinho970715-star.github.io/milcheck';
const meta = {
  '': ['병역판정검사 모의 시뮬레이터 | MILCHECK 밀체크','병역판정검사 절차와 신장·체중 기준을 공식 자료에 따라 미리 살펴보는 모의 시뮬레이터입니다.','og-default.png'],
  simulation: ['군대 신체검사 모의 테스트 | MILCHECK','병역판정검사의 주요 과목을 단계별로 탐색하고 확인할 준비사항을 정리합니다.','og-simulation.png'],
  bmi: ['군대 BMI 계산기 및 병역판정 신장·체중 기준 | MILCHECK','신장과 체중을 입력해 현행 병역판정 신체검사규칙의 참고 구간을 확인하세요.','og-bmi.png'],
  criteria: ['병역판정검사 질환별 신체등급 기준 검색 | MILCHECK','검사 과목과 질환 키워드로 공식 평가기준 확인 경로를 찾습니다.','og-criteria.png'],
  grades: ['병역판정검사 신체등급 1~7급 안내 | MILCHECK','신체등급과 병역처분의 차이를 공식 자료에 따라 쉽게 설명합니다.','og-grades.png'],
  guide: ['병역판정검사 절차 및 준비물 총정리 | MILCHECK','검사 절차와 준비물을 한눈에 확인하세요.','og-guide.png'],
  faq: ['병역판정검사 자주 묻는 질문 | MILCHECK','병역판정검사와 MILCHECK 이용에 관한 자주 묻는 질문입니다.','og-default.png'],
  about: ['MILCHECK 서비스 소개','MILCHECK의 운영 원칙과 공식 자료 활용 방식을 안내합니다.','og-default.png'],
  privacy: ['MILCHECK 개인정보 처리 안내','건강정보를 서버나 저장소에 남기지 않는 처리 방식을 안내합니다.','og-default.png'],
  terms: ['MILCHECK 이용 안내','MILCHECK 정보와 모의 검사 결과의 이용 범위를 안내합니다.','og-default.png']
};
fs.rmSync(dist, { recursive: true, force: true });
fs.mkdirSync(dist, { recursive: true });

fs.copyFileSync(path.join(src, 'styles.css'), path.join(dist, 'styles.css'));
const appSource = fs.readFileSync(path.join(src, 'app.js'), 'utf8')
  .replaceAll('href="/', 'href="/milcheck/')
  .replaceAll('src="/', 'src="/milcheck/');
fs.writeFileSync(path.join(dist, 'app.js'), appSource);
fs.cpSync(path.join(src, 'assets'), path.join(dist, 'assets'), { recursive: true });
const template = fs.readFileSync(path.join(src, 'index.html'), 'utf8')
  .replaceAll('href="/', 'href="/milcheck/')
  .replaceAll('src="/', 'src="/milcheck/');
for (const route of routes) {
  const dir = route ? path.join(dist, route) : dist;
  fs.mkdirSync(dir, { recursive: true });
  const prefix = route ? '../' : '';
  const [title, desc, og] = meta[route];
  const canonical = `${origin}/${route ? `${route}/` : ''}`;
  fs.writeFileSync(path.join(dir, 'index.html'), template.replaceAll('__PREFIX__', prefix).replaceAll('__ROUTE__', route || 'home').replaceAll('__TITLE__', title).replaceAll('__DESC__', desc).replaceAll('__CANONICAL__', canonical).replaceAll('__OG__', `${origin}/assets/${og}`));
}

const urls = ['', ...routes.filter(Boolean)].map(r => `<url><loc>${origin}/${r}</loc><lastmod>2026-11-26</lastmod></url>`).join('');
fs.writeFileSync(path.join(dist, 'sitemap.xml'), `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urls}</urlset>`);
fs.writeFileSync(path.join(dist, 'robots.txt'), `User-agent: *\nAllow: /\nDisallow: /simulation?*\nSitemap: ${origin}/sitemap.xml\n`);
fs.writeFileSync(path.join(dist, 'site.webmanifest'), JSON.stringify({name:'MILCHECK 병역판정검사 모의 시뮬레이터',short_name:'MILCHECK',start_url:'/milcheck/',display:'standalone',background_color:'#f6faf7',theme_color:'#377a63',icons:[{src:'/milcheck/assets/icon-192.png',sizes:'192x192',type:'image/png'},{src:'/milcheck/assets/icon-512.png',sizes:'512x512',type:'image/png'}]}, null, 2));
fs.writeFileSync(path.join(dist, '404.html'), template.replaceAll('__PREFIX__', '').replaceAll('__ROUTE__', '404').replaceAll('__TITLE__', '페이지를 찾을 수 없습니다 | MILCHECK').replaceAll('__DESC__', '요청한 MILCHECK 페이지를 찾을 수 없습니다.').replaceAll('__CANONICAL__', `${origin}/404.html`).replaceAll('__OG__', `${origin}/assets/og-default.png`));
fs.cpSync(path.join(root, '.openai'), path.join(dist, '.openai'), { recursive: true });
console.log(`Built ${routes.length} pages into ${dist}`);
