*&---------------------------------------------------------------------*
*& Report  ZSOL_SD_REL_BILL_BLOCK
*&
*&---------------------------------------------------------------------*
*& Author: Saurabh Khare
*& Creation Date: 07.04.17 11:56 AM
*& Description: Release Credit Billing Block from sales order line items(update z table)
*& TCODE: ZSD_BILLBLOCK
*&---------------------------------------------------------------------*

REPORT zsol_sd_rel_bill_block.

* ---- Data declaration ---- *

* ---- Type-Pools ---- *
TYPE-POOLS: slis.

* ---- Constants ---- *
CONSTANTS: startcol TYPE i VALUE 20,
           startrow TYPE i VALUE 1.

* ---- Types ---- *
TYPES: BEGIN OF ty_final,
         sel(1)   TYPE c,
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
         vkorg    TYPE wb2_v_vbak_vbap2-vkorg,
         vtweg    TYPE wb2_v_vbak_vbap2-vtweg,
         name1    TYPE kna1-name1,
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
         kzwi7    TYPE vbap-kzwi7,
       END OF ty_final,

       BEGIN OF ty_log,                           " Output Log
         log(280) TYPE c,
       END OF ty_log.

* ---- Internal Tables ---- *
DATA: it_data  TYPE TABLE OF wb2_v_vbak_vbap2 ##NEEDED, " Sales Order
      wa_data  TYPE wb2_v_vbak_vbap2          ##NEEDED,

      it_final TYPE TABLE OF ty_final ##NEEDED,
      wa_final TYPE ty_final          ##NEEDED,

      it_tmp   TYPE TABLE OF ty_final ##NEEDED,
      wa_tmp   TYPE ty_final          ##NEEDED,

      it_tvfst TYPE TABLE OF tvfst ##NEEDED,            " Billing Block
      wa_tvfst TYPE tvfst          ##NEEDED,

      it_log   TYPE TABLE OF ty_log ##NEEDED,           " Output Log
      wa_log   TYPE ty_log          ##NEEDED,

      it_kna1  TYPE TABLE OF kna1 ##NEEDED,
      wa_kna1  TYPE kna1          ##NEEDED,

      it_vbap  TYPE TABLE OF vbap ##NEEDED,
      wa_vbap  TYPE vbap          ##NEEDED.

* ---- Variables ---- *
DATA: msg      TYPE string ##NEEDED,               " Error handling messages
      cnt_s(3) TYPE c      ##NEEDED,               " Selected count
      cnt_p(3) TYPE c      ##NEEDED,               " Failed count
      cnt_a(3) TYPE c      ##NEEDED,               " Successful count
      vbeln    TYPE vbeln  ##NEEDED,
      posnr    TYPE posnr  ##NEEDED,
      audat    TYPE audat  ##NEEDED,
      kunnr    TYPE kunnr  ##NEEDED,
      vkorg    TYPE vkorg  ##NEEDED,
      vtweg    TYPE vtweg  ##NEEDED.

* ---- ALV Related ---- *
DATA: it_fieldcat TYPE slis_t_fieldcat_alv ##NEEDED,
      wa_fieldcat TYPE slis_fieldcat_alv   ##NEEDED,
      wa_layout   TYPE slis_layout_alv     ##NEEDED,
      g_variant   TYPE disvariant          ##NEEDED,
      gx_variant  TYPE disvariant          ##NEEDED.

* ---- Selection Screen ---- *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_vbeln FOR vbeln,
                s_posnr FOR posnr,
                s_audat FOR audat," OBLIGATORY DEFAULT sy-datum,
                s_kunnr FOR kunnr,
                s_vkorg FOR vkorg,
                s_vtweg FOR vtweg.
SELECTION-SCREEN END OF BLOCK b1.

PARAMETERS: variant TYPE disvariant-variant NO-DISPLAY.

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
    MESSAGE 'No data found' TYPE 'I' DISPLAY LIKE 'E' ##NO_TEXT.
    RETURN.
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
    AND   kunnr   IN s_kunnr
    AND   vkorg   IN s_vkorg
    AND   vtweg   IN s_vtweg
    AND   faksp_i EQ 'ZC'.      " Credit Block only

  IF sy-subrc = 0.
    SELECT *
      FROM kna1
      INTO TABLE it_kna1
      FOR ALL ENTRIES IN it_data
      WHERE kunnr = it_data-kunnr.

    SELECT *
      FROM vbap
      INTO TABLE it_vbap
      FOR ALL ENTRIES IN it_data
      WHERE vbeln = it_data-vbeln_i
      AND   posnr = it_data-posnr_i.
  ENDIF.

  SELECT *
    FROM tvfst
    INTO TABLE it_tvfst
    WHERE faksp EQ 'ZC'.
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

      SHIFT wa_final-vbeln_i LEFT DELETING LEADING '0'.
      SHIFT wa_final-posnr_i LEFT DELETING LEADING '0'.

      READ TABLE it_vbap INTO wa_vbap WITH KEY vbeln = wa_data-vbeln_i
                                               posnr = wa_data-posnr_i.
      IF sy-subrc = 0.
        wa_final-kzwi7 = wa_vbap-kzwi7.
      ENDIF.

      READ TABLE it_kna1 INTO wa_kna1 WITH KEY kunnr = wa_data-kunnr.
      IF sy-subrc = 0.
        wa_final-name1 = wa_kna1-name1.
      ENDIF.

      SHIFT wa_final-kunnr LEFT DELETING LEADING '0'.

      " Get billing block description(header)
      READ TABLE it_tvfst INTO wa_tvfst WITH KEY faksp = wa_final-faksk.
      IF sy-subrc = 0.
        wa_final-vtext = wa_tvfst-vtext.
      ENDIF.
      CLEAR wa_tvfst.
      " Get billing block description(item)
      READ TABLE it_tvfst INTO wa_tvfst WITH KEY faksp = wa_final-faksp_i.
      IF sy-subrc = 0.
        wa_final-vtext_i = wa_tvfst-vtext.
      ENDIF.
      APPEND wa_final TO it_final.
      CLEAR: wa_final, wa_data, wa_tvfst, wa_kna1, wa_vbap.
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
  PERFORM fill_fcat USING: 'VBELN_I'  'IT_FINAL'  'Sales Document.'       space 'X'   ##NO_TEXT,
                           'POSNR_I'  'IT_FINAL'  'Sales Document Item'   space 'X'   ##NO_TEXT,
                           'ERDAT'    'IT_FINAL'  'Creation Date(Head)'   space space ##NO_TEXT,
                           'ERZET'    'IT_FINAL'  'Creation Time(Head)'   space space ##NO_TEXT,
                           'ERNAM'    'IT_FINAL'  'Created By(Head)'      space space ##NO_TEXT,
                           'AUDAT'    'IT_FINAL'  'Document Date'         space space ##NO_TEXT,
                           'AUART'    'IT_FINAL'  'Document Type'         space space ##NO_TEXT,
                           'FAKSK'    'IT_FINAL'  'Bill. Block(Head)'     space space ##NO_TEXT,
                           'VTEXT'    'IT_FINAL'  'Bill. Block Desc.(H)'  space space ##NO_TEXT,
                           'NETWR'    'IT_FINAL'  'Net Value(Head)'       space space ##NO_TEXT,
                           'WAERK'    'IT_FINAL'  'Doc. Currency(Head)'   space space ##NO_TEXT,
                           'VKORG'    'IT_FINAL'  'Sales Organisation'    space space ##NO_TEXT,
                           'VTWEG'    'IT_FINAL'  'Distr. Channel'        space space ##NO_TEXT,
                           'KUNNR'    'IT_FINAL'  'Customer No.'          space space ##NO_TEXT,
                           'NAME1'    'IT_FINAL'  'Customer Name.'        space space ##NO_TEXT,
                           'MATNR_I'  'IT_FINAL'  'Material'              space space ##NO_TEXT,
                           'ARKTX_I'  'IT_FINAL'  'Mat. Desc.'            space space ##NO_TEXT,
                           'FAKSP_I'  'IT_FINAL'  'Bill. Block'           space 'X'   ##NO_TEXT,
                           'VTEXT_I'  'IT_FINAL'  'Bill. Block Desc'      space 'X'   ##NO_TEXT,
                           'NETWR_I'  'IT_FINAL'  'Net Value'             space space ##NO_TEXT,
                           'WAERK_I'  'IT_FINAL'  'Doc. Currency'         space space ##NO_TEXT,
                           'KWMENG_I' 'IT_FINAL'  'Order Qty.'            space space ##NO_TEXT,
                           'VRKME_I'  'IT_FINAL'  'Unit'                  space space ##NO_TEXT,
                           'NETPR_I'  'IT_FINAL'  'Net Price'             space space ##NO_TEXT,
                           'KPEIN_I'  'IT_FINAL'  'Con. Pr. Unit'         space space ##NO_TEXT,
                           'KMEIN_I'  'IT_FINAL'  'Cond. Unit'            space space ##NO_TEXT,
                           'ERDAT_I'  'IT_FINAL'  'Creation Date'         space space ##NO_TEXT,
                           'ERNAM_I'  'IT_FINAL'  'Created By'            space space ##NO_TEXT,
                           'ERZET_I'  'IT_FINAL'  'Creation Time'         space space ##NO_TEXT,
                           'KZWI7'    'IT_FINAL'  'Subtotal 6(KZWI7)'     space space ##NO_TEXT.
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
  IF sy-subrc <> 0 ##NEEDED.
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
FORM top-of-page  ##FIELD_HYPHEN ##CALLED.
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
  CONCATENATE textn 'Release Billing Block' INTO textn SEPARATED BY space ##NO_TEXT.
  gs_header-info = textn.
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- User ---- *
  gs_header-typ  = 'S'.
  gs_header-key = 'User :- ' ##NO_TEXT.
  CONCATENATE  sy-uname ' ' INTO gs_header-info.   "Logged in user
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- Date ---- *
  gs_header-typ  = 'S'.
  gs_header-key = 'Date :- ' ##NO_TEXT.
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
  gs_header-key = 'Time :- ' ##NO_TEXT.
  CLEAR v_text.
  WRITE: sy-uzeit TO v_text USING EDIT MASK '__:__:__'.
  CONCATENATE  v_text gs_header-info INTO gs_header-info.   "Logged in user
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- Total No. of Records Selected ---- *
  DESCRIBE TABLE  it_final LINES ld_lines.
  ld_linesc = ld_lines.
  CONCATENATE 'Total no. of records selected: ' ld_linesc INTO textn SEPARATED BY space ##NO_TEXT.
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
FORM set_pf_status USING rt_extab TYPE slis_t_extab ##NEEDED ##CALLED.
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
                        rs_selfield TYPE slis_selfield ##NEEDED ##CALLED.

  IF it_final[] IS NOT INITIAL.
    PERFORM rel_bill_block.     " Release credit billing block
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

  READ TABLE it_final INTO wa_final WITH KEY sel = 'X'.
  IF sy-subrc = 0.  " Proceed only if atleast one row is selected
    it_tmp[] = it_final[].
    SORT it_tmp[] BY vbeln_i posnr_i.

    LOOP AT it_tmp INTO wa_tmp WHERE sel = 'X'.

      LOOP AT it_final INTO wa_final WHERE vbeln_i = wa_tmp-vbeln_i
                                      AND  sel = 'X'.
        ADD 1 TO cnt_s.                 " No of rows selected
        order_headerx-updateflag = 'U'.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_final-posnr_i
          IMPORTING
            output = wa_final-posnr_i.

        order_item-itm_number = wa_final-posnr_i.
        order_item-bill_block = space.
        APPEND order_item.

        order_itemx-itm_number = wa_final-posnr_i.
        order_itemx-updateflag = 'U'.
        order_itemx-bill_block = 'X'.
        APPEND order_itemx.
        CLEAR: order_item, order_itemx.
      ENDLOOP.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_tmp-vbeln_i
        IMPORTING
          output = wa_tmp-vbeln_i.

      IF order_item[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
          EXPORTING
            salesdocument    = wa_tmp-vbeln_i
            order_header_inx = order_headerx
          TABLES
            return           = return
            order_item_in    = order_item
            order_item_inx   = order_itemx.

        READ TABLE return WITH KEY type = 'E'.
        IF sy-subrc <> 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

          LOOP AT order_item.
            CLEAR msg.
            CONCATENATE wa_tmp-vbeln_i order_item-itm_number ': Billing block released for the next 48 hours' INTO msg
            SEPARATED BY space ##NO_TEXT.
            MOVE msg TO wa_log-log.
            APPEND wa_log TO it_log.
            SHIFT order_item-itm_number LEFT DELETING LEADING '0'.
            DELETE it_final WHERE vbeln_i = wa_final-vbeln_i AND posnr_i = order_item-itm_number.
            ADD 1 TO cnt_a.   " No. of successful rows
          ENDLOOP.
        ELSE.
          CLEAR msg.
          CONCATENATE wa_final-vbeln_i wa_final-posnr_i ':' return-message INTO msg SEPARATED BY space.
          MOVE msg TO wa_log-log.
          APPEND wa_log TO it_log.
          ADD 1 TO cnt_p.     " No. of failed rows
        ENDIF.
      ENDIF.
      SHIFT wa_tmp-vbeln_i LEFT DELETING LEADING '0'.
      DELETE it_tmp WHERE vbeln_i = wa_tmp-vbeln_i.
      CLEAR: wa_final, order_headerx, wa_log, wa_tmp.
      REFRESH: order_item, order_itemx, return.
    ENDLOOP.

    IF ( cnt_a IS NOT INITIAL OR cnt_s IS NOT INITIAL ).
      CLEAR msg.
      CONCATENATE cnt_s 'items selected for processing.' INTO msg SEPARATED BY space ##NO_TEXT.
      CONCATENATE msg cnt_a 'items processed successfully.' INTO msg SEPARATED BY space ##NO_TEXT.
      CONCATENATE msg cnt_p 'items could not be processed.' INTO msg SEPARATED BY space ##NO_TEXT.
      MESSAGE msg TYPE 'I'.
      cnt_s = cnt_p = cnt_a = 0.
    ENDIF.

    IF it_log IS NOT INITIAL.
      CALL FUNCTION 'ADA_POPUP_WITH_TABLE'
        EXPORTING
          startpos_col = startcol
          startpos_row = startrow
          titletext    = 'Log'
*         WORDWRAP_POSITION       =
        TABLES
          valuetab     = it_log.
      REFRESH it_log[].
    ENDIF.
  ELSE.
    MESSAGE 'No rows selected for processing.' TYPE 'S' DISPLAY LIKE 'E' ##NO_TEXT.
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
FORM fill_fcat  USING    VALUE(p_fname) TYPE any
                         VALUE(p_tname) TYPE any
                         VALUE(p_stext) TYPE any
                         VALUE(p_outln) TYPE any
                         VALUE(p_key)   TYPE any.

  wa_fieldcat-fieldname = p_fname.
  wa_fieldcat-tabname   = p_tname.
  wa_fieldcat-seltext_m = p_stext.
  wa_fieldcat-outputlen = p_outln.
  wa_fieldcat-key       = p_key.

  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR wa_fieldcat.

ENDFORM.                    " FILL_FCAT
