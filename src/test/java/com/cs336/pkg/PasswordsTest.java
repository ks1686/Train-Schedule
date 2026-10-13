package com.cs336.pkg;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

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

    @Test
    public void hashRejectsPasswordsLongerThanBcryptLimit() {
        // jBCrypt only reads the first 72 bytes, so a longer password would
        // silently match any other password sharing that prefix.
        StringBuilder prefix = new StringBuilder();
        for (int i = 0; i < 72; i++) {
            prefix.append('a');
        }
        try {
            Passwords.hash(prefix + "x");
            fail("expected IllegalArgumentException");
        } catch (IllegalArgumentException expected) {
            // expected
        }
    }

    @Test
    public void lengthLimitCountsUtf8Bytes() {
        StringBuilder ok = new StringBuilder();
        StringBuilder tooLong = new StringBuilder();
        for (int i = 0; i < 36; i++) {
            ok.append('\u00e9');
        }
        for (int i = 0; i < 37; i++) {
            tooLong.append('\u00e9');
        }
        assertTrue(Passwords.isAcceptable(ok.toString()));
        assertFalse(Passwords.isAcceptable(tooLong.toString()));
    }

    @Test
    public void emptyPasswordIsNotAcceptable() {
        assertFalse(Passwords.isAcceptable(""));
        assertFalse(Passwords.isAcceptable(null));
    }
}
