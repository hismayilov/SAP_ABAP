*&---------------------------------------------------------------------*
*& Report  ZSD_CREDIT_NOTE_GST_DRV
*&
*&---------------------------------------------------------------------*
*&   Print of a invoice/credit note by SMART FORMS
*&
*&---------------------------------------------------------------------*
REPORT zsd_credit_note_gst_drv.

* declaration of data
INCLUDE rlb_invoice_data_declare.
* definition of forms
INCLUDE rlb_invoice_form01.
INCLUDE rlb_print_forms.

*---------------------------------------------------------------------*
*       FORM ENTRY
*---------------------------------------------------------------------*
FORM entry USING return_code us_screen.

  DATA: lf_retcode TYPE sy-subrc.
  CLEAR retcode.
  xscreen = us_screen.
  PERFORM processing USING us_screen
                     CHANGING lf_retcode.
  IF lf_retcode NE 0.
    return_code = 1.
  ELSE.
    return_code = 0.
  ENDIF.

ENDFORM.                    "ENTRY
*---------------------------------------------------------------------*
*       FORM PROCESSING                                               *
*---------------------------------------------------------------------*
FORM processing USING proc_screen
                CHANGING cf_retcode.

  DATA: ls_print_data_to_read TYPE lbbil_print_data_to_read.
  DATA: ls_bil_invoice TYPE lbbil_invoice.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.
  DATA: ls_dlv-land           LIKE vbrk-land1.
  DATA: ls_job_info           TYPE ssfcrescl.

* SmartForm from customizing table TNAPR
  lf_formname = tnapr-sform.

* BEGIN: Country specific extension for Hungary
  DATA: lv_ccnum TYPE idhuccnum,
        lv_error TYPE c.

* If a valid entry exists for the form in customizing view
* IDHUBILLINGOUT then the localized output shall be used.
  SELECT SINGLE ccnum INTO lv_ccnum FROM idhubillingout WHERE
    kschl = nast-kschl.

  IF sy-subrc EQ 0.
    IF lv_ccnum IS INITIAL.
      lv_ccnum = 1.
    ENDIF.

    IF ( nast-delet IS INITIAL OR nast-dimme IS INITIAL ).

      nast-delet = 'X'.
      nast-dimme = 'X'.

      sy-msgid = 'IDFIHU'.
      sy-msgty = 'W'.
      sy-msgno = 201.
      sy-msgv1 = nast-objky.

      CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
        EXPORTING
        msg_arbgb = sy-msgid
        msg_nr    = sy-msgno
        msg_ty    = sy-msgty
        msg_v1    = sy-msgv1
        msg_v2    = ''
        msg_v3    = ''
        msg_v4    = ''
      EXCEPTIONS
        OTHERS    = 1.
    ENDIF.
  ELSE.
    CLEAR lv_ccnum.
  ENDIF.
* END: Country specific extension for Hungary

* determine print data
  PERFORM set_print_data_to_read USING    lf_formname
                                 CHANGING ls_print_data_to_read
                                 cf_retcode.

  IF cf_retcode = 0.
* select print data
    PERFORM get_data USING    ls_print_data_to_read
                     CHANGING ls_addr_key
                              ls_dlv-land
                              ls_bil_invoice
                              cf_retcode.
  ENDIF.

  IF cf_retcode = 0.
    PERFORM set_print_param USING    ls_addr_key
                                     ls_dlv-land
                            CHANGING ls_control_param
                                     ls_composer_param
                                     ls_recipient
                                     ls_sender
                                     cf_retcode.
  ENDIF.

  IF cf_retcode = 0.
* determine smartform function module for invoice
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
         EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
         IMPORTING  fm_name            = lf_fm_name
         EXCEPTIONS no_form            = 1
                    no_function_module = 2
                    OTHERS             = 3.
    IF sy-subrc <> 0.
*   error handling
      cf_retcode = sy-subrc.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

  IF cf_retcode = 0.
    PERFORM check_repeat.
    IF ls_composer_param-tdcopies EQ 0.
      nast_anzal = 1.
    ELSE.
      nast_anzal = ls_composer_param-tdcopies.
    ENDIF.
    ls_composer_param-tdcopies = 1.

    DO nast_anzal TIMES.
* In case of repetition only one time archiving
      IF sy-index > 1 AND nast-tdarmod = 3.
        nast_tdarmod = nast-tdarmod.
        nast-tdarmod = 1.
        ls_composer_param-tdarmod = 1.
      ENDIF.
      IF sy-index NE 1 AND repeat IS INITIAL.
        repeat = 'X'.
      ENDIF.
* BEGIN: Country specific extension for Hungary
    IF lv_ccnum IS NOT INITIAL.
      IF nast-repid IS INITIAL.
        nast-repid = 1.
      ELSE.
        nast-repid = nast-repid + 1.
      ENDIF.
      nast-pfld1 = lv_ccnum.
    ENDIF.
* END: Country specific extension for Hungary
* call smartform invoice
      CALL FUNCTION lf_fm_name
           EXPORTING
                      archive_index        = toa_dara
                      archive_parameters   = arc_params
                      control_parameters   = ls_control_param
*                 mail_appl_obj        =
                      mail_recipient       = ls_recipient
                      mail_sender          = ls_sender
                      output_options       = ls_composer_param
                      user_settings        = space
                      is_bil_invoice       = ls_bil_invoice
                      is_nast              = nast
                      is_repeat            = repeat
           IMPORTING  job_output_info      = ls_job_info
*                     document_output_info =
*                     job_output_options   =
           EXCEPTIONS formatting_error     = 1
                      internal_error       = 2
                      send_error           = 3
                      user_canceled        = 4
                      OTHERS               = 5.
      IF sy-subrc <> 0.
*   error handling
        cf_retcode = sy-subrc.
        PERFORM protocol_update.
* get SmartForm protocoll and store it in the NAST protocoll
        PERFORM add_smfrm_prot.
      ENDIF.
    ENDDO.
* get SmartForm spoolid and store it in the NAST protocoll
    DATA ls_spoolid LIKE LINE OF ls_job_info-spoolids.
    LOOP AT ls_job_info-spoolids INTO ls_spoolid.
      IF ls_spoolid NE space.
        PERFORM protocol_update_spool USING '342' ls_spoolid
                                            space space space.
      ENDIF.
    ENDLOOP.
    ls_composer_param-tdcopies = nast_anzal.
    IF NOT nast_tdarmod IS INITIAL.
      nast-tdarmod = nast_tdarmod.
      CLEAR nast_tdarmod.
    ENDIF.

  ENDIF.

* get SmartForm protocoll and store it in the NAST protocoll
* PERFORM ADD_SMFRM_PROT.

ENDFORM.                    "PROCESSING
