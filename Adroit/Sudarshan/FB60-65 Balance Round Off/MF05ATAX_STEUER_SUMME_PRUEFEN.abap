"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Form STEUER_SUMME_PRUEFEN, End                                                                                                                    A
*$*$-Start: (1)---------------------------------------------------------------------------------$*$*
ENHANCEMENT 2  ZBAL_CHECK_ROUND.    "active version
IF sy-tcode = 'FB60' OR sy-tcode EQ 'FB65'.
  DATA: wa_sal LIKE LINE OF saltab,
        diffhw   LIKE saltab-sollhw,
        difffw   LIKE saltab-sollfw.
  IF saltab[] IS NOT INITIAL.
    LOOP AT saltab INTO wa_sal.
      diffhw = wa_sal-sollhw - wa_sal-habenhw.
      IF diffhw < 0.
        diffhw = diffhw * -1.
      ENDIF.
      IF diffhw LT '2.00'.
        wa_sal-sollhw = wa_sal-habenhw.
        MODIFY saltab FROM wa_sal TRANSPORTING sollhw.
      ENDIF.

      difffw = wa_sal-sollfw - wa_sal-habenfw.
      IF difffw < 0.
        difffw = difffw * -1.
      ENDIF.
      IF difffw LT '2.00'.
        wa_sal-sollfw = wa_sal-habenfw.
        MODIFY saltab FROM wa_sal TRANSPORTING sollfw.
      ENDIF.
      CLEAR: wa_sal, diffhw, difffw.
    ENDLOOP.
  ENDIF.
ENDIF.
ENDENHANCEMENT.
*$*$-End:   (1)---------------------------------------------------------------------------------$*$*
ENDFORM.                    "STEUER_SUMME_PRUEFEN
