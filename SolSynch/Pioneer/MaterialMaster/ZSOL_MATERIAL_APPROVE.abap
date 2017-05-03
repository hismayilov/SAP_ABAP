*&---------------------------------------------------------------------*
*& Report ZSOL_MATERIAL_APPROVE
*&---------------------------------------------------------------------*
*& Author: Saurabh Khare
*& Creation Date: 29.03.2017
*& Description: Approve materials requested via zmat_req(only authorised users)
*& TCODE: ZMAT_APPR
*&---------------------------------------------------------------------*
REPORT zsol_material_approve.

* ---- Data declaration ---- *

* ---- Type-Pools ---- *
TYPE-POOLS: slis.

* ---- Tables ---- *
TABLES: zsol_mmcreate.

* ---- Constants ---- *
*CONSTANTS: .

* ---- Types ---- *
TYPES: BEGIN OF ty_final,
         sel,
         matnr       TYPE zsol_mmcreate-matnr,
         maktx       TYPE zsol_mmcreate-maktx,
         spart       TYPE zsol_mmcreate-spart,
         reqby       TYPE zsol_mmcreate-reqby,
         reqdat      TYPE zsol_mmcreate-reqdat,
         reqtim      TYPE zsol_mmcreate-reqtim,
         appby       TYPE zsol_mmcreate-appby,
         appdat      TYPE zsol_mmcreate-appdat,
         apptim      TYPE zsol_mmcreate-apptim,
         matl_grp    TYPE zsol_mmcreate-matl_grp,
         act_denier  TYPE zsol_mmcreate-act_denier,
         std_pr_val  TYPE zsol_mmcreate-std_pr_val,
         denier_desc TYPE zsol_mmcreate-denier_desc,
         mat_created TYPE char3,
         log         TYPE zsol_mmcreate-log,
       END OF ty_final.

* ---- Internal Tables ---- *
DATA: it_mmcreate TYPE TABLE OF zsol_mmcreate,
      wa_mmcreate TYPE zsol_mmcreate,

      it_update   TYPE TABLE OF zsol_mmcreate,
      wa_update   TYPE zsol_mmcreate,

      it_mmdef    TYPE TABLE OF zsol_mmdef,
      wa_mmdef    TYPE zsol_mmdef,

      it_final    TYPE TABLE OF ty_final,
      wa_final    TYPE ty_final.

* ---- Variables ---- *
DATA: msg      TYPE string,              " Error handling messages
      txt      TYPE string,              " Message
      cnt_s(3) TYPE c,                   " Selected count
      cnt_p(3) TYPE c,                   " Approved count
      cnt_a(3) TYPE c,                   " Approved count
      lv_items TYPE n LENGTH 3,          " Table lines
      lv_spart TYPE zsol_mmdef-spart,    " Division
      divs     TYPE string.              " Divisions responsible for

* ---- ALV Related ---- *
DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      wa_layout   TYPE slis_layout_alv,
      g_variant   TYPE disvariant,
      gx_variant  TYPE disvariant.

* ---- Selection Screen ---- *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_reqdat FOR zsol_mmcreate-reqdat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS: rad1 RADIOBUTTON GROUP app DEFAULT 'X', " All
            rad2 RADIOBUTTON GROUP app,             " Approved Only
            rad3 RADIOBUTTON GROUP app.             " Approval Pending Only
SELECTION-SCREEN END OF BLOCK b2.

PARAMETERS: variant LIKE disvariant-variant NO-DISPLAY.

INITIALIZATION.
* ---- Get default variant ---- *
  IF variant IS INITIAL.
    gx_variant-report = sy-repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
      EXPORTING
        i_save     = 'X'
      CHANGING
        cs_variant = gx_variant
      EXCEPTIONS
        not_found  = 2.
    IF sy-subrc = 0.
      variant = gx_variant-variant.
      g_variant-variant = variant.
    ENDIF.
  ENDIF.

  cnt_s = cnt_p = cnt_a = 0.

* ---- Selection Screen Events ---- *

* ---- Begin Main Program ---- *
START-OF-SELECTION.
* ---- Get Data from database ---- *
  PERFORM get_data.
* ---- Construct final table ---- *
  PERFORM process_data.

* ---- Build FCAT and display ALV ---- *
  IF it_final[] IS NOT INITIAL.
    PERFORM build_layout.
    PERFORM fcat.
    PERFORM alv_display.
  ELSE.
    CLEAR: msg.
    CONCATENATE 'No data found. User:' sy-uname '- Division/s:' divs INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'I' DISPLAY LIKE 'E'.
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
* ---- Get requested material details ---- *
  IF rad1 = 'X'.
    SELECT *
      FROM zsol_mmcreate
      INTO CORRESPONDING FIELDS OF TABLE it_mmcreate
      WHERE reqdat IN s_reqdat.
  ELSEIF rad2 = 'X'.
    SELECT *
      FROM zsol_mmcreate
      INTO CORRESPONDING FIELDS OF TABLE it_mmcreate
      WHERE reqdat IN s_reqdat
      AND   appby  NE ''
      AND   appdat NE ''
      AND   apptim NE ''.
  ELSEIF rad3 = 'X'.
    SELECT *
      FROM zsol_mmcreate
      INTO CORRESPONDING FIELDS OF TABLE it_mmcreate
      WHERE reqdat IN s_reqdat
      AND   appby  EQ ''
      AND   appdat EQ '00000000'
      AND   apptim EQ '000000'
      AND   mat_created NE 'X'.
  ENDIF.

  SELECT *
    FROM zsol_mmdef
    INTO TABLE it_mmdef.

  IF sy-subrc = 0.
    CLEAR divs.
    LOOP AT it_mmdef INTO wa_mmdef WHERE zuser EQ sy-uname.
      CONCATENATE divs wa_mmdef-spart INTO divs SEPARATED BY space.
      CLEAR wa_mmdef.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "get_data
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data .
* ---- Process data / Construct final ALV table ---- *
  IF it_mmcreate[] IS NOT INITIAL.

    LOOP AT it_mmcreate INTO wa_mmcreate.
      MOVE-CORRESPONDING wa_mmcreate TO wa_final.
      IF wa_final-mat_created EQ 'X'.
        wa_final-mat_created = 'Yes'.
      ELSE.
        wa_final-mat_created = 'No'.
      ENDIF.
      APPEND wa_final TO it_final.
      CLEAR: wa_final, wa_mmcreate.
    ENDLOOP.

    LOOP AT it_final INTO wa_final.
      lv_spart = wa_final-spart.
      IF lv_spart IS INITIAL.
        DELETE it_final.
      ELSE.
        READ TABLE it_mmdef INTO wa_mmdef WITH KEY spart = lv_spart.
        IF sy-subrc = 0.
          IF wa_mmdef-zuser NE sy-uname.
            DELETE it_final.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_final, wa_mmdef, lv_spart.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "process_data
*&---------------------------------------------------------------------*
*&      Form  FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fcat .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
*     I_INTERNAL_TABNAME     =
      i_structure_name       = 'ZSOL_MMCREATE'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = it_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF it_fieldcat IS NOT INITIAL.
    LOOP AT it_fieldcat INTO wa_fieldcat.
      IF wa_fieldcat-fieldname = 'MATNR'.
        wa_fieldcat-seltext_m = 'Material'.
        wa_fieldcat-outputlen = '30'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'MAKTX'.
        wa_fieldcat-seltext_m = 'Material Description'.
        wa_fieldcat-outputlen = '30'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'REQBY'.
        wa_fieldcat-seltext_m = 'Requested By'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'REQDAT'.
        wa_fieldcat-seltext_m = 'Request Date'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'REQTIM'.
        wa_fieldcat-seltext_m = 'Request Time'.
        wa_fieldcat-no_zero   = 'X'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'APPBY'.
        wa_fieldcat-seltext_m = 'Approved By'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'APPDAT'.
        wa_fieldcat-seltext_m = 'Approved Date'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'APPTIM'.
        wa_fieldcat-seltext_m = 'Approved Time'.
        wa_fieldcat-no_zero   = 'X'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'MATL_GRP'.
        wa_fieldcat-seltext_m = 'Material Group'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'ACT_DENIER'.
        wa_fieldcat-seltext_m = 'Actual Denier'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'DENIER_DESC'.
        wa_fieldcat-seltext_m = 'Denier Description'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'STD_PR_VAL'.
        wa_fieldcat-seltext_m = 'Standard Price'.
        wa_fieldcat-no_zero   = 'X'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'MAT_CREATED'.
        wa_fieldcat-seltext_m = 'Material Created'.
        wa_fieldcat-outputlen = '15'.
      ENDIF.
      IF wa_fieldcat-fieldname = 'LOG'.
        wa_fieldcat-seltext_m = 'Creation Log'.
      ENDIF.
      MODIFY it_fieldcat FROM wa_fieldcat.
      CLEAR: wa_fieldcat.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "fcat
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_display .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_top_of_page   = 'TOP-OF-PAGE'
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = wa_layout
      it_fieldcat              = it_fieldcat[]
      i_save                   = 'X'
      is_variant               = g_variant
    TABLES
      t_outtab                 = it_final[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    "alv_display
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_layout.
  wa_layout-box_fieldname     = 'SEL'.
  wa_layout-zebra             = 'X'.
ENDFORM.                    "build_layout
*&---------------------------------------------------------------------*
*&      Form  top-of-page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top-of-page.
* ---- ALV Header declarations ---- *
  DATA: gt_header     TYPE slis_t_listheader,
        gs_header     TYPE slis_listheader,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c,
        textn         TYPE slis_listheader-info.

* ---- Title ---- *
  gs_header-typ = 'H'.
  CONCATENATE 'Approve requested materials for division/s: ' divs INTO textn SEPARATED BY space.
  gs_header-info = textn.
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- User ---- *
  gs_header-typ  = 'S'.
  gs_header-key = 'User :- '.
  CONCATENATE  sy-uname ' ' INTO gs_header-info.   "Logged in user
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- Total No. of Records Selected ---- *
  DESCRIBE TABLE  it_final LINES ld_lines.
  ld_linesc = ld_lines.
  CONCATENATE 'Total no. of records selected: ' ld_linesc INTO textn SEPARATED BY space.
  gs_header-typ  = 'A'.
  gs_header-info = textn.
  APPEND gs_header TO gt_header.
  CLEAR: gs_header, textn.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header.

ENDFORM.                    "top-of-page
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.        "#EC CALLED
  SET PF-STATUS 'ZSTAT_MMAPPROVE'.
ENDFORM.                    "zstat_ins
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
  DATA: ref1     TYPE REF TO cl_gui_alv_grid,
        gv_valid TYPE char01.

  CLEAR gv_valid.
* ---- Get modified ALV data ---- *
  IF r_ucomm EQ '&DATA_SAVE' OR r_ucomm EQ '&APPROVE'.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref1.
* ---- Check correctness of changed data ---- *
    CALL METHOD ref1->check_changed_data
      IMPORTING
        e_valid = gv_valid.
* ---- Create material -- only if entered data is valid ---- *
    IF gv_valid IS NOT INITIAL.
      IF it_final[] IS NOT INITIAL.
        PERFORM approve.
      ENDIF.
      rs_selfield-refresh = 'X'.
    ELSE.
      CLEAR txt.
      txt = 'Please rectify the above errors in your input.'.
      CLEAR msg.
      CONCATENATE txt msg INTO msg.
      MESSAGE msg TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*& Form APPROVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM approve .

  LOOP AT it_final INTO wa_final WHERE sel = 'X'.
    IF wa_final-appby IS INITIAL
       AND wa_final-appdat IS INITIAL
       AND wa_final-apptim IS INITIAL
       AND wa_final-mat_created EQ 'No'.

      wa_update-appby  = wa_final-appby  = sy-uname.
      wa_update-appdat = wa_final-appdat = sy-datum.
      wa_update-apptim = wa_final-apptim = sy-uzeit.

      UPDATE zsol_mmcreate SET    appby  = wa_update-appby
                                  appdat = wa_update-appdat
                                  apptim = wa_update-apptim
                           WHERE  matnr  = wa_final-matnr.
      IF sy-subrc = 0.
        ADD 1 TO cnt_a.
        MODIFY it_final FROM wa_final TRANSPORTING appby appdat apptim.
      ENDIF.
    ENDIF.
    ADD 1 TO cnt_s.
    CLEAR wa_final.
  ENDLOOP.

  COMMIT WORK.
  IF sy-subrc = 0 AND ( cnt_a IS NOT INITIAL OR cnt_s IS NOT INITIAL ).
    CLEAR msg.
    CONCATENATE cnt_s 'materials selected.' INTO msg SEPARATED BY space.
    cnt_p = cnt_s - cnt_a.
    CONCATENATE msg cnt_p 'materials already approved.' INTO msg SEPARATED BY space.
    CONCATENATE msg cnt_a 'materials approved in this session.' INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'I'.
    cnt_s = cnt_p = cnt_a = 0.
  ENDIF.
ENDFORM.
