*&---------------------------------------------------------------------*
*& Report  ZSOL_TAX_INV_PDF
*&
*&---------------------------------------------------------------------*
*& Author: Shraddha,
*&         SaurabhK.
*& Created On: 02.05.2017
*& Description: PDF download program for Tax Invoices (Tradex)
*&---------------------------------------------------------------------*

REPORT sy-repid.

TABLES: vbrk.

* ---- Types ---- *
TYPES: BEGIN OF ty_invo,
        vbeln TYPE vbrk-vbeln,
       END OF ty_invo,

       BEGIN OF ty_log,
         log TYPE string,
       END OF ty_log.

* ---- SF Data ---- *
DATA: fname   TYPE tdsfname VALUE 'ZSF_TAX_INVOICE',
      fm_name TYPE rs38l_fnam.

DATA: lw_control_parameters TYPE ssfctrlop,
      lw_output_options TYPE ssfcompop,
      lw_ssfcrescl TYPE ssfcrescl,
      v_devtype TYPE rspoptype.

* ---- Convert to PDF Declarations ---- *
DATA: li_otf          TYPE TABLE OF itcoo,
      li_pdf_tab      TYPE TABLE OF tline,
      lv_bin_filesize TYPE i,
      lv_bin_file     TYPE xstring,
      li_bin_tab      TYPE solix_tab.

* ---- File download declarations ---- *
DATA: filename    TYPE string,
      filepath    TYPE string,
      fullpath    TYPE string,
      filelen     TYPE i,
      " Log declarations
      lv_lines(5) TYPE c,
      msg         TYPE string.

* ---- Internal Tables ---- *
DATA: it_invo TYPE TABLE OF ty_invo,
      wa_invo TYPE ty_invo,

      it_log TYPE TABLE OF ty_log,
      wa_log TYPE ty_log.

* ---- Selection Screen ---- *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_invo FOR vbrk-vbeln,
                s_date FOR vbrk-fkdat.
SELECTION-SCREEN :END OF BLOCK b1.

* ---- Initialisation ---- *
INITIALIZATION.

  " Get client specific FM for SF
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fname
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

  CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
    EXPORTING
      i_language                   = sy-langu
*     I_APPLICATION                = 'SAPDEFAULT'
   IMPORTING
     e_devtype                    = v_devtype
   EXCEPTIONS
     no_language                  = 1
     language_not_installed       = 2
     no_devtype_found             = 3
     system_error                 = 4
     OTHERS                       = 5
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  " Set SF o/p & control parameters
*/.. Get OTF data
  lw_control_parameters-getotf     = 'X'.
*/.. To supress preview
  lw_control_parameters-no_dialog  = 'X'.
  lw_control_parameters-langu      = sy-langu.
  lw_output_options-tdnoprev       = 'X'.
  lw_output_options-tddest         = v_devtype.

START-OF-SELECTION.

  PERFORM get_data.

END-OF-SELECTION.

" Process data
  IF it_invo[] IS NOT INITIAL.
    PERFORM download_pdf.
  ELSE.
    MESSAGE 'No Invoices found for given criteria.' TYPE 'I' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
  IF s_invo IS NOT INITIAL OR s_date IS NOT INITIAL.
    SELECT vbeln
      FROM vbrk
      INTO TABLE it_invo
      WHERE vbeln IN s_invo
      AND   fkdat IN s_date
      AND   fkart EQ 'YTRD'.
  ELSE.
    MESSAGE 'Please provide altleast one input: invoice number and/or date.' TYPE 'S' DISPLAY LIKE 'E'.
    " LEAVE LIST-PROCESSING.
    STOP.
  ENDIF.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_pdf .
* ---- Select file directory ---- *
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Specify the path to save the pdf file/s'
*     initial_folder       =
    CHANGING
      selected_folder      = filepath
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF filepath IS INITIAL.
    MESSAGE 'No file path specified. Cannot download files.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

" Begin main download
  LOOP AT it_invo INTO wa_invo.
    " Call SF with invoice number
    CALL FUNCTION fm_name "'/1BCDWB/SF00000030'
      EXPORTING
        control_parameters = lw_control_parameters
        output_options     = lw_output_options
        invoice            = wa_invo-vbeln
      IMPORTING
        job_output_info    = lw_ssfcrescl
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid
      TYPE 'S' " sy-msgty
      NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.

      CONTINUE.
    ELSE.
      " Get OTF data to convert to PDF
      CLEAR : lv_bin_filesize, lv_bin_file.
      REFRESH: li_otf[], li_pdf_tab.

      li_otf[] = lw_ssfcrescl-otfdata[].

      " Convert otf to binary
      CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
        IMPORTING
          bin_filesize          = lv_bin_filesize
          bin_file              = lv_bin_file
        TABLES
          otf                   = li_otf
          lines                 = li_pdf_tab
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          err_bad_otf           = 4
          OTHERS                = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CONCATENATE wa_invo-vbeln '.pdf' INTO filename.
      CONCATENATE filepath '\' filename INTO fullpath.

* ---- Convert pdf to binary ---- *
      REFRESH li_bin_tab[].
      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = lv_bin_file
        TABLES
          binary_tab = li_bin_tab.

* ---- Download binary file as pdf ---- *
      IF li_bin_tab[] IS NOT INITIAL AND fullpath IS NOT INITIAL.
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            bin_filesize            = lv_bin_filesize
            filename                = fullpath
            filetype                = 'BIN'
            confirm_overwrite       = 'X'
            show_transfer_status    = abap_true
          IMPORTING
            filelength              = filelen
          TABLES
            data_tab                = li_bin_tab
          EXCEPTIONS
            file_write_error        = 1
            no_batch                = 2
            gui_refuse_filetransfer = 3
            invalid_type            = 4
            no_authority            = 5
            unknown_error           = 6
            header_not_allowed      = 7
            separator_not_allowed   = 8
            filesize_not_allowed    = 9
            header_too_long         = 10
            dp_error_create         = 11
            dp_error_send           = 12
            dp_error_write          = 13
            unknown_dp_error        = 14
            access_denied           = 15
            dp_out_of_memory        = 16
            disk_full               = 17
            dp_timeout              = 18
            file_not_found          = 19
            dataprovider_exception  = 20
            control_flush_error     = 21
            OTHERS                  = 22.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          CONCATENATE fullpath 'saved.' INTO wa_log-log SEPARATED BY space.
          APPEND wa_log TO it_log.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR: wa_invo, filename, fullpath.
  ENDLOOP.

" Write log
  IF it_log IS NOT INITIAL.
    DESCRIBE TABLE it_log LINES lv_lines.
    SHIFT lv_lines LEFT DELETING LEADING space.
    CONCATENATE lv_lines 'file/s downloaded at selected path.' INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'I'.

    LOOP AT it_log INTO wa_log.
      WRITE:/ wa_log-log.
      CLEAR wa_log.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " DOWNLOAD_PDF
