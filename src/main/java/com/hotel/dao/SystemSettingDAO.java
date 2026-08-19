package com.hotel.dao;

import com.hotel.model.SystemSetting;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;

public class SystemSettingDAO {

    public String getSetting(String key) {
        return getSetting(key, "");
    }

    public String getSetting(String key, String defaultValue) {
        if (key == null || key.trim().isEmpty()) {
            return defaultValue;
        }
        EntityManager em = DBContext.getEntityManager();
        try {
            SystemSetting setting = em.find(SystemSetting.class, key.trim());
            if (setting != null && setting.getSettingValue() != null && !setting.getSettingValue().trim().isEmpty()) {
                return setting.getSettingValue().trim();
            }
        } catch (Exception e) {
            System.err.println("[SystemSettingDAO.getSetting Warning]: " + e.getMessage());
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        return defaultValue;
    }

    public boolean setSetting(String key, String value) {
        if (key == null || key.trim().isEmpty()) {
            return false;
        }
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            SystemSetting setting = em.find(SystemSetting.class, key.trim());
            if (setting == null) {
                setting = new SystemSetting(key.trim(), value);
                em.persist(setting);
            } else {
                setting.setSettingValue(value);
                em.merge(setting);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            e.printStackTrace();
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        return false;
    }

    public boolean saveSetting(String key, String value) {
        return setSetting(key, value);
    }

    public java.util.Map<String, String> getAllSettings() {
        java.util.Map<String, String> result = new java.util.HashMap<>();
        EntityManager em = DBContext.getEntityManager();
        try {
            java.util.List<SystemSetting> list = em.createQuery("SELECT s FROM SystemSetting s", SystemSetting.class).getResultList();
            if (list != null) {
                for (SystemSetting s : list) {
                    if (s.getSettingKey() != null) {
                        result.put(s.getSettingKey(), s.getSettingValue() != null ? s.getSettingValue() : "");
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[SystemSettingDAO.getAllSettings Warning]: " + e.getMessage());
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        return result;
    }

    public String getBankId() {
        return getSetting("hotel_bank_id", getSetting("bankId", "MB"));
    }

    public String getBankAccount() {
        return getSetting("hotel_bank_account", getSetting("bankAccount", "1903567890123"));
    }

    public String getBankName() {
        return getSetting("hotel_bank_name", getSetting("bankName", "CONG TY NESTORA HOTEL"));
    }
}
