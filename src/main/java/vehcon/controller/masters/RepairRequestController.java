package vehcon.controller.masters;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import vehcon.repo.masters.RepairRequestRepository;


import vehcon.models.masters.Departments;
import vehcon.models.masters.RepairRequest;
import vehcon.services.masters.RepairRequestService;
import vehcon.services.masters.PoolParkedService;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/repairrequest")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class RepairRequestController {

    private final RepairRequestService repairRequestService;
    private final PoolParkedService poolParkedService;
    private final RepairRequestRepository repairRequestRepository;


    // =====================================================================================
    // 1. 🔹 Create new Repair Request WITH MULTIPLE PROBLEMS
    // =====================================================================================
    @PostMapping("/add")
    public ResponseEntity<?> addRepairRequest(@RequestBody Map<String, Object> data) {
        try {
            Long vehicleId = data.get("vehicleId") != null
                    ? Long.parseLong(data.get("vehicleId").toString())
                    : null;

            Long departmentId = data.get("departmentId") != null
                    ? Long.parseLong(data.get("departmentId").toString())
                    : null;

            if (vehicleId == null || departmentId == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "vehicleId or departmentId missing"));
            }

            // 🔥 MULTIPLE PROBLEMS
            List<String> problems = (List<String>) data.get("problems");
            if (problems == null || problems.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Problems list cannot be empty"));
            }

            String location = (String) data.getOrDefault("location", "");
            String urgency = (String) data.getOrDefault("urgency", "");
            Integer kilometerReading = data.get("kilometerReading") != null
                    ? Integer.parseInt(data.get("kilometerReading").toString())
                    : null;

            String lastServiceDateStr = (String) data.getOrDefault("lastServiceDate", null);
            LocalDate lastServiceDate = lastServiceDateStr != null && !lastServiceDateStr.isBlank()
                    ? LocalDate.parse(lastServiceDateStr)
                    : null;

            Departments dept = new Departments();
            dept.setDepartmentCode(departmentId.intValue());

            RepairRequest request = RepairRequest.builder()
                    .vehicleId(vehicleId)
                    .department(dept)
                    .kilometerReading(kilometerReading)
                    .lastServiceDate(lastServiceDate)
                    .location(location)
                    .urgency(urgency)
                    .status("Pending with SAD2")
                    .processCode(20L)
                    .build();

            // 🔥 Save parent + children
            RepairRequest saved = repairRequestService.addRepairRequest(request, problems);
            poolParkedService.updateProcessCode(vehicleId, 20L);

            return ResponseEntity.ok(Map.of(
                    "message", "Repair request created successfully",
                    "data", saved
            ));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

	 // =====================================================================================
	 // 9. 🔹 ALL Vehicle Repair History (Transport)
	 // =====================================================================================
	 @GetMapping("/vehicle/history")
	 public ResponseEntity<?> getAllVehicleRepairHistory() {
	     try {
	         List<RepairRequest> history =
	                 repairRequestRepository.findByTdApprovedTrueOrderByTdApprovedDateDesc();
	
	         return ResponseEntity.ok(history);
	
	     } catch (Exception e) {
	         return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
	     }
	 }
	 
	 
	//=====================================================================================
	//🔟 Send Vehicle Back to Department (Repair Completed)
	//=====================================================================================
	@PutMapping("/{id}/send-back-to-department")
	public ResponseEntity<?> sendBackToDepartment(@PathVariable Long id) {
	  try {
	      RepairRequest updated = repairRequestService.sendBackToDepartment(id);
	      return ResponseEntity.ok(Map.of(
	              "message", "Vehicle sent back to department",
	              "data", updated
	      ));
	  } catch (Exception e) {
	      return ResponseEntity.badRequest().body(Map.of(
	              "error", e.getMessage()
	      ));
	  }
	}

    // =====================================================================================
    // 2. 🔹 Get by status
    // =====================================================================================
    @GetMapping("/status/{status}")
    public ResponseEntity<?> getByStatus(@PathVariable String status) {
        try {
            return ResponseEntity.ok(repairRequestService.getByStatus(status));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    // =====================================================================================
    // 3. 🔹 SAD2 → Send for Estimate
    // =====================================================================================
    @PutMapping("/{id}/send-for-estimate")
    public ResponseEntity<?> sendForEstimate(@PathVariable Long id) {
        try {
            RepairRequest updated = repairRequestService.updateStatus(id, "Pending with Transport", 19L);
            return ResponseEntity.ok(Map.of(
                    "message", "Sent to Transport Department",
                    "data", updated
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =====================================================================================
    // 4. 🔹 NEW → Update ALL Problems Estimate for a Request (OPTION 2 ✔)
    // =====================================================================================
    @PutMapping("/{id}/estimate")
    public ResponseEntity<?> updateAllEstimates(
            @PathVariable Long id,
            @RequestBody Map<String, Object> payload
    ) {
        try {
            List<Map<String, Object>> problems =
                    (List<Map<String, Object>>) payload.get("problems");

            if (problems == null || problems.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Problems list is empty"));
            }

            RepairRequest updated = repairRequestService.updateAllProblemEstimates(id, problems);

            return ResponseEntity.ok(Map.of(
                    "message", "All problem estimates updated successfully",
                    "data", updated
            ));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // =====================================================================================
    // 5. 🔹 Get all problems for a request
    // =====================================================================================
    @GetMapping("/{id}/problems")
    public ResponseEntity<?> getProblems(@PathVariable Long id) {
        return ResponseEntity.ok(repairRequestService.getProblems(id));
    }

    // =====================================================================================
    // 6. 🔹 Latest Status for Dashboard
    // =====================================================================================
    @GetMapping("/latest-status")
    public ResponseEntity<?> getLatestRepairStatus() {
        return ResponseEntity.ok(repairRequestService.getLatestRepairStatusDetailed());
    }

    // =====================================================================================
    // 7. 🔹 File Uploads
    // =====================================================================================
    @PutMapping("/{id}/upload-approval")
    public ResponseEntity<?> uploadApproval(@PathVariable Long id, @RequestParam("file") MultipartFile file) {
        try {
            return ResponseEntity.ok(Map.of(
                    "message", "Approval uploaded",
                    "data", repairRequestService.uploadApprovalOrder(id, file)
            ));
        } catch (IOException e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}/upload-workorder")
    public ResponseEntity<?> uploadWorkOrder(@PathVariable Long id, @RequestParam("file") MultipartFile file) {
        try {
            return ResponseEntity.ok(Map.of(
                    "message", "Work order uploaded",
                    "data", repairRequestService.uploadWorkOrder(id, file)
            ));
        } catch (IOException e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}/upload-sanction")
    public ResponseEntity<?> uploadSanction(@PathVariable Long id, @RequestParam("file") MultipartFile file) {
        try {
            return ResponseEntity.ok(Map.of(
                    "message", "Sanction uploaded",
                    "data", repairRequestService.uploadSanctionOrder(id, file)
            ));
        } catch (IOException e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }
}
