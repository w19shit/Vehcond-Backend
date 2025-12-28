package vehcon.config;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Properties;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.fasterxml.jackson.databind.ObjectMapper;

import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import vehcon.services.appdata.CoreServices;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    private final UserDetailsService userDetailsService;

    @Autowired
    private final CoreServices coreServices;

    @Value("${config.vehcond}")
    private String configVehcond;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        // Allow CORS preflight (OPTIONS) to pass quickly
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        try {

            String path = request.getServletPath();

            // Allow authentication routes (login, refresh, logout, captcha) to be accessed
            // without requiring a Bearer token — API-Key is validated for these endpoints.
            if (path.startsWith("/auth/")) {
                filterChain.doFilter(request, response);
                return;
            }

            // Normal JWT processing
            final String authHeader = request.getHeader("Authorization");

            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                // No token provided; let security configuration decide access to endpoint
                filterChain.doFilter(request, response);
                return;
            }

            final String jwt = authHeader.substring(7);
            final String username = jwtService.extractUsername(jwt);

            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                String clientIp = coreServices.getClientIp(request);

                if (jwtService.isTokenValid(jwt, userDetails, clientIp)) {

                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities()
                            );

                    authToken.setDetails(
                            new WebAuthenticationDetailsSource().buildDetails(request)
                    );

                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }

            filterChain.doFilter(request, response);

        } catch (ExpiredJwtException e) {

            response.resetBuffer();
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setHeader(HttpHeaders.CONTENT_TYPE, "application/json");

            HashMap<String, String> map = new HashMap<>();
            map.put("message", "JWT token has expired");

            response.getOutputStream().print(new ObjectMapper().writeValueAsString(map));
            response.flushBuffer();
        }
    }

    private String loadConfig() {
        try {
            Path path = Paths.get(configVehcond);
            Properties properties = new Properties();
            properties.load(Files.newBufferedReader(path));
            return properties.getProperty("API_KEY");
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }
}
