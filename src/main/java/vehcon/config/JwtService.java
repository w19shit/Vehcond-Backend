package vehcon.config;

import java.security.Key;
import java.sql.Timestamp;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import vehcon.models.auth.Invalidate;
import vehcon.repo.auth.InvalidateRepository;

@Service
public class JwtService {

    @Value("${application.security.jwt.secret-key}")
    private String secretKey;

    @Value("${application.security.jwt.expiration}")
    private long jwtExpiration;

    @Value("${application.security.jwt.refresh-token.expiration}")
    private long refreshExpiration;

    private final InvalidateRepository invalidateRepo;

    public JwtService(InvalidateRepository invalidateRepository) {
        this.invalidateRepo = invalidateRepository;
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(), userDetails);
    }

    public String generateToken(Map<String, Object> extraClaims, UserDetails userDetails) {
        return buildToken(extraClaims, userDetails, jwtExpiration);
    }

    public String generateRefreshToken(UserDetails userDetails) {
        return buildToken(new HashMap<>(), userDetails, refreshExpiration);
    }

    private String buildToken(Map<String, Object> extraClaims, UserDetails userDetails, long expiration) {
        return Jwts.builder()
            .setClaims(extraClaims)
            .setSubject(userDetails.getUsername())
            .setIssuedAt(new Date(System.currentTimeMillis()))
            .setExpiration(new Date(System.currentTimeMillis() + expiration))
            .signWith(getSignInKey(), SignatureAlgorithm.HS256)
            .setHeaderParam("typ", "JWT")
            .compact();
    }

    /**
     * Token validation:
     * - username must match
     * - token not expired
     * - JWT algorithm must be HS256
     * - if there is an invalidate record for this username+ip, token.iat must be strictly AFTER invalidatedAt
     */
    public boolean isTokenValid(String token, UserDetails userDetails, String ipAddress) {

        final String username = extractUsername(token);

        // If token doesn't belong to the user -> invalid
        if (!username.equals(userDetails.getUsername())) {
            return false;
        }

        // token expiration check
        if (isTokenExpired(token)) {
            return false;
        }

        // algorithm check
        if (!isAlgorithmValid(token)) {
            return false;
        }

        // invalidation check: if there's an invalidation record for username+ip then token.iat must be AFTER it
        Optional<Invalidate> invalidation =
                invalidateRepo.findByUsernameAndIpAddressEquals(username, ipAddress);

        if (invalidation.isPresent()) {
            Timestamp invalidatedAt = invalidation.get().getInvalidatedAt();
            Timestamp tokenIat = new Timestamp(extractIat(token).getTime());

            // Strict requirement: token issued strictly after invalidation time
            if (!tokenIat.after(invalidatedAt)) {
                return false;
            }
        }

        // All checks passed
        return true;
    }

    private boolean isAlgorithmValid(String token) {
        SecretKey secret = Keys.hmacShaKeyFor(Decoders.BASE64.decode(secretKey));
        Jws<Claims> jws = Jwts.parserBuilder().setSigningKey(secret).build().parseClaimsJws(token);
        String algo = jws.getHeader().getAlgorithm();
        return "HS256".equals(algo);
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    private Date extractIat(String token) {
        return extractClaim(token, Claims::getIssuedAt);
    }

    Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(getSignInKey())
            .build()
            .parseClaimsJws(token)
            .getBody();
    }

    private Key getSignInKey() {
        byte[] keyByte = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyByte);
    }

    /**
     * Invalidate: keep current behaviour (username + ip). This sets invalidatedAt to now (or updates).
     * IMPORTANT: ensure the LogoutService calls this with the same ipAddress that the JWT filter uses
     * (i.e. coreServices.getClientIp(request)).
     */
    public void invalidateToken(String username, String ipAddress) {
        Optional<Invalidate> invalidUser = invalidateRepo.findByUsernameAndIpAddressEquals(username, ipAddress);
        if (invalidUser.isPresent()) {
            invalidUser.get().setInvalidatedAt(new Timestamp(System.currentTimeMillis()));
            invalidateRepo.save(invalidUser.get());
        } else {
            Invalidate invalidation = new Invalidate();
            invalidation.setUsername(username);
            invalidation.setInvalidatedAt(new Timestamp(System.currentTimeMillis()));
            invalidation.setIpAddress(ipAddress);
            invalidateRepo.save(invalidation);
        }
    }

    public void invalidateRefreshToken(String token) {
        Key key = getSignInKey();
        Claims claims = Jwts.parserBuilder()
            .setSigningKey(key)
            .build()
            .parseClaimsJws(token)
            .getBody();

        Date yesterday = new Date(System.currentTimeMillis() - 86400000);
        claims.setExpiration(yesterday);

        Jwts.builder().setClaims(claims).signWith(key, SignatureAlgorithm.HS256).compact();
    }
}
