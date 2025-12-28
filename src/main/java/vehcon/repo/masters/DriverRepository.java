package vehcon.repo.masters;

import org.springframework.data.jpa.repository.JpaRepository;
import vehcon.models.masters.Driver;

public interface DriverRepository extends JpaRepository<Driver, Long> {
}
