/* Beantr: shared page behavior (reveal-on-scroll + copy buttons).
   Loaded on every page. Reveal only animates when the head guard added
   .js-reveal to <html>; otherwise content is already visible via CSS. */
(function () {
  var els = document.querySelectorAll('.reveal');
  if (document.documentElement.classList.contains('js-reveal')) {
    var reveal = function (el) { el.classList.add('is-visible'); };
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) { reveal(entry.target); io.unobserve(entry.target); }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.01 });
    els.forEach(function (el) { io.observe(el); });
    // Belt-and-suspenders: if a renderer never dispatches intersection events
    // (some full-page screenshot tools), reveal everything after a beat.
    setTimeout(function () { els.forEach(reveal); }, 2200);
  }
})();

(function () {
  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      try {
        var ta = document.createElement('textarea');
        ta.value = text;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.focus();
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        resolve();
      } catch (err) {
        reject(err);
      }
    });
  }
  document.querySelectorAll('.copy-btn').forEach(function (btn) {
    var label = btn.querySelector('.copy-btn__label');
    var original = label ? label.textContent : '';
    btn.addEventListener('click', function () {
      copyText(btn.getAttribute('data-copy')).then(function () {
        btn.classList.add('is-copied');
        if (label) label.textContent = 'Copied';
        clearTimeout(btn._copyTimeout);
        btn._copyTimeout = setTimeout(function () {
          btn.classList.remove('is-copied');
          if (label) label.textContent = original;
        }, 1600);
      });
    });
  });
})();

/* GitHub star count in the topbar — progressive enhancement. Renders only when
   the repo is public and has stars; on a private repo / 404 / 0 stars / offline
   it stays hidden. */
(function () {
  var link = document.querySelector('.nav-links a.is-github');
  if (!link || !window.fetch) return;
  var KEY = 'beantr_gh_stars';
  function fmt(n) { return n >= 1000 ? (n / 1000).toFixed(1).replace(/\.0$/, '') + 'k' : String(n); }
  function render(n) {
    if (typeof n !== 'number' || n <= 0 || link.querySelector('.gh-stars')) return;
    var s = document.createElement('span');
    s.className = 'gh-stars';
    s.setAttribute('aria-label', n + ' GitHub stars');
    s.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><span class="gh-stars__count"></span>';
    s.querySelector('.gh-stars__count').textContent = fmt(n);
    link.appendChild(s);
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
})();
