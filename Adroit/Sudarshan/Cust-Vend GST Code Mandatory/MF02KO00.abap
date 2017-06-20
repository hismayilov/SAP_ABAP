MODULE DYNPRO_MODIFIZIEREN OUTPUT.
  PERFORM DYNPRO_MODIFIZIEREN_AP.
  IF NOT ZAV_FLAG IS INITIAL.
    IF T020-AKTYP CA 'VP' AND X055_COUNT > 0.
      PERFORM ZAV_BERECHTIGUNGSPRUEFUNG TABLES X055 CHANGING KRED-FAUSA.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT SAPLWR11_02 SPOTS ES_SAPMF02K  STATIC .

ENHANCEMENT-POINT SAPLWR11_03 SPOTS ES_SAPMF02K .
....
ENHANCEMENT 1  ZVEND_GST_MANDATORY.    "active version
  DATA: gstflag TYPE flag.
  IMPORT gstflag FROM MEMORY ID 'ZFLAG'.

  IF gstflag EQ 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'LFA1-STCD3'.
        SET CURSOR FIELD 'LFA1-STCD3'.
        screen-required = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDENHANCEMENT.
*$*$-End:   SAPLWR11_03-------------------------------------------------------------------------$*$*


ENDMODULE.
