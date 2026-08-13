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
            String pVal = (phone != null) ? phone.trim() : "";
            String eVal = (email != null) ? email.trim() : "";
            String cVal = (cccd != null) ? cccd.trim() : "";
            String nVal = (name != null) ? name.trim() : "";

            String jpql = "SELECT c FROM Customer c WHERE "
                    + "(:phone != '' AND c.customerPhone = :phone) OR "
                    + "(:email != '' AND c.customerEmail = :email) OR "
                    + "(:cccd != '' AND c.customerCccd = :cccd)";
            TypedQuery<Customer> query = em.createQuery(jpql, Customer.class);
            query.setParameter("phone", pVal);
            query.setParameter("email", eVal);
            query.setParameter("cccd", cVal);
            List<Customer> list = query.getResultList();

            if (!list.isEmpty()) {
                Customer existing = list.get(0);
                boolean updated = false;
                if ((existing.getCustomerName() == null || existing.getCustomerName().trim().isEmpty()) && !nVal.isEmpty()) {
                    existing.setCustomerName(nVal);
                    updated = true;
                }
                if ((existing.getCustomerPhone() == null || existing.getCustomerPhone().trim().isEmpty()) && !pVal.isEmpty()) {
                    existing.setCustomerPhone(pVal);
                    updated = true;
                }
                if ((existing.getCustomerCccd() == null || existing.getCustomerCccd().trim().isEmpty()) && !cVal.isEmpty()) {
                    existing.setCustomerCccd(cVal);
                    updated = true;
                }
                if ((existing.getCustomerEmail() == null || existing.getCustomerEmail().trim().isEmpty()) && !eVal.isEmpty()) {
                    existing.setCustomerEmail(eVal);
                    updated = true;
                }
                if (updated) {
                    tx.begin();
                    em.merge(existing);
                    tx.commit();
                }
                return existing;
            }

            tx.begin();
            Customer newCust = new Customer(nVal, cVal, pVal, eVal);
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
