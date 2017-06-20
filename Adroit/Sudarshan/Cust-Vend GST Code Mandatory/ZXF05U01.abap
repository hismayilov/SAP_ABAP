CMOD Project: ZSAPMF2K
EXIT: EXIT_SAPMF02K_001

* ---- Addition by SaurabhK on 13.06.17 02:21 PM to make GST IN Code mandatory for registered vendors ---- *
FIELD-SYMBOLS: <venclass> TYPE j_1imovend-ven_class.
DATA: venclass TYPE j_1imovend-ven_class,
      gstflag TYPE flag.

CLEAR: gstflag, venclass.
ASSIGN ('(SAPLJ1I_MASTER)J_1IMOVEND-VEN_CLASS') TO <venclass> .

IF <venclass> IS ASSIGNED.
  venclass = <venclass>.
  IF venclass IS INITIAL.
    IF i_lfa1-stcd3 IS INITIAL.
      MESSAGE 'GST IN code is mandatory for registered vendors' TYPE 'I' DISPLAY LIKE 'E'.
      gstflag = 'X'.
      EXPORT gstflag TO MEMORY ID 'ZFLAG'.
      LEAVE TO SCREEN 0120.
    ENDIF.
  ENDIF.
ELSE.
  MESSAGE 'Vendor class is not maintained' TYPE 'E'.
ENDIF.
** ---- End of Addition ---- *
