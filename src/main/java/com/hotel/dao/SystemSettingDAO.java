package com.hotel.dao;

import com.hotel.model.SystemSetting;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class SystemSettingDAO {

    // Bộ nhớ đệm tạm thời (Memory Store) với giá trị cài đặt mặc định
    private static final Map<String, String> memorySettings = new ConcurrentHashMap<>();

    static {
        memorySettings.put("hotel_name", "Nestora");
        memorySettings.put("hotel_address", "Số 12 Đường Hùng Vương, Thành phố Nha Trang, Việt Nam");
        memorySettings.put("hotel_phone", "+84 (0) 258 3567 890");
        memorySettings.put("hotel_email", "info@nestorahotel.com");
        memorySettings.put("hotel_bank_id", "MB");
        memorySettings.put("hotel_bank_account", "1903567890123");
        memorySettings.put("hotel_bank_name", "CONG TY NESTORA HOTEL");
        memorySettings.put("nestora_theme", "light");
    }

    /**
     * Lấy giá trị cài đặt theo key từ CSDL (hoặc Memory Store nếu DB chưa có).
     */
    public String getSetting(String key) {
        if (key == null || key.trim().isEmpty()) return "";
        String cleanKey = key.trim();

        EntityManager em = DBContext.getEntityManager();
        try {
            SystemSetting setting = em.find(SystemSetting.class, cleanKey);
            if (setting != null && setting.getSettingValue() != null) {
                memorySettings.put(cleanKey, setting.getSettingValue());
                return setting.getSettingValue();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }

        return memorySettings.getOrDefault(cleanKey, "");
    }

    /**
     * Lưu hoặc cập nhật một cặp key - value cài đặt vào CSDL.
     */
    public boolean saveSetting(String key, String value) {
        if (key == null || key.trim().isEmpty()) return false;
        String cleanKey = key.trim();
        String cleanVal = value != null ? value.trim() : "";

        // Đồng bộ vào bộ nhớ đệm
        memorySettings.put(cleanKey, cleanVal);

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            SystemSetting setting = em.find(SystemSetting.class, cleanKey);
            if (setting == null) {
                setting = new SystemSetting(cleanKey, cleanVal);
                em.persist(setting);
            } else {
                setting.setSettingValue(cleanVal);
                em.merge(setting);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return true;
    }

    /**
     * Lấy toàn bộ cài đặt dưới dạng Map<String, String>.
     */
    public Map<String, String> getAllSettings() {
        Map<String, String> map = new HashMap<>(memorySettings);
        EntityManager em = DBContext.getEntityManager();
        try {
            List<SystemSetting> list = em.createQuery("SELECT s FROM SystemSetting s", SystemSetting.class).getResultList();
            for (SystemSetting s : list) {
                if (s.getSettingKey() != null) {
                    String val = s.getSettingValue() != null ? s.getSettingValue() : "";
                    map.put(s.getSettingKey(), val);
                    memorySettings.put(s.getSettingKey(), val);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return map;
    }
}
