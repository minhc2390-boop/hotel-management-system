(function () {
  const sidebar = document.querySelector('.sidebar');
  const mobileToggle = document.querySelector('[data-sidebar-toggle]');
  const collapseToggle = document.querySelector('[data-sidebar-collapse]');

  // Load and apply theme and hotel configurations
  const savedTheme = localStorage.getItem('nestora_theme') || 'light';
  document.documentElement.setAttribute('data-theme', savedTheme);

  // Tránh trình duyệt khôi phục vị trí cuộn cũ khi mở một trang quản trị khác.
  if (document.querySelector('.admin-layout') && !window.location.hash) {
    if ('scrollRestoration' in window.history) window.history.scrollRestoration = 'manual';
    window.requestAnimationFrame(function () {
      window.scrollTo(0, 0);
    });
  }

  // Sync theme changes across tabs in real-time
  window.addEventListener('storage', function(e) {
    if (e.key === 'nestora_theme' && e.newValue) {
      document.documentElement.setAttribute('data-theme', e.newValue);
    }
  });

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

  function normalizeSearch(value) {
    return (value || '').toString().normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .trim();
  }

  // Shared search and filter behavior for all administration tables.
  document.querySelectorAll('.surface').forEach(function (surface) {
    const searchInput = surface.querySelector('.table-tools .search-box input[type="search"]');
    const filters = Array.from(surface.querySelectorAll('[data-admin-filter]'));
    const tableWrap = surface.querySelector('.table-wrap');
    const tbody = tableWrap ? tableWrap.querySelector('table tbody') : null;
    if ((!searchInput && filters.length === 0) || !tbody) return;

    const rows = Array.from(tbody.querySelectorAll('tr')).filter(function (row) {
      return row.children.length > 1;
    });
    if (rows.length === 0) return;

    const meta = surface.querySelector('.table-meta');
    const originalMeta = meta ? meta.textContent.trim() : '';
    const resultUnit = originalMeta.replace(/^[\d.,]+\s*/, '') || 'kết quả';
    const emptyMessage = document.createElement('div');
    emptyMessage.className = 'admin-filter-empty';
    emptyMessage.hidden = true;
    emptyMessage.textContent = 'Không tìm thấy dữ liệu phù hợp.';
    tableWrap.insertAdjacentElement('afterend', emptyMessage);

    function applyFilters() {
      const query = normalizeSearch(searchInput ? searchInput.value : '');
      let visibleCount = 0;

      rows.forEach(function (row) {
        const matchesSearch = !query || normalizeSearch(row.textContent).includes(query);
        const matchesFilters = filters.every(function (filter) {
          if (!filter.value) return true;
          const filterKey = filter.dataset.filterKey;
          const source = filterKey ? row.dataset[filterKey] : row.textContent;
          return normalizeSearch(source).includes(normalizeSearch(filter.value));
        });
        row.hidden = !(matchesSearch && matchesFilters);
        if (!row.hidden) visibleCount += 1;
      });

      if (meta) meta.textContent = visibleCount + ' ' + resultUnit;
      emptyMessage.hidden = visibleCount !== 0;
    }

    if (searchInput) searchInput.addEventListener('input', applyFilters);
    filters.forEach(function (filter) {
      filter.addEventListener('change', applyFilters);
    });
  });

  // Phân trang gọn cho các bảng quản trị có nhiều dữ liệu.
  document.querySelectorAll('.table-wrap[data-admin-paginated]').forEach(function (tableWrap) {
    const tbody = tableWrap.querySelector('table tbody');
    if (!tbody) return;

    const rows = Array.from(tbody.querySelectorAll('tr')).filter(function (row) {
      return row.children.length > 1;
    });
    const configuredPageSize = Number.parseInt(tableWrap.dataset.adminPaginated, 10);
    const pageSize = Number.isFinite(configuredPageSize) && configuredPageSize > 0 ? configuredPageSize : 10;
    const pageCount = Math.ceil(rows.length / pageSize);
    if (pageCount <= 1) return;

    let currentPage = 1;
    const pagination = document.createElement('nav');
    pagination.className = 'pagination';
    pagination.setAttribute('aria-label', 'Phân trang danh sách');
    tableWrap.insertAdjacentElement('afterend', pagination);

    function renderPage() {
      const firstRow = (currentPage - 1) * pageSize;
      const lastRow = firstRow + pageSize;
      rows.forEach(function (row, index) {
        row.hidden = index < firstRow || index >= lastRow;
      });

      pagination.replaceChildren();

      function appendPageButton(label, targetPage, active, disabled, ariaLabel) {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'page-number' + (active ? ' active' : '');
        button.textContent = label;
        button.disabled = disabled;
        button.setAttribute('aria-label', ariaLabel);
        if (active) button.setAttribute('aria-current', 'page');
        button.addEventListener('click', function () {
          currentPage = targetPage;
          renderPage();
          const surface = tableWrap.closest('.surface');
          if (surface) surface.scrollIntoView({ block: 'start', behavior: 'smooth' });
        });
        pagination.appendChild(button);
      }

      appendPageButton('‹', currentPage - 1, false, currentPage === 1, 'Trang trước');
      for (let page = 1; page <= pageCount; page += 1) {
        appendPageButton(String(page), page, page === currentPage, false, 'Trang ' + page);
      }
      appendPageButton('›', currentPage + 1, false, currentPage === pageCount, 'Trang sau');
    }

    renderPage();
  });

  // A single reusable dialog prevents nested forms in booking list pages.
  let cancelDialog = null;
  let cancelForm = null;
  let cancellationReason = null;

  function closeCancelDialog() {
    if (!cancelDialog) return;
    cancelDialog.hidden = true;
    document.body.classList.remove('modal-open');
  }

  function ensureCancelDialog() {
    if (cancelDialog) return;
    cancelDialog = document.createElement('div');
    cancelDialog.className = 'cancel-booking-modal';
    cancelDialog.hidden = true;
    cancelDialog.innerHTML =
      '<div class="cancel-booking-dialog" role="dialog" aria-modal="true" aria-labelledby="cancel-booking-title">' +
        '<h2 id="cancel-booking-title">Lý do hủy đặt phòng</h2>' +
        '<p>Vui lòng nhập lý do để lưu cùng thông tin đặt phòng.</p>' +
        '<form method="post" id="cancel-booking-form">' +
          '<input type="hidden" name="action" value="cancel">' +
          '<input type="hidden" name="bookingId" value="">' +
          '<label class="form-label" for="cancellation-reason">Lý do hủy <span aria-hidden="true">*</span></label>' +
          '<textarea class="form-control" id="cancellation-reason" name="cancellationReason" rows="4" minlength="3" maxlength="500" required placeholder="Nhập lý do hủy đặt phòng..."></textarea>' +
          '<small class="form-hint">Từ 3 đến 500 ký tự.</small>' +
          '<div class="cancel-booking-actions">' +
            '<button class="btn btn-outline" type="button" data-cancel-dialog-close>Quay lại</button>' +
            '<button class="btn btn-danger" type="submit">Xác nhận hủy</button>' +
          '</div>' +
        '</form>' +
      '</div>';
    document.body.appendChild(cancelDialog);
    cancelForm = cancelDialog.querySelector('#cancel-booking-form');
    cancellationReason = cancelDialog.querySelector('#cancellation-reason');

    cancelDialog.addEventListener('click', function (event) {
      if (event.target === cancelDialog || event.target.closest('[data-cancel-dialog-close]')) {
        closeCancelDialog();
      }
    });
  }

  document.addEventListener('click', function (event) {
    const trigger = event.target.closest('[data-cancel-booking]');
    if (!trigger) return;
    event.preventDefault();
    ensureCancelDialog();
    cancelForm.action = trigger.dataset.cancelUrl || window.location.pathname;
    cancelForm.querySelector('[name="bookingId"]').value = trigger.dataset.bookingId || '';
    cancellationReason.value = '';
    cancelDialog.hidden = false;
    document.body.classList.add('modal-open');
    window.setTimeout(function () { cancellationReason.focus(); }, 0);
  });

  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && cancelDialog && !cancelDialog.hidden) closeCancelDialog();
  });

})();
