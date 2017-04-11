*&---------------------------------------------------------------------*
*& Report  ZSOL_SD_REL_BILL_BLOCK
*&
*&---------------------------------------------------------------------*
*& Author: Saurabh Khare
*& Creation Date: 07.04.17 11:56 AM
*& Description: Release Billing Block from sales order line items(update z table)
*& TCODE: ZSD_BILLBLOCK
*&---------------------------------------------------------------------*

REPORT zsol_sd_rel_bill_block.

* ---- Data declaration ---- *

* ---- Type-Pools ---- *
TYPE-POOLS: slis.

* ---- Tables ---- *
TABLES: wb2_v_vbak_vbap2, zsol_billblock.

* ---- Constants ---- *
*CONSTANTS: .

* ---- Types ---- *
TYPES: BEGIN OF ty_final,
         sel,
         vbeln_i  TYPE wb2_v_vbak_vbap2-vbeln_i,
         posnr_i  TYPE wb2_v_vbak_vbap2-posnr_i,
         erdat    TYPE wb2_v_vbak_vbap2-erdat,
         erzet    TYPE wb2_v_vbak_vbap2-erzet,
         ernam    TYPE wb2_v_vbak_vbap2-ernam,
         audat    TYPE wb2_v_vbak_vbap2-audat,
         auart    TYPE wb2_v_vbak_vbap2-auart,
         faksk    TYPE wb2_v_vbak_vbap2-faksk,
         vtext    TYPE tvfst-vtext,
         netwr    TYPE wb2_v_vbak_vbap2-netwr,
         waerk    TYPE wb2_v_vbak_vbap2-waerk,
         kunnr    TYPE wb2_v_vbak_vbap2-kunnr,
         matnr_i  TYPE wb2_v_vbak_vbap2-matnr_i,
         arktx_i  TYPE wb2_v_vbak_vbap2-arktx_i,
         faksp_i  TYPE wb2_v_vbak_vbap2-faksp_i,
         vtext_i  TYPE tvfst-vtext,
         netwr_i  TYPE wb2_v_vbak_vbap2-netwr_i,
         waerk_i  TYPE wb2_v_vbak_vbap2-waerk_i,
         kwmeng_i TYPE wb2_v_vbak_vbap2-kwmeng_i,
         vrkme_i  TYPE wb2_v_vbak_vbap2-vrkme_i,
         netpr_i  TYPE wb2_v_vbak_vbap2-netpr_i,
         kpein_i  TYPE wb2_v_vbak_vbap2-kpein_i,
         kmein_i  TYPE wb2_v_vbak_vbap2-kmein_i,
         erdat_i  TYPE wb2_v_vbak_vbap2-erdat_i,
         ernam_i  TYPE wb2_v_vbak_vbap2-ernam_i,
         erzet_i  TYPE wb2_v_vbak_vbap2-erzet_i,
       END OF ty_final,

       BEGIN OF ty_log,
         log(280) TYPE c,
       END OF ty_log.

* ---- Internal Tables ---- *
DATA: it_data   TYPE TABLE OF wb2_v_vbak_vbap2,
      wa_data   TYPE wb2_v_vbak_vbap2,

      wa_update TYPE zsol_billblock,

      it_final  TYPE TABLE OF ty_final,
      wa_final  TYPE ty_final,

      it_tvfst  TYPE TABLE OF tvfst,
      wa_tvfst  TYPE tvfst,

      it_log    TYPE TABLE OF ty_log,
      wa_log    TYPE ty_log.

* ---- Variables ---- *
DATA: msg      TYPE string,              " Error handling messages
      txt      TYPE string,              " Message
      cnt_s(3) TYPE c,                   " Selected count
      cnt_p(3) TYPE c,                   " Approved count
      cnt_a(3) TYPE c,                   " Approved count
      lv_items TYPE n LENGTH 3,          " Table lines
      v_seq    TYPE zsol_billblock-sqnce.

* ---- ALV Related ---- *
DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      wa_layout   TYPE slis_layout_alv,
      g_variant   TYPE disvariant,
      gx_variant  TYPE disvariant.

* ---- Selection Screen ---- *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_vbeln FOR wb2_v_vbak_vbap2-vbeln_i,
                s_posnr FOR wb2_v_vbak_vbap2-posnr_i,
                s_audat FOR wb2_v_vbak_vbap2-audat OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK b1.

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
    MESSAGE 'No data found' TYPE 'I' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
**&---------------------------------------------------------------------*
**&      Form  GET_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM get_data .
* ---- Get sales order line items blocked for billing ---- *
  SELECT *
    FROM wb2_v_vbak_vbap2
    INTO TABLE it_data
    WHERE vbeln_i IN s_vbeln
    AND   posnr_i IN s_posnr
    AND   audat   IN s_audat
    AND   faksp_i EQ 'ZC'.

  SELECT *
    FROM tvfst
    INTO TABLE it_tvfst.

  SELECT SINGLE MAX( sqnce )
    FROM zsol_billblock
    INTO v_seq.
ENDFORM.                    "get_data
**&---------------------------------------------------------------------*
**&      Form  PROCESS_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM process_data .
* ---- Process data / Construct final ALV table ---- *
  IF it_data[] IS NOT INITIAL.

    LOOP AT it_data INTO wa_data.
      MOVE-CORRESPONDING wa_data TO wa_final.
      READ TABLE it_tvfst INTO wa_tvfst WITH KEY faksp = wa_final-faksk.
      IF sy-subrc = 0.
        wa_final-vtext = wa_tvfst-vtext.
      ENDIF.
      CLEAR wa_tvfst.
      READ TABLE it_tvfst INTO wa_tvfst WITH KEY faksp = wa_final-faksp_i.
      IF sy-subrc = 0.
        wa_final-vtext_i = wa_tvfst-vtext.
      ENDIF.
      APPEND wa_final TO it_final.
      CLEAR: wa_final, wa_data, wa_tvfst.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "process_data
**&---------------------------------------------------------------------*
**&      Form  FCAT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM fcat .
  PERFORM fill_fcat USING: 'VBELN_I'  'IT_FINAL'  'Sales Document'        space 'X',
                           'POSNR_I'  'IT_FINAL'  'Sales Document Item'   space 'X',
                           'ERDAT'    'IT_FINAL'  'Creation Date(Head)'   space space,
                           'ERZET'    'IT_FINAL'  'Creation Time(Head)'   space space,
                           'ERNAM'    'IT_FINAL'  'Created By(Head)'      space space,
                           'AUDAT'    'IT_FINAL'  'Document Date'         space space,
                           'AUART'    'IT_FINAL'  'Document Type'         space space,
                           'FAKSK'    'IT_FINAL'  'Bill. Block(Head)'     space space,
                           'VTEXT'    'IT_FINAL'  'Bill. Block Desc.(H)'  space space,
                           'NETWR'    'IT_FINAL'  'Net Value(Head)'       space space,
                           'WAERK'    'IT_FINAL'  'Doc. Currency(Head)'   space space,
                           'KUNNR'    'IT_FINAL'  'Customer'              space space,
                           'MATNR_I'  'IT_FINAL'  'Material'              space space,
                           'ARKTX_I'  'IT_FINAL'  'Mat. Desc.'            space space,
                           'FAKSP_I'  'IT_FINAL'  'Bill. Block'           space 'X',
                           'VTEXT_I'  'IT_FINAL'  'Bill. Block Desc'      space 'X',
                           'NETWR_I'  'IT_FINAL'  'Net Value'             space space,
                           'WAERK_I'  'IT_FINAL'  'Doc. Currency'         space space,
                           'KWMENG_I' 'IT_FINAL'  'Order Qty.'            space space,
                           'VRKME_I'  'IT_FINAL'  'Unit'                  space space,
                           'NETPR_I'  'IT_FINAL'  'Net Price'             space space,
                           'KPEIN_I'  'IT_FINAL'  'Con. Pr. Unit'         space space,
                           'KMEIN_I'  'IT_FINAL'  'Cond. Unit'            space space,
                           'ERDAT_I'  'IT_FINAL'  'Creation Date'         space space,
                           'ERNAM_I'  'IT_FINAL'  'Created By'            space space,
                           'ERZET_I'  'IT_FINAL'  'Creation Time'         space space.
ENDFORM.                    "fcat
**&---------------------------------------------------------------------*
**&      Form  ALV_DISPLAY
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
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
*
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
        textn         TYPE slis_listheader-info,
        v_text(20)    TYPE c.

* ---- Title ---- *
  gs_header-typ = 'H'.
  CLEAR textn.
  CONCATENATE textn 'Release Billing Block' INTO textn SEPARATED BY space.
  gs_header-info = textn.
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- User ---- *
  gs_header-typ  = 'S'.
  gs_header-key = 'User :- '.
  CONCATENATE  sy-uname ' ' INTO gs_header-info.   "Logged in user
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- Date ---- *
  gs_header-typ  = 'S'.
  gs_header-key = 'Date :- '.
  CLEAR v_text.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = sy-datum
    IMPORTING
      date_external            = v_text
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    CONCATENATE v_text gs_header-info INTO gs_header-info.
  ENDIF.
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- Time ---- *
  gs_header-typ  = 'S'.
  gs_header-key = 'Time :- '.
  CLEAR v_text.
  WRITE: sy-uzeit TO v_text USING EDIT MASK '__:__:__'.
  CONCATENATE  v_text gs_header-info INTO gs_header-info.   "Logged in user
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
  SET PF-STATUS 'ZSTAT_BBLOCK'.
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

  IF it_final[] IS NOT INITIAL.
    PERFORM rel_bill_block.
  ENDIF.
  rs_selfield-refresh = 'X'.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*& Form REL_BILL_BLOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM rel_bill_block .

  DATA: order_headerx TYPE bapisdh1x,
        return        TYPE TABLE OF bapiret2   WITH HEADER LINE,
        order_item    TYPE TABLE OF bapisditm  WITH HEADER LINE,
        order_itemx   TYPE TABLE OF bapisditmx WITH HEADER LINE.

  DATA: retcode TYPE inri-returncode.

  READ TABLE it_final INTO wa_final WITH KEY sel = 'X'.
  IF sy-subrc = 0.

    LOOP AT it_final INTO wa_final WHERE sel = 'X'.
      ADD 1 TO cnt_s.

      order_headerx-updateflag = 'U'.

      order_item-itm_number = wa_final-posnr_i.
      order_item-bill_block = space.
      APPEND order_item.

      order_itemx-itm_number = wa_final-posnr_i.
      order_itemx-updateflag = 'U'.
      order_itemx-bill_block = 'X'.
      APPEND order_itemx.

      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          salesdocument    = wa_final-vbeln_i
          order_header_inx = order_headerx
        TABLES
          return           = return
          order_item_in    = order_item
          order_item_inx   = order_itemx.

      READ TABLE return WITH KEY type = 'E'.
      IF sy-subrc <> 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*       EXPORTING
*         WAIT          =
*       IMPORTING
*         RETURN        =
          .
        IF sy-subrc = 0.
          CLEAR msg.
          CONCATENATE wa_final-vbeln_i wa_final-posnr_i ': Billing block released for the next 48 hours' INTO msg
          SEPARATED BY space.
          MOVE msg TO wa_log-log.

          DELETE it_final.
          ADD 1 TO cnt_a.
        ENDIF.
      ELSE.
        CLEAR msg.
        CONCATENATE wa_final-vbeln_i wa_final-posnr_i ':' return-message INTO msg SEPARATED BY space.
        MOVE msg TO wa_log-log.
        ADD 1 TO cnt_p.
      ENDIF.
      APPEND wa_log TO it_log.
      CLEAR: wa_final, order_headerx, order_item, order_itemx, wa_log.
      REFRESH: order_item, order_itemx, return.
    ENDLOOP.

    IF sy-subrc = 0 AND ( cnt_a IS NOT INITIAL OR cnt_s IS NOT INITIAL ).
      CLEAR msg.
      CONCATENATE cnt_s 'items selected for processing.' INTO msg SEPARATED BY space.
      CONCATENATE msg cnt_a 'items processed successfully.' INTO msg SEPARATED BY space.
      CONCATENATE msg cnt_p 'items could not be processed.' INTO msg SEPARATED BY space.
      MESSAGE msg TYPE 'I'.
      cnt_s = cnt_p = cnt_a = 0.
    ENDIF.

    IF it_log IS NOT INITIAL.
      CALL FUNCTION 'ADA_POPUP_WITH_TABLE'
        EXPORTING
          startpos_col = 20
          startpos_row = 1
          titletext    = 'Log'
*         WORDWRAP_POSITION       =
        TABLES
          valuetab     = it_log.
      REFRESH it_log[].
    ENDIF.
  ELSE.
    MESSAGE 'No rows selected for processing.' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0408   text
*      -->P_0409   text
*      -->P_0410   text
*      -->P_0411   text
*      -->P_SPACE  text
*      -->P_0413   text
*----------------------------------------------------------------------*
FORM fill_fcat  USING    VALUE(p_fname)
                         VALUE(p_tname)
                         VALUE(p_stext)
                         VALUE(p_outln)
                         VALUE(p_key).

  wa_fieldcat-fieldname = p_fname.
  wa_fieldcat-tabname   = p_tname.
  wa_fieldcat-seltext_m = p_stext.
  wa_fieldcat-outputlen = p_outln.
  wa_fieldcat-key       = p_key.

  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

ENDFORM.                    " FILL_FCAT
