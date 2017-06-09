"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Form BALANCE_CALCULATE, End                                                                                                                       A
*$*$-Start: (1)---------------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZBAL_CHECK_ROUND.    "active version
DATA: bal like rf05a-azsal.

IF sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65'.
  IF rf05a-azsal LT 0.
    bal = rf05a-azsal * -1.
  ELSE.
    bal = rf05a-azsal.
  ENDIF.

  IF bal LT '2.00'.       " Tolerance condition
    rf05a-azsal = '0.00'.
    perform traffic_light using rf05a-azsal.
  ENDIF.
ENDIF.
ENDENHANCEMENT.
*$*$-End:   (1)---------------------------------------------------------------------------------$*$*
endform.                               " BALANCE_CALCULATE
