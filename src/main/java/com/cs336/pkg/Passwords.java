package com.cs336.pkg;

import org.mindrot.jbcrypt.BCrypt;

public final class Passwords {
    private Passwords() {
    }

    public static String hash(String plaintext) {
        if (plaintext == null) {
            throw new IllegalArgumentException("password required");
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
