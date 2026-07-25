(function () {
  const sidebar = document.querySelector('.sidebar');
  const mobileToggle = document.querySelector('[data-sidebar-toggle]');
  const collapseToggle = document.querySelector('[data-sidebar-collapse]');

  // Load and apply theme and hotel configurations
  const savedTheme = localStorage.getItem('nestora_theme') || 'light';
  document.documentElement.setAttribute('data-theme', savedTheme);

  const savedHotelName = localStorage.getItem('hotel_name') || 'NESTORA';
  const brandNameStrong = document.querySelectorAll('.brand-name strong');
  if (brandNameStrong.length > 0) {
    brandNameStrong.forEach(el => el.innerText = savedHotelName.toUpperCase());
  }

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
    if (sidebar.classList.contains('open') && !sidebar.contains(event.target) && (!mobileToggle || !mobileToggle.contains(event.target))) {
      sidebar.classList.remove('open');
    }
  });

})();
