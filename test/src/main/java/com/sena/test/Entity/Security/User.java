package com.sena.test.Entity.Security;

    import jakarta.persistence.Column;
    import jakarta.persistence.Entity;
    import jakarta.persistence.Id;
    import jakarta.persistence.GeneratedValue;
    import jakarta.persistence.GenerationType;
    import jakarta.persistence.JoinColumn;
    import jakarta.persistence.OneToOne;

    import lombok.Getter;
    import lombok.Setter;
    import lombok.NoArgsConstructor;
    import lombok.AllArgsConstructor;
    import lombok.ToString;

    @Entity
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @ToString
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(nullable =false, unique =true, length =120)
    private String password;
    
    @OneToOne
    @JoinColumn(name = "person_ide", nullable = false)
    private Person person;


}
