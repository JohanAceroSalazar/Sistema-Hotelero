package com.sena.test.IRepository.IInventoryRepository;

import com.sena.test.Entity.Security.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface IRepositoryUserRole {
  
     List<UserRole> findByUserId(Long userId);

     List<UserRole>findByRoleId(Long roleId);
     
}
