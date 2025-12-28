package vehcon.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // serve files from the filesystem 'uploads' folder
        registry.addResourceHandler("/uploads/**")
        		.addResourceLocations("file:///C:/Users/Wamesambiang laloo/Documents/Vehcond-Backend/uploads/");
    }
}
