package com.sena.test.IRepository.IInventoryRepository;

import com.sena.test.Entity.Inventory.Product;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface IRepositoryProduct extends JpaRepository<Product, Long>{

}
