package com.cs336.pkg;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class PasswordsTest {

    @Test
    public void hashVerifiesAndIsNotPlaintext() {
        String hash = Passwords.hash("securepass1");
        assertTrue(hash.startsWith("$2"));
        assertTrue(Passwords.matches("securepass1", hash));
        assertFalse(Passwords.matches("wrong", hash));
        assertFalse(Passwords.needsUpgrade(hash));
    }

    @Test
    public void legacyPlaintextMatchesAndNeedsUpgrade() {
        assertTrue(Passwords.matches("mgr1", "mgr1"));
        assertTrue(Passwords.needsUpgrade("mgr1"));
        assertFalse(Passwords.matches("mgr1", "emp1"));
    }
}
