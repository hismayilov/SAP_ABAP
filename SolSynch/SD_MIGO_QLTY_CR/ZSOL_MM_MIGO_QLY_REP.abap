*&---------------------------------------------------------------------*
*& Report  ZSOL_MM_MIGO_QLY_REP
*& Tcode: zmigo_qlty
*&---------------------------------------------------------------------*
*&Developed by : Prasad Gurjar
*&Developed On : 18.10.2016
*&Description  : MIGO quality criteria
*&---------------------------------------------------------------------*

REPORT  zsol_mm_migo_qly_rep.

TYPE-POOLS : slis.
TABLES : zqlty_data.

TYPES : BEGIN OF ty_final.
        INCLUDE STRUCTURE zqlty_data.
TYPES:  maktx TYPE maktx.
TYPES : END OF ty_final.

DATA: it_final TYPE STANDARD TABLE OF ty_final,
      wa_final TYPE ty_final,
      it_makt TYPE STANDARD TABLE OF makt,
      wa_makt TYPE makt.

DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid,
      g_save       TYPE c VALUE 'X',
      g_variant    TYPE disvariant,
      gx_variant   TYPE disvariant,
      g_exit       TYPE c,
      ispfli       TYPE TABLE OF spfli.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
SELECT-OPTIONS: s_mblnr FOR zqlty_data-mblnr,
                s_budat FOR zqlty_data-budat_mkpf,
                s_mjahr FOR zqlty_data-mjahr ,
                s_cpudt FOR zqlty_data-cpudt_mkpf OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b15 WITH FRAME TITLE text-002 .
PARAMETERS: variant LIKE disvariant-variant NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b15.
**GETTING DEFAULT VARIANT

INITIALIZATION.

  t1 = 'Input Data'.

  gx_variant-report = sy-repid.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    variant = gx_variant-variant.
  ENDIF.

START-OF-SELECTION.
  PERFORM data_retrivel.
  PERFORM build_fieldcatalog.
  PERFORM display_alv_report.
*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_retrivel .

  SELECT *
    FROM zqlty_data
    INTO CORRESPONDING FIELDS OF TABLE it_final
    WHERE mblnr      IN s_mblnr
    AND   mjahr      IN s_mjahr
    AND   budat_mkpf IN s_budat
    AND   cpudt_mkpf IN s_cpudt.

  IF it_final[] IS NOT INITIAL.

    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE it_makt
      FOR ALL ENTRIES IN it_final
      WHERE matnr EQ it_final-matnr.

    SORT it_final ASCENDING BY mblnr.
    DATA: v_tabix TYPE sy-tabix.
    LOOP AT it_final INTO wa_final.
      v_tabix = sy-tabix.
      READ TABLE it_makt INTO wa_makt WITH KEY matnr = wa_final-matnr.
      IF sy-subrc = 0.
        wa_final-maktx = wa_makt-maktx.
      ENDIF.
      MODIFY it_final FROM wa_final TRANSPORTING maktx.
    ENDLOOP.
  ENDIF.

  LOOP AT it_final INTO wa_final.
    AT END OF mblnr.
      IF wa_final-mblnr IS NOT INITIAL.
        INSERT INITIAL LINE INTO it_final INDEX ( sy-tabix + 1 ).
      ENDIF.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " DATA_RETRIVEL
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcatalog .

  fieldcatalog-fieldname      = 'MBLNR'.
  fieldcatalog-seltext_m      = 'Material Doc.'.
  gd_layout-colwidth_optimize = 'X'.
  fieldcatalog-key = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'EBELN'.
  fieldcatalog-seltext_m      = 'PO No.'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'ZEILE'.
  fieldcatalog-seltext_m      = 'Item No.'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'MATNR'.
  fieldcatalog-seltext_m      = 'Material'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'MAKTX'.
  fieldcatalog-seltext_m      = 'Material Desc.'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'MJAHR'.
  fieldcatalog-seltext_m      = 'Year'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'WERKS'.
  fieldcatalog-seltext_m      = 'Plant'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'BUKRS'.
  fieldcatalog-seltext_m      = 'Company Code'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'BUDAT_MKPF'.
  fieldcatalog-seltext_m      = 'Posting Date'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'CPUDT_MKPF'.
  fieldcatalog-seltext_m      = 'Entry Date'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'MENGE'.
  fieldcatalog-seltext_m      = 'Quantity'.
  fieldcatalog-no_zero        = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'STREN'.
  fieldcatalog-seltext_m      = 'Strength'.
  fieldcatalog-no_zero        = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'STUM'.
  fieldcatalog-seltext_m      = 'Str.Unit'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'WEIGHT'.
  fieldcatalog-seltext_m      = 'Weight'.
  fieldcatalog-no_zero        = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'WUM'.
  fieldcatalog-seltext_m      = 'Weight Unit'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

ENDFORM.                    " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_report .
  gd_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = gd_repid
      is_layout              = gd_layout
      i_callback_top_of_page = 'TOP-OF-PAGE'
      it_fieldcat            = fieldcatalog[]
      i_save                 = 'X'
      is_variant             = g_variant
    TABLES
      t_outtab               = it_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " DISPLAY_ALV_REPORT
*-------------------------------------------------------------------*
* Form  TOP-OF-PAGE                                                 *
*-------------------------------------------------------------------*
* ALV Report Header                                                 *
*-------------------------------------------------------------------*
FORM top-of-page.
*ALV Header declarations
  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c.

*Title
  wa_header-typ  = 'H'.
  wa_header-info = 'MIGO Quality Criteria Report'.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

*User
  wa_header-typ  = 'S'.
  wa_header-key = 'User: '.
  CONCATENATE  sy-uname ' ' INTO wa_header-info.   "Logged in user
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

*Period
  wa_header-typ  = 'S'.
  wa_header-key = 'Entry Date:'.
  CONCATENATE  s_cpudt-low+6(2) '/' s_cpudt-low+4(2)'/' s_cpudt-low+0(4) '.TO.'
               s_cpudt-high+6(2) '/' s_cpudt-high+4(2) '/' s_cpudt-high+0(4) ' ' INTO wa_header-info.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

* Total No. of Records Selected
  DESCRIBE TABLE  it_final LINES ld_lines.
  ld_linesc = ld_lines.
  CONCATENATE 'Total No. of Records Selected: ' ld_linesc INTO t_line SEPARATED BY space.
  wa_header-typ  = 'A'.
  wa_header-info = t_line.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, t_line.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.
ENDFORM.                    "top-of-page
