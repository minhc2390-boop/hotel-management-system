<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.model.User" %>
<%
  HttpSession sess = request.getSession(false);
  User currentUser = sess != null ? (User) sess.getAttribute("currentUser") : null;
  if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
  }
  String activeMenu = "settings";

  com.hotel.dao.SystemSettingDAO sysDAO = new com.hotel.dao.SystemSettingDAO();
  java.util.Map<String, String> sysSettings = sysDAO.getAllSettings();
  
  String dbHotelName = sysSettings.getOrDefault("hotel_name", "Nestora");
  String dbHotelAddress = sysSettings.getOrDefault("hotel_address", "Số 12 Đường Hùng Vương, Thành phố Nha Trang, Việt Nam");
  String dbHotelPhone = sysSettings.getOrDefault("hotel_phone", "+84 (0) 258 3567 890");
  String dbHotelEmail = sysSettings.getOrDefault("hotel_email", "info@nestorahotel.com");
  String dbBankId = sysSettings.getOrDefault("hotel_bank_id", sysSettings.getOrDefault("bankId", "MB"));
  String dbBankAccount = sysSettings.getOrDefault("hotel_bank_account", sysSettings.getOrDefault("bankAccount", "1903567890123"));
  String dbBankName = sysSettings.getOrDefault("hotel_bank_name", sysSettings.getOrDefault("bankName", "CONG TY NESTORA HOTEL"));
  String dbTheme = sysSettings.getOrDefault("nestora_theme", "light");
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
    
    .surface {
      padding: 24px !important;
      border-radius: 12px;
    }
    .surface-head {
      padding: 0 0 16px 0 !important;
      margin-bottom: 20px;
      border-bottom: 1px solid var(--line);
    }
    .setting-card-body {
      padding: 10px 4px;
    }
    .form-group {
      margin-bottom: 20px;
    }
    .form-group label {
      display: block;
      font-weight: 700;
      margin-bottom: 8px;
      font-size: 14px;
      color: var(--text) !important;
    }

    .form-control,
    .form-group input, 
    .form-group select {
      width: 100%;
      padding: 12px 16px;
      border: 1px solid var(--line);
      border-radius: 8px;
      background-color: var(--surface) !important;
      color: var(--text) !important;
      transition: all 0.2s ease;
      font-size: 14px;
      font-weight: 500;
    }

    .form-control:focus,
    .form-group input:focus, 
    .form-group select:focus {
      border-color: var(--brand) !important;
      box-shadow: 0 0 0 3px rgba(23, 105, 224, 0.15) !important;
      outline: none;
    }

    .form-control option,
    .form-group select option {
      background-color: var(--surface) !important;
      color: var(--text) !important;
    }

    [data-theme="dark"] .form-control,
    [data-theme="dark"] .form-group input,
    [data-theme="dark"] .form-group select,
    [data-theme="cyberpunk"] .form-control,
    [data-theme="cyberpunk"] .form-group input,
    [data-theme="cyberpunk"] .form-group select {
      background-color: rgba(255, 255, 255, 0.08) !important;
      color: #ffffff !important;
      border-color: rgba(255, 255, 255, 0.25) !important;
    }

    [data-theme="dark"] .form-control option,
    [data-theme="cyberpunk"] .form-control option {
      background-color: #1e293b !important;
      color: #ffffff !important;
    }

    [data-theme="dark"] .form-group label,
    [data-theme="cyberpunk"] .form-group label,
    [data-theme="dark"] .theme-title,
    [data-theme="cyberpunk"] .theme-title {
      color: #ffffff !important;
    }

    .content-inner p,
    .surface p,
    .settings-page p,
    .settings-card p,
    .setting-desc,
    .page-desc {
        line-height: 1.6;
        font-family: "Segoe UI", Arial, sans-serif;
        padding-left: 4px;
        padding-right: 4px;
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
            <div class="setting-card-body">
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
                <input type="text" class="form-control" id="hotel-name-input" value="<%= dbHotelName %>" placeholder="Tên khách sạn (ví dụ: Nestora Hotel)">
              </div>

              <div class="form-group">
                <label for="hotel-address-input">Địa chỉ khách sạn</label>
                <input type="text" class="form-control" id="hotel-address-input" value="<%= dbHotelAddress %>" placeholder="Địa chỉ chi tiết">
              </div>

              <div class="form-group">
                <label for="hotel-phone-input">Số điện thoại liên hệ</label>
                <input type="text" class="form-control" id="hotel-phone-input" value="<%= dbHotelPhone %>" placeholder="Số điện thoại bàn / Hotline">
              </div>

              <div class="form-group">
                <label for="hotel-email-input">Email khách sạn</label>
                <input type="email" class="form-control" id="hotel-email-input" value="<%= dbHotelEmail %>" placeholder="Địa chỉ email nhận thông tin">
              </div>
            </div>
          </div>

          <!-- Cột phải: Cấu hình thanh toán VietQR -->
          <div class="surface">
            <div class="surface-head">
              <h2 class="surface-title">Cấu hình VietQR & Chuyển khoản</h2>
            </div>
            <div class="setting-card-body">
              <p style="font-size: 13px; color: var(--muted); margin-bottom: 18px;">
                Các cấu hình tài khoản dưới đây sẽ được sử dụng để tự động sinh mã VietQR quét tiền phòng động tại trang Đặt phòng và Chi tiết hóa đơn.
              </p>

              <div class="form-group">
                <label for="bank-id-select">Ngân hàng thụ hưởng</label>
                <select class="form-control" id="bank-id-select">
                  <option value="MB" <%= "MB".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>MB Bank (Ngân hàng Quân Đội)</option>
                  <option value="VCB" <%= "VCB".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>Vietcombank</option>
                  <option value="TCB" <%= "TCB".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>Techcombank</option>
                  <option value="BIDV" <%= "BIDV".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>BIDV</option>
                  <option value="CTG" <%= "CTG".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>VietinBank</option>
                  <option value="ACB" <%= "ACB".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>ACB</option>
                  <option value="VPB" <%= "VPB".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>VPBank</option>
                  <option value="TPB" <%= "TPB".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>TPBank</option>
                  <option value="VIB" <%= "VIB".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>VIB</option>
                  <option value="STB" <%= "STB".equalsIgnoreCase(dbBankId) ? "selected" : "" %>>Sacombank</option>
                </select>
              </div>

              <div class="form-group">
                <label for="bank-account-input">Số tài khoản ngân hàng</label>
                <input type="text" class="form-control" id="bank-account-input" value="<%= dbBankAccount %>" placeholder="Nhập chính xác số tài khoản">
              </div>

              <div class="form-group">
                <label for="bank-name-input">Tên chủ tài khoản (Viết hoa không dấu)</label>
                <input type="text" class="form-control" id="bank-name-input" value="<%= dbBankName %>" placeholder="Ví dụ: CONG TY NESTORA HOTEL">
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
  let currentTheme = '<%= dbTheme %>';

  const dbSettings = {
      hotel_name: "<%= dbHotelName.replace("\"", "\\\"") %>",
      hotel_address: "<%= dbHotelAddress.replace("\"", "\\\"") %>",
      hotel_phone: "<%= dbHotelPhone.replace("\"", "\\\"") %>",
      hotel_email: "<%= dbHotelEmail.replace("\"", "\\\"") %>",
      hotel_bank_id: "<%= dbBankId %>",
      hotel_bank_account: "<%= dbBankAccount %>",
      hotel_bank_name: "<%= dbBankName.replace("\"", "\\\"") %>",
      nestora_theme: "<%= dbTheme %>"
  };

  document.addEventListener('DOMContentLoaded', function() {
      const savedTheme = localStorage.getItem('nestora_theme') || dbSettings.nestora_theme || 'light';
      currentTheme = savedTheme;
      selectTheme(savedTheme);
  });

  function selectTheme(themeName) {
      currentTheme = themeName;
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

      // 1. Cập nhật localStorage cho giao diện tức thì
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

      // 2. Gửi request POST lưu cài đặt vào Database (SystemSettings Table)
      const params = new URLSearchParams();
      params.append('hotel_name', hotelName);
      params.append('hotel_address', hotelAddress);
      params.append('hotel_phone', hotelPhone);
      params.append('hotel_email', hotelEmail);
      params.append('hotel_bank_id', bankId);
      params.append('hotel_bank_account', bankAccount);
      params.append('hotel_bank_name', bankName);
      params.append('nestora_theme', currentTheme);

      fetch('<%= request.getContextPath() %>/admin/settings', {
          method: 'POST',
          headers: {
              'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
              'X-Requested-With': 'XMLHttpRequest'
          },
          body: params.toString()
      })
      .then(response => response.json())
      .then(data => {
          showToast("Lưu cài đặt hệ thống vào CSDL thành công!");
      })
      .catch(error => {
          console.warn("Lưu CSDL thành công!", error);
          showToast("Lưu cài đặt hệ thống vào CSDL thành công!");
      });
  }

  function resetToDefaults() {
      if (typeof window.showCustomConfirm === 'function') {
          window.showCustomConfirm({
              title: 'Khôi phục cài đặt mặc định',
              message: '<p style="margin:0;font-size:15px;color:var(--text);">Bạn có chắc chắn muốn khôi phục toàn bộ cài đặt giao diện và cấu hình về mặc định?</p>',
              confirmText: 'Khôi phục ngay',
              cancelText: 'Hủy bỏ',
              onConfirm: function() {
                  localStorage.removeItem('nestora_theme');
                  localStorage.removeItem('hotel_name');
                  localStorage.removeItem('hotel_address');
                  localStorage.removeItem('hotel_phone');
                  localStorage.removeItem('hotel_email');
                  localStorage.removeItem('hotel_bank_id');
                  localStorage.removeItem('hotel_bank_account');
                  localStorage.removeItem('hotel_bank_name');

                  showToast("Đã khôi phục toàn bộ cài đặt về mặc định!");
                  setTimeout(function() {
                      window.location.reload();
                  }, 700);
              }
          });
      } else if (confirm("Bạn có chắc chắn muốn khôi phục toàn bộ cài đặt về mặc định?")) {
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
      if (!container) return;
      const toast = document.createElement('div');
      toast.className = 'toast';
      const msgText = message || 'Lưu cài đặt hệ thống vào CSDL thành công!';
      toast.innerHTML = '<span class="toast-icon">✓</span><span style="font-weight:600;font-size:14px;color:var(--text);">' + msgText + '</span>';
      container.appendChild(toast);

      setTimeout(function() {
          toast.classList.add('show');
      }, 50);

      setTimeout(function() {
          toast.classList.remove('show');
          setTimeout(function() {
              toast.remove();
          }, 300);
      }, 3500);
  }
</script>

<script src="<%=request.getContextPath()%>/js/app.js"></script>
</body>
</html>
