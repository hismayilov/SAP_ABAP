* Test Conditional Operators with IF condition
* NE with AND

REPORT ztest_sk_01.

SELECTION-SCREEN BEGIN OF BLOCK b1.
PARAMETERS: alph TYPE c LENGTH 1.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
*IF alph <> 'A' OR alph <> 'B' OR alph <> 'C'.
*  MESSAGE 'ERROR WILL BE DISPLAYED' TYPE 'S' DISPLAY LIKE 'E'.
*ENDIF.

  IF alph <> 'A' AND alph <> 'B' AND alph <> 'C'.
    MESSAGE 'ERROR WILL BE DISPLAYED' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.


*"========AND=========
*IF
*  IF
*    IF .
*
*    ENDIF.
*
*  ENDIF.
*
*ENDIF.
*
*"=======OR==========
*IF .
*
*ENDIF.
*
*IF .
*
*ENDIF.
*
*IF .
*
*ENDIF.
