****NACE -> V3 -> YTRD -> Program: ZSOL_DP_SALES_TAX_INV -> Form: Entry -> Smartform: ZSF_TAX_INVOICE****

*&---------------------------------------------------------------------*
*& Report  ZSOL_DP_SALES_TAX_INV
*& Attached to SMF: ZSF_TAX_INVOICE
*&---------------------------------------------------------------------*
*& Developed by: SaurabhK
*& Developed on: 07.12.2016
*& Description: Sales Tax Invoice Driver Program (YTRD)
*&---------------------------------------------------------------------*

REPORT  zsol_dp_sales_tax_inv.

TABLES: vbrp,vbrk.

TABLES: nast, tnapr.

DATA:fm_name TYPE rs38l_fnam,
     fm_name_smart_form LIKE fm_name,
     g_vbeln TYPE vbrk-vbeln.
*&---------------------------------------------------------------------*
*&      Form  entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ENT_RETCO  text
*      -->ENT_SCREEN text
*----------------------------------------------------------------------*
FORM entry USING  ent_retco TYPE sy-subrc
                       ent_screen TYPE c.
  CLEAR ent_retco.
  DATA: l_options TYPE ssfcompop,
        l_control TYPE ssfctrlop,
        sfm_name TYPE tdsfname.

  sfm_name = tnapr-sform.

  g_vbeln = nast-objky.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = sfm_name
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  l_control-preview = 'X'.
  l_control-no_dialog = 'X'.

  CALL FUNCTION fm_name
    EXPORTING
      invoice = g_vbeln.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    "entry
