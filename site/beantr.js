/* Beantr: shared page behavior. Loaded on every page.
   Copy buttons, reveal-on-scroll, a magnetic primary button, GitHub stars.
   Motion only ever runs when the head guard added .js to <html>; without it
   every element is already visible via CSS. */
(function () {
  var motion = document.documentElement.classList.contains('js');

  /* copy: data-copy holds the text, or "#id" to copy that element's text */
  function copyText(t) {
    if (navigator.clipboard && navigator.clipboard.writeText) return navigator.clipboard.writeText(t);
    return new Promise(function (res, rej) {
      try {
        var ta = document.createElement('textarea');
        ta.value = t; ta.style.position = 'fixed'; ta.style.opacity = '0';
        document.body.appendChild(ta); ta.select(); document.execCommand('copy'); document.body.removeChild(ta); res();
      } catch (e) { rej(e); }
    });
  }
  document.querySelectorAll('[data-copy]').forEach(function (btn) {
    var orig = btn.textContent;
    btn.addEventListener('click', function () {
      var src = btn.getAttribute('data-copy');
      var text = src.charAt(0) === '#' ? document.querySelector(src).textContent.replace(/\s+/g, ' ').trim() : src;
      copyText(text).then(function () {
        var box = btn.closest('.ask, .cmdline, .codeblock');
        btn.classList.add('is-copied'); btn.textContent = 'Copied';
        if (box) box.classList.add('is-copied');
        clearTimeout(btn._t);
        btn._t = setTimeout(function () {
          btn.classList.remove('is-copied'); btn.textContent = orig;
          if (box) box.classList.remove('is-copied');
        }, 1600);
      });
    });
  });

  /* magnetic: the primary button leans toward the pointer while it is near (hover devices only) */
  if (motion && window.matchMedia('(hover: hover)').matches) {
    document.querySelectorAll('[data-magnetic]').forEach(function (btn) {
      var zone = btn.closest('.ask') || btn.parentNode;
      zone.addEventListener('pointermove', function (e) {
        var r = btn.getBoundingClientRect();
        var dx = e.clientX - (r.left + r.width / 2), dy = e.clientY - (r.top + r.height / 2);
        var d = Math.hypot(dx, dy), max = 140;
        if (d > max) { btn.style.transform = ''; return; }
        var k = (1 - d / max) * 0.18;
        btn.style.transform = 'translate(' + (dx * k).toFixed(1) + 'px,' + (dy * k).toFixed(1) + 'px)';
      });
      zone.addEventListener('pointerleave', function () { btn.style.transform = ''; });
    });
  }

  /* reveal on scroll */
  if (motion) {
    var els = document.querySelectorAll('.reveal');
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { rootMargin: '0px 0px -10% 0px', threshold: 0.05 });
    els.forEach(function (el) { io.observe(el); });
    /* renderers that never dispatch intersections still get everything after a beat */
    setTimeout(function () { els.forEach(function (el) { el.classList.add('in'); }); }, 2600);
  }

  /* GitHub stars next to the GitHub link, as the usual star badge (icon + count).
     Progressive: only rendered once the repo has more than 100 stars, and never
     on a private repo, a 404, or offline. */
  var gh = document.querySelector('.pill nav a[href*="github.com/tiagomoraes/beantr"]');
  if (gh && window.fetch) {
    var KEY = 'beantr_gh_stars';
    var MIN_STARS = 100;
    function fmt(n) { return n >= 1000 ? (n / 1000).toFixed(1).replace(/\.0$/, '') + 'k' : String(n); }
    function render(n) {
      if (typeof n !== 'number' || n <= MIN_STARS || gh.querySelector('.stars')) return;
      var s = document.createElement('span');
      s.className = 'stars';
      s.setAttribute('aria-label', n + ' GitHub stars');
      s.innerHTML = '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M8 .9l2.2 4.6 5 .7-3.6 3.5.9 5-4.5-2.4-4.5 2.4.9-5L.8 6.2l5-.7z"/></svg>';
      s.appendChild(document.createTextNode(fmt(n)));
      gh.appendChild(s);
    }
    try { var c = sessionStorage.getItem(KEY); if (c) render(parseInt(c, 10)); } catch (e) {}
    fetch('https://api.github.com/repos/tiagomoraes/beantr', { headers: { Accept: 'application/vnd.github+json' } })
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (d) {
        if (!d || typeof d.stargazers_count !== 'number') return;
        try { sessionStorage.setItem(KEY, String(d.stargazers_count)); } catch (e) {}
        render(d.stargazers_count);
      })
      .catch(function () {});
  }
})();
