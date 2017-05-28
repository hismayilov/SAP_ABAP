*&---------------------------------------------------------------------*
*&  Include           ZLMEWPF11
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  RATE_TO_EXTERNAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      --> I_BUKRS
*      --> I_BEDAT
*      --> I_WAERS
*      --> I_WKURS
*      <-- E_RATE
*      <-- E_RATE_CM
*----------------------------------------------------------------------*
FORM rate_to_external USING    i_bukrs   LIKE ekko-bukrs
                               i_bedat   LIKE ekko-bedat
                               i_waers   LIKE ekko-waers
                               i_wkurs   LIKE ekko-wkurs
                      CHANGING e_rate    LIKE bapiekko-exch_rate
                               e_rate_cm LIKE bapiekko-exch_rate_cm.

  DATA: l_hwaers LIKE t001-waers.

* Retrieve local currency:
  SELECT SINGLE waers INTO l_hwaers FROM t001 WHERE bukrs = i_bukrs.

  CALL FUNCTION 'CONVERT_RATE_TO_EXTERNAL'
    EXPORTING
      date             = i_bedat
      foreign_currency = i_waers
      local_currency   = l_hwaers
      rate             = i_wkurs
    IMPORTING
      rate_p           = e_rate
      rate_v           = e_rate_cm
    EXCEPTIONS
      no_factors_found = 1
      derived_2_times  = 2
      no_spread_found  = 3
      overflow         = 4
      OTHERS           = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                               " RATE_TO_EXTERNAL
