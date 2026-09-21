/* PROTOTYPE ONLY. Floating variant switcher for site/prototype/*.html.
   Not part of the real site: delete together with this directory.
   Each variant page sets <body data-variant="a|b|c"> and loads this file. */
(function () {
  var V = [
    { k: 'a', name: 'Ledger split', file: 'a.html' },
    { k: 'b', name: 'Manifesto', file: 'b.html' },
    { k: 'c', name: 'Index', file: 'c.html' },
    { k: 'd', name: 'Roastery', file: 'd.html' }
  ];
  var cur = (document.body.getAttribute('data-variant') || 'a').toLowerCase();
  var i = 0;
  for (var j = 0; j < V.length; j++) if (V[j].k === cur) i = j;

  function go(d) {
    var n = V[(i + d + V.length) % V.length];
    window.location.href = n.file;
  }

  var css = [
    '.proto-bar{position:fixed;left:50%;bottom:18px;transform:translateX(-50%);z-index:9000;',
    'display:flex;align-items:center;gap:6px;padding:6px 8px 6px 14px;background:#FF3B00;color:#fff;',
    'font:600 12px/1 -apple-system,"Segoe UI",Helvetica,Arial,sans-serif;letter-spacing:.02em;',
    'border-radius:999px;box-shadow:0 12px 32px rgba(0,0,0,.38);white-space:nowrap}',
    '.proto-bar b{font-weight:800;opacity:.9;margin-right:6px}',
    '.proto-bar kbd{font:inherit;opacity:.75;margin-left:6px}',
    '.proto-bar button{all:unset;cursor:pointer;width:28px;height:28px;display:grid;place-items:center;',
    'border-radius:999px;background:rgba(255,255,255,.2);font-size:14px;line-height:1}',
    '.proto-bar button:hover{background:rgba(255,255,255,.34)}',
    '.proto-bar button:focus-visible{outline:2px solid #fff;outline-offset:2px}',
    '@media print{.proto-bar{display:none}}'
  ].join('');
  var st = document.createElement('style');
  st.textContent = css;
  document.head.appendChild(st);

  var bar = document.createElement('div');
  bar.className = 'proto-bar';
  bar.setAttribute('role', 'group');
  bar.setAttribute('aria-label', 'Prototype variant switcher');
  bar.innerHTML =
    '<b>PROTOTYPE</b>' +
    '<button type="button" aria-label="Previous variant">&larr;</button>' +
    '<span>' + cur.toUpperCase() + ' &middot; ' + V[i].name + '<kbd>' + (i + 1) + '/' + V.length + '</kbd></span>' +
    '<button type="button" aria-label="Next variant">&rarr;</button>';
  var btns = bar.querySelectorAll('button');
  btns[0].addEventListener('click', function () { go(-1); });
  btns[1].addEventListener('click', function () { go(1); });

  document.addEventListener('keydown', function (e) {
    var t = e.target;
    var tag = t && t.tagName;
    if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || (t && t.isContentEditable)) return;
    if (e.key === 'ArrowLeft') go(-1);
    if (e.key === 'ArrowRight') go(1);
  });

  document.body.appendChild(bar);
})();
