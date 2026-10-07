package dev.chainguard.jjwtbypass;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwt;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

/**
 * Encodes the secure expectation for CGP-xpq5-jm7p-884r: a token whose
 * signature has been stripped must be rejected when a signing key is
 * configured. The test fails against the vulnerable jjwt 0.7.0, which accepts
 * the forged token, and passes against the remediated 0.7.0-0.cgr.1 build.
 */
class JwtBypassTest {

    private static final String KEY =
        Base64.getEncoder().encodeToString(
            "demo-secret-key-that-is-long-enough".getBytes(StandardCharsets.UTF_8));

    @Test
    void forgedUnsignedTokenIsRejected() {
        // header.payload. with the signature stripped: {"alg":"none"}/{"sub":"admin"}
        String forged = b64("{\"alg\":\"none\"}") + "." + b64("{\"sub\":\"admin\"}") + ".";

        assertThrows(JwtException.class,
            () -> Jwts.parser().setSigningKey(KEY).parse(forged),
            "A token with no signature must be rejected when a key is configured");
    }

    @Test
    void validSignedTokenIsAccepted() {
        String signed = Jwts.builder()
            .setSubject("alice")
            .signWith(SignatureAlgorithm.HS256, KEY)
            .compact();

        Jwt<?, ?> jwt = Jwts.parser().setSigningKey(KEY).parse(signed);
        Claims claims = (Claims) jwt.getBody();

        assertEquals("alice", claims.getSubject());
    }

    private static String b64(String json) {
        return Base64.getUrlEncoder().withoutPadding()
            .encodeToString(json.getBytes(StandardCharsets.UTF_8));
    }
}
