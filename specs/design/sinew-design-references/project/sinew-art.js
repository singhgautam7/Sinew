/* Sinew signature art: <sinew-mark>, <sinew-barbell>, <sinew-muscles>, <sinew-silhouette>.
   All colours come from the Sinew token set (tokens/sinew_tokens.json). Flat fills, no outlines/gradients. */
(function () {
  if (window.__sinewArt) return; window.__sinewArt = true;
  const RM = () => window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  const SPRING = 'cubic-bezier(.34,1.56,.64,1)'; // Curves.easeOutBack, Kuber/Mull "spring"
  const PL = {
    light: { 25: ['#C2460D', '#991B00'], 20: ['#0070B5', '#004C8F'], 15: ['#DBD856', '#B5B124'], 10: ['#5C913C', '#396D14'], 5: ['#F1F2EF', '#CACBC7'], 2.5: ['#32342E', '#151712'], 1.25: ['#B6B8B1', '#91938C'] },
    dark: { 25: ['#B13D03', '#8C0400'], 20: ['#0064A5', '#004082'], 15: ['#CDCB51', '#A8A405'], 10: ['#528435', '#2E6100'], 5: ['#D0D1CE', '#BDBEBB'], 2.5: ['#282A24', '#0D0E09'], 1.25: ['#AAACA5', '#858781'] }
  };
  const T = {
    light: { p: '#617600', sec: '#C4DE7A', base: '#DDDFD5', ol: '#ACB09F', s: '#F9FBF4', on: '#15180B', onv: '#626556', olv: '#D4D8C7', cont: '#E0EAC9', heat: ['#E1FC97', '#C4DE7A', '#9CB450', '#6C8213', '#495C00'], bar: '#A4A5A2', barD: '#7E807A', then: '#858878', pl: PL.light },
    dark: { p: '#A1B567', sec: '#3B4A00', base: '#32342C', ol: '#54574B', s: '#161811', on: '#F1F2EE', onv: '#A3A69C', olv: '#3C3F33', cont: '#252C0F', heat: ['#222F00', '#3B4A00', '#607223', '#8FA255', '#BACF80'], bar: '#868783', barD: '#62645E', then: '#7F8178', pl: PL.dark },
    'dyn-light': { p: '#4567A8', sec: '#AAD1FF', base: '#DDE2EC', ol: '#A9B0BE', s: '#F7FAFF', on: '#11161F', onv: '#5D646F', olv: '#CFD6E3', cont: '#D6E5FF', heat: ['#C6EFFF', '#AAD1FF', '#82A8ED', '#5376B8', '#2F508F'], bar: '#A4A5A2', barD: '#7E807A', then: '#8A909C', pl: PL.light },
    'dyn-dark': { p: '#DE958E', sec: '#6A2C29', base: '#3A302F', ol: '#5A4D4C', s: '#1C1514', on: '#F5F0F0', onv: '#ACA2A1', olv: '#453A39', cont: '#3B211F', heat: ['#4C1010', '#6A2C29', '#96534F', '#CA827C', '#F9AEA7'], bar: '#868783', barD: '#62645E', then: '#8A7F7E', pl: PL.dark }
  };
  const th = el => T[el.getAttribute('theme')] || T.light;
  const font = "font-family:Inter,system-ui,sans-serif;font-variant-numeric:tabular-nums;";

  class Base extends HTMLElement {
    static get observedAttributes() { return this.attrs || []; }
    connectedCallback() { this.style.display = this.style.display || 'block'; this.render(true); }
    attributeChangedCallback() { if (this.isConnected) this.render(false); }
  }

  /* ---------------- Icon mark ---------------- */
  const GLYPH = {
    plates: { draw: (d, m, t) => plateS(d, m, 'round', t) },
    platesCut: { draw: (d, m, t) => plateS(d, m, 'butt', t) },
    abs: { draw: (d, m, t) => absS(d, m, t, false) },
    absv: { draw: (d, m, t) => absS(d, m, t, true) },
    muscle: { draw: (d, m, t) => muscleS(d, m, t) },
    kettlebell: { draw: (d, m, t) => `<g transform="translate(256 256) scale(.8) translate(-256 -272)"><path d="M190 272 L184 206 Q182 154 234 154 L278 154 Q330 154 328 206 L322 272" fill="none" stroke="${d}" stroke-width="50" stroke-linecap="round" stroke-linejoin="round"/><path d="M200 410 A106 106 0 1 1 312 410 Z" fill="${m}"/><path d="M282 286 L256 286 A27 27 0 0 0 256 340 A27 27 0 0 1 256 394 L228 394" fill="none" stroke="${t}" stroke-width="24" stroke-linecap="round" stroke-linejoin="round"/></g>` },
    arm: { draw: (d, m, t) => `<g transform="translate(256 256) scale(.86) translate(-252 -270)"><path d="M108 300 C148 228 214 206 260 224 C296 238 310 272 308 306 L342 338 C376 358 380 412 330 412 L120 412 C112 412 108 406 108 398 Z" fill="${d}"/><path d="M322 330 L338 212 L388 208 L398 362 C396 396 352 408 332 392 Z" fill="${m}" stroke="${m}" stroke-width="20" stroke-linejoin="round"/><g transform="rotate(-10 362 168)"><rect x="316" y="124" width="96" height="92" rx="32" fill="${m}"/><path d="M330 176 H372" stroke="${t}" stroke-width="9" stroke-linecap="round"/></g></g>` },
    strong: { s: 0.76, cy: 222, cx: 290, dark: ['M270 152 L352 152 A28 28 0 0 0 380 124 L380 80'], blobs: [['ellipse', 330, 140, 28, 22]], head: [290, 82, 30], mid: ['M300 152 L256 152 A52 52 0 0 0 204 204 A52 52 0 0 0 256 256 A52 52 0 0 1 308 308 A52 52 0 0 1 256 360 L212 360'] },
    pose: { s: 0.82, cy: 258, dark: ['M300 138 L256 138 A60 60 0 0 0 196 198 A60 60 0 0 0 256 258'], head: [298, 208, 22], mid: ['M230.6 252.4 A60 60 0 0 0 256 258 A60 60 0 0 1 316 318 A60 60 0 0 1 256 378 L212 378'] },
    bicep: { s: 0.82, cy: 258, dark: ['M300 138 L256 138 A60 60 0 0 0 196 198 A60 60 0 0 0 256 258'], blobs: [['ellipse', 226, 194, 34, 42], ['circle', 304, 140, 34]], mid: ['M230.6 252.4 A60 60 0 0 0 256 258 A60 60 0 0 1 316 318 A60 60 0 0 1 256 378 L212 378'] },
    dumbbell: { s: 0.82, cy: 258, dark: ['M300 162 L256 162 A48 48 0 0 0 208 210 A48 48 0 0 0 256 258', 'M326 124 L326 200'], mid: ['M232 251.6 A48 48 0 0 0 256 258 A48 48 0 0 1 304 306 A48 48 0 0 1 256 354 L212 354', 'M186 316 L186 392'] },
    flex: { s: 0.80, cy: 240, cx: 262, dark: ['M256 258 A48 48 0 0 1 208 210 A48 48 0 0 1 256 162 L280 162 A26 26 0 0 0 306 136 L306 122'], fist: [306, 106, 30], mid: ['M232 251.6 A48 48 0 0 0 256 258 A58 58 0 0 1 314 316 A58 58 0 0 1 256 374 L218 374'] }
  };
  /* Six-pack: six equal blocks in one tone with even crevices. The S is drawn in the dark tone along the crevices:
     right half of the upper intersection, the linea alba, left half of the lower one. */
  function absS(dark, mid, tint, vee) {
    if (dark === mid) mid = `color-mix(in oklch, ${dark} 45%, ${tint})`;
    const T = 112, B = 392, I = [T, 206, 300, B], h = 9, r = 20, lift = -10;
    const W = y => 124 - (y - T) * 0.07;
    const cy = (Ic, x) => Ic + lift * Math.pow(Math.min(1, Math.abs(x - 256) / 124), 2);
    let blocks = '';
    for (let i = 0; i < 3; i++) {
      const ya = I[i], yb = I[i + 1], et = i === 0 ? r : h + r, eb = i === 2 ? r : h + r, xi = 256 + h + r;
      const pts = [];
      const outX = y => 256 + W(y) - r;
      const xTopO = outX(ya + et), xBotO = outX(yb - eb);
      for (let k = 0; k <= 4; k++) { const x = xi + (xTopO - xi) * k / 4; pts.push([x, cy(ya, x) + et]); }
      const yT = cy(ya, xTopO) + et, yB = cy(yb, xBotO) - eb;
      for (let k = 1; k < 4; k++) { const y = yT + (yB - yT) * k / 4; pts.push([outX(y) + 7 * Math.sin(Math.PI * k / 4), y]); }
      for (let k = 4; k >= 0; k--) { const x = xi + (xBotO - xi) * k / 4; pts.push([x, cy(yb, x) - eb]); }
      const d = 'M' + pts.map(p => p[0].toFixed(1) + ' ' + p[1].toFixed(1)).join(' L') + 'Z';
      blocks += `<path d="${d}" fill="${mid}" stroke="${mid}" stroke-width="${2 * r}" stroke-linejoin="round"/><path d="${d}" transform="translate(512 0) scale(-1 1)" fill="${mid}" stroke="${mid}" stroke-width="${2 * r}" stroke-linejoin="round"/>`;
    }
    const rc = 40, line = (Ic, x0, x1) => { const p = []; for (let k = 0; k <= 8; k++) { const x = x0 + (x1 - x0) * k / 8; p.push(x.toFixed(1) + ' ' + cy(Ic, x).toFixed(1)); } return p; };
    const xr = 256 + W(I[1]) - 2, xl = 256 - W(I[2]) + 2;
    const up = line(I[1], xr, 256 + rc), lo = line(I[2], 256 - rc, xl);
    const sd = `M${up.join(' L')} Q256 ${I[1]} 256 ${I[1] + rc} L256 ${I[2] - rc} Q256 ${I[2]} ${lo.join(' L')}`;
    const S = `<path d="${sd}" fill="none" stroke="${dark}" stroke-width="26" stroke-linecap="round" stroke-linejoin="round"/>`;
    const v = vee ? `<path d="M150 360 Q172 414 232 436 M362 360 Q340 414 280 436" fill="none" stroke="${dark}" stroke-width="20" stroke-linecap="round"/>` : '';
    const c = vee ? 272 : 252, sc = vee ? .74 : .8;
    return `<g transform="translate(256 256) scale(${sc}) translate(-256 -${c})">${blocks}${v}${S}</g>`;
  }
  /* Plate S: two weight plates seen face-on. Each is a thick ring with a hub; the top one is open at the lower right,
     the bottom one (its 180° turn) at the upper left, and they meet at the spine, so the pair is the S. */
  function plateS(dark, mid, cap, tint) {
    const R = 62, w = 34, hub = 31, P = (cx, cy, a) => [cx + R * Math.cos(a * Math.PI / 180), cy + R * Math.sin(a * Math.PI / 180)];
    const arc = (cx, cy, a0, a1) => { const p0 = P(cx, cy, a0), p1 = P(cx, cy, a1); return `M${p0[0].toFixed(2)} ${p0[1].toFixed(2)} A${R} ${R} 0 1 1 ${p1[0].toFixed(2)} ${p1[1].toFixed(2)}`; };
    const end = cap === 'butt' ? 0 : 334, endB = cap === 'butt' ? 180 : 154;
    const top = arc(256, 194, 90, cap === 'butt' ? 360 : end), bot = arc(256, 318, 270, cap === 'butt' ? 540 - 360 + 0 : endB);
    const st = c => `fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="${cap}"`;
    const join = `<path d="M${P(256, 194, 70)[0].toFixed(2)} ${P(256, 194, 70)[1].toFixed(2)} A${R} ${R} 0 0 1 256 256" ${st(mid)} stroke-linecap="butt"/>`;
    return `<g transform="translate(256 256) scale(.92) translate(-256 -256)"><path d="${top}" ${st(dark)}/><circle cx="256" cy="194" r="${hub}" fill="${dark}"/><circle cx="256" cy="194" r="11" fill="${tint}"/><path d="${bot}" ${st(mid)}/>${join}<circle cx="256" cy="318" r="${hub}" fill="${mid}"/><circle cx="256" cy="318" r="11" fill="${tint}"/></g>`;
  }
  function taper(pts, wf) {
    const n = pts.length, L = [0]; for (let i = 1; i < n; i++) L.push(L[i - 1] + Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]));
    const left = [], right = [];
    pts.forEach((p, i) => { const a = pts[Math.max(0, i - 1)], b = pts[Math.min(n - 1, i + 1)], dx = b[0] - a[0], dy = b[1] - a[1], k = Math.hypot(dx, dy) || 1, w = wf(L[i] / L[n - 1]) / 2; left.push([p[0] - dy / k * w, p[1] + dx / k * w]); right.push([p[0] + dy / k * w, p[1] - dx / k * w]); });
    const f = q => q[0].toFixed(1) + ' ' + q[1].toFixed(1);
    return { d: 'M' + left.map(f).join(' L') + ' L' + right.reverse().map(f).join(' L') + 'Z', ends: [[pts[0], wf(0) / 2], [pts[n - 1], wf(1) / 2]] };
  }
  function muscleS(dark, mid, tint) {
    const arc = (cx, cy, r, a0, a1, N) => Array.from({ length: N + 1 }, (_, i) => { const a = (a0 + (a1 - a0) * i / N) * Math.PI / 180; return [cx + r * Math.cos(a), cy + r * Math.sin(a)]; });
    const line = (x0, y0, x1, y1, N) => Array.from({ length: N + 1 }, (_, i) => [x0 + (x1 - x0) * i / N, y0 + (y1 - y0) * i / N]);
    const up = line(304, 136, 256, 136, 8).concat(arc(256, 197, 61, -90, -270, 40).slice(1));
    const lo = arc(256, 319, 61, -90, 90, 40).concat(line(256, 380, 208, 380, 8).slice(1));
    const wU = u => 26 + 58 * Math.pow(Math.sin(Math.PI * Math.pow(u, 1.36)), 1.6), wL = u => wU(1 - u);
    const piece = (pts, c, wf) => { const t = taper(pts, wf); return `<path d="${t.d}" fill="${c}"/>` + t.ends.map(([p, r]) => `<circle cx="${p[0]}" cy="${p[1]}" r="${r}" fill="${c}"/>`).join(''); };
    const fibre = (pts) => { const s = Math.round(pts.length * .3), e = Math.round(pts.length * .7); return `<polyline points="${pts.slice(s, e).map(p => p.join(',')).join(' ')}" fill="none" stroke="${tint}" stroke-width="7" stroke-linecap="round"/>`; };
    return `<g transform="translate(256 256) scale(.86) translate(-256 -258)">${piece(up, dark, wU)}${fibre(up)}${piece(lo, mid, wL)}${fibre(lo)}</g>`;
  }
  function glyphSVG(concept, dark, mid, tint) {
    const G = GLYPH[concept] || GLYPH.muscle; if (G.draw) return G.draw(dark, mid, tint);
    const g = G, sw = 44 / g.s;
    const p = (d, c) => `<path d="${d}" fill="none" stroke="${c}" stroke-width="${sw}" stroke-linecap="round" stroke-linejoin="round"/>`;
    let s = g.dark.map(d => p(d, dark)).join('');
    if (g.blobs) g.blobs.forEach(b => { s += b[0] === 'circle' ? `<circle cx="${b[1]}" cy="${b[2]}" r="${b[3]}" fill="${dark}"/>` : `<ellipse cx="${b[1]}" cy="${b[2]}" rx="${b[3]}" ry="${b[4]}" fill="${dark}"/>`; });
    if (g.head) s += `<circle cx="${g.head[0]}" cy="${g.head[1]}" r="${g.head[2]}" fill="${dark}"/>`;
    if (g.fist) s += `<circle cx="${g.fist[0]}" cy="${g.fist[1]}" r="${g.fist[2] / g.s * 0.86}" fill="${dark}"/>`;
    s += g.mid.map(d => p(d, mid)).join('');
    return `<g transform="translate(256 256) scale(${g.s}) translate(${-(g.cx || 256)} ${-g.cy})">${s}</g>`;
  }
  class Mark extends Base {
    static attrs = ['concept', 'bg', 'size', 'mode', 'dark', 'mid', 'tint', 'guides'];
    render() {
      const a = n => this.getAttribute(n);
      const size = +(a('size') || 96), bg = a('bg') || 'square', mode = a('mode') || 'color';
      let dark = a('dark') || '#3B4707', mid = a('mid') || '#6D8817', tint = a('tint') || '#E4ECC7';
      if (mode === 'mono') { mid = dark = a('dark') || '#394B00'; tint = a('tint') || '#E0EAC9'; }
      if (mode === 'mono-dark') { mid = dark = '#D9E3C0'; tint = '#252C0F'; }
      let body = glyphSVG(a('concept') || 'plates', dark, mid, tint), back = '';
      if (bg === 'square') back = `<rect width="512" height="512" fill="${tint}"/>`;
      if (bg === 'tile') back = `<rect width="512" height="512" rx="115" fill="${tint}"/>`;
      if (bg === 'circle') back = `<circle cx="256" cy="256" r="256" fill="${tint}"/>`;
      if (bg === 'adaptive' || bg === 'adaptive-fg') {
        // 108dp canvas; glyph sits as it does in the 72dp visible mask, well inside the 66dp safe zone
        const k = 512 / 108;
        back = bg === 'adaptive' ? `<rect width="512" height="512" fill="${tint}"/>` : `<rect width="512" height="512" fill="url(#chk)"/>`;
        body = `<g transform="translate(256 256) scale(${72 / 108}) translate(-256 -256)">${body}</g>`;
        if (a('guides') !== 'false') body += `<circle cx="256" cy="256" r="${36 * k}" fill="none" stroke="#B5B124" stroke-width="3" stroke-dasharray="10 8"/><circle cx="256" cy="256" r="${33 * k}" fill="none" stroke="#C2460D" stroke-width="3" stroke-dasharray="4 6"/><rect x="1.5" y="1.5" width="509" height="509" fill="none" stroke="#858878" stroke-width="3" stroke-dasharray="10 8"/>`;
      }
      const defs = `<defs><pattern id="chk" width="32" height="32" patternUnits="userSpaceOnUse"><rect width="32" height="32" fill="#F4F5F1"/><rect width="16" height="16" fill="#E6E8E1"/><rect x="16" y="16" width="16" height="16" fill="#E6E8E1"/></pattern></defs>`;
      this.style.width = size + 'px'; this.style.height = size + 'px'; this.style.lineHeight = '0';
      this.innerHTML = `<svg viewBox="0 0 512 512" width="${size}" height="${size}" style="display:block">${defs}${back}${body}</svg>`;
    }
  }

  /* ---------------- Barbell / dumbbell / stack ---------------- */
  const KG = { plates: [25, 20, 15, 10, 5, 2.5, 1.25], perSide: { 25: 2, 20: 1, 15: 1, 10: 1, 5: 1, 2.5: 1, 1.25: 1 }, bar: 20 };
  const LB = { plates: [55, 45, 35, 25, 10, 5, 2.5], perSide: { 55: 0, 45: 4, 35: 1, 25: 1, 10: 2, 5: 1, 2.5: 1 }, bar: 45 };
  const LBC = { 55: 25, 45: 20, 35: 15, 25: 10, 10: 5, 5: 2.5, 2.5: 1.25 };
  const DIMD = { 5: [78, 12], 2.5: [62, 9], 1.25: [52, 7] };
  const DIM = { 25: [96, 15], 20: [96, 13], 15: [96, 11], 10: [96, 9], 5: [62, 8], 2.5: [48, 7], 1.25: [40, 6] };
  function load(side, inv) {
    const out = []; let r = side;
    for (const p of inv.plates) { let n = inv.perSide[p] || 0; while (n > 0 && r >= p - 1e-9) { out.push(p); r = +(r - p).toFixed(3); n--; } }
    return { plates: out, rest: r };
  }
  const fmt = n => (Math.round(n * 100) / 100).toString();
  class Barbell extends Base {
    static attrs = ['weight', 'unit', 'kind', 'theme', 'caption', 'bar', 'width', 'stack-step', 'stack-count', 'inventory'];
    plan() {
      const a = n => this.getAttribute(n);
      const unit = a('unit') || 'kg', kind = a('kind') || 'barbell';
      const inv = JSON.parse(JSON.stringify(unit === 'lb' ? LB : KG));
      if (a('inventory')) Object.assign(inv.perSide, JSON.parse(a('inventory')));
      const w = +(a('weight') || 0);
      if (kind === 'dumbbell') { inv.bar = +(a('bar') || (unit === 'lb' ? 5 : 2)); inv.plates = unit === 'lb' ? [10, 5, 2.5] : [5, 2.5, 1.25]; inv.perSide = unit === 'lb' ? { 10: 3, 5: 1, 2.5: 1 } : { 5: 3, 2.5: 1, 1.25: 1 }; }
      else if (a('bar')) inv.bar = +a('bar');
      const side = Math.max(0, (w - inv.bar) / 2);
      let { plates, rest } = load(side, inv), note = '', shown = w;
      if (w < inv.bar) { note = `Lighter than the ${fmt(inv.bar)} ${unit} ${kind === 'dumbbell' ? 'handle' : 'bar'}`; shown = inv.bar; plates = []; }
      else if (rest > 1e-6) {
        const lo = inv.bar + 2 * plates.reduce((s, p) => s + p, 0);
        const smallest = inv.plates.filter(p => inv.perSide[p] > 0).slice(-1)[0];
        const hiL = load(side + smallest - rest, inv), hi = hiL.rest < 1e-6 ? inv.bar + 2 * hiL.plates.reduce((s, p) => s + p, 0) : null;
        const pickHi = hi !== null && hi - w < w - lo;
        shown = pickHi ? hi : lo; plates = pickHi ? hiL.plates : plates;
        note = `${fmt(w)} ${unit} isn't possible with your plates. Nearest: ${fmt(shown)} ${unit}`;
      }
      return { unit, kind, inv, plates, note, shown, w };
    }
    render(first) {
      const t = th(this), a = n => this.getAttribute(n), P = this.plan();
      if (P.kind === 'stack') return this.renderStack(t, first);
      const W = +(a('width') || 340), H = P.kind === 'dumbbell' ? 96 : 120, cx = W / 2, cy = H / 2;
      const col = p => t.pl[P.unit === 'lb' ? LBC[p] : p], dim = p => (P.kind === 'dumbbell' ? DIMD : DIM)[P.unit === 'lb' ? LBC[p] : p];
      const sc = 1;
      const collar = P.kind === 'dumbbell' ? 30 : 64;
      let total = P.plates.reduce((s, p) => s + dim(p)[1] + 2, 0) * sc, room = cx - collar - 14;
      const k = total > room ? room / total : 1;
      const parts = [];
      // bar
      if (P.kind === 'dumbbell') {
        parts.push(`<rect x="${cx - collar}" y="${cy - 5}" width="${collar * 2}" height="10" rx="5" fill="${t.barD}"/>`);
        parts.push(`<rect x="${cx - collar - 34}" y="${cy - 4}" width="34" height="8" rx="4" fill="${t.bar}"/><rect x="${cx + collar}" y="${cy - 4}" width="34" height="8" rx="4" fill="${t.bar}"/>`);
      } else {
        parts.push(`<rect x="${cx - collar}" y="${cy - 3.5}" width="${collar * 2}" height="7" rx="3.5" fill="${t.barD}"/>`);
        parts.push(`<rect x="8" y="${cy - 6}" width="${cx - collar - 8}" height="12" rx="6" fill="${t.bar}"/><rect x="${cx + collar}" y="${cy - 6}" width="${cx - collar - 8}" height="12" rx="6" fill="${t.bar}"/>`);
        parts.push(`<rect x="${cx - collar - 6}" y="${cy - 13}" width="8" height="26" rx="3" fill="${t.barD}"/><rect x="${cx + collar - 2}" y="${cy - 13}" width="8" height="26" rx="3" fill="${t.barD}"/>`);
      }
      const plateG = [];
      for (const dir of [-1, 1]) {
        let x = cx + dir * (collar + (P.kind === 'dumbbell' ? 1 : 3));
        P.plates.forEach((p, i) => {
          const [h0, w0] = dim(p), h = h0 * sc, w = w0 * sc * k, [f, e] = col(p);
          const xx = dir > 0 ? x : x - w;
          plateG.push({ key: dir + ':' + i + ':' + p, dir, i, svg: `<g data-k="${dir}:${i}:${p}"><rect x="${xx}" y="${cy - h / 2}" width="${w}" height="${h}" rx="${Math.min(3, w / 2)}" fill="${f}"/><rect x="${xx}" y="${cy - h / 2}" width="${w}" height="${h}" rx="${Math.min(3, w / 2)}" fill="none" stroke="${e}" stroke-width="1.5"/></g>` });
          x += dir * (w + 2 * k);
        });
      }
      const prev = this._prev || [];
      const html = `<svg viewBox="0 0 ${W} ${H}" width="100%" style="display:block;max-width:${W}px;margin:0 auto;overflow:visible">${parts.join('')}${plateG.map(g => g.svg).join('')}</svg>`;
      let cap = '';
      if (a('caption') !== 'none') {
        const sideSum = P.plates.reduce((s, p) => s + p, 0);
        const what = P.kind === 'dumbbell' ? 'Handle' : 'Bar';
        const line = P.plates.length ? `${what} ${fmt(P.inv.bar)} ${P.unit} · ${fmt(sideSum)} ${P.unit} per side: ${P.plates.map(fmt).join(' + ')}` : (P.kind === 'dumbbell' ? `Handle only · ${fmt(P.inv.bar)} ${P.unit}` : `Empty bar · ${fmt(P.inv.bar)} ${P.unit}`);
        cap = `<div style="${font}font-size:13px;line-height:18px;color:${t.onv};text-align:center;margin-top:6px">${line}</div>`;
        if (P.note) cap += `<div style="${font}font-size:13px;line-height:18px;font-weight:600;color:${t.on};text-align:center;margin-top:2px">${P.note}</div>`;
      }
      this.innerHTML = html + cap;
      if (!first && !RM()) {
        const prevKeys = new Set(prev);
        this.querySelectorAll('g[data-k]').forEach(g => {
          const key = g.getAttribute('data-k'); if (prevKeys.has(key)) return;
          const dir = +key.split(':')[0], i = +key.split(':')[1];
          g.animate([{ transform: `translateX(${dir * 46}px)`, opacity: 0 }, { transform: 'translateX(0)', opacity: 1 }], { duration: 420, easing: SPRING, delay: i * 45, fill: 'backwards' });
        });
      }
      this._prev = plateG.map(g => g.key);
    }
    renderStack(t, first) {
      const a = n => this.getAttribute(n), step = +(a('stack-step') || 5), n = +(a('stack-count') || 16), w = +(a('weight') || 0);
      const sel = Math.max(1, Math.min(n, Math.round(w / step))), ph = 9, W = 200, H = n * (ph + 2) + 20;
      let s = `<rect x="${W / 2 - 3}" y="0" width="6" height="${H}" rx="3" fill="${t.barD}"/>`;
      for (let i = 0; i < n; i++) {
        const y = 10 + i * (ph + 2), on = i < sel;
        s += `<rect x="${W / 2 - 46}" y="${y}" width="92" height="${ph}" rx="2.5" fill="${on ? t.p : t.base}"/>`;
        if ((i + 1) % 4 === 0) s += `<text x="${W / 2 + 56}" y="${y + 8}" style="${font}font-size:10px;fill:${t.onv}">${(i + 1) * step}</text>`;
      }
      const py = 10 + (sel - 1) * (ph + 2) + ph / 2;
      s += `<g class="pin" style="transition:transform ${RM() ? 0 : 420}ms ${SPRING};transform:translateY(${py}px)"><rect x="${W / 2 - 64}" y="-2" width="30" height="4" rx="2" fill="${t.on}"/><circle cx="${W / 2 - 66}" cy="0" r="6" fill="${t.on}"/></g>`;
      const old = this.querySelector('.pin');
      this.innerHTML = `<svg viewBox="0 0 ${W} ${H}" width="100%" style="display:block;max-width:${W}px;margin:0 auto">${s}</svg>` + (a('caption') !== 'none' ? `<div style="${font}font-size:13px;line-height:18px;color:${t.onv};text-align:center;margin-top:6px">Pin at ${sel * step} ${a('unit') || 'kg'} · plate ${sel} of ${n}</div>` : '');
    }
  }

  /* ---------------- Muscle map ---------------- */
  const M_FRONT = {
    shoulders: '<ellipse cx="34" cy="52" rx="9" ry="10"/>',
    chest: '<path d="M44 45 Q52 42 58.5 45 L58.5 64 Q51 68 44 63 Q41 54 44 45Z"/>',
    biceps: '<ellipse cx="29" cy="76" rx="6" ry="13"/>',
    forearms: '<ellipse cx="25" cy="103" rx="5.5" ry="14"/>',
    abs: '<rect x="52" y="70" width="7" height="11" rx="3"/><rect x="52" y="83" width="7" height="11" rx="3"/><rect x="52" y="96" width="7" height="11" rx="3"/>',
    obliques: '<ellipse cx="45.5" cy="88" rx="4.5" ry="15"/>',
    quads: '<ellipse cx="47.5" cy="150" rx="9.5" ry="26"/>',
    adductors: '<ellipse cx="56.5" cy="141" rx="3.2" ry="15"/>',
    calves: '<ellipse cx="47" cy="205" rx="6.5" ry="19"/>',
    traps: '<path d="M53 35 L41 43 L53 43Z"/>'
  };
  const M_BACK = {
    traps: '<path d="M60 32 L45 45 L60 76Z"/>',
    shoulders: '<ellipse cx="34" cy="52" rx="9" ry="10"/>',
    triceps: '<ellipse cx="29" cy="76" rx="6" ry="13"/>',
    forearms: '<ellipse cx="25" cy="103" rx="5.5" ry="14"/>',
    lats: '<path d="M46 58 L58 66 L58.5 96 L49 92 L42 70Z"/>',
    'lower-back': '<rect x="53.5" y="94" width="6" height="16" rx="3"/>',
    glutes: '<ellipse cx="51" cy="121" rx="9.5" ry="11"/>',
    hamstrings: '<ellipse cx="48" cy="155" rx="8.5" ry="23"/>',
    calves: '<ellipse cx="47" cy="203" rx="7.5" ry="18"/>'
  };
  const F_FRONT = Object.assign({}, M_FRONT, {
    shoulders: '<ellipse cx="36.5" cy="52" rx="8" ry="9"/>',
    chest: '<path d="M45.5 47 Q52 45 58.5 47 L58.5 61 Q51 67 45.5 62 Q43.5 54 45.5 47Z"/>',
    biceps: '<ellipse cx="31.5" cy="76" rx="5" ry="12.5"/>',
    forearms: '<ellipse cx="28" cy="103" rx="4.5" ry="13.5"/>',
    obliques: '<ellipse cx="48" cy="88" rx="3.8" ry="13"/>',
    quads: '<ellipse cx="46.5" cy="150" rx="10.5" ry="26"/>',
    calves: '<ellipse cx="46.5" cy="205" rx="6" ry="19"/>'
  });
  const F_BACK = Object.assign({}, M_BACK, {
    traps: '<path d="M60 33 L47 45 L60 72Z"/>',
    shoulders: '<ellipse cx="36.5" cy="52" rx="8" ry="9"/>',
    triceps: '<ellipse cx="31.5" cy="76" rx="5" ry="12.5"/>',
    forearms: '<ellipse cx="28" cy="103" rx="4.5" ry="13.5"/>',
    lats: '<path d="M47 59 L58 66 L58.5 92 L50.5 90 L44.5 70Z"/>',
    glutes: '<ellipse cx="50" cy="121" rx="10.5" ry="12"/>',
    hamstrings: '<ellipse cx="47.5" cy="155" rx="9" ry="23"/>',
    calves: '<ellipse cx="46.5" cy="203" rx="7" ry="18"/>'
  });
  const BASE_FEM = (c) => `<g fill="${c}"><circle cx="60" cy="17" r="11.5"/><circle cx="60" cy="5" r="5.5"/><rect x="55.5" y="27" width="9" height="10" rx="4"/><path d="M44 43 Q60 38 76 43 L77 62 Q75 82 72.5 92 Q78 102 80 110 L40 110 Q42 102 47.5 92 Q45 82 43 62Z"/><path d="M40 108 L80 108 L74 128 L46 128Z"/><circle cx="26" cy="121" r="4.5"/><circle cx="94" cy="121" r="4.5"/><circle cx="47" cy="180" r="6"/><circle cx="73" cy="180" r="6"/><ellipse cx="46" cy="232" rx="6.5" ry="4"/><ellipse cx="74" cy="232" rx="6.5" ry="4"/></g>`;
  const FRONT_ONLY = ['chest', 'biceps', 'abs', 'obliques', 'quads', 'adductors'], BACK_ONLY = ['triceps', 'lats', 'lower-back', 'glutes', 'hamstrings'];
  const BASE_FIG = (c) => `<g fill="${c}"><circle cx="60" cy="17" r="12"/><rect x="54.5" y="27" width="11" height="10" rx="4"/><path d="M42 42 Q60 36 78 42 L80 66 Q78 108 76 110 L44 110 Q42 108 40 66Z"/><path d="M44 108 L76 108 L71 126 L49 126Z"/><circle cx="23" cy="122" r="5"/><circle cx="97" cy="122" r="5"/><circle cx="48" cy="180" r="6"/><circle cx="72" cy="180" r="6"/><ellipse cx="46" cy="232" rx="7" ry="4"/><ellipse cx="74" cy="232" rx="7" ry="4"/></g>`;
  class Muscles extends Base {
    static attrs = ['primary', 'secondary', 'heat', 'view', 'theme', 'labels', 'sex', 'fit', 'color'];
    render() {
      if (this.getAttribute('fit') === 'crop') return this.renderCrop();
      const t0 = th(this), cc = this.getAttribute('color'), t = cc ? Object.assign({}, t0, { p: cc, sec: `color-mix(in oklch, ${cc} 40%, ${t0.s})` }) : t0;
      const a = n => this.getAttribute(n);
      const prim = (a('primary') || '').split(',').map(s => s.trim()).filter(Boolean), sec = (a('secondary') || '').split(',').map(s => s.trim()).filter(Boolean);
      const heat = {}; (a('heat') || '').split(',').filter(Boolean).forEach(x => { const [k, v] = x.split(':'); heat[k.trim()] = +v; });
      const view = a('view') || 'both';
      const fill = m => heat[m] ? t.heat[Math.min(4, heat[m] - 1 + (heat[m] > 0 ? 0 : 0))] : prim.includes(m) ? t.p : sec.includes(m) ? t.sec : t.ol;
      const fem = a('sex') === 'female', FR = fem ? F_FRONT : M_FRONT, BK = fem ? F_BACK : M_BACK, BF = fem ? BASE_FEM : BASE_FIG;
      const fig = (map, label) => {
        let s = BF(t.base);
        for (const m in map) { const c = fill(m); s += `<g fill="${c}">${map[m]}</g><g fill="${c}" transform="translate(120 0) scale(-1 1)">${map[m]}</g>`; }
        return `<div style="display:flex;flex-direction:column;align-items:center;gap:4px;flex:1;min-width:0;height:100%;min-height:0"><svg viewBox="8 0 104 242" style="display:block;width:100%;flex:1;min-height:0">${s}</svg>${a('labels') === 'false' ? '' : `<div style="${font}font-size:11px;line-height:16px;font-weight:500;letter-spacing:.5px;color:${t.onv};flex:none">${label}</div>`}</div>`;
      };
      this.style.height = this.style.height || '100%';
      this.innerHTML = `<div style="display:flex;gap:6px;width:100%;height:100%">${view !== 'back' ? fig(FR, 'Front') : ''}${view !== 'front' ? fig(BK, 'Back') : ''}</div>`;
    }
    /* Single view, zoomed to the worked muscles so it fills a small square tile. */
    renderCrop() {
      const t0 = th(this), a = n => this.getAttribute(n), cc = a('color'), t = cc ? Object.assign({}, t0, { p: cc, sec: `color-mix(in oklch, ${cc} 40%, ${t0.s})` }) : t0;
      const list = n => (a(n) || '').split(',').map(s => s.trim()).filter(Boolean), prim = list('primary'), sec = list('secondary');
      let view = a('view');
      if (view !== 'front' && view !== 'back') {
        const sc = arr => prim.filter(m => arr.includes(m)).length * 2 + sec.filter(m => arr.includes(m)).length;
        view = sc(BACK_ONLY) > sc(FRONT_ONLY) ? 'back' : 'front';
      }
      const fem = a('sex') === 'female', map = view === 'back' ? (fem ? F_BACK : M_BACK) : (fem ? F_FRONT : M_FRONT);
      let s = (fem ? BASE_FEM : BASE_FIG)(t.base);
      for (const m in map) {
        const c = prim.includes(m) ? t.p : sec.includes(m) ? t.sec : t.ol, hl = prim.includes(m) || sec.includes(m) ? ' data-hl="1"' : '';
        s += `<g fill="${c}"${hl}>${map[m]}</g><g fill="${c}" transform="translate(120 0) scale(-1 1)">${map[m]}</g>`;
      }
      this.style.width = '100%'; this.style.height = '100%';
      this.innerHTML = `<svg viewBox="8 0 104 242" preserveAspectRatio="xMidYMid slice" style="display:block;width:100%;height:100%">${s}</svg>`;
      const svg = this.firstChild, gs = svg.querySelectorAll('g[data-hl]');
      let x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9;
      try { gs.forEach(g => { const b = g.getBBox(); x0 = Math.min(x0, b.x, 120 - b.x - b.width); x1 = Math.max(x1, b.x + b.width, 120 - b.x); y0 = Math.min(y0, b.y); y1 = Math.max(y1, b.y + b.height); }); } catch (e) {}
      if (!(x1 > x0)) { x0 = 20; x1 = 100; y0 = 30; y1 = 130; }
      const size = Math.max(64, x1 - x0, y1 - y0) + 14, cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
      svg.setAttribute('viewBox', `${cx - size / 2} ${cy - size / 2} ${size} ${size}`);
    }
  }

  /* ---------------- Silhouette ---------------- */
  const BASES = {
    male: { height: 178, neck: 39, shoulders: 118, chest: 100, waist: 84, hips: 98, bicep: 33, forearm: 28, thigh: 56, calf: 37 },
    female: { height: 165, neck: 32, shoulders: 102, chest: 90, waist: 71, hips: 100, bicep: 28, forearm: 24, thigh: 58, calf: 36 },
    neutral: { height: 172, neck: 36, shoulders: 110, chest: 95, waist: 78, hips: 99, bicep: 30, forearm: 26, thigh: 57, calf: 36.5 }
  };
  const KEYS = ['height', 'neck', 'shoulders', 'chest', 'waist', 'hips', 'bicep', 'forearm', 'thigh', 'calf'];
  function figure(m, has) {
    const H = 400, k = H / m.height, X = c => c * k; // px per cm
    const Y = f => 12 + f * H;
    const tw = c => X(c * 0.36) / 2, lw = c => X(c / Math.PI) / 2; // half widths
    const legC = tw(m.hips) * .56, thH = lw(m.thigh), cfH = lw(m.calf);
    const R = [
      [Y(.112), lw(m.neck) * .92, 'neck'], [Y(.145), lw(m.neck), 'neck'], [Y(.162), lw(m.neck) + X(5), 'shoulders'], [Y(.178), tw(m.shoulders) - X(2.2), 'shoulders'], [Y(.205), tw(m.shoulders), 'shoulders'],
      [Y(.25), tw(m.chest), 'chest'], [Y(.30), tw(m.chest) * .97, 'chest'], [Y(.40), tw(m.waist), 'waist'], [Y(.50), tw(m.hips), 'hips'],
      [Y(.58), legC + thH, 'thigh'], [Y(.72), legC + thH * .62, 'thigh'], [Y(.80), legC + cfH, 'calf'], [Y(.95), legC + X(3.2), 'calf'], [Y(.985), legC + X(5), null],
      [Y(.995), legC - X(3), null], [Y(.95), legC - X(3.4), 'calf'], [Y(.80), Math.max(X(1.5), legC - cfH * .9), 'calf'], [Y(.72), Math.max(X(1.4), legC - thH * .55), 'thigh'],
      [Y(.58), Math.max(X(0.8), legC - thH), 'thigh'], [Y(.528), 0.01, null]
    ];
    const L = R.slice().reverse().map(([y, x, key]) => [y, -x, key]);
    const torso = R.concat(L.slice(1));
    const ax = Math.max(tw(m.shoulders) - lw(m.bicep) * .55, tw(m.chest) + lw(m.bicep) + X(1.8)), bw = lw(m.bicep), fw = lw(m.forearm);
    const arm = [[Y(.19), ax + bw * .35, 'shoulders'], [Y(.215), ax + bw * 1.05, 'bicep'], [Y(.29), ax + bw, 'bicep'], [Y(.355), ax + X(1.2) + fw * .85, 'forearm'], [Y(.40), ax + X(1.8) + fw, 'forearm'], [Y(.47), ax + X(2.6) + fw * .55, 'forearm'], [Y(.53), ax + X(2.8) + X(2.2), null], [Y(.545), ax + X(2.8), null], [Y(.53), ax + X(2.8) - X(2.3), null], [Y(.47), ax + X(2.4) - fw * .55, 'forearm'], [Y(.40), ax + X(1.6) - fw * .9, 'forearm'], [Y(.355), ax + X(1) - fw * .8, 'forearm'], [Y(.29), ax - bw * .85, 'bicep'], [Y(.24), ax - bw * .7, 'bicep']];
    return { torso, armR: arm, armL: arm.map(([y, x, key]) => [y, -x, key]), head: { cy: Y(.064), rx: X(8), ry: X(11.6) }, Y, has };
  }
  function crPaths(pts, closed, cx, has, style) {
    const n = pts.length, P = i => pts[(i + n) % n], out = [];
    for (let i = 0; i < (closed ? n : n - 1); i++) {
      const p0 = P(i - 1), p1 = P(i), p2 = P(i + 1), p3 = P(i + 2);
      const c1 = [p1[1] + (p2[1] - p0[1]) / 6, p1[0] + (p2[0] - p0[0]) / 6], c2 = [p2[1] - (p3[1] - p1[1]) / 6, p2[0] - (p3[0] - p1[0]) / 6];
      const est = [p1[2], p2[2]].some(k => k && !has[k]);
      out.push(`<path d="M${cx + p1[1]} ${p1[0]} C${cx + c1[0]} ${c1[1]} ${cx + c2[0]} ${c2[1]} ${cx + p2[1]} ${p2[0]}" ${est ? style.est : style.real}/>`);
    }
    return out.join('');
  }
  function fillPath(pts, cx) {
    const n = pts.length, P = i => pts[(i + n) % n]; let d = `M${cx + pts[0][1]} ${pts[0][0]}`;
    for (let i = 0; i < n; i++) { const p0 = P(i - 1), p1 = P(i), p2 = P(i + 1), p3 = P(i + 2); d += ` C${cx + p1[1] + (p2[1] - p0[1]) / 6} ${p1[0] + (p2[0] - p0[0]) / 6} ${cx + p2[1] - (p3[1] - p1[1]) / 6} ${p2[0] - (p3[0] - p1[0]) / 6} ${cx + p2[1]} ${p2[0]}`; }
    return d + 'Z';
  }
  const LEVEL = { neck: .145, shoulders: .195, chest: .26, waist: .40, hips: .50, bicep: .27, forearm: .40, thigh: .60, calf: .80 };
  class Silhouette extends Base {
    static attrs = ['base', 'data', 'compare', 't', 'theme', 'highlight', 'width'];
    render() {
      const t = th(this), a = n => this.getAttribute(n), base = BASES[a('base') || 'neutral'];
      const data = a('data') ? JSON.parse(a('data')) : {};
      const has = {}; KEYS.forEach(k => has[k] = data[k] != null);
      const now = Object.assign({}, base, data);
      const cx = 120, W = 240, Hh = 424;
      const empty = !a('data');
      const strokeNow = empty ? t.ol : t.p;
      const styleNow = { real: `fill="none" stroke="${strokeNow}" stroke-width="2.25" stroke-linecap="round"`, est: `fill="none" stroke="${t.ol}" stroke-width="1.75" stroke-dasharray="3 5" stroke-linecap="round"` };
      let s = '';
      const draw = (m, h, st, fillC) => {
        const f = figure(m, h);
        if (fillC) s += `<g fill="${fillC}"><path d="${fillPath(f.torso, cx)}"/><path d="${fillPath(f.armR, cx)}"/><path d="${fillPath(f.armL, cx)}"/></g>`;
        s += crPaths(f.torso, false, cx, h, st) + crPaths(f.armR, true, cx, h, st) + crPaths(f.armL, true, cx, h, st);
        s += `<ellipse cx="${cx}" cy="${f.head.cy}" rx="${f.head.rx}" ry="${f.head.ry}" ${(h.height ? st.real : st.est).replace('fill="none"', fillC ? `fill="${fillC}"` : 'fill="none"')}/>`;
        return f;
      };
      if (a('compare')) {
        const then0 = Object.assign({}, base, JSON.parse(a('compare'))), tt = a('t') != null ? +a('t') : 1;
        const mix = {}; KEYS.forEach(k => mix[k] = then0[k] + (now[k] - then0[k]) * tt);
        const allHas = {}; KEYS.forEach(k => allHas[k] = true);
        draw(then0, allHas, { real: `fill="none" stroke="${t.then}" stroke-width="1.5" stroke-dasharray="1 4" stroke-linecap="round"`, est: `fill="none" stroke="${t.then}" stroke-width="1.5" stroke-dasharray="1 4" stroke-linecap="round"` });
        draw(mix, has, styleNow, t.cont);
      } else draw(now, has, styleNow, empty ? null : t.cont);
      const hl = a('highlight');
      if (hl && LEVEL[hl]) {
        const f = figure(now, has), y = f.Y(LEVEL[hl]);
        s += `<line x1="18" x2="${W - 18}" y1="${y}" y2="${y}" stroke="${t.on}" stroke-width="1.25" stroke-dasharray="2 4"/><circle cx="${W - 18}" cy="${y}" r="4.5" fill="${t.on}"/>`;
      }
      this.innerHTML = `<svg viewBox="0 0 ${W} ${Hh}" style="display:block;width:100%;height:100%">${s}</svg>`;
    }
  }
  /* ---------------- Nav glyphs (Perch language: 20x16 art in a 24 slot, 1.75 stroke, rounded) ---------------- */
  const NAV = [
    '<rect x="2.6" y="2.2" width="14.8" height="12.9" rx="3" fill="none"/><path d="M2.6 6.4 H17.4 M6.6 0.9 V3.4 M13.4 0.9 V3.4" fill="none"/><circle cx="10" cy="10.7" r="1.7" stroke="none" fill="currentColor"/>',
    '<path d="M6.4 8 H13.6" fill="none"/><rect x="3.4" y="3.4" width="3" height="9.2" rx="1.5" fill="none"/><rect x="13.6" y="3.4" width="3" height="9.2" rx="1.5" fill="none"/><path d="M1.2 6.4 V9.6 M18.8 6.4 V9.6" fill="none"/>',
    '<circle cx="10" cy="9.2" r="5.9" fill="none"/><path d="M8.2 0.9 H11.8 M10 9.2 V6.2 M15 3.6 L16.2 2.4" fill="none"/>',
    '<circle cx="10" cy="3.4" r="2.2" fill="none"/><path d="M5 15.1 V10.6 A5 5 0 0 1 15 10.6 V15.1" fill="none"/>',
    '<rect x="2.4" y="0.9" width="6.8" height="6.8" rx="2.2" fill="none"/><rect x="10.8" y="0.9" width="6.8" height="6.8" rx="2.2" fill="none"/><rect x="2.4" y="8.3" width="6.8" height="6.8" rx="2.2" fill="none"/><rect x="10.8" y="8.3" width="6.8" height="6.8" rx="2.2" fill="none"/>'
  ];
  class NavGlyph extends Base {
    static attrs = ['i'];
    render() { this.style.display = 'block'; this.style.width = '24px'; this.style.height = '24px'; this.innerHTML = `<svg width="24" height="24" viewBox="-2 -4 24 24" style="display:block" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">${NAV[+this.getAttribute('i') || 0]}</svg>`; }
  }
  customElements.define('sinew-nav-glyph', NavGlyph);
  customElements.define('sinew-mark', Mark);
  customElements.define('sinew-barbell', Barbell);
  customElements.define('sinew-muscles', Muscles);
  customElements.define('sinew-silhouette', Silhouette);
  window.SinewArt = { BASES, KG, LB, T };
})();
