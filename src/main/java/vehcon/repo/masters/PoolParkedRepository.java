package vehcon.repo.masters;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;
import vehcon.models.masters.PoolParked;

import java.util.List;

@Repository
public interface PoolParkedRepository extends JpaRepository<PoolParked, Long> {

    boolean existsByEngineNo(String engineNo);

    // Unallotted vehicles
    List<PoolParked> findByDepartmentId(Long departmentId);

    // Allotted vehicles
    List<PoolParked> findByDepartmentIdNot(Long departmentId);
    
    List<PoolParked> findByDepartmentIdAndProcessCode(Long departmentId, Long processCode);


        // ✅ Get all vehicles (any status) under a department
    // ✅ Include all vehicles for a department (regardless of process code or status)
    @Query("""
        SELECT p FROM PoolParked p
        WHERE p.departmentId = :departmentId
        ORDER BY p.id DESC
    """)
    List<PoolParked> findAllByDepartment(@Param("departmentId") Long departmentId);

}
