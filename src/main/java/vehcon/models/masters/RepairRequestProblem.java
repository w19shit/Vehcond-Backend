package vehcon.models.masters;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;   // ✅ ADD THIS

@Entity
@Table(name = "repair_request_problems", schema = "vehiclecondemnations")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RepairRequestProblem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "repair_request_id")
    @JsonIgnoreProperties({"problems"})   // ✅ Now works
    private RepairRequest repairRequest;

    @Column(name = "problem_text")
    private String problemText;

    @Column(name = "estimate_amount")
    private Double estimateAmount;

    @Column(name = "remark")
    private String remark;
}
