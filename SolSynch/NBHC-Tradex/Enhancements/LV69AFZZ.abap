*----------------------------------------------------------------------*
***INCLUDE LV69AFZZ .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  USEREXIT_FIELD_MODIFIC_LEER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form userexit_field_modific_leer.

endform.                               " USEREXIT_FIELD_MODIFIC_LEER
*&---------------------------------------------------------------------*
*&      Form  USEREXIT_FIELD_MODIFIC_KZWI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form userexit_field_modific_kzwi.

endform.                               " USEREXIT_FIELD_MODIFIC_KZWI
*&---------------------------------------------------------------------*
*&      Form  USEREXIT_FIELD_MODIFIC_KOPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form userexit_field_modific_kopf.

endform.                               " USEREXIT_FIELD_MODIFIC_KOPF
*&---------------------------------------------------------------------*
*&      Form  USEREXIT_FIELD_MODIFICATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form userexit_field_modification.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1 ) Form USEREXIT_FIELD_MODIFICATION, Start                                                                                                      D
*$*$-Start: (1 )--------------------------------------------------------------------------------$*$*
ENHANCEMENT 50  ZSOL_TRADEX_DISABLE_YTRD_KBETR.    "inactive version
* ---- Disable KBETR/Amount field for YTRD condition type for YFSC Sales Order Type in VA02 ---- *
DATA: wa_vbak TYPE vbak.
* ---- Disble field/s only for YTRD cond type ---- *
IF komv-kschl = 'YTRD'.
* ---- KOMP-AUBEL is Sales Order No., use that to get order type from sales header table ---- *
  SELECT SINGLE auart
    FROM vbak
    INTO wa_vbak-auart
    WHERE vbeln = komp-aubel
    AND   auart = 'YFSC'.

* ---- Check if Transaction is VA02 and order type is YFSC ---- *
  IF sy-tcode = 'VA02' AND sy-subrc = 0.
* ---- Disable all fields for condition type YTRD ---- *
    IF screen-name = 'KOMV-KBETR' OR screen-name = 'RV61A-KOEIN' OR screen-name = 'KOMV-KPEIN'
      OR screen-name = 'KOMV-KMEIN'.
      screen-input = 0.
    ENDIF.
  ENDIF.
ENDIF.
ENDENHANCEMENT.
*$*$-End:   (1 )--------------------------------------------------------------------------------$*$*

endform.                               " USEREXIT_FIELD_MODIFICATION
*&---------------------------------------------------------------------*
*&      Form  USEREXIT_PRICING_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form userexit_pricing_check.

endform.                               " USEREXIT_PRICING_CHECK
*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CHANGE_PRICING_RULE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RV61A_KSTEU  text
*----------------------------------------------------------------------*
form userexit_change_pricing_rule using    p_rv61a_ksteu.

endform.                               " USEREXIT_CHANGE_PRICING_RULE
