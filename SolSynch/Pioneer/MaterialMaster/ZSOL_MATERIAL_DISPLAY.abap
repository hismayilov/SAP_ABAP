*&---------------------------------------------------------------------*
*& Report ZSOL_MATERIAL_DISPLAY
*&---------------------------------------------------------------------*
*& Author: Saurabh Khare
*& Creation Date: 27.03.2017
*& Description: Display materials requested theough zmat_req(All users)
*& TCODE: ZMAT_DISP
*&---------------------------------------------------------------------*
REPORT zsol_material_display.

* ---- Data declaration ---- *

* ---- Type-Pools ---- *
TYPE-POOLS: slis.

* ---- Tables ---- *
TABLES: zsol_mmcreate.

* ---- Constants ---- *
*CONSTANTS: .

* ---- Types ---- *
TYPES: BEGIN OF ty_final,
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
         denier_desc TYPE zsol_mmcreate-denier_desc,
         std_pr_val  TYPE zsol_mmcreate-std_pr_val,
         mat_created TYPE char3,
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
      lv_items TYPE n LENGTH 3.          " Table lines

* ---- ALV Related ---- *
DATA: it_fieldcat TYPE lvc_t_fcat,
      wa_fieldcat TYPE lvc_s_fcat,
      wa_layout   TYPE lvc_s_layo,
      g_variant   TYPE disvariant,
      gx_variant  TYPE disvariant.

* ---- Selection Screen ---- *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_reqdat FOR zsol_mmcreate-reqdat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS: rad1 RADIOBUTTON GROUP app DEFAULT 'X', " All
            rad2 RADIOBUTTON GROUP app,             " Approved Only
            rad3 RADIOBUTTON GROUP app,             " Approval Pending Only
            rad4 RADIOBUTTON GROUP app,             " Created
            rad5 RADIOBUTTON GROUP app.             " Not Created
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
    MESSAGE 'No data found' TYPE 'I' DISPLAY LIKE 'E'.
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
  ELSEIF rad4 = 'X'.
    SELECT *
      FROM zsol_mmcreate
      INTO CORRESPONDING FIELDS OF TABLE it_mmcreate
      WHERE reqdat IN s_reqdat
      AND   mat_created EQ 'X'.
  ELSEIF rad5 = 'X'.
    SELECT *
      FROM zsol_mmcreate
      INTO CORRESPONDING FIELDS OF TABLE it_mmcreate
      WHERE reqdat IN s_reqdat
      AND   mat_created NE 'X'.
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
  PERFORM fill_fcat USING:
  'MATNR'       'IT_FINAL'  'Material'          'X'   'X'   space,
  'MAKTX'       'IT_FINAL'  'Material Descr.'   'X'   'X'   space,
  'SPART'       'IT_FINAL'  'Division'          'X'   'X'   space,
  'REQBY'       'IT_FINAL'  'Requested By'      'X'   'X'   space,
  'REQDAT'      'IT_FINAL'  'Request Date'      'X'   'X'   space,
  'REQTIM'      'IT_FINAL'  'Request Time'      'X'   'X'   space,
  'APPBY'       'IT_FINAL'  'Approved By'       'X'   'X'   space,
  'APPDAT'      'IT_FINAL'  'Approved Date'     'X'   'X'   space,
  'APPTIM'      'IT_FINAL'  'Approved Time'     'X'   'X'   space,
  'MATL_GRP'    'IT_FINAL'  'Material Group'    'X'   'X'   space,
  'ACT_DENIER'  'IT_FINAL'  'Actual Denier'     'X'   'X'   space,
  'DENIER_DESC' 'IT_FINAL'  'Denier Descr.'     'X'   'X'   space,
  'STD_PR_VAL'  'IT_FINAL'  'Standard Price'    'X'   'X'   space,
  'MAT_CREATED' 'IT_FINAL'  'Material Created?' 'X'   'X'   space.

* ---- Make PO Number as key field in ALV, remains fixed while scrolling ---- *
  IF it_fieldcat[] IS NOT INITIAL.
    LOOP AT it_fieldcat INTO wa_fieldcat WHERE fieldname = 'MATNR'.
      wa_fieldcat-key = 'X'.    " Key field
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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'TOP-OF-PAGE'
      is_layout_lvc          = wa_layout
      it_fieldcat_lvc        = it_fieldcat[]
*     IT_SORT_LVC            =
*     I_DEFAULT              = 'X'
      i_save                 = 'X'
      is_variant             = g_variant
*     IT_EVENTS              =
    TABLES
      t_outtab               = it_final[]
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
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
  wa_layout-zebra         = 'X'.
ENDFORM.                    "build_layout
*&---------------------------------------------------------------------*
*&      Form  FILL_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM fill_fcat  USING    VALUE(p_fname)
                         VALUE(p_tname)
                         VALUE(p_stext)
                         VALUE(p_clopt)
                         VALUE(p_blank)
                         VALUE(p_outln).

  wa_fieldcat-fieldname   = p_fname.
  wa_fieldcat-tabname     = p_tname.
  wa_fieldcat-scrtext_m   = p_stext.
  wa_fieldcat-col_opt     = p_clopt.
  wa_fieldcat-no_zero     = p_blank.    " Replace '0' value by blank
  wa_fieldcat-outputlen   = p_outln.    " Output length

  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
ENDFORM.                    "fill_fcat
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
  gs_header-info = 'Requested materials' .
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
