/* Beantr: "In writing" page behaviour.
   Progressive: without .js (no IntersectionObserver, reduced motion, or no JS)
   every line is already visible. Motion only ever enhances. */
(function () {
  var root = document.documentElement;
  var motion = root.classList.contains('js');
  var page = document.querySelector('.page');
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)');
  var hover = window.matchMedia('(hover: hover)');
  var clamp = function (v, a, b) { return v < a ? a : v > b ? b : v; };

  /* ---------- spine alignment ---------- */
  function alignSpine() {
    var shell = document.querySelector('.hero .shell');
    if (!shell) return;
    if (window.innerWidth <= 980) { root.style.removeProperty('--spine-x'); return; }
    var x = shell.getBoundingClientRect().left + parseFloat(getComputedStyle(shell).paddingLeft) + 9;
    root.style.setProperty('--spine-x', Math.round(x) + 'px');
  }
  alignSpine();
  window.addEventListener('resize', alignSpine, { passive: true });

  /* ---------- reveals ---------- */
  var reveals = Array.prototype.slice.call(document.querySelectorAll('[data-reveal]'));
  if (motion && 'IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
    reveals.forEach(function (el) { io.observe(el); });
    // renderers that never fire intersections still get everything
    setTimeout(function () { reveals.forEach(function (el) { el.classList.add('in'); }); }, 2800);
  }

  // hero headline: on the first paint, not on scroll
  var immediate = document.querySelectorAll('[data-reveal-immediate]');
  if (motion) {
    requestAnimationFrame(function () {
      requestAnimationFrame(function () {
        Array.prototype.forEach.call(immediate, function (el) { el.classList.add('in'); });
      });
    });
  }

  /* ---------- progress + filed scroll piece ---------- */
  var filed = document.querySelector('[data-filed]');
  var stepEls = filed ? Array.prototype.slice.call(filed.querySelectorAll('[data-step]')) : [];
  var lastStep = -1;

  function setSteps(n) {
    if (n === lastStep) return;
    lastStep = n;
    stepEls.forEach(function (el) {
      var s = parseInt(el.getAttribute('data-step'), 10);
      if (s <= n) el.classList.add('on'); else el.classList.remove('on');
    });
  }

  function showAllSteps() {
    lastStep = -2;
    stepEls.forEach(function (el) { el.classList.add('on'); });
  }

  function onFrame() {
    // spine progress
    var doc = root.scrollHeight - window.innerHeight;
    var p = doc > 0 ? clamp(window.scrollY / doc, 0, 1) : 0;
    if (page) page.style.setProperty('--p', p.toFixed(4));

    // filed steps, only while the panel is on screen
    if (filed && stepEls.length) {
      var r = filed.getBoundingClientRect();
      var vh = window.innerHeight;
      if (r.bottom > 0 && r.top < vh) {
        var total = Math.max(filed.offsetHeight - vh, 1);
        var travelled = clamp(-r.top, 0, total);
        var prog = travelled / total;
        setSteps(clamp(Math.floor(prog * 5), 0, 4));
      }
    }
  }

  var ticking = false;
  function requestFrame() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(function () { onFrame(); ticking = false; });
  }
  window.addEventListener('scroll', requestFrame, { passive: true });
  window.addEventListener('resize', requestFrame, { passive: true });
  onFrame();

  function syncStepsLayout() {
    if (!filed) return;
    if (window.innerWidth <= 980 || reduce.matches) showAllSteps();
    else { lastStep = -1; requestFrame(); }
  }
  syncStepsLayout();
  window.addEventListener('resize', syncStepsLayout, { passive: true });
  if (reduce.addEventListener) reduce.addEventListener('change', syncStepsLayout);

  /* ---------- pointer: light + hero parallax ---------- */
  if (motion && hover.matches) {
    var gx = 0, gy = 0, gQueued = false;
    document.addEventListener('pointermove', function (e) {
      gx = e.clientX; gy = e.clientY;
      if (gQueued) return;
      gQueued = true;
      requestAnimationFrame(function () {
        root.style.setProperty('--gx', gx + 'px');
        root.style.setProperty('--gy', gy + 'px');
        gQueued = false;
      });
    }, { passive: true });

    var hero = document.querySelector('.hero');
    if (hero) {
      hero.addEventListener('pointermove', function (e) {
        var r = hero.getBoundingClientRect();
        var px = ((e.clientX - r.left) / r.width - 0.5) * 2;
        var py = ((e.clientY - r.top) / r.height - 0.5) * 2;
        hero.style.setProperty('--px', px.toFixed(3));
        hero.style.setProperty('--py', py.toFixed(3));
      }, { passive: true });
      hero.addEventListener('pointerleave', function () {
        hero.style.setProperty('--px', 0);
        hero.style.setProperty('--py', 0);
      }, { passive: true });
    }
  }

  /* ---------- copy ---------- */
  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) return navigator.clipboard.writeText(text);
    return new Promise(function (resolve, reject) {
      try {
        var ta = document.createElement('textarea');
        ta.value = text;
        ta.setAttribute('readonly', '');
        ta.style.position = 'fixed';
        ta.style.top = '-1000px';
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        resolve();
      } catch (err) { reject(err); }
    });
  }

  document.querySelectorAll('[data-copy]').forEach(function (btn) {
    var card = btn.closest('.card');
    var target = btn.getAttribute('data-copy');
    var orig = (btn.textContent || 'copy').trim();
    var reset = function () {
      btn.classList.remove('is-copied');
      btn.textContent = orig;
    };
    btn.addEventListener('click', function () {
      var text;
      if (target && target.charAt(0) === '#') {
        var el = document.querySelector(target);
        text = el ? el.textContent : '';
      } else if (card) {
        var body = card.querySelector('.card__body');
        text = body ? body.textContent : '';
      } else {
        text = btn.getAttribute('data-copy') || '';
      }
      copyText(text.replace(/\s+/g, ' ').trim()).then(function () {
        btn.classList.add('is-copied');
        btn.textContent = 'copied';
        clearTimeout(btn._t);
        btn._t = setTimeout(reset, 1800);
      }).catch(function () {});
    });
  });

  /* ---------- magnetic buttons ---------- */
  if (motion && hover.matches) {
    document.querySelectorAll('[data-magnetic]').forEach(function (btn) {
      var zone = btn.parentNode;
      zone.addEventListener('pointermove', function (e) {
        var r = btn.getBoundingClientRect();
        var dx = e.clientX - (r.left + r.width / 2);
        var dy = e.clientY - (r.top + r.height / 2);
        var d = Math.hypot(dx, dy);
        if (d > 120) { btn.style.transform = ''; return; }
        var k = (1 - d / 120) * 0.12;
        btn.style.transform = 'translate(' + (dx * k).toFixed(1) + 'px,' + (dy * k).toFixed(1) + 'px)';
      });
      zone.addEventListener('pointerleave', function () { btn.style.transform = ''; });
    });
  }

  /* ---------- shelf detail ---------- */
  var shelf = document.querySelector('[data-shelf]');
  if (shelf) {
    var detail = shelf.querySelector('.shelf__detail');
    var fields = {
      name: shelf.querySelector('[data-d="name"]'),
      g: shelf.querySelector('[data-d="g"]'),
      cap: shelf.querySelector('[data-d="cap"]'),
      roast: shelf.querySelector('[data-d="roast"]'),
      tube: shelf.querySelector('[data-d="tube"]'),
      state: shelf.querySelector('[data-d="state"]')
    };
    var timer;
    var allTubes = shelf.querySelectorAll('.tube');
    function show(btn) {
      var d = btn.dataset;
      allTubes.forEach(function (t) { t.classList.toggle('is-active', t === btn); });
      detail.classList.add('is-swapping');
      clearTimeout(timer);
      timer = setTimeout(function () {
        fields.name.textContent = d.name;
        fields.g.textContent = d.g;
        fields.cap.textContent = d.cap;
        fields.roast.textContent = d.roast;
        fields.tube.textContent = d.tube;
        fields.state.textContent = d.state;
        detail.classList.remove('is-swapping');
      }, 140);
    }
    shelf.querySelectorAll('.tube').forEach(function (btn) {
      btn.addEventListener('pointerenter', function () { show(btn); });
      btn.addEventListener('focus', function () { show(btn); });
    });
  }
})();
