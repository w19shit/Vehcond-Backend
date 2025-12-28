package vehcon.repo.masters;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vehcon.models.masters.RepairRequestProblem;

import java.util.List;

@Repository
public interface RepairRequestProblemRepository extends JpaRepository<RepairRequestProblem, Long> {

    // ------------------------------------------------------------
    // 1) Fetch all problems for a repair request
    // ------------------------------------------------------------
    @Query("""
        SELECT p FROM RepairRequestProblem p
        WHERE p.repairRequest.id = :requestId
        ORDER BY p.id
    """)
    List<RepairRequestProblem> findByRequestId(@Param("requestId") Long requestId);

    // ------------------------------------------------------------
    // 2) Fetch problems with estimate already filled (Transport use-case)
    // ------------------------------------------------------------
    @Query("""
        SELECT p FROM RepairRequestProblem p
        WHERE p.repairRequest.id = :requestId
          AND p.estimateAmount IS NOT NULL
        ORDER BY p.id
    """)
    List<RepairRequestProblem> findEstimatedProblems(@Param("requestId") Long requestId);

    // ------------------------------------------------------------
    // 3) Fetch problems pending estimation
    // ------------------------------------------------------------
    @Query("""
        SELECT p FROM RepairRequestProblem p
        WHERE p.repairRequest.id = :requestId
          AND p.estimateAmount IS NULL
        ORDER BY p.id
    """)
    List<RepairRequestProblem> findPendingProblems(@Param("requestId") Long requestId);
}
