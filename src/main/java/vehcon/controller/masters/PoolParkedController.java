package vehcon.controller.masters;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vehcon.models.auth.User;
import vehcon.models.masters.PoolParked;
import vehcon.services.masters.PoolParkedService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/poolparked")
@CrossOrigin(origins = "*")
public class PoolParkedController {

    private final PoolParkedService poolParkedService;

    public PoolParkedController(PoolParkedService poolParkedService) {
        this.poolParkedService = poolParkedService;
    }

    // ✅ Get all vehicles (SAD roles only)
    @GetMapping("/all")
    public ResponseEntity<List<PoolParked>> getAllVehicles() {
        List<PoolParked> vehicles = poolParkedService.getAllVehicles();
        return ResponseEntity.ok(vehicles);
    }

    // ✅ Get unallotted vehicles ((process code = 17)
    @GetMapping("/unallotted")
    public ResponseEntity<List<PoolParked>> getUnallottedVehicles() {
        return ResponseEntity.ok(poolParkedService.getUnallottedVehicles());
    }

    // ✅ Get allotted vehicles (process code = 18)
    @GetMapping("/allotted")
    public ResponseEntity<List<PoolParked>> getAllottedVehicles() {
        return ResponseEntity.ok(poolParkedService.getAllottedVehicles());
    }

    // ✅ Add a new vehicle
    @PostMapping("/add")
    public ResponseEntity<?> addVehicle(@RequestBody PoolParked vehicle) {
        try {
            PoolParked savedVehicle = poolParkedService.addVehicle(vehicle);
            return ResponseEntity.ok(savedVehicle);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Please fill all required fields", "details", e.getMessage()));
        }
    }

    // ✅ Update vehicle info
    @PutMapping("/{id}")
    public ResponseEntity<?> updateVehicle(@PathVariable Long id, @RequestBody PoolParked vehicle) {
        try {
            PoolParked updatedVehicle = poolParkedService.updateVehicle(id, vehicle);
            return ResponseEntity.ok(updatedVehicle);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "Failed to update vehicle", "details", e.getMessage()));
        }
    }

    // ✅ Discard vehicle (sets processCode = -4)
    @PutMapping("/{id}/discard")
    public ResponseEntity<?> discardVehicle(@PathVariable Long id) {
        try {
            PoolParked discardedVehicle = poolParkedService.discardVehicle(id, -4L);
            return ResponseEntity.ok(discardedVehicle);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "Failed to discard vehicle", "details", e.getMessage()));
        }
    }

    // ✅ Fetch vehicles for logged-in user's department
    @GetMapping("/my-department")
    public ResponseEntity<?> getVehiclesForLoggedInDepartment(Authentication authentication) {
        try {
            User user = (User) authentication.getPrincipal();

            // If SAD roles, return all vehicles
            if (user.getRole() != null &&
                (user.getRole().name().equalsIgnoreCase("SAD1") ||
                 user.getRole().name().equalsIgnoreCase("SAD2"))) {
                return ResponseEntity.ok(poolParkedService.getAllVehicles());
            }

            if (user.getDepartment() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("error", "User is not assigned to any department"));
            }

            // ✅ Convert Integer to Long safely
            Long departmentId = user.getDepartment().getDepartmentCode().longValue();

            List<PoolParked> vehicles = poolParkedService.getVehiclesByDepartment(departmentId);
            return ResponseEntity.ok(vehicles);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to fetch vehicles", "details", e.getMessage()));
        }
    }

    // ✅ Allot vehicle to department
    @PostMapping("/allot")
    public ResponseEntity<?> allotVehicle(@RequestBody Map<String, Object> requestData) {
        try {
            Long vehicleId = Long.parseLong(requestData.get("vehicleId").toString());
            Long departmentId = Long.parseLong(requestData.get("departmentId").toString());

            boolean success = poolParkedService.allotVehicle(vehicleId, departmentId);
            if (success) {
                return ResponseEntity.ok("Vehicle allotted successfully");
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to allot vehicle");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error allotting vehicle: " + e.getMessage());
        }
    }
}
