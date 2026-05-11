package com.sena.test.IRepository.IBillRepository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.sena.test.Entity.Bill.BillDetail;

public interface IRepositoryBildetail extends JpaRepository<BillDetail, Long>{

}
