(function () {
  const sidebar = document.querySelector('.sidebar');
  const mobileToggle = document.querySelector('[data-sidebar-toggle]');
  const collapseToggle = document.querySelector('[data-sidebar-collapse]');

  if (mobileToggle && sidebar) {
    mobileToggle.addEventListener('click', function () {
      sidebar.classList.toggle('open');
    });
  }

  if (collapseToggle) {
    collapseToggle.addEventListener('click', function (event) {
      event.preventDefault();
      document.documentElement.classList.toggle('sidebar-collapsed');
    });
  }

  document.addEventListener('click', function (event) {
    if (!sidebar || window.innerWidth > 900) return;
    if (
      sidebar.classList.contains('open') &&
      !sidebar.contains(event.target) &&
      (!mobileToggle || !mobileToggle.contains(event.target))
    ) {
      sidebar.classList.remove('open');
    }
  });
})();
