package vehcon.services.masters;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import vehcon.models.masters.RepairRequest;
import vehcon.models.masters.RepairRequestProblem;

import vehcon.repo.masters.RepairRequestRepository;
import vehcon.repo.masters.RepairRequestProblemRepository;
import vehcon.repo.masters.PoolParkedRepository;

import java.util.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class RepairRequestService {

    private final RepairRequestRepository repo;
    private final RepairRequestProblemRepository problemRepo;
    private final PoolParkedRepository poolParkedRepository;

    private static final String UPLOAD_DIR =
            "C:/Users/Wamesambiang laloo/Documents/Vehcond-Backend/uploads/";

    // ======================================================================================
    // 1️⃣ ADD REPAIR REQUEST (DEPARTMENT SIDE)
    // ======================================================================================
    public RepairRequest addRepairRequest(RepairRequest request, List<String> problems) {

        if (request.getProcessCode() == null) request.setProcessCode(20L);
        if (request.getStatus() == null || request.getStatus().isEmpty())
            request.setStatus("Pending with SAD2");

        updateVehicleStatus(request.getVehicleId(), "Pending with SAD2");

        // Create child problems
        List<RepairRequestProblem> childList = new ArrayList<>();

        for (String text : problems) {
            RepairRequestProblem p = new RepairRequestProblem();
            p.setProblemText(text);
            p.setRepairRequest(request);
            childList.add(p);
        }

        request.setProblems(childList);
        return repo.save(request);
    }

 // ======================================================================================
 // 🔟 SEND BACK TO DEPARTMENT (Repair Completed)
 // ======================================================================================
 public RepairRequest sendBackToDepartment(Long requestId) {

     RepairRequest req = repo.findById(requestId)
             .orElseThrow(() -> new RuntimeException("Repair request not found"));

     // Finalize repair
     req.setStatus("Running");
     req.setProcessCode(18L);

     // Update vehicle master status
     updateVehicleStatus(req.getVehicleId(), "Running");

     return repo.save(req);
 }

    // ======================================================================================
    // 2️⃣ FETCH BY STATUS
    // ======================================================================================
    public List<RepairRequest> getByStatus(String status) {
        return repo.findByStatusWithVehicle(status.trim());
    }

    // ======================================================================================
    // 3️⃣ UPDATE OVERALL STATUS
    // ======================================================================================
    public RepairRequest updateStatus(Long id, String status, Long processCode) {

        RepairRequest req = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Repair Request not found"));

        req.setStatus(status);
        req.setProcessCode(processCode);

        updateVehicleStatus(req.getVehicleId(), status);
        return repo.save(req);
    }

    // ======================================================================================
    // 4️⃣ UPDATE ALL PROBLEM ESTIMATES (OPTION 2 ✔)
    // ======================================================================================
    public RepairRequest updateAllProblemEstimates(
            Long requestId,
            List<Map<String, Object>> problemsPayload) {

        RepairRequest request = repo.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Repair request not found"));

        double totalEstimate = 0.0;

        for (Map<String, Object> map : problemsPayload) {

            Long pid = Long.valueOf(map.get("id").toString());
            Double amount = map.get("estimateAmount") != null
                    ? Double.valueOf(map.get("estimateAmount").toString())
                    : 0.0;

            String remark = map.get("remark") != null
                    ? map.get("remark").toString()
                    : "";

            RepairRequestProblem problem = problemRepo.findById(pid)
                    .orElseThrow(() -> new RuntimeException("Problem not found: " + pid));

            problem.setEstimateAmount(amount);
            problem.setRemark(remark);
            problemRepo.save(problem);

            totalEstimate += amount;
        }

        // Update parent
        request.setEstimateAmount(totalEstimate);

        // TD approval happens HERE
        request.setStatus("Repair Estimated");
        request.setProcessCode(21L);
        request.setTdApproved(true);
        request.setTdApprovedDate(LocalDate.now());

        updateVehicleStatus(request.getVehicleId(), "Repair Estimated");

        return repo.save(request);
    }
    // ======================================================================================
    // 5️⃣ GET ALL PROBLEMS FOR A REQUEST
    // ======================================================================================
    public List<RepairRequestProblem> getProblems(Long requestId) {

        // Ensure parent exists (optional but safe)
        if (!repo.existsById(requestId)) {
            throw new RuntimeException("Request not found");
        }

        // ✅ CORRECT: fetch from repair_request_problems table
        return problemRepo.findByRequestId(requestId);
    }

    // ======================================================================================
    // 6️⃣ LATEST STATUS (dashboard)
    // ======================================================================================
    public Map<Long, Map<String, Object>> getLatestRepairStatusDetailed() {

        List<Object[]> rows = repo.findLatestStatusForAllVehicles();
        Map<Long, Map<String, Object>> result = new HashMap<>();

        for (Object[] row : rows) {

            Long vehicleId = ((Number) row[0]).longValue();
            String status = row[1] != null ? row[1].toString() : "Running";
            String approval = row[2] != null ? row[2].toString() : null;
            String work = row[3] != null ? row[3].toString() : null;
            String sanction = row[4] != null ? row[4].toString() : null;

            Map<String, Object> info = new HashMap<>();
            info.put("status", status);
            info.put("approvalOrderFile", approval);
            info.put("workOrderFile", work);
            info.put("sanctionOrderFile", sanction);

            result.put(vehicleId, info);
        }

        return result;
    }

    // ======================================================================================
    // 7️⃣ FILE UPLOADS
    // ======================================================================================
    public RepairRequest uploadApprovalOrder(Long id, MultipartFile file) throws IOException {

        RepairRequest req = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Repair request not found"));

        String fileName = saveFile(file);

        req.setApprovalOrderFile(fileName);
        req.setStatus("Approval Order Uploaded");
        req.setProcessCode(22L);

        updateVehicleStatus(req.getVehicleId(), "Approval Order Uploaded");
        return repo.save(req);
    }

    public RepairRequest uploadWorkOrder(Long id, MultipartFile file) throws IOException {

        RepairRequest req = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Repair request not found"));

        String fileName = saveFile(file);

        req.setWorkOrderFile(fileName);
        req.setStatus("Work Order Uploaded");
        req.setProcessCode(23L);

        updateVehicleStatus(req.getVehicleId(), "Work Order Uploaded");
        return repo.save(req);
    }

    public RepairRequest uploadSanctionOrder(Long id, MultipartFile file) throws IOException {

        RepairRequest req = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Repair request not found"));

        String fileName = saveFile(file);

        req.setSanctionOrderFile(fileName);
        req.setStatus("Approved for Repair");
        req.setProcessCode(24L);

        updateVehicleStatus(req.getVehicleId(), "Approved for Repair");
        return repo.save(req);
    }

    // ======================================================================================
    // 8️⃣ Update Vehicle Status
    // ======================================================================================
    private void updateVehicleStatus(Long vehicleId, String status) {

        poolParkedRepository.findById(vehicleId).ifPresent(vehicle -> {
            vehicle.setStatus(status);
            poolParkedRepository.save(vehicle);
        });
    }

    // ======================================================================================
    // 9️⃣ Save PDF File
    // ======================================================================================
    private String saveFile(MultipartFile file) throws IOException {

        File folder = new File(UPLOAD_DIR);
        if (!folder.exists()) folder.mkdirs();

        String original = file.getOriginalFilename();
        String ext = original != null && original.contains(".")
                ? original.substring(original.lastIndexOf(".") + 1).toLowerCase()
                : "";

        byte[] bytes = file.getBytes();
        boolean isPdf = bytes.length > 4 &&
                bytes[0] == 0x25 && bytes[1] == 0x50 &&
                bytes[2] == 0x44 && bytes[3] == 0x46;

        if (!"pdf".equals(ext) || !isPdf)
            throw new IOException("Only real PDF files allowed");

        if (file.getSize() > 3 * 1024 * 1024)
            throw new IOException("File too large (max 3MB)");

        String fileName = UUID.randomUUID() + "_" + original;
        Path path = Paths.get(UPLOAD_DIR, fileName);
        Files.write(path, bytes);

        return fileName;
    }
}
