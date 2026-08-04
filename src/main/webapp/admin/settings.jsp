<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%
  HttpSession sess = request.getSession(false);
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
  if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
  }
  String activeMenu = "settings";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Cài đặt hệ thống - Nestora</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
  <style>
    /* Fix màu chữ tiêu đề tương phản trên nền tối cho toàn bộ các trang */
    [data-theme="dark"] .page-title,
    [data-theme="cyberpunk"] .page-title,
    [data-theme="dark"] .surface-title,
    [data-theme="cyberpunk"] .surface-title {
      color: #ffffff !important;
    }

    [data-theme="dark"] .page-desc,
    [data-theme="cyberpunk"] .page-desc,
    [data-theme="dark"] .breadcrumb,
    [data-theme="cyberpunk"] .breadcrumb {
      color: rgba(255, 255, 255, 0.7) !important;
    }

    .settings-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;
      margin-top: 20px;
    }
    @media (max-width: 992px) {
      .settings-grid {
        grid-template-columns: 1fr;
      }
    }
    
    /* Theme Cards style */
    .theme-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
      gap: 12px;
      margin-top: 10px;
    }
    .theme-card {
      border: 2px solid var(--line);
      border-radius: 8px;
      padding: 12px;
      cursor: pointer;
      position: relative;
      transition: all 0.25s ease;
      background: var(--surface);
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
    }
    .theme-card:hover {
      transform: translateY(-2px);
      box-shadow: var(--shadow);
      border-color: var(--brand);
    }
    .theme-card.active {
      border-color: var(--brand);
      background: var(--brand-soft);
    }
    .theme-card.active::after {
      content: '✓';
      position: absolute;
      top: 6px;
      right: 8px;
      color: var(--brand);
      font-weight: bold;
      font-size: 14px;
    }
    
    .color-preview {
      width: 100%;
      height: 24px;
      border-radius: 4px;
      display: flex;
      overflow: hidden;
      border: 1px solid var(--line);
    }
    .color-preview span {
      flex: 1;
      height: 100%;
    }
    .theme-title {
      font-size: 13px;
      font-weight: 600;
      color: var(--text);
    }
    
    /* Toast styles */
    .toast-container {
      position: fixed;
      top: 20px;
      right: 20px;
      z-index: 9999;
      pointer-events: none;
    }
    .toast {
      background: var(--surface);
      border-left: 4px solid var(--success);
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
      border-radius: 6px;
      padding: 14px 20px;
      margin-bottom: 10px;
      display: flex;
      align-items: center;
      gap: 12px;
      transform: translateX(120%);
      transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      min-width: 280px;
      color: var(--text);
    }
    .toast.show {
      transform: translateX(0);
    }
    .toast-icon {
      color: var(--success);
      font-weight: bold;
      font-size: 16px;
    }
    
    .form-group {
      margin-bottom: 16px;
    }
    .form-group label {
      display: block;
      font-weight: 600;
      margin-bottom: 6px;
      font-size: 13px;
      color: var(--text);
    }
    .form-group input, .form-group select {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: var(--surface);
      color: var(--text);
      transition: border-color 0.2s;
    }
    .form-group input:focus, .form-group select:focus {
      border-color: var(--brand);
      outline: none;
    }
    .content-inner p,
.content-inner li,
.surface p,
.surface li,
.settings-page p,
.settings-card p,
.setting-desc {
    text-indent: 0 !important;
    margin-left: 0 !important;
    padding-left: 0 !important;
    line-height: 1.6;
    font-family: "Segoe UI", Arial, sans-serif;
}
  </style>
</head>
<body>
<div class="admin-layout">
  <%@ include file="../WEB-INF/jspf/admin-sidebar.jspf" %>
  <main class="main-shell">
    <%@ include file="../WEB-INF/jspf/admin-topbar.jspf" %>
    <section class="content">
      <div class="content-inner">
        <div class="page-head">
          <div>
            <div class="breadcrumb">Hệ thống / Cài đặt</div>
            <h1 class="page-title">Cài đặt cấu hình</h1>
            <p class="page-desc">Chỉnh sửa giao diện hệ thống, thông tin khách sạn và thông tin thanh toán chuyển khoản.</p>
          </div>
        </div>

        <div class="settings-grid">
          <!-- Cột trái: Cấu hình giao diện -->
          <div class="surface">
            <div class="surface-head">
              <h2 class="surface-title">Cấu hình giao diện & Trải nghiệm</h2>
            </div>
            <div style="padding: 15px 0">
              <div class="form-group">
                <label>Lựa chọn chủ đề (Web Theme)</label>
                <div class="theme-grid">
                  
                  <div class="theme-card" data-theme-val="light" onclick="selectTheme('light')">
                    <div class="color-preview">
                      <span style="background: #1769e0"></span>
                      <span style="background: #ffffff"></span>
                      <span style="background: #f4f7fb"></span>
                    </div>
                    <span class="theme-title">Mặc định (Sáng)</span>
                  </div>

                  <div class="theme-card" data-theme-val="dark" onclick="selectTheme('dark')">
                    <div class="color-preview">
                      <span style="background: #3b82f6"></span>
                      <span style="background: #1e293b"></span>
                      <span style="background: #0f172a"></span>
                    </div>
                    <span class="theme-title">Tối (Dark)</span>
                  </div>

                  <div class="theme-card" data-theme-val="forest" onclick="selectTheme('forest')">
                    <div class="color-preview">
                      <span style="background: #10b981"></span>
                      <span style="background: #ecfdf5"></span>
                      <span style="background: #f0fdf4"></span>
                    </div>
                    <span class="theme-title">Xanh rừng (Forest)</span>
                  </div>

                  <div class="theme-card" data-theme-val="sunset" onclick="selectTheme('sunset')">
                    <div class="color-preview">
                      <span style="background: #f97316"></span>
                      <span style="background: #fff7ed"></span>
                      <span style="background: #fffaf0"></span>
                    </div>
                    <span class="theme-title">Hoàng hôn</span>
                  </div>

                  <div class="theme-card" data-theme-val="cyberpunk" onclick="selectTheme('cyberpunk')">
                    <div class="color-preview">
                      <span style="background: #ff007f"></span>
                      <span style="background: #120022"></span>
                      <span style="background: #090011"></span>
                    </div>
                    <span class="theme-title">Cyberpunk</span>
                  </div>

                </div>
              </div>

              <div class="form-group" style="margin-top: 24px;">
                <label for="hotel-name-input">Tên khách sạn hiển thị (Branding)</label>
                <input type="text" id="hotel-name-input" placeholder="Tên khách sạn (ví dụ: Nestora Hotel)">
              </div>

              <div class="form-group">
                <label for="hotel-address-input">Địa chỉ khách sạn</label>
                <input type="text" id="hotel-address-input" placeholder="Địa chỉ chi tiết">
              </div>

              <div class="form-group">
                <label for="hotel-phone-input">Số điện thoại liên hệ</label>
                <input type="text" id="hotel-phone-input" placeholder="Số điện thoại bàn / Hotline">
              </div>

              <div class="form-group">
                <label for="hotel-email-input">Email khách sạn</label>
                <input type="email" id="hotel-email-input" placeholder="Địa chỉ email nhận thông tin">
              </div>
            </div>
          </div>

          <!-- Cột phải: Cấu hình thanh toán VietQR -->
          <div class="surface">
            <div class="surface-head">
              <h2 class="surface-title">Cấu hình VietQR & Chuyển khoản</h2>
            </div>
            <div style="padding: 15px 0">
              <p style="font-size: 13px; color: var(--muted); margin-bottom: 18px;">
                Các cấu hình tài khoản dưới đây sẽ được sử dụng để tự động sinh mã VietQR quét tiền phòng động tại trang Chi tiết hóa đơn khách hàng.
              </p>

              <div class="form-group">
                <label for="bank-id-select">Ngân hàng thụ hưởng</label>
                <select id="bank-id-select">
                  <option value="MB">MB Bank (Ngân hàng Quân Đội)</option>
                  <option value="VCB">Vietcombank</option>
                  <option value="TCB">Techcombank</option>
                  <option value="BIDV">BIDV</option>
                  <option value="CTG">VietinBank</option>
                  <option value="ACB">ACB</option>
                  <option value="VPB">VPBank</option>
                  <option value="TPB">TPBank</option>
                  <option value="VIB">VIB</option>
                  <option value="STB">Sacombank</option>
                </select>
              </div>

              <div class="form-group">
                <label for="bank-account-input">Số tài khoản ngân hàng</label>
                <input type="text" id="bank-account-input" placeholder="Nhập chính xác số tài khoản">
              </div>

              <div class="form-group">
                <label for="bank-name-input">Tên chủ tài khoản (Viết hoa không dấu)</label>
                <input type="text" id="bank-name-input" placeholder="Ví dụ: CONG TY NESTORA HOTEL">
              </div>

              <div style="margin-top: 30px; display: flex; gap: 10px;">
                <button class="btn btn-primary" style="flex: 1" onclick="saveSettings()">Lưu cấu hình</button>
                <button class="btn btn-outline" onclick="resetToDefaults()">Khôi phục mặc định</button>
              </div>
            </div>
          </div>
        </div>

      </div>
    </section>
  </main>
</div>

<!-- Toast Container -->
<div class="toast-container" id="toast-container"></div>

<script>
  let currentTheme = 'light';

  document.addEventListener('DOMContentLoaded', function() {
      const savedTheme = localStorage.getItem('nestora_theme') || 'light';
      currentTheme = savedTheme;
      selectTheme(savedTheme);

      document.getElementById('hotel-name-input').value = localStorage.getItem('hotel_name') || 'Nestora';
      document.getElementById('hotel-address-input').value = localStorage.getItem('hotel_address') || 'Số 12 Đường Hùng Vương, Thành phố Nha Trang, Việt Nam';
      document.getElementById('hotel-phone-input').value = localStorage.getItem('hotel_phone') || '+84 (0) 258 3567 890';
      document.getElementById('hotel-email-input').value = localStorage.getItem('hotel_email') || 'info@nestorahotel.com';

      document.getElementById('bank-id-select').value = localStorage.getItem('hotel_bank_id') || 'MB';
      document.getElementById('bank-account-input').value = localStorage.getItem('hotel_bank_account') || '1903567890123';
      document.getElementById('bank-name-input').value = localStorage.getItem('hotel_bank_name') || 'CONG TY NESTORA HOTEL';
  });

  function selectTheme(themeName) {
      currentTheme = themeName;
      
      // Áp dụng ngay thuộc tính data-theme lên thẻ html/root
      document.documentElement.setAttribute('data-theme', themeName);

      document.querySelectorAll('.theme-card').forEach(card => {
          if (card.getAttribute('data-theme-val') === themeName) {
              card.classList.add('active');
          } else {
              card.classList.remove('active');
          }
      });
  }

  function saveSettings() {
      const hotelName = document.getElementById('hotel-name-input').value.trim();
      const hotelAddress = document.getElementById('hotel-address-input').value.trim();
      const hotelPhone = document.getElementById('hotel-phone-input').value.trim();
      const hotelEmail = document.getElementById('hotel-email-input').value.trim();

      const bankId = document.getElementById('bank-id-select').value;
      const bankAccount = document.getElementById('bank-account-input').value.trim();
      const bankName = document.getElementById('bank-name-input').value.trim().toUpperCase();

      localStorage.setItem('nestora_theme', currentTheme);
      localStorage.setItem('hotel_name', hotelName);
      localStorage.setItem('hotel_address', hotelAddress);
      localStorage.setItem('hotel_phone', hotelPhone);
      localStorage.setItem('hotel_email', hotelEmail);

      localStorage.setItem('hotel_bank_id', bankId);
      localStorage.setItem('hotel_bank_account', bankAccount);
      localStorage.setItem('hotel_bank_name', bankName);

      const brandNameStrong = document.querySelectorAll('.brand-name strong');
      if (brandNameStrong.length > 0) {
          brandNameStrong.forEach(el => el.innerText = hotelName.toUpperCase());
      }

      showToast("Lưu cấu hình hệ thống thành công!");
  }

  function resetToDefaults() {
      if (confirm("Bạn có chắc chắn muốn khôi phục toàn bộ cài đặt về mặc định?")) {
          localStorage.removeItem('nestora_theme');
          localStorage.removeItem('hotel_name');
          localStorage.removeItem('hotel_address');
          localStorage.removeItem('hotel_phone');
          localStorage.removeItem('hotel_email');
          localStorage.removeItem('hotel_bank_id');
          localStorage.removeItem('hotel_bank_account');
          localStorage.removeItem('hotel_bank_name');

          window.location.reload();
      }
  }

  function showToast(message) {
      const container = document.getElementById('toast-container');
      const toast = document.createElement('div');
      toast.className = 'toast';
      toast.innerHTML = `<span class="toast-icon">✓</span><span>${message}</span>`;
      container.appendChild(toast);

      setTimeout(() => {
          toast.classList.add('show');
      }, 50);

      setTimeout(() => {
          toast.classList.remove('show');
          setTimeout(() => {
              toast.remove();
          }, 300);
      }, 3000);
  }
</script>

<script src="<%=request.getContextPath()%>/js/app.js"></script>
</body>
</html>
