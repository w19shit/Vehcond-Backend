package vehcon.services.auth;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.EncodedKeySpec;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.Calendar;
import java.util.Date;
import java.util.Optional;

import javax.crypto.Cipher;

import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import vehcon.annotations.Auditable;
import vehcon.config.JwtService;
import vehcon.dto.auth.AuthenticationRequest;
import vehcon.dto.auth.AuthenticationResponse;
import vehcon.dto.auth.RegisterRequest;
import vehcon.exception.InternalServerError;
import vehcon.exception.ObjectNotFoundException;
import vehcon.exception.UnauthorizedException;
import vehcon.logs.Login;
import vehcon.logs.LoginRepository;
import vehcon.models.auth.PasswordResetToken;
import vehcon.models.auth.Role;
import vehcon.models.auth.Roles;
import vehcon.models.auth.User;
import vehcon.models.masters.Departments;
import vehcon.repo.auth.PasswordTokenRepository;
import vehcon.repo.auth.RolesRepository;
import vehcon.repo.auth.UserRepository;
import vehcon.repo.masters.DepartmentsRepository;
import vehcon.services.appdata.CoreServices;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final CoreServices coreServices;
    private final PasswordTokenRepository passwordTokenRepo;
    private final LoginRepository loginRepo;
    private final RolesRepository rolesRepo;
    private final DepartmentsRepository deptRepo;

    @Value("${keys.dir}")
    private String keysDir;


    // ----------------- REGISTER ---------------------

    @Auditable
    @Transactional
    public User register(RegisterRequest request) {

        Optional<User> existingUser = userRepo.findByUsername(request.getUsername());
        if (existingUser.isPresent())
            throw new InternalServerError("Username already registered");

        Departments department = deptRepo.findById(request.getDepartmentCode())
                .orElseThrow(() -> new ObjectNotFoundException("Invalid department code"));

        Role role = Role.valueOf(request.getRole().toString().toUpperCase());
        String pw = request.getPassword(); // Already encrypted outside

        var user = User.builder()
                .name(request.getName())
                .department(department)
                .username(request.getUsername())
                .password(passwordEncoder.encode(pw))
                .role(role)
                .userAccess(true)
                .build();

        userRepo.save(user);
        return user;
    }



    // ----------------- AUTHENTICATE (ONLY ONE NOW) ---------------------

    @Auditable
    public AuthenticationResponse authenticate(AuthenticationRequest request,
                                               HttpServletRequest httpRequest,
                                               HttpServletResponse response)
            throws IOException {

        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getUsername(),
                            decryptPassword(request.getPassword())
                    )
            );
        } catch (BadCredentialsException | UsernameNotFoundException e) {
            throw new UnauthorizedException("Incorrect username or password");
        } catch (DisabledException e) {
            throw new UnauthorizedException("Account is disabled");
        } catch (Exception e) {
            throw new UnauthorizedException("Incorrect username or password");
        }

        var user = userRepo.findByUsername(request.getUsername())
                .orElseThrow(() -> new ObjectNotFoundException("User not found"));

        var jwtToken = jwtService.generateToken(user);
        var refreshToken = jwtService.generateRefreshToken(user);

        Login login = Login.builder()
                .username(user.getUsername())
                .uri(httpRequest.getRequestURI())
                .httpMethod(httpRequest.getMethod())
                .ts(new Date())
                .httpStatus(response.getStatus())
                .build();
        loginRepo.save(login);

        MDC.put("username", user.getUsername());
        log.info("Login");
        MDC.remove("username");

        return AuthenticationResponse.builder()
                .accessToken(jwtToken)
                .refreshToken(refreshToken)
                .role(user.getRole().toString())
                .roleCode(getRoleCode(user.getRole().toString()))
                .build();
    }



    // ----------------- PASSWORD DECRYPTION ---------------------

    public String decryptPassword(String encryptedPassword) {
        try {
            Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPWITHSHA-512ANDMGF1PADDING");
            File privateKeyFile = new File(keysDir + "//private.key");
            byte[] privateKeyBytes = Files.readAllBytes(privateKeyFile.toPath());
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            PKCS8EncodedKeySpec privateKeySpec = new PKCS8EncodedKeySpec(privateKeyBytes);
            PrivateKey privateKey = keyFactory.generatePrivate(privateKeySpec);

            cipher.init(Cipher.DECRYPT_MODE, privateKey);
            byte[] decrypt = cipher.doFinal(Base64.getDecoder().decode(encryptedPassword));

            return new String(decrypt);
        } catch (Exception e) {
            throw new InternalServerError("Failed to decrypt password", e);
        }
    }



    // ----------------- JWT TOKEN REFRESH ---------------------

    @Transactional
    public void refreshToken(HttpServletRequest request, HttpServletResponse response) throws IOException {

        final String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer "))
            return;

        String refreshToken = authHeader.substring(7);
        String userEmail = jwtService.extractUsername(refreshToken);

        if (userEmail != null) {

            var user = userRepo.findByUsername(userEmail)
                    .orElseThrow(() -> new ObjectNotFoundException("User not found"));

            if (jwtService.isTokenValid(refreshToken, user, coreServices.getClientIp(request))) {

                var accessToken = jwtService.generateToken(user);
                jwtService.invalidateRefreshToken(refreshToken);

                var authResponse = AuthenticationResponse.builder()
                        .accessToken(accessToken)
                        .refreshToken(jwtService.generateRefreshToken(user))
                        .role(user.getRole().toString())
                        .build();

                new ObjectMapper().writeValue(response.getOutputStream(), authResponse);

            } else
                throw new UnauthorizedException("Invalidated Token");
        }
    }



    // ----------------- PUBLIC KEY / RSA ---------------------

    private void createKeys() {
        try {
            Files.createDirectories(Paths.get(keysDir).toAbsolutePath().normalize());

            KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
            keyPairGenerator.initialize(2048);
            KeyPair keyPair = keyPairGenerator.generateKeyPair();

            try (FileOutputStream fos = new FileOutputStream(keysDir + "//public.key")) {
                fos.write(keyPair.getPublic().getEncoded());
            }
            try (FileOutputStream fos = new FileOutputStream(keysDir + "//private.key")) {
                fos.write(keyPair.getPrivate().getEncoded());
            }

        } catch (Exception e) {
            throw new InternalServerError("Failed to generate Key Pair for encryption", e);
        }
    }

    public String getPublicKey()
            throws IOException, InvalidKeySpecException, NoSuchAlgorithmException {

        File publicKeyFile = new File(keysDir + "//public.key");
        byte[] publicKeyBytes;

        if (publicKeyFile.exists() && !publicKeyFile.isDirectory()) {
            publicKeyBytes = Files.readAllBytes(publicKeyFile.toPath());
        } else {
            createKeys();
            publicKeyBytes = Files.readAllBytes(publicKeyFile.toPath());
        }

        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        EncodedKeySpec publicKeySpec = new X509EncodedKeySpec(publicKeyBytes);
        PublicKey publicKey = keyFactory.generatePublic(publicKeySpec);

        return Base64.getEncoder().encodeToString(publicKey.getEncoded());
    }



    // ----------------- PASSWORD RESET TOKEN ---------------------

    public String validatePasswordResetToken(String token) {
        Optional<PasswordResetToken> passToken = passwordTokenRepo.findByToken(token);

        if (passToken.isEmpty())
            return "invalidToken";
        else if (isTokenExpired(passToken.get()))
            return "expired";
        else {
            passwordTokenRepo.deleteById(passToken.get().getId());
            return null;
        }
    }

    private boolean isTokenExpired(PasswordResetToken passToken) {
        final Calendar cal = Calendar.getInstance();
        return passToken.expiry.before(cal.getTime());
    }


    // ----------------- HELPERS ---------------------

    private Integer getRoleCode(String role) {
        Roles role1 = rolesRepo.findByRole(role).orElseThrow();
        return role1.getRolecode();
    }
}
