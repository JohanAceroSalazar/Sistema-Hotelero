package com.sena.test.IService.ISecurityService;

//import com.sena.test.Entity.Security.User;
import com.sena.test.DTO.SecurityDTO.UserDTORequest;
import com.sena.test.DTO.SecurityDTO.UserDTOResponse;

import java.util.List;


public interface IServiceUser {

UserDTOResponse create(UserDTORequest dto);
UserDTOResponse update(Long id, UserDTORequest dto);
UserDTOResponse findById(Long id);
List <UserDTOResponse> findAll();
void delete (Long id);


}
