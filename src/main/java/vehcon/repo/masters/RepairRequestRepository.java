package vehcon.repo.masters;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vehcon.models.masters.RepairRequest;

import java.util.List;

@Repository
public interface RepairRequestRepository extends JpaRepository<RepairRequest, Long> {

    // Fetch by status
    List<RepairRequest> findByStatusIgnoreCase(String status);

    @Query("""
        SELECT r FROM RepairRequest r
        LEFT JOIN FETCH r.department d
        WHERE LOWER(TRIM(r.status)) = LOWER(TRIM(:status))
        ORDER BY r.id DESC
    """)
    List<RepairRequest> findByStatusWithVehicle(@Param("status") String status);

    // Fetch all
    @Query("""
        SELECT r FROM RepairRequest r
        LEFT JOIN FETCH r.department d
        ORDER BY r.id DESC
    """)
    List<RepairRequest> findAllWithVehicle();

    // Fetch by vehicleId
    @Query("""
        SELECT r FROM RepairRequest r
        LEFT JOIN FETCH r.department d
        WHERE r.vehicleId = :vehicleId
        ORDER BY r.id DESC
    """)
    List<RepairRequest> findByVehicleId(@Param("vehicleId") Long vehicleId);


    // ⚠️ Updated: Remove estimate_amount & remarks (they are now in child table)
    @Query(value = """
        SELECT rr.vehicle_id,
               rr.status,
               rr.approval_order_file,
               rr.work_order_file,
               rr.sanction_order_file,
               rr.id AS request_id
        FROM vehiclecondemnations.repair_requests rr
        INNER JOIN (
            SELECT vehicle_id, MAX(id) AS latest_id
            FROM vehiclecondemnations.repair_requests
            GROUP BY vehicle_id
        ) latest ON rr.id = latest.latest_id
    """, nativeQuery = true)
    List<Object[]> findLatestStatusForAllVehicles();
    
    long countByVehicleIdAndTdApprovedTrue(Long vehicleId);

    List<RepairRequest>
    findByVehicleIdAndTdApprovedTrueOrderByTdApprovedDateDesc(Long vehicleId);
    List<RepairRequest> findByTdApprovedTrueOrderByTdApprovedDateDesc();

}
