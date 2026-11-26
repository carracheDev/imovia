const root = document.documentElement;
const toggle = document.querySelector('#theme-toggle');
const savedTheme = localStorage.getItem('imovia-theme');
const preferredTheme = window.matchMedia('(prefers-color-scheme: dark)').matches
  ? 'dark'
  : 'light';
const toast = document.querySelector('#toast');
let toastTimeout;

function setTheme(theme) {
  root.dataset.theme = theme;
  const isDark = theme === 'dark';
  toggle.setAttribute('aria-pressed', String(isDark));
  toggle.setAttribute(
    'aria-label',
    isDark ? 'Activer le thème clair' : 'Activer le thème sombre',
  );
  localStorage.setItem('imovia-theme', theme);
}

setTheme(
  savedTheme === 'dark' || savedTheme === 'light' ? savedTheme : preferredTheme,
);
toggle.addEventListener('click', () => {
  setTheme(root.dataset.theme === 'dark' ? 'light' : 'dark');
});

document.querySelectorAll('[data-tab]').forEach((tab) => {
  tab.addEventListener('click', () => {
    document.querySelectorAll('[data-tab]').forEach((item) => {
      const selected = item === tab;
      item.classList.toggle('active', selected);
      item.setAttribute('aria-selected', String(selected));
    });

    const labels = {
      review: 'File de modération · 8 annonces attendent une décision.',
      published: 'Annonces publiées · 24 biens sont visibles dans le catalogue.',
      changes: 'À compléter · 3 annonceurs doivent corriger leur dossier.',
    };
    document.querySelector('#tab-content').textContent =
      labels[tab.dataset.tab];
  });
});

function showToast(message, type = 'success') {
  window.clearTimeout(toastTimeout);
  toast.textContent = message;
  toast.classList.toggle('toast-error', type === 'error');
  toast.hidden = false;
  toastTimeout = window.setTimeout(() => {
    toast.hidden = true;
  }, 3200);
}

document.querySelectorAll('[data-toast]').forEach((button) => {
  button.addEventListener('click', () => {
    showToast(button.dataset.toast, button.dataset.toastType);
  });
});

document.querySelectorAll('[data-dialog]').forEach((button) => {
  button.addEventListener('click', () => {
    document.querySelector(`#${button.dataset.dialog}`).showModal();
  });
});

document.querySelectorAll('.property-favorite').forEach((button) => {
  button.addEventListener('click', () => {
    const isFavorite = button.getAttribute('aria-pressed') === 'true';
    button.setAttribute('aria-pressed', String(!isFavorite));
    button.textContent = isFavorite ? '♡' : '♥';
    showToast(
      isFavorite
        ? 'Annonce retirée des favoris.'
        : 'Annonce ajoutée aux favoris.',
    );
  });
});
