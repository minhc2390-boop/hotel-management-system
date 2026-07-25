package com.hotel.listener;
import com.hotel.dao.DBContext;import javax.servlet.ServletContextEvent;import javax.servlet.ServletContextListener;import javax.servlet.annotation.WebListener;
@WebListener public class JPAAppListener implements ServletContextListener {
 public void contextInitialized(ServletContextEvent sce){try{DBContext.getEntityManager().close();System.out.println("Hotel Manage started. JPA initialized.");}catch(Throwable error){System.err.println("JPA unavailable; frontend preview remains active: "+error.getMessage());}}
 public void contextDestroyed(ServletContextEvent sce){try{DBContext.shutdown();}catch(Throwable error){System.err.println("JPA shutdown skipped: "+error.getMessage());}}
}
