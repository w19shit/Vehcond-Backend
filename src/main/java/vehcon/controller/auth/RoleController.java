package vehcon.controller.auth;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import vehcon.dto.auth.RolesDTO;
import vehcon.exception.UnauthorizedException;
import vehcon.models.auth.Roles;
import vehcon.models.auth.User;
import vehcon.services.auth.RolesService;

@RestController
@RequestMapping("/role")
@RequiredArgsConstructor
public class RoleController {
	
	private final RolesService roleService;
	
	@GetMapping
	public List<Roles> getRolesForSelection()
	{
		try
		{
			return roleService.getRoles();
		}
		catch(UnauthorizedException ex)
		{
			throw ex;
		}
		catch(Exception e)
		{
			throw e;
		}
	}
	
	@GetMapping("/list")
	public ResponseEntity<Page<Roles>> getAllRoles(
			@RequestParam(name = "search", required = false) String searchTerm,
			Pageable pageable,
			@AuthenticationPrincipal User user
			)
	{
		
		try
		{
			Page<Roles> role = roleService.getAllRoles(searchTerm, pageable);
			return ResponseEntity.ok(role);
		}
		catch(Exception e)
		{
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
					.body(null);
		}
	}
	
	@PostMapping("/add-role")
	public ResponseEntity<String> addRole(@RequestBody RolesDTO dto) {
	    try {
	        Roles savedRole = roleService.addRoles(dto);
	        return ResponseEntity
	                .status(HttpStatus.CREATED)
	                .body("Role '" + savedRole.getRole() + "' created successfully");
	    } catch (Exception e) {
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
	                .body("Failed to create role: " + e.getMessage());
	    }
	}
}
