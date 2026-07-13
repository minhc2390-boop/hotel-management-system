package com.hotel.dao;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

/**
 * JPA Utility class acting as the Entity Manager Factory provider.
 * Retains the name DBContext to avoid changing package structures.
 */
public class DBContext {

    private static EntityManagerFactory emf;

    static {
        try {
            // "HotelPU" matches the persistence-unit name in persistence.xml
            emf = Persistence.createEntityManagerFactory("HotelPU");
        } catch (Throwable ex) {
            System.err.println("Initial EntityManagerFactory creation failed: " + ex);
            throw new ExceptionInInitializerError(ex);
        }
    }

    /**
     * Get a new EntityManager instance.
     * Remember to close it after transactions complete!
     */
    public static EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    /**
     * Shutdown the EntityManagerFactory on application exit.
     */
    public static void shutdown() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}
