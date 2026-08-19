(function () {
  const sidebar = document.querySelector('.sidebar');
  const mobileToggle = document.querySelector('[data-sidebar-toggle]');
  const collapseToggle = document.querySelector('[data-sidebar-collapse]');

  // Load and apply theme and hotel configurations
  const savedTheme = localStorage.getItem('nestora_theme') || 'light';
  document.documentElement.setAttribute('data-theme', savedTheme);

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

  // Preserve sidebar scroll position across page navigation without scroll jumping
  const sidebarScroll = document.querySelector('.sidebar-scroll');
  if (sidebarScroll) {
    const savedScrollPos = localStorage.getItem('nestora_sidebar_scroll');
    if (savedScrollPos !== null) {
      sidebarScroll.scrollTop = parseInt(savedScrollPos, 10);
    }
    sidebarScroll.addEventListener('scroll', function () {
      localStorage.setItem('nestora_sidebar_scroll', sidebarScroll.scrollTop);
    });
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

  // =========================================================================
  // UNIVERSAL CUSTOM CONFIRMATION MODAL (Thay thế toàn bộ confirm() mặc định)
  // =========================================================================
  let confirmDialogEl = null;
  let confirmTitleEl = null;
  let confirmMessageEl = null;
  let confirmBtnDeleteEl = null;
  let confirmBtnCancelEl = null;
  let pendingConfirmCallback = null;

  function ensureCustomConfirmDialog() {
    if (confirmDialogEl) return;

    confirmDialogEl = document.createElement('div');
    confirmDialogEl.className = 'custom-confirm-modal';
    confirmDialogEl.hidden = true;
    confirmDialogEl.innerHTML =
      '<div class="custom-confirm-dialog" role="dialog" aria-modal="true" aria-labelledby="custom-confirm-title">' +
        '<div class="confirm-icon-wrap">' +
          '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
            '<polyline points="3 6 5 6 21 6"></polyline>' +
            '<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>' +
            '<line x1="10" y1="11" x2="10" y2="17"></line>' +
            '<line x1="14" y1="11" x2="14" y2="17"></line>' +
          '</svg>' +
        '</div>' +
        '<h3 class="confirm-title" id="custom-confirm-title">Xác nhận xóa dữ liệu</h3>' +
        '<div class="confirm-message" id="custom-confirm-message">' +
          'Bạn có chắc chắn muốn thực hiện thao tác xóa này không?' +
        '</div>' +
        '<div class="confirm-actions">' +
          '<button type="button" class="btn btn-cancel" data-confirm-cancel>Hủy bỏ</button>' +
          '<button type="button" class="btn btn-confirm-delete" data-confirm-ok>' +
            '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">' +
              '<polyline points="3 6 5 6 21 6"></polyline>' +
              '<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>' +
            '</svg>' +
            '<span>Xác nhận xóa</span>' +
          '</button>' +
        '</div>' +
      '</div>';

    document.body.appendChild(confirmDialogEl);

    confirmTitleEl = confirmDialogEl.querySelector('#custom-confirm-title');
    confirmMessageEl = confirmDialogEl.querySelector('#custom-confirm-message');
    confirmBtnDeleteEl = confirmDialogEl.querySelector('[data-confirm-ok]');
    confirmBtnCancelEl = confirmDialogEl.querySelector('[data-confirm-cancel]');

    function closeConfirmModal() {
      if (confirmDialogEl) {
        confirmDialogEl.hidden = true;
        document.body.classList.remove('modal-open');
      }
      pendingConfirmCallback = null;
    }

    confirmBtnCancelEl.addEventListener('click', closeConfirmModal);
    confirmDialogEl.addEventListener('click', function (e) {
      if (e.target === confirmDialogEl) {
        closeConfirmModal();
      }
    });

    confirmBtnDeleteEl.addEventListener('click', function () {
      const cb = pendingConfirmCallback;
      closeConfirmModal();
      if (typeof cb === 'function') {
        cb();
      }
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && confirmDialogEl && !confirmDialogEl.hidden) {
        closeConfirmModal();
      }
    });
  }

  // Cung cấp hàm toàn cục
  window.showCustomConfirm = function (options) {
    ensureCustomConfirmDialog();
    const title = options.title || 'Xác nhận xóa dữ liệu';
    let message = options.message || 'Bạn có chắc chắn muốn xóa mục này? Thao tác này không thể hoàn tác.';
    const confirmText = options.confirmText || 'Xác nhận xóa';
    const cancelText = options.cancelText || 'Hủy bỏ';

    confirmTitleEl.textContent = title;
    confirmMessageEl.innerHTML = message;
    confirmBtnDeleteEl.querySelector('span').textContent = confirmText;
    confirmBtnCancelEl.textContent = cancelText;

    pendingConfirmCallback = options.onConfirm || null;
    confirmDialogEl.hidden = false;
    document.body.classList.add('modal-open');
    window.setTimeout(function () {
      confirmBtnDeleteEl.focus();
    }, 50);
  };

  // Tự động chặn (intercept) tất cả các nút Xóa và các hàm confirm() trên toàn bộ trang
  document.addEventListener('click', function (e) {
    const target = e.target.closest('a, button');
    if (!target) return;

    // Bỏ qua modal cancel booking lý do riêng
    if (target.closest('.cancel-booking-modal') || target.closest('.custom-confirm-modal')) return;
    if (target.dataset.cancelBooking || target.dataset.noCustomConfirm) return;

    const onclickAttr = target.getAttribute('onclick') || '';
    const href = target.getAttribute('href') || '';
    const hasConfirmAttr = target.hasAttribute('data-confirm') || target.hasAttribute('data-confirm-delete');
    const isDeleteAction = href.includes('action=delete') || href.includes('/delete') || target.classList.contains('btn-danger') || target.classList.contains('btn-action-del');

    if (onclickAttr.includes('confirm(') || hasConfirmAttr || isDeleteAction) {
      // Ngăn chặn sự kiện mặc định và chặn confirm() gốc của trình duyệt
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();

      // Trích xuất nội dung thông báo từ confirm('...') hoặc data-confirm
      let msg = target.getAttribute('data-confirm') || target.getAttribute('data-confirm-delete') || '';
      if (!msg && onclickAttr) {
        const match = onclickAttr.match(/confirm\s*\(\s*['"`](.*?)['"`]\s*\)/);
        if (match && match[1]) {
          msg = match[1];
        }
      }
      if (!msg) {
        msg = 'Bạn có chắc chắn muốn xóa dữ liệu này khỏi hệ thống không?';
      }

      msg = msg.replace(/\\'/g, "'").replace(/\\"/g, '"');

      window.showCustomConfirm({
        title: 'Xác nhận xóa dữ liệu',
        message: '<p style="margin:0;font-size:15px;font-weight:500;color:var(--text);">' + msg + '</p>' +
                 '<p style="margin:10px 0 0;font-size:12px;color:#dc2626;background:rgba(220,38,38,0.08);padding:6px 10px;border-radius:6px;display:inline-block;">⚠️ Thao tác này sẽ xóa dữ liệu và không thể hoàn tác.</p>',
        confirmText: 'Xác nhận xóa',
        cancelText: 'Hủy bỏ',
        onConfirm: function () {
          if (target.tagName.toLowerCase() === 'a' && href && href !== '#') {
            window.location.href = href;
          } else if (target.type === 'submit' && target.form) {
            target.form.submit();
          } else if (target.classList.contains('btn-action-del')) {
            const tr = target.closest('tr');
            if (tr) tr.remove();
          }
        }
      });
    }
  }, true);

})();
