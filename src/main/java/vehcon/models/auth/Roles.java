package vehcon.models.auth;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "roles", schema = "auth")
@Data
public class Roles {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer rolecode;

    @Column(name = "rolename", unique = true, nullable = false)
    private String role;

    @Column(name = "description")
    private String description;
}
