package vehcon.config;

import static org.springframework.http.HttpMethod.GET;
import static org.springframework.http.HttpMethod.POST;
import static org.springframework.http.HttpMethod.PUT;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

import lombok.RequiredArgsConstructor;
import vehcon.services.auth.LogoutService;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final AuthenticationProvider authenticationProvider;

    @Autowired
    private final LogoutService logoutService;

    @Autowired
    private Environment env;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http.csrf(csrf -> csrf.disable());

        http.authorizeHttpRequests(auth -> auth

            // Allow public auth endpoints (both with and without context prefix)
            .requestMatchers(
                "/auth/**",
                "/vehcond/auth/**",
                "/uploads/**"
            ).permitAll()

            // Role-based GET access for all /vehcond/** GET requests
            .requestMatchers(GET, "/vehcond/**",
            		"/users/profile",
        	        "/users/list/enabled",
        	        "/users/list/disabled",
        	        "/users/get-user-info",
        	        "/driverss",
        	        "/menu",
        	        "/districts/**",
        	        "/financial-year/**",
        	        "/district-rto/**",
        	        "/vehicle-type/**",
        	        "/vehicle-manufacturer/**",
        	        "/department/**",
        	        "/poolparked/**",
        	        "/repairrequest/**",
        	        "/vehicle-parts/**",
        	        "/processes/**",
        	        "/draft/**",
        	        "/final-submit/**",
        	        "/transport-review/**",
        	        "/transport-placement/**",
        	        "/transport-price-fixation/**",
        	        "/transport-action/**",
        	        "/transport-allotment/**",
        	        "/transport-lifting/**",
        	        "/role/**",
        	        "/pageUrl/**",
        	        "/reports/**",
        	        "/dates/**",
        	        "/assigned-pages/**")
            .hasAnyAuthority("ADMIN", "DA", "TD", "SAD1", "SAD2")

            // Role-based PUT access for /vehcond/** (adjust if you want more granular lists)
            .requestMatchers(PUT, "/vehcond/**", "/poolparked/**", "/repairrequest/**")
            .hasAnyAuthority("TD", "SAD1", "SAD2", "DA")

            // Role-based POST access for /vehcond/** (adjust if you want more granular lists)
            .requestMatchers(POST, "/vehcond/**",
            		"/users/**",
        	        "/driverss",
        	        "/poolparked/**",
        	        "/repairrequest/**",
        	        "/department/**",
        	        "/vehicle-type/**",
        	        "/vehicle-manufacturer/**",
        	        "/draft/**",
        	        "/final-submit/**",
        	        "/processes/**",
        	        "/transport-review/**",
        	        "/transport-placement/**",
        	        "/transport-price-fixation/**",
        	        "/transport-action/**",
        	        "/transport-allotment/**",
        	        "/transport-lifting/**",
        	        "/role/**",
        	        "/assign-pages/**"
            )
            .hasAnyAuthority("ADMIN", "DA", "TD", "SAD1", "SAD2")

            // Everything else still requires authentication
            .anyRequest().authenticated()
        );

        // Stateless session (JWT)
        http.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        // Add authentication provider + JWT filter
        http.authenticationProvider(authenticationProvider);
        http.addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        // Logout — accept either /auth/logout or /vehcond/auth/logout (POST)
        // Frontend must call POST /auth/logout (baseURL likely includes /vehcond), so this matcher accepts both.
        http.logout(logout -> logout
            .logoutRequestMatcher(new AntPathRequestMatcher("/**/auth/logout", "POST"))
            .logoutSuccessHandler(logoutService)
            .invalidateHttpSession(true)
            .deleteCookies("JSESSIONID")
        );

        // CORS
        String urls = env.getProperty("cors.urls");
        http.cors(cors -> cors.configurationSource(req -> {
            CorsConfiguration cfg = new CorsConfiguration();
            cfg.setAllowedOrigins(List.of(urls == null ? "*" : urls));
            cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
            cfg.setAllowedHeaders(List.of(
                "Authorization",
                "Content-Type",
                "Accept",
                "X-Requested-With",
                "API-Key",
                "Cache-Control",
                "referrer-policy",
                "Referrer-Policy",
                "Referer",
                "Content-Length",
                "Upgrade-Insecure-Requests"
            ));
            cfg.setAllowCredentials(true);
            return cfg;
        }));

        return http.build();
    }
}
