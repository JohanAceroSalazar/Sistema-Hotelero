package com.sena.test.IService.ISecurityService;

//import com.sena.test.Entity.Security.UserRole;
import com.sena.test.DTO.SecurityDTO.UserRoleDTOResponse;
import com.sena.test.DTO.SecurityDTO.PersonDTORequest;
import com.sena.test.DTO.SecurityDTO.UserRoleDTORequest;

import java.util.List;

public interface IServiceUserRole {
UserRoleDTOResponse create(UserRoleDTORequest dto);
UserRoleDTOResponse update(Long id,PersonDTORequest  dto);
UserRoleDTOResponse findById(Long id);
void delete (Long id);
List <UserRoleDTOResponse> findAll();
}
