package com.hotel.dao;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

/**
 * JPA Utility class acting as the Entity Manager Factory provider.
 * Retains the name DBContext to avoid changing package structures.
 */
public class DBContext {

    private static volatile EntityManagerFactory emf;

    /**
     * Lazy-loads the EntityManagerFactory safely.
     */
    public static EntityManagerFactory getEntityManagerFactory() {
        if (emf == null || !emf.isOpen()) {
            synchronized (DBContext.class) {
                if (emf == null || !emf.isOpen()) {
                    try {
                        emf = Persistence.createEntityManagerFactory("HotelPU");
                    } catch (Throwable ex) {
                        System.err.println("Initial EntityManagerFactory creation failed: " + ex);
                        throw new RuntimeException("Không thể kết nối Cơ sở dữ liệu SQL Server (HotelPU): " + ex.getMessage(), ex);
                    }
                }
            }
        }
        return emf;
    }

    /**
     * Get a new EntityManager instance.
     * Remember to close it after transactions complete!
     */
    public static EntityManager getEntityManager() {
        return getEntityManagerFactory().createEntityManager();
    }

    /**
     * Shutdown the EntityManagerFactory on application exit.
     */
    public static void shutdown() {
        if (emf != null && emf.isOpen()) {
            emf.close();
            emf = null;
        }
    }
}
