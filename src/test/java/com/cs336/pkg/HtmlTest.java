package com.cs336.pkg;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class HtmlTest {

    @Test
    public void escapesMarkupAndQuotes() {
        assertEquals("&lt;b&gt;x&amp;y&lt;/b&gt;", Html.escape("<b>x&y</b>"));
        assertEquals("&quot;hi&quot;", Html.escape("\"hi\""));
        assertEquals("&#39;hi&#39;", Html.escape("'hi'"));
    }

    @Test
    public void nullBecomesEmpty() {
        assertEquals("", Html.escape(null));
    }
}
