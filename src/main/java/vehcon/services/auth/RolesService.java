package vehcon.services.auth;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import vehcon.common.data.util.SpecificationUtils;
import vehcon.dto.auth.RolesDTO;
import vehcon.models.auth.Roles;
import vehcon.repo.auth.RolesRepository;

@Service
@RequiredArgsConstructor
public class RolesService {

    private final RolesRepository roleRepo;

    public List<Roles> getRoles() {
        return roleRepo.findAll();
    }

    public Page<Roles> getAllRoles(String searchTerm, Pageable pageable) {
        Specification<Roles> spec = Specification.where(null);

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            List<String> fields = List.of("rolecode", "role", "description");
            Specification<Roles> searchSpec = SpecificationUtils.searchInFields(searchTerm, fields);
            if (searchSpec != null) spec = spec.and(searchSpec);
        }

        return roleRepo.findAll(spec, pageable);
    }

    public Roles addRoles(RolesDTO dto) {
        Roles role = new Roles();
        role.setRole(dto.getRole());                 // matches DTO
        role.setDescription(dto.getDescription());
        return roleRepo.save(role);                  // persist
    }
}
