/* Native review interactions; no scientific code or object loading runs here. */
(() => {
  let noticeTimer;
  const notice = message => {
    const box = document.getElementById('notice');
    if (!box) return;
    box.textContent = message;
    box.hidden = false;
    clearTimeout(noticeTimer);
    noticeTimer = setTimeout(() => { box.hidden = true; }, 4000);
  };
  document.addEventListener('click', async event => {
    const copy = event.target.closest('[data-copy]');
    if (copy) {
      try {
        await navigator.clipboard.writeText(copy.dataset.copy);
        notice('Copied.');
      } catch {
        notice('Copy is unavailable here. Select the displayed path to copy it.');
      }
      return;
    }
    const enlarge = event.target.closest('[data-enlarge]');
    if (enlarge) {
      const dialog = document.getElementById('figure-dialog');
      const img = document.getElementById('figure-image');
      const title = document.getElementById('figure-title');
      if (!dialog || !img || !title || typeof dialog.showModal !== 'function') {
        notice('Enlargement is unavailable here. Open the figure using its file location.');
        return;
      }
      img.src = enlarge.dataset.enlarge;
      img.alt = enlarge.dataset.title || 'Saved scientific figure';
      title.textContent = enlarge.dataset.title || 'Saved figure';
      dialog.showModal();
      return;
    }
    if (event.target.closest('[data-close-figure]')) {
      document.getElementById('figure-dialog')?.close();
    }
  });
  // Deep links into an expandable file description reveal that description.
  const revealAnchor = () => {
    let id;
    try { id = decodeURIComponent(location.hash.slice(1)); } catch { return; }
    const target = document.getElementById(id);
    if (!target) return;
    for (let node = target.parentElement; node; node = node.parentElement) {
      if (node.tagName === 'DETAILS') node.open = true;
    }
    if (target.tagName === 'DETAILS') target.open = true;
    target.scrollIntoView({block: 'start'});
  };
  window.addEventListener('hashchange', revealAnchor);
  revealAnchor();
})();
