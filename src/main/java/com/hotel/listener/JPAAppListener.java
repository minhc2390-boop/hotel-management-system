package com.hotel.listener;

import com.hotel.dao.DBContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class JPAAppListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            // Warm up and initialize EntityManagerFactory early on app startup
            DBContext.getEntityManager().close();
            System.out.println("=================================================");
            System.out.println("🏨 Hotel Manage application started successfully.");
            System.out.println("   JPA EntityManagerFactory initialized.");
            System.out.println("=================================================");
        } catch (Exception e) {
            System.err.println("Failed to initialize JPA on startup: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Shutdown EntityManagerFactory to release database connection pools and prevent memory leaks
        DBContext.shutdown();
        System.out.println("=================================================");
        System.out.println("🏨 Hotel Manage application stopped.");
        System.out.println("   JPA EntityManagerFactory shut down.");
        System.out.println("=================================================");
    }
}
