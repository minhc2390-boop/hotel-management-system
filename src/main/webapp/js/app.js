(function () {
  const sidebar = document.querySelector('.sidebar');
  const mobileToggle = document.querySelector('[data-sidebar-toggle]');
  const collapseToggle = document.querySelector('[data-sidebar-collapse]');

  // Load and apply theme and hotel configurations
  const savedTheme = localStorage.getItem('nestora_theme') || 'light';
  document.documentElement.setAttribute('data-theme', savedTheme);

  const savedHotelName = localStorage.getItem('hotel_name') || 'NESTORA';
  const brandNameStrong = document.querySelectorAll('.brand-name strong, [data-hotel-name]');
  if (brandNameStrong.length > 0) {
    brandNameStrong.forEach(el => el.innerText = savedHotelName.toUpperCase());
  }

  const hotelDetails = {
    '[data-hotel-address]': localStorage.getItem('hotel_address') || 'Số 12 Đường Hùng Vương, Thành phố Nha Trang, Việt Nam',
    '[data-hotel-phone]': localStorage.getItem('hotel_phone') || '+84 (0) 258 3567 890',
    '[data-hotel-email]': localStorage.getItem('hotel_email') || 'info@nestorahotel.com'
  };
  Object.keys(hotelDetails).forEach(selector => {
    document.querySelectorAll(selector).forEach(element => {
      element.textContent = hotelDetails[selector];
    });
  });

  const clientNavToggle = document.querySelector('[data-client-nav-toggle]');
  const clientNav = document.querySelector('[data-client-nav]');
  if (clientNavToggle && clientNav) {
    clientNavToggle.addEventListener('click', function () {
      const isOpen = clientNav.classList.toggle('open');
      clientNavToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    });
  }

  // Load and apply sidebar collapsed state from localStorage
  const sidebarCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
  if (sidebarCollapsed) {
    document.documentElement.classList.add('sidebar-collapsed');
    document.documentElement.classList.add('collapsed');
  }

  if (mobileToggle && sidebar) {
    mobileToggle.addEventListener('click', function () {
      sidebar.classList.toggle('open');
    });
  }

  if (collapseToggle) {
    collapseToggle.addEventListener('click', function (event) {
      event.preventDefault();
      const isNowCollapsed = document.documentElement.classList.toggle('sidebar-collapsed');
      document.documentElement.classList.toggle('collapsed', isNowCollapsed);
      localStorage.setItem('sidebarCollapsed', isNowCollapsed ? 'true' : 'false');
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

  document.addEventListener('click', function (event) {
    if (!clientNav || !clientNavToggle || window.innerWidth > 980) return;
    if (clientNav.classList.contains('open')
        && !clientNav.contains(event.target)
        && !clientNavToggle.contains(event.target)) {
      clientNav.classList.remove('open');
      clientNavToggle.setAttribute('aria-expanded', 'false');
    }
  });

})();
