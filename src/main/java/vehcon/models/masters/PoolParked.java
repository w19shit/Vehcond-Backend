package vehcon.models.masters;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDate;
import java.time.LocalDateTime;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "pool_parked", schema = "vehiclecondemnations")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PoolParked {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "department_id")
    private Long departmentId;

    @Column(name = "vehicle_type_id")
    private Long vehicleTypeId;

    @Column(name = "manufacturer_id")
    private Long manufacturerId;

    @Column(name = "model")
    private String model;

    @Column(name = "registration_no")
    private String registrationNo;

    @Column(name = "chassis_no")
    private String chassisNo;

    @Column(name = "engine_no")
    private String engineNo;

    @Column(name = "purchase_date")
    private LocalDate purchaseDate;

    @Column(name = "purchase_cost")
    private Double purchaseCost;

    @Column(name = "vehicle_description")
    private String vehicleDescription;

    @Column(name = "date_of_manufacturing")
    private LocalDate dateOfManufacturing;

    @Column(name = "process_code")
    private Long processCode; // 👈 to track process (e.g., 18 for allotted)

    @Column(name = "allotted_date")
    private LocalDate allottedDate; // 👈 when vehicle was allotted
    
    @Column(name = "status")
    private String status;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }


    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime updatedAt = LocalDateTime.now();
}
