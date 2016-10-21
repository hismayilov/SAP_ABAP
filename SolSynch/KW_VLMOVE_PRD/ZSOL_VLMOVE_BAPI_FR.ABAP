*&---------------------------------------------------------------------*
*&  Include           ZSOL_VLMOVE_BAPI_FR
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_file .
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'p_file'
    IMPORTING
      file_name     = p_file.
ENDFORM.                    " GET_FILE

*&---------------------------------------------------------------------*
*&      Form  UPLOAD
*&---------------------------------------------------------------------*
*       Upload excel file and convert to int tab format
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload .
  IF p_file IS NOT INITIAL.
    " CONVERT EXCEL TO INTERNAL TABLE
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = c_x
        i_line_header        = c_x
        i_tab_raw_data       = it_raw
        i_filename           = p_file
      TABLES
        i_tab_converted_data = it_tab
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " UPLOAD

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
  LOOP AT it_tab INTO wa_tab.

    alpha_input wa_tab-handunit wa_tab-handunit.

    MOVE-CORRESPONDING wa_tab TO wa_data.
    APPEND wa_data TO it_data.
    MODIFY it_tab FROM wa_tab.
  ENDLOOP.

  SORT it_data BY handunit.
  IF it_data IS NOT INITIAL.

    SELECT *
      FROM vekp
      INTO CORRESPONDING FIELDS OF TABLE it_vekp
      FOR ALL ENTRIES IN it_data
      WHERE exidv = it_data-handunit.

    LOOP AT it_data INTO wa_data.
      READ TABLE it_vekp INTO wa_vekp WITH KEY exidv = wa_data-handunit.
      wa_data-venum = wa_vekp-venum.
      MODIFY it_data FROM wa_data.
    ENDLOOP.

    SELECT *
      FROM vepo
      INTO CORRESPONDING FIELDS OF TABLE it_vepo
      FOR ALL ENTRIES IN it_data
      WHERE venum = it_data-venum.

    LOOP AT it_data INTO wa_data.
      READ TABLE it_vepo INTO wa_vepo WITH KEY venum = wa_data-venum.
      wa_data-vepos = wa_vepo-vepos.
      wa_data-tabix = cnt.
      cnt = cnt + 1.
      MODIFY it_data FROM wa_data.
    ENDLOOP.

  ENDIF.

  LOOP AT it_data INTO wa_data.

    CLEAR : wa_mv_to, wa_ex_id.

    wa_mv_to-huwbevent = lv_process.
    wa_mv_to-werks     = wa_data-plant.
    wa_mv_to-lgort     = wa_data-stgloc.

    TRANSLATE wa_mv_to-lgort TO UPPER CASE.

    wa_mv_to-bwart = lv_mvttype.
    wa_ex_id-exidv = wa_data-handunit.

    wa_hu_im-venum = wa_data-venum.
    wa_hu_im-vepos = wa_data-vepos.
    wa_hu_im-tabix = wa_data-tabix.

    APPEND wa_hu_im TO wa_mv_to-hu_items.

    APPEND wa_mv_to TO it_mv_to.
    APPEND wa_ex_id TO it_ex_id.

  ENDLOOP.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  BAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bapi .
  " BAPI Call
  CALL FUNCTION 'HU_CREATE_GOODS_MOVEMENT'
    EXPORTING
      if_simulate    = ' '
      if_commit      = ' '
      if_tcode       = lv_tcode
      it_move_to     = it_mv_to
      it_external_id = it_ex_id
    IMPORTING
      ef_posted      = lv_pstd
      es_message     = wa_msg
      et_messages    = it_msg
      es_emkpf       = wa_emkpf.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = c_x.

  DATA: msg(100) TYPE c.

  IF wa_emkpf-mblnr IS NOT INITIAL AND sy-subrc = 0.
    CONCATENATE 'Document' wa_emkpf-mblnr 'Succsessfully Posted.' INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'I'.
  ENDIF.
ENDFORM.                    " BAPI
*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init .
  title = 'Provide file for upload:'.
  lv_tcode = 'VLMOVE'.
ENDFORM.                    " INIT
