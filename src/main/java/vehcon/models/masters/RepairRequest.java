package vehcon.models.masters;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "repair_requests", schema = "vehiclecondemnations")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RepairRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "vehicle_id")
    private Long vehicleId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "department_id", referencedColumnName = "departmentcode")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Departments department;

    @Column(name = "kilometer_reading")
    private Integer kilometerReading;

    @Column(name = "last_service_date")
    private LocalDate lastServiceDate;

    @Column(name = "location")
    private String location;

    @Column(name = "urgency")
    private String urgency;

    @Column(name = "status")
    private String status = "Pending with Transport";


    @Column(name = "process_code")
    private Long processCode;

    @Column(name = "approval_order_file")
    private String approvalOrderFile;

    @Column(name = "work_order_file")
    private String workOrderFile;

    @Column(name = "sanction_order_file")
    private String sanctionOrderFile;
    
    @Column(name = "estimate_amount")
    private Double estimateAmount;
    
    @Column(name = "td_approved")
    private Boolean tdApproved = false;

    @Column(name = "td_approved_date")
    private LocalDate tdApprovedDate;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id", insertable = false, updatable = false)
    @JsonIgnoreProperties({"repairRequests"})
    private PoolParked vehicle;

    // ---------- NEW SECTION: CHILD RELATION ----------

    @OneToMany(mappedBy = "repairRequest", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnoreProperties({"repairRequest"})
    private java.util.List<RepairRequestProblem> problems = new java.util.ArrayList<>();
}
