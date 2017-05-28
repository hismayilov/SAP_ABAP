*&---------------------------------------------------------------------*
*& Report  ZSOL_PUR_REG
*&
*&---------------------------------------------------------------------*
*&Developed By : Prasad Gurjar
*&Developed on : 01/02/2017
*&Description  : Purchase register
*&               1.Create sales order
*&               2.Goods movement
*&---------------------------------------------------------------------*

REPORT  zsol_mm_pur_reg.

TYPE-POOLS: slis.

*&---------------------------------------------------------------------*
*&  Selection Screen
*&---------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE t2.
*PARAMETERS: p_vari LIKE disvariant-variant.
*SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
PARAMETERS : p_vbeln TYPE vbeln OBLIGATORY.
*PARAMETERS : p_kunnr TYPE vbak-kunnr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b15 WITH FRAME TITLE text-002 .
PARAMETERS: variant LIKE disvariant-variant NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b15.
*&---------------------------------------------------------------------*
*&  Data declaration
*&---------------------------------------------------------------------*

DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid,
      g_save       TYPE c VALUE 'X',
      g_variant    TYPE disvariant,
      gx_variant   TYPE disvariant,
      g_exit       TYPE c,
      ispfli       TYPE TABLE OF spfli.

TYPES: BEGIN OF ty_final,
        sel,
        sow       TYPE ekkn-vbeln,
        vend      TYPE bseg-lifnr,
        mat       TYPE bseg-matnr,
        po        TYPE bseg-belnr,
        miro      TYPE mkpf-mblnr,
        grdate    TYPE ekbe-budat,
        amt       TYPE bseg-dmbtr,
        clr_doc   TYPE bseg-augbl,
        qty       TYPE bseg-menge,
        plant     TYPE vbap-werks,
        deb_note  TYPE mkpf-mblnr,
        so_posted TYPE c,
        gm_posted TYPE c,
        wh(20) TYPE c,
        whn(100) TYPE c,
        bags(50) TYPE c,
        sales_or  TYPE ekkn-vbeln,
        mat_doc   TYPE mkpf-mblnr,
        deb_flag  TYPE c,
        batch     TYPE ekbe-charg,
      END OF ty_final.

TYPES: BEGIN OF ty_rbkp_temp,
        rmwwr TYPE rmwwr,
      END OF ty_rbkp_temp.

DATA: it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final,
      it_view TYPE TABLE OF wb2_v_mkpf_mseg2,
      wa_view TYPE wb2_v_mkpf_mseg2,
      it_final_sum TYPE TABLE OF ty_final,
      wa_final_sum TYPE ty_final,
      it_ekkn TYPE STANDARD TABLE OF ekkn,
      wa_ekkn TYPE ekkn,
      it_ekko TYPE STANDARD TABLE OF ekko,
      wa_ekko TYPE ekko,
      it_ekbe TYPE STANDARD TABLE OF ekbe,
      wa_ekbe TYPE ekbe,
      wa_ekbe_miro TYPE ekbe,
      it_rbkp TYPE STANDARD TABLE OF rbkp,
      wa_rbkp TYPE rbkp,
      wa_rbkp_deb TYPE rbkp,
      it_rbkp_temp TYPE STANDARD TABLE OF ty_rbkp_temp,
      wa_rbkp_temp TYPE ty_rbkp_temp,
      it_rseg TYPE STANDARD TABLE OF rseg,
      wa_rseg TYPE rseg,
      it_t001l TYPE STANDARD TABLE OF t001l,
      wa_t001l TYPE t001l,
      it_sales TYPE TABLE OF wb2_v_vbak_vbap2,
      wa_sales TYPE wb2_v_vbak_vbap2,
      it_konv TYPE STANDARD TABLE OF konv,
      wa_konv TYPE konv,
      it_sales_upd TYPE STANDARD TABLE OF ztb_sales_data,
      wa_sales_upd TYPE ztb_sales_data,
      wa_chk_upd TYPE ztb_sales_data.

*&---------------------------------------------------------------------*
*&  Initialization
*&---------------------------------------------------------------------*
INITIALIZATION.
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

  gd_layout-get_selinfos = 'X'.
  gd_layout-group_change_edit = 'X'.
  gd_layout-box_fieldname = 'SEL'.

  t1 = 'Input Data'.
*  t2 = 'Select Layout'.
*&---------------------------------------------------------------------*
*&  START-OF-SELECTION
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM data_retrivel.
  PERFORM build_fieldcatalog.

  IF it_final IS NOT INITIAL.
    PERFORM display_alv_report.
  ELSE.
    MESSAGE 'No data selected' TYPE 'I' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
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
    FROM ekkn
    INTO CORRESPONDING FIELDS OF TABLE it_ekkn
    WHERE vbeln EQ p_vbeln.

  SELECT *
    FROM ekbe
    INTO CORRESPONDING FIELDS OF TABLE it_ekbe
    FOR ALL ENTRIES IN it_ekkn
    WHERE ebeln EQ it_ekkn-ebeln.

  IF it_ekbe[] IS NOT INITIAL.
    SELECT *
      FROM wb2_v_mkpf_mseg2
      INTO CORRESPONDING FIELDS OF TABLE it_view
      FOR ALL ENTRIES IN it_ekbe
      WHERE mblnr EQ it_ekbe-belnr
      AND   mjahr EQ it_ekbe-gjahr.

    SELECT *
      FROM rbkp
      INTO CORRESPONDING FIELDS OF TABLE it_rbkp
      FOR ALL ENTRIES IN it_ekbe
      WHERE belnr EQ it_ekbe-belnr
      AND   gjahr EQ it_ekbe-gjahr.

    IF it_view[] IS NOT INITIAL.
      SELECT *
          FROM t001l
          INTO CORRESPONDING FIELDS OF TABLE it_t001l
          FOR ALL ENTRIES IN it_view
          WHERE werks = it_view-werks_i
          AND   lgort = it_view-lgort_i.

    ENDIF.
  ENDIF.

  IF it_ekkn[] IS NOT INITIAL.

    SELECT *
      FROM ekko
      INTO CORRESPONDING FIELDS OF TABLE it_ekko
      FOR ALL ENTRIES IN it_ekkn
      WHERE ebeln EQ it_ekkn-ebeln.

    SELECT *
      FROM rseg
      INTO CORRESPONDING FIELDS OF TABLE it_rseg
      FOR ALL ENTRIES IN it_ekkn
      WHERE ebeln EQ it_ekkn-ebeln
      AND   ebelp EQ it_ekkn-ebelp
      AND   zekkn EQ it_ekkn-zekkn.

  ENDIF.

  LOOP AT it_rbkp INTO wa_rbkp.
    READ TABLE it_ekbe INTO wa_ekbe WITH KEY belnr = wa_rbkp-belnr gjahr = wa_rbkp-gjahr.
    IF wa_ekbe-bewtp EQ 'N'.
      wa_rbkp_temp-rmwwr = wa_rbkp-rmwwr * -1.
    ELSE.
      wa_rbkp_temp-rmwwr = wa_rbkp-rmwwr.
    ENDIF.
    COLLECT wa_rbkp_temp INTO it_rbkp_temp.
  ENDLOOP.

  LOOP AT it_ekbe INTO wa_ekbe WHERE bwart EQ '101'.
    wa_final-miro = wa_ekbe-belnr.

    READ TABLE it_view INTO wa_view WITH KEY mblnr = wa_ekbe-belnr mjahr = wa_ekbe-gjahr.
    IF sy-subrc = 0.
      wa_final-sow = wa_view-kdauf_i.
      wa_final-mat = wa_view-matnr_i.
      wa_final-batch = wa_view-charg_i.
      wa_final-vend = wa_view-lifnr_i.
*      wa_final-amt = wa_view-bualt_i.
      wa_final-qty = wa_view-menge_i.
      wa_final-bags = wa_view-sgtxt_i.
      wa_final-wh = wa_view-lgort_i.
      wa_final-po = wa_view-ebeln_i.
      wa_final-grdate = wa_view-budat.
    ENDIF.

    READ TABLE it_ekbe INTO wa_ekbe_miro WITH KEY bewtp = 'Q' lfbnr = wa_ekbe-belnr.
    IF sy-subrc = 0.
      READ TABLE it_rbkp INTO wa_rbkp WITH KEY belnr = wa_ekbe_miro-belnr gjahr = wa_ekbe_miro-gjahr.
      IF sy-subrc = 0.
        READ TABLE it_rbkp INTO wa_rbkp_deb WITH KEY xblnr = wa_rbkp-belnr gjahr = wa_rbkp-gjahr.
        IF sy-subrc = 0.
          wa_final-amt = wa_rbkp-rmwwr - ( wa_rbkp_deb-rmwwr - wa_rbkp_deb-wmwst1 ) .
        ELSE.
          wa_final-amt = wa_rbkp-rmwwr.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE it_t001l INTO wa_t001l WITH KEY werks = wa_view-werks_i lgort = wa_view-lgort_i.
    IF sy-subrc = 0.
      wa_final-whn = wa_t001l-lgobe.
    ENDIF.
    APPEND wa_final TO it_final.
    CLEAR : wa_final,wa_ekbe,wa_view,wa_t001l.

  ENDLOOP.

  LOOP AT it_final INTO wa_final.

    SELECT SINGLE * FROM ztb_sales_data INTO wa_chk_upd WHERE sow  EQ wa_final-sow
                                                          AND po   EQ wa_final-po
                                                          AND miro EQ wa_final-miro.
    IF sy-subrc = 0.
      wa_final-so_posted = wa_chk_upd-so_posted.
      wa_final-gm_posted = wa_chk_upd-gm_posted.
      wa_final-sales_or = wa_chk_upd-sales_or.
      wa_final-mat_doc = wa_chk_upd-mat_doc.

    ENDIF.

    MODIFY it_final FROM wa_final.
    CLEAR: wa_final,wa_chk_upd.
  ENDLOOP.

*----------Get contract details---------*
  IF it_final[] IS NOT INITIAL.
    SELECT *
      FROM wb2_v_vbak_vbap2
      INTO CORRESPONDING FIELDS OF TABLE it_sales
      FOR ALL ENTRIES IN it_final
      WHERE vbeln EQ it_final-sow.
  ENDIF.

* -----Get condition type details----- *
  IF it_sales[] IS NOT INITIAL.
    SELECT *
      FROM konv
      INTO CORRESPONDING FIELDS OF TABLE it_konv
      FOR ALL ENTRIES IN it_sales
      WHERE knumv = it_sales-knumv
      AND ( kschl EQ 'YTRD' OR kschl EQ 'ZC10' ).
  ENDIF.

  SORT it_final BY sow po.

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

  fieldcatalog-fieldname      = 'SEL'.
  fieldcatalog-checkbox       = 'X'.
  fieldcatalog-no_out         = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR fieldcatalog.

  fieldcatalog-fieldname      = 'SOW'.
  fieldcatalog-seltext_m      = 'SOW No.'.
  fieldcatalog-key            = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'VEND'.
  fieldcatalog-seltext_m      = 'Vendor'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'MAT'.
  fieldcatalog-seltext_m      = 'Variety'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'WH'.
  fieldcatalog-seltext_m      = 'Warehouse Code'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'WHN'.
  fieldcatalog-seltext_m      = 'Warehouse Name'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'MIRO'.
  fieldcatalog-seltext_m      = 'Ref.GRN no.'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'GRDATE'.
  fieldcatalog-seltext_m      = 'GRN date'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'BATCH'.
  fieldcatalog-seltext_m      = 'CAD No.'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'BAGS'.
  fieldcatalog-seltext_m      = 'No of Bags(GRN)'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'PO'.
  fieldcatalog-seltext_m      = 'PO No.'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

**  fieldcatalog-fieldname      = 'DEB_NOTE'.
**  fieldcatalog-seltext_m      = 'Deb.Note No.'.
**  gd_layout-colwidth_optimize = 'X'.
**  APPEND fieldcatalog TO fieldcatalog.
**  CLEAR  fieldcatalog.
**
**  fieldcatalog-fieldname      = 'CLR_DOC'.
**  fieldcatalog-seltext_m      = 'Clearing Doc.'.
**  gd_layout-colwidth_optimize = 'X'.
**  APPEND fieldcatalog TO fieldcatalog.
**  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'QTY'.
  fieldcatalog-seltext_m      = 'Quantity'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'AMT'.
  fieldcatalog-seltext_m      = 'Amount'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'SO_POSTED'.
  fieldcatalog-seltext_m      = 'SO Created'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'GM_POSTED'.
  fieldcatalog-seltext_m      = 'GM Posted'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'SALES_OR'.
  fieldcatalog-seltext_m      = 'Crt.Sales Ord.'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'MAT_DOC'.
  fieldcatalog-seltext_m      = 'Posted Mat.Doc.'.
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
      i_callback_program       = gd_repid
      is_layout                = gd_layout
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP-OF-PAGE'
      it_fieldcat              = fieldcatalog[]
      i_save                   = 'X'
      is_variant               = g_variant
    TABLES
      t_outtab                 = it_final[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
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
  wa_header-info = 'Purchase Register: Create Sales Order & Post Goods Movement'.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

*User
  wa_header-typ  = 'S'.
  wa_header-key = 'User: '.
  CONCATENATE  sy-uname ' ' INTO wa_header-info.   "Logged in user
  APPEND wa_header TO t_header.
  CLEAR: wa_header.
*SOW
  wa_header-typ  = 'S'.
  wa_header-key = 'SOW: '.
  wa_header-info = p_vbeln.
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
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.        "#EC CALLED
  SET PF-STATUS 'ZSALES'.
ENDFORM.                    "zage_stat
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN 'POST'.
      PERFORM creat_so.
      PERFORM goods_movement.
      rs_selfield-refresh = 'X'.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  creat_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM creat_so .

  DATA: order_header_inx     LIKE bapisdhd1x,
        salesdocument        LIKE bapivbeln-vbeln,
        order_header_in      LIKE bapisdhd1,
        salesdocument_ex     LIKE bapivbeln-vbeln,
        return               LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        order_items_in       LIKE bapisditm OCCURS 0 WITH HEADER LINE,
        order_items_inx      LIKE bapisditmx OCCURS 0 WITH HEADER LINE,
        torder_partners      LIKE bapiparnr OCCURS 0 WITH HEADER LINE,
        order_schedules_in   LIKE bapischdl OCCURS 0 WITH HEADER LINE,
        order_schedules_inx  LIKE bapischdlx OCCURS 0 WITH HEADER LINE,
        order_conditions_in  LIKE bapicond OCCURS 0 WITH HEADER LINE,
        order_conditions_inx LIKE bapicondx OCCURS 0 WITH HEADER LINE,
        logic_switch         LIKE bapisdls.

  DATA: v_qty TYPE bseg-menge,
        v_amt TYPE bseg-dmbtr.
  DATA: msg(70) TYPE c.

  REFRESH it_final_sum[].
  LOOP AT it_final INTO wa_final WHERE sel = 'X' AND deb_flag NE 'X' AND so_posted NE 'X'.
    wa_final_sum-sow = wa_final-sow.
    wa_final_sum-amt = wa_final-amt.
    wa_final_sum-qty = wa_final-qty.
    COLLECT wa_final_sum INTO it_final_sum.
    CLEAR: wa_final,wa_final_sum.
  ENDLOOP.

  IF it_final_sum IS NOT INITIAL.

    LOOP AT it_final_sum INTO wa_final_sum.
      LOOP AT it_sales INTO wa_sales WHERE vbeln = wa_final_sum-sow.

        CLEAR order_header_in.
        order_header_in-refobjtype = 'BUS2032'.
        order_header_in-refobjkey  = 'RAMIRO1'.
        order_header_in-doc_type   = 'YFSC'.
        order_header_in-refdoctype = wa_final_sum-sow.
        order_header_in-ref_doc_l_long = wa_final_sum-sow.
        order_header_in-sales_org  = wa_sales-vkorg.
        order_header_in-distr_chan = wa_sales-vtweg.
        order_header_in-division   = wa_sales-spart.
        order_header_in-ord_reason = wa_sales-augru.
        order_header_in-sales_off  = wa_sales-vkbur.
        order_header_in-purch_no_c = '.'.
        REFRESH torder_partners.

        logic_switch-cond_handl = 'X'.

        torder_partners-partn_role = 'AG'.
        torder_partners-partn_numb = wa_sales-kunnr.
        APPEND torder_partners.

        torder_partners-partn_role = 'WE'.
        torder_partners-partn_numb = wa_sales-kunnr.
        APPEND torder_partners.

        REFRESH order_items_in.
        REFRESH order_schedules_in.

        CLEAR order_items_in.
        order_items_in-itm_number = wa_sales-posnr_i.
        order_items_in-plant      = wa_sales-werks_i.
        order_items_in-store_loc  = wa_sales-lgort_i.
        order_items_in-refobjtype = 'BUS2032'.
        order_items_in-refobjkey  = 'RAMIRO1'.
        order_items_in-material   = wa_sales-matnr_i.
        APPEND order_items_in.

        CLEAR order_schedules_in.
        order_schedules_in-itm_number = wa_sales-posnr_i.
        order_schedules_in-refobjtype = 'BUS2032'.
        order_schedules_in-refobjkey = 'RAMIRO1'.
        order_schedules_in-req_qty = wa_final_sum-qty.
        APPEND order_schedules_in.

        READ TABLE it_konv INTO wa_konv WITH KEY knumv = wa_sales-knumv kschl = 'YTRD'.
        IF sy-subrc = 0.
          CLEAR order_conditions_in.
*        order_conditions_in-cond_st_no = wa_konv-stunr.
*        order_conditions_in-cond_count = wa_konv-zaehk.
          order_conditions_in-cond_type  = wa_konv-kschl.
          order_conditions_in-itm_number = wa_sales-posnr_i.
          order_conditions_in-cond_value = ( ( wa_final_sum-amt / 10 ) / wa_final_sum-qty ).
          APPEND order_conditions_in.

          CLEAR order_conditions_inx.
          order_conditions_inx-updateflag = 'U'.
          order_conditions_inx-itm_number = wa_konv-kposn.
          order_conditions_inx-cond_st_no = wa_konv-stunr.
          order_conditions_inx-cond_count = wa_konv-zaehk.
          order_conditions_inx-cond_type  = wa_konv-kschl.
          order_conditions_inx-cond_value = 'X'.
          APPEND order_conditions_inx.
        ENDIF.

        READ TABLE it_konv INTO wa_konv WITH KEY knumv = wa_sales-knumv kschl = 'ZC10'.
        IF sy-subrc = 0.
          CLEAR order_conditions_in.
*        order_conditions_in-cond_st_no = wa_konv-stunr.
*        order_conditions_in-cond_count = wa_konv-zaehk.
          order_conditions_in-cond_type  = wa_konv-kschl.
          order_conditions_in-cond_value = ( wa_konv-kbetr / 100 ).
          order_conditions_in-itm_number = wa_sales-posnr_i.
          APPEND order_conditions_in.

          CLEAR order_conditions_inx.
          order_conditions_inx-updateflag = 'U'.
          order_conditions_inx-itm_number = wa_konv-kposn.
          order_conditions_inx-cond_st_no = wa_konv-stunr.
          order_conditions_inx-cond_count = wa_konv-zaehk.
          order_conditions_inx-cond_type  = wa_konv-kschl.
          order_conditions_inx-cond_value = 'X'.
          APPEND order_conditions_inx.
        ENDIF.
        CLEAR : wa_sales.
      ENDLOOP.
      CLEAR: wa_final_sum.
    ENDLOOP.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        order_header_in         = order_header_in
        order_header_inx        = order_header_inx
        logic_switch            = logic_switch
*      binary_relationshiptype = 'VORA'
*      int_number_assignment   = 'X'
      IMPORTING
        salesdocument           = salesdocument_ex
      TABLES
        return                  = return
        order_items_in          = order_items_in
        order_items_inx         = order_items_inx
        order_partners          = torder_partners
        order_schedules_in      = order_schedules_in
        order_schedules_inx     = order_schedules_inx
        order_conditions_in     = order_conditions_in
        order_conditions_inx    = order_conditions_inx.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      p_vbeln = salesdocument_ex.

      LOOP AT it_final INTO wa_final WHERE sel = 'X'.
        wa_sales_upd-sow        = wa_final-sow.
        wa_sales_upd-po         = wa_final-po.
        wa_sales_upd-miro       = wa_final-miro.
        wa_sales_upd-amt        = wa_final-amt.
        wa_sales_upd-clr_doc    = wa_final-clr_doc.
        wa_sales_upd-qty        = wa_final-qty.
        wa_sales_upd-deb_note   = wa_final-deb_note.
        wa_sales_upd-sales_or   = wa_final-sales_or = p_vbeln.
        wa_sales_upd-so_posted  = wa_final-so_posted = 'X'.
        MODIFY it_final FROM wa_final.
        APPEND wa_sales_upd TO it_sales_upd .
        CLEAR : wa_final,wa_sales_upd.
      ENDLOOP.

      LOOP AT it_sales_upd INTO wa_sales_upd.
        INSERT into ztb_sales_data values wa_sales_upd.
        COMMIT WORK.
        CLEAR: wa_sales_upd.
      ENDLOOP.
    ENDIF.

    CONCATENATE 'Sales order' p_vbeln 'has been created!' INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'I'.
    CLEAR : msg.
  ELSE.
    MESSAGE 'SO has already been posted for selected lines!' TYPE 'I'.
  ENDIF.

ENDFORM.                    " creat_so
*&---------------------------------------------------------------------*
*&      Form  GOODS_MOVEMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM goods_movement .

  DATA: wa_head TYPE bapi2017_gm_head_01,
       gm_code TYPE bapi2017_gm_code VALUE '04',
       it_item TYPE TABLE OF bapi2017_gm_item_create,
       wa_item TYPE bapi2017_gm_item_create,
       it_return TYPE TABLE OF bapiret2,
       wa_return TYPE bapiret2.

  DATA: v_qty1 TYPE bseg-menge.

  DATA: mat_doc    TYPE bapi2017_gm_head_ret-mat_doc,
        doc_year   TYPE bapi2017_gm_head_ret-doc_year,
        v_msg1(150) TYPE c,
        v_posnr TYPE posnr.

  REFRESH it_final_sum[].
  LOOP AT it_final INTO wa_final WHERE sel = 'X' AND deb_flag NE 'X' AND gm_posted NE 'X' AND so_posted EQ 'X'.
    wa_final_sum-sow = wa_final-sow.
    wa_final_sum-amt = wa_final-amt.
    wa_final_sum-qty = wa_final-qty.
    wa_final_sum-miro = wa_final-miro.    " Added by SaurabhK on 03.05.17 02:45 PM
    COLLECT wa_final_sum INTO it_final_sum.
    CLEAR : wa_final_sum.
  ENDLOOP.

  IF it_final_sum[] IS NOT INITIAL.
*    IF it_sales_upd[] IS NOT INITIAL.
    LOOP AT it_final_sum INTO wa_final_sum.

      READ TABLE it_sales INTO wa_sales WITH KEY vbeln = wa_final-sow.
      IF sy-subrc = 0.
        READ TABLE it_rseg INTO wa_rseg WITH KEY ebeln = wa_final-po.
        IF sy-subrc = 0.
          SELECT SINGLE * FROM ekbe INTO wa_ekbe WHERE ebeln = wa_rseg-ebeln
                                                 AND ebelp EQ wa_rseg-ebelp
                                                 AND bwart EQ '101'
                                                 AND belnr = wa_final_sum-miro.
          IF sy-subrc = 0.
            "header data
            wa_head-pstng_date = sy-datum.
            wa_head-doc_date = sy-datum.
            gm_code = '04'.
            "item data
            wa_item-material = wa_sales-matnr_i.
            wa_item-plant = wa_sales-werks_i.
            wa_item-stge_loc = wa_sales-lgort_i.
            wa_item-batch = wa_ekbe-charg.
            wa_item-move_mat = wa_sales-matnr_i.
            wa_item-move_batch = wa_ekbe-charg.
            wa_item-move_type = '413'.
            wa_item-spec_stock = 'E'.
            wa_item-entry_qnt = wa_final_sum-qty.
            wa_item-entry_uom = wa_sales-vrkme_i.
            wa_item-move_stloc = wa_sales-lgort_i.
            "SOW details
            wa_item-val_sales_ord = wa_sales-vbeln.
            wa_item-val_s_ord_item = wa_sales-posnr_i.
            "sales order details
            wa_item-sales_ord = p_vbeln.
            SELECT SINGLE posnr INTO v_posnr FROM vbap WHERE vbeln EQ p_vbeln.
            IF sy-subrc = 0.
              wa_item-s_ord_item = v_posnr.
            ENDIF.
            APPEND wa_item TO it_item.
            REFRESH it_return[].
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR: wa_final_sum,wa_sales,wa_rseg,wa_ekbe.
    ENDLOOP.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = wa_head
        goodsmvt_code    = gm_code
      IMPORTING
        materialdocument = mat_doc
        matdocumentyear  = doc_year
      TABLES
        goodsmvt_item    = it_item
        return           = it_return.

    IF mat_doc IS NOT INITIAL AND sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      CONCATENATE 'Doc.' mat_doc 'with' doc_year 'has been created!' INTO v_msg1 SEPARATED BY space.
      MESSAGE v_msg1 TYPE 'I'.

      LOOP AT it_final INTO wa_final WHERE sel = 'X'.
        READ TABLE it_sales_upd INTO wa_sales_upd WITH KEY sow = wa_final-sow po = wa_final-po miro = wa_final-miro.
        wa_sales_upd-sow        = wa_final-sow.
        wa_sales_upd-po         = wa_final-po.
        wa_sales_upd-miro       = wa_final-miro.
        wa_sales_upd-amt        = wa_final-amt.
        wa_sales_upd-clr_doc    = wa_final-clr_doc.
        wa_sales_upd-qty        = wa_final-qty.
        wa_sales_upd-deb_note   = wa_final-deb_note.
        wa_sales_upd-mat_doc    = wa_final-mat_doc    = mat_doc.
        wa_sales_upd-gm_posted  = wa_final-gm_posted  = 'X'.
        MODIFY it_final FROM wa_final.
        UPDATE ztb_sales_data SET gm_posted = wa_sales_upd-gm_posted mat_doc = wa_sales_upd-mat_doc
                              WHERE sow  = wa_sales_upd-sow
                              AND   po   = wa_sales_upd-po
                              AND   miro = wa_sales_upd-miro.
        CLEAR: wa_final,wa_sales_upd.
      ENDLOOP.
    ELSE.
      CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
        TABLES
          it_return = it_return.
    ENDIF.
*    ELSE.
*      MESSAGE 'Sales order is not been created for selected lines!' TYPE 'I'.
*    ENDIF.
  ELSE.
    MESSAGE 'Goods movement has already been posted for selected lines!' TYPE 'I'.
  ENDIF.

ENDFORM.                    " GOODS_MOVEMENT
