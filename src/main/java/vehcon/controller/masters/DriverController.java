package vehcon.controller.masters;

import org.springframework.web.bind.annotation.*;
import vehcon.models.masters.Driver;
import vehcon.services.masters.DriverService;

import java.util.List;

@RestController
@RequestMapping("/driverss")
public class DriverController {

    private final DriverService driverService;

    public DriverController(DriverService driverService) {
        this.driverService = driverService;
    }

    @GetMapping
    public List<Driver> getAllDrivers() {
        return driverService.getAllDrivers();
    }

    @PostMapping
    public Driver createDriver(@RequestBody Driver driver) {
        return driverService.saveDriver(driver);
    }
}
