package com.hotel.dao;

import com.hotel.model.Customer;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.List;

public class CustomerDAO {

    public List<Customer> getAllCustomers() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT c FROM Customer c ORDER BY c.customerName ASC";
            TypedQuery<Customer> query = em.createQuery(jpql, Customer.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public Customer getCustomerById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.find(Customer.class, id);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public boolean insertCustomer(Customer customer) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (customer.getCustomerId() > 0) {
                em.merge(customer);
            } else {
                em.persist(customer);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
    }

    public Customer findOrCreateCustomer(String name, String phone, String email, String cccd) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            // Tìm theo email hoặc CCCD
            String jpql = "SELECT c FROM Customer c WHERE (c.customerEmail = :email AND :email IS NOT NULL AND :email != '') OR (c.customerCccd = :cccd AND :cccd IS NOT NULL AND :cccd != '')";
            TypedQuery<Customer> query = em.createQuery(jpql, Customer.class);
            query.setParameter("email", email);
            query.setParameter("cccd", cccd);
            List<Customer> list = query.getResultList();
            
            if (!list.isEmpty()) {
                return list.get(0);
            }
            
            // Không tìm thấy -> tạo mới
            tx.begin();
            Customer newCust = new Customer(name, cccd, phone, email);
            em.persist(newCust);
            tx.commit();
            return newCust;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }
}
