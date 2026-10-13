package com.cs336.pkg;

import java.nio.charset.StandardCharsets;

import org.mindrot.jbcrypt.BCrypt;

public final class Passwords {
    /** bcrypt ignores everything after the first 72 bytes of input. */
    public static final int MAX_BYTES = 72;

    private Passwords() {
    }

    /** True when the password is non-empty and fits bcrypt's 72-byte input limit. */
    public static boolean isAcceptable(String plaintext) {
        return plaintext != null && !plaintext.isEmpty()
                && plaintext.getBytes(StandardCharsets.UTF_8).length <= MAX_BYTES;
    }

    public static String hash(String plaintext) {
        if (!isAcceptable(plaintext)) {
            throw new IllegalArgumentException("password must be 1 to " + MAX_BYTES + " bytes");
        }
        return BCrypt.hashpw(plaintext, BCrypt.gensalt());
    }

    public static boolean matches(String plaintext, String stored) {
        if (plaintext == null || stored == null) {
            return false;
        }
        if (isBcrypt(stored)) {
            try {
                return BCrypt.checkpw(plaintext, stored);
            } catch (IllegalArgumentException e) {
                return false;
            }
        }
        return stored.equals(plaintext);
    }

    public static boolean needsUpgrade(String stored) {
        return stored != null && !isBcrypt(stored);
    }

    private static boolean isBcrypt(String stored) {
        return stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$");
    }
}
