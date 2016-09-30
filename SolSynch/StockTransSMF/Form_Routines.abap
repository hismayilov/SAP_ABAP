*&---------------------------------------------------------------------*
*&      Form  CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_FINAL_MATNR  text
*      -->P_WA_FINAL_MEINS  text
*      -->P_WA_MARM_MEINH  text
*      -->P_WA_FINAL_MENGE  text
*      <--P_WA_FINAL_ALQTY  text
*----------------------------------------------------------------------*
FORM conversion  USING    p_wa_final_matnr
                          p_wa_final_meins
                          p_lv_meinh
                          p_wa_final_menge
                 CHANGING p_wa_final_alqty.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = p_wa_final_matnr " mat no
      i_in_me              = p_wa_final_meins " BUoM
      i_out_me             = p_lv_meinh  " AltUm
      i_menge              = p_wa_final_menge " BQty
    IMPORTING
      e_menge              = p_wa_final_alqty " AlQty
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ENDIF.


ENDFORM.
