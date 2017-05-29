===== Note radio button handling =====

*&---------------------------------------------------------------------*
*& Report  ZSOL_PO_DRIVER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zsol_po_driver.

TABLES : aufk, vbfa.
TYPE-POOLS : slis.

TYPES : BEGIN OF ty_aufk,
             aufnr TYPE afko-aufnr,
          END OF ty_aufk.
"---------------------------------

DATA : it_aufk TYPE TABLE OF ty_aufk,
       wa_aufk TYPE ty_aufk.

"-------------------------------
DATA: it_vbfa TYPE TABLE OF vbfa.
"-------------------------------

DATA : aufnr TYPE aufk-aufnr.

DATA : fm_name TYPE rs38l_fnam,
       fm_name_smart_form LIKE fm_name,
       g_vbeln TYPE vbak-vbeln.

DATA : gt_dynp TYPE STANDARD TABLE OF dynpread,
       gs_dynp LIKE dynpread.

DATA: lt_pdf TYPE TABLE OF tline,
      ls_pdf LIKE LINE OF lt_pdf,
      lv_url TYPE char255,
      pdf_fsize TYPE  i,
      lv_content  TYPE xstring,
      lt_data TYPE STANDARD TABLE OF x255.

DATA : l_job_output_info TYPE ssfcrescl.
DATA : ls_control_param  TYPE ssfctrlop.

"-------------------------------
**** Selection Screen ****
SELECTION-SCREEN BEGIN OF BLOCK rad WITH FRAME TITLE text-s03.
PARAMETERS: p_so TYPE c RADIOBUTTON GROUP rbg DEFAULT 'X' USER-COMMAND rad.
PARAMETERS: p_po TYPE c RADIOBUTTON GROUP rbg.
SELECTION-SCREEN END OF BLOCK rad.

SELECTION-SCREEN BEGIN OF BLOCK so WITH FRAME TITLE text-s02.
SELECT-OPTIONS: s_vbeln FOR vbfa-vbeln MODIF ID so.
SELECTION-SCREEN END OF BLOCK so.

SELECTION-SCREEN BEGIN OF BLOCK po WITH FRAME TITLE text-s01.
SELECT-OPTIONS: p_aufnr FOR aufk-aufnr MODIF ID po.
SELECTION-SCREEN END OF BLOCK po.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'SO' AND p_so NE 'X'.
      screen-active = 0.
    ELSEIF screen-group1 = 'PO' AND p_po NE 'X'.
      screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  "-------------------------------

*SELECTION-SCREEN : BEGIN OF BLOCK a WITH FRAME TITLE text-s01.
* SELECT-OPTIONS : p_aufnr FOR afko-aufnr  OBLIGATORY.
*SELECTION-SCREEN: END OF BLOCK a.

START-OF-SELECTION.

  PERFORM get_data.

  IF it_aufk[] IS NOT INITIAL.
    PERFORM call_form.
  ELSE.
    MESSAGE s000(8i) WITH 'No Data available.' 'Please check the Input Parameters.'.
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
  IF p_so = 'X' AND s_vbeln[] IS NOT INITIAL.
    SELECT *
      FROM vbfa
      INTO TABLE it_vbfa
      WHERE vbeln IN s_vbeln.

    IF sy-subrc = 0.
      SELECT aufnr
        FROM aufk
        INTO TABLE it_aufk
        FOR ALL ENTRIES IN it_vbfa
        WHERE kdauf = it_vbfa-vbelv
        AND kdpos = it_vbfa-posnv
        AND loekz NE 'X'.
    ENDIF.
  ELSEIF p_po = 'X' AND p_aufnr[] IS NOT INITIAL.
    SELECT aufnr
           INTO TABLE it_aufk
           FROM aufk
           WHERE aufnr IN p_aufnr
           AND loekz NE 'X'.
  ELSE.
    MESSAGE 'Fill in all the required fields' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  CALL_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_form .

  DATA: l_options TYPE ssfcompop,
        l_control TYPE ssfctrlop,
        sfm_name TYPE tdsfname.

  CALL FUNCTION 'SSF_OPEN'
    EXPORTING
*     ARCHIVE_PARAMETERS =
*     USER_SETTINGS    = 'X'
*     MAIL_SENDER      =
*     MAIL_RECIPIENT   =
*     MAIL_APPL_OBJ    =
      output_options   = l_options
*     CONTROL_PARAMETERS =
* IMPORTING
*     JOB_OUTPUT_OPTIONS =
    EXCEPTIONS
      formatting_error = 1
      internal_error   = 2
      send_error       = 3
      user_canceled    = 4
      OTHERS           = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT it_aufk INTO wa_aufk.

    aufnr = wa_aufk-aufnr.

    sfm_name = 'ZSOL_MM_PR_ORD'.

    l_control-no_dialog = 'X'.
    l_control-no_open   = 'X'.
    l_control-no_close  = 'X'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = sfm_name
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
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

    CALL FUNCTION fm_name
      EXPORTING
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
        control_parameters = l_control
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
*       OUTPUT_OPTIONS     = l_options
*       USER_SETTINGS      = 'X'
        p_aufnr            = aufnr
* IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO    =
*       JOB_OUTPUT_OPTIONS =
* EXCEPTIONS
*       FORMATTING_ERROR   = 1
*       INTERNAL_ERROR     = 2
*       SEND_ERROR         = 3
*       USER_CANCELED      = 4
*       OTHERS             = 5
      .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    CLEAR : wa_aufk,aufnr.
  ENDLOOP.

  CALL FUNCTION 'SSF_CLOSE'
*    IMPORTING
*     JOB_OUTPUT_INFO =
    EXCEPTIONS
      formatting_error = 1
*     INTERNAL_ERROR   = 2
*     SEND_ERROR       = 3
*     OTHERS           = 4
    .
  IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " CALL_FORM
