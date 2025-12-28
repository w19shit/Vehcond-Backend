package vehcon.services.masters;

import org.springframework.stereotype.Service;
import vehcon.models.masters.PoolParked;
import vehcon.repo.masters.PoolParkedRepository;
import vehcon.services.masters.PoolParkedService;


import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class PoolParkedService {

    private final PoolParkedRepository poolParkedRepository;

    public PoolParkedService(PoolParkedRepository poolParkedRepository) {
        this.poolParkedRepository = poolParkedRepository;
    }

    // Get all vehicles
    public List<PoolParked> getAllVehicles() {
        return poolParkedRepository.findAll();
    }

    // Get unallotted vehicles (departmentId = 0)
    public List<PoolParked> getUnallottedVehicles() {
        return poolParkedRepository.findByDepartmentId(0L);
    }

    // Get allotted vehicles (departmentId != 0)
    public List<PoolParked> getAllottedVehicles() {
        return poolParkedRepository.findByDepartmentIdNot(0L);
    }

    // Allot vehicle to a department
    public boolean allotVehicle(Long vehicleId, Long departmentId) {
        Optional<PoolParked> optionalVehicle = poolParkedRepository.findById(vehicleId);
        if (optionalVehicle.isPresent()) {
            PoolParked vehicle = optionalVehicle.get();
            vehicle.setDepartmentId(departmentId);
            vehicle.setAllottedDate(LocalDate.now());
            vehicle.setProcessCode(18L); // 18 = allotted
            vehicle.setUpdatedAt(LocalDateTime.now());
            poolParkedRepository.save(vehicle);
            return true;
        }
        return false;
    }

    // Add new vehicle
    public PoolParked addVehicle(PoolParked vehicle) {
        vehicle.setId(null); // Ensure new entity
        vehicle.setCreatedAt(LocalDateTime.now());
        vehicle.setUpdatedAt(LocalDateTime.now());
        return poolParkedRepository.save(vehicle);
    }
    
 // Discard new vehicle
    public PoolParked discardVehicle(Long id, Long processCode) {
        PoolParked vehicle = poolParkedRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vehicle not found"));

        vehicle.setProcessCode(processCode); // set -4
        return poolParkedRepository.save(vehicle);
    }


 // ✅ Get all vehicles belonging to a specific department (any status)
    public List<PoolParked> getVehiclesByDepartment(Long departmentId) {
        return poolParkedRepository.findAllByDepartment(departmentId);
    }




    // ✅ 2. Update status -> "Pending with Transport department"
    public void sendForRepair(Long id) {
        PoolParked vehicle = poolParkedRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vehicle not found with ID: " + id));
        vehicle.setStatus("Pending with Transport department");
        poolParkedRepository.save(vehicle);
    }
    
    public void updateProcessCode(Long vehicleId, Long processCode) {
        Optional<PoolParked> optionalVehicle = poolParkedRepository.findById(vehicleId);
        if (optionalVehicle.isPresent()) {
            PoolParked vehicle = optionalVehicle.get();
            vehicle.setProcessCode(processCode);
            poolParkedRepository.save(vehicle);
        }
    }




    // Update existing vehicle
    public PoolParked updateVehicle(Long id, PoolParked updatedVehicle) {
        Optional<PoolParked> optionalVehicle = poolParkedRepository.findById(id);
        if (optionalVehicle.isPresent()) {
            PoolParked existingVehicle = optionalVehicle.get();

            existingVehicle.setDepartmentId(updatedVehicle.getDepartmentId());
            existingVehicle.setVehicleTypeId(updatedVehicle.getVehicleTypeId());
            existingVehicle.setManufacturerId(updatedVehicle.getManufacturerId());
            existingVehicle.setModel(updatedVehicle.getModel());
            existingVehicle.setRegistrationNo(updatedVehicle.getRegistrationNo());
            existingVehicle.setChassisNo(updatedVehicle.getChassisNo());
            existingVehicle.setEngineNo(updatedVehicle.getEngineNo());
            existingVehicle.setPurchaseDate(updatedVehicle.getPurchaseDate());
            existingVehicle.setDateOfManufacturing(updatedVehicle.getDateOfManufacturing());
            existingVehicle.setPurchaseCost(updatedVehicle.getPurchaseCost());
            existingVehicle.setVehicleDescription(updatedVehicle.getVehicleDescription());
            existingVehicle.setUpdatedAt(LocalDateTime.now());

            return poolParkedRepository.save(existingVehicle);
        } else {
            throw new RuntimeException("Vehicle not found with ID: " + id);
        }
    }
}
