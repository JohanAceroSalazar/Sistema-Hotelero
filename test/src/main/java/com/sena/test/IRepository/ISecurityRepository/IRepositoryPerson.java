package com.sena.test.IRepository.ISecurityRepository;

import com.sena.test.Entity.Security.Person;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface IRepositoryPerson extends JpaRepository<Person, Long> {
/*    Optional<Person> findByEmail(String email);
        //Spring Data JPA genera automáticamente la consulta SQL solo por el nombre del método.
consultas personalizadas
    Optional<Person> findByIdentidad(String identidad);
*/
}
