package vehcon.dto.auth;

import lombok.Data;

@Data
public class RolesDTO {
    private String role;         // matches frontend payload
    private String description;  // optional
}
