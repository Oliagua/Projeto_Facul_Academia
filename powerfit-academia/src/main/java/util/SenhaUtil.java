package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/** Senha no mesmo formato do app: "salt:hash", com hash = SHA-256(salt + senha). */
public final class SenhaUtil {
    private static final SecureRandom ALEATORIO = new SecureRandom();

    private SenhaUtil() { }

    public static String gerar(String senha) {
        byte[] bytes = new byte[16];
        ALEATORIO.nextBytes(bytes);
        String salt = Base64.getUrlEncoder().encodeToString(bytes);
        return salt + ":" + hash(senha, salt);
    }

    public static boolean confere(String senhaDigitada, String armazenado) {
        if (senhaDigitada == null || armazenado == null) return false;
        int separador = armazenado.indexOf(':');
        if (separador <= 0) return false;
        String salt = armazenado.substring(0, separador);
        String esperado = armazenado.substring(separador + 1);
        return MessageDigest.isEqual(
                hash(senhaDigitada, salt).getBytes(StandardCharsets.UTF_8),
                esperado.getBytes(StandardCharsets.UTF_8));
    }

    static String hash(String senha, String salt) {
        try {
            byte[] resumo = MessageDigest.getInstance("SHA-256")
                    .digest((salt + senha).getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : resumo) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 indisponível", e);
        }
    }
}
