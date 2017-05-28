*&---------------------------------------------------------------------*
*& Report  ZSOL_MM_MIRO_DEB_NOTE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zsol_mm_miro_deb_note.

TYPE-POOLS: slis.
TABLES:vbak.
*&---------------------------------------------------------------------*
*&  Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
SELECT-OPTIONS : s_vbeln FOR vbak-vbeln ,
                 s_date FOR vbak-erdat OBLIGATORY.
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
        year      TYPE gjahr,
        deb_amt TYPE bseg-wrbtr,
        doc	TYPE belnr,
        doc_year  TYPE gjahr,
        flag TYPE c,
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

DATA: it_vbak TYPE STANDARD TABLE OF vbak,
      wa_vbak TYPE vbak,
      it_specs TYPE STANDARD TABLE OF ztb_trd_specs,
      wa_specs TYPE ztb_trd_specs.

DATA: v_percent TYPE p DECIMALS 3,
      v_deb_amt TYPE bseg-wrbtr,
      v_tax TYPE bset-fwste,
      v_bukrs    TYPE bkpf-bukrs,
      v_taxcode  TYPE bseg-mwskz,
      v_curr     TYPE bkpf-waers.

DATA: t_mwdat TYPE TABLE OF rtax1u15.

DATA : header TYPE bapi_incinv_create_header,
       it_itemdata TYPE TABLE OF bapi_incinv_create_item,
       wa_itemdata TYPE bapi_incinv_create_item ,
       it_return TYPE TABLE OF bapiret2.

DATA:invoicedocnumber TYPE  bapi_incinv_fld-inv_doc_no,
     fiscalyear       TYPE bapi_incinv_fld-fisc_year,
     v_msg            TYPE string.

DATA: it_deb TYPE STANDARD TABLE OF ztb_deb_note,
      wa_deb TYPE ztb_deb_note,
      wa_deb_data TYPE ztb_deb_note.

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
    FROM vbak
    INTO CORRESPONDING FIELDS OF TABLE it_vbak
    WHERE vbeln IN s_vbeln
    AND   erdat IN s_date.

  IF it_vbak[] IS NOT INITIAL.
    SELECT *
      FROM ekkn
      INTO CORRESPONDING FIELDS OF TABLE it_ekkn
      FOR ALL ENTRIES IN it_vbak
      WHERE vbeln EQ it_vbak-vbeln.

    IF it_ekkn[] IS NOT INITIAL.
      SELECT *
        FROM ekbe
        INTO CORRESPONDING FIELDS OF TABLE it_ekbe
        FOR ALL ENTRIES IN it_ekkn
        WHERE ebeln EQ it_ekkn-ebeln.
    ENDIF.
  ENDIF.

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

      SELECT *
        FROM ztb_trd_specs
        INTO CORRESPONDING FIELDS OF TABLE it_specs
        FOR ALL ENTRIES IN it_view
        WHERE vbeln EQ it_view-kdauf_i
        AND   lorry_no EQ it_view-bktxt
        AND   matnr EQ it_view-matnr_i
        AND   charg EQ it_view-charg_i.

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
    CLEAR: wa_rbkp,wa_rbkp_temp.
  ENDLOOP.

  LOOP AT it_ekbe INTO wa_ekbe WHERE bwart EQ '101'.
    wa_final-miro = wa_ekbe-belnr.

    READ TABLE it_view INTO wa_view WITH KEY mblnr = wa_ekbe-belnr mjahr = wa_ekbe-gjahr.
    IF sy-subrc = 0.
      wa_final-sow = wa_view-kdauf_i.
      wa_final-mat = wa_view-matnr_i.
      wa_final-batch = wa_view-charg_i.
      wa_final-vend = wa_view-lifnr_i.
      wa_final-amt = wa_view-bualt_i.
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
        wa_final-amt = wa_rbkp-rmwwr.
        wa_final-year = wa_rbkp-gjahr.
      ENDIF.
    ENDIF.

    LOOP AT it_specs INTO wa_specs WHERE vbeln    EQ wa_view-kdauf_i AND
                                         lorry_no EQ wa_view-bktxt AND
                                         matnr    EQ wa_view-matnr_i AND
                                         charg    EQ wa_view-charg_i.

      v_percent = v_percent + wa_specs-act_dect.  "Get total deduction % of all the characteristics
    ENDLOOP.

    v_deb_amt = ( wa_rbkp-rmwwr * v_percent ) / 100. "Calculate debit note amt.
    wa_final-deb_amt = v_deb_amt.



    READ TABLE it_t001l INTO wa_t001l WITH KEY werks = wa_view-werks_i lgort = wa_view-lgort_i.
    IF sy-subrc = 0.
      wa_final-whn = wa_t001l-lgobe.
    ENDIF.

    APPEND wa_final TO it_final.
    CLEAR : wa_final,wa_ekbe,wa_view,wa_t001l, v_percent,v_deb_amt.

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

  SELECT *
    FROM ztb_deb_note
    INTO CORRESPONDING FIELDS OF TABLE it_deb
    FOR ALL ENTRIES IN it_final
    WHERE sow EQ it_final-sow
    AND   po EQ it_final-po
    AND   vend EQ it_final-vend
    AND   mat EQ it_final-mat
    AND   miro EQ it_final-miro
    AND   batch EQ it_final-batch.

  LOOP AT it_final INTO wa_final .
    READ TABLE it_deb INTO wa_deb WITH KEY sow = wa_final-sow
                                           po = wa_final-po
                                           vend = wa_final-vend
                                           mat = wa_final-mat
                                           miro = wa_final-miro
                                           batch = wa_final-batch.
    IF sy-subrc = 0.
      DELETE it_final.
      CONTINUE.
    ENDIF.
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

  fieldcatalog-fieldname      = 'DEB_AMT'.
  fieldcatalog-seltext_m      = 'Debit Amt.'.
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
  wa_header-info = 'Debit Note For Quality Deduction'.
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
*  wa_header-info = p_vbeln.
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
  SET PF-STATUS 'ZDEB'.
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
      PERFORM post_dbnote.
      rs_selfield-refresh = 'X'.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  POST_DBNOTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM post_dbnote .

  DATA: v_doc_msg TYPE string.

  LOOP AT it_final INTO wa_final WHERE sel = 'X'.

    READ TABLE it_ekbe INTO wa_ekbe WITH KEY belnr = wa_final-miro.
    IF sy-subrc = 0.
      READ TABLE it_rseg INTO wa_rseg WITH KEY ebeln = wa_ekbe-ebeln ebelp = wa_ekbe-ebelp.

      READ TABLE it_ekbe INTO wa_ekbe_miro WITH KEY bewtp = 'Q' lfbnr = wa_ekbe-belnr.

      READ TABLE it_rbkp INTO wa_rbkp WITH KEY belnr = wa_ekbe_miro-belnr gjahr = wa_ekbe_miro-gjahr.


      v_deb_amt = wa_final-deb_amt.

      v_bukrs   = wa_rbkp-bukrs.
      v_taxcode = wa_rbkp-mwskz1.
      v_curr    = wa_rbkp-waers.

      "To calculate tax for the debit amt.that we have calculated
      CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
        EXPORTING
          i_bukrs = v_bukrs
          i_mwskz = v_taxcode
          i_waers = v_curr
          i_wrbtr = v_deb_amt
        IMPORTING
          e_fwste = v_tax
        TABLES
          t_mwdat = t_mwdat.

      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CLEAR: header.
      REFRESH : it_itemdata[].
      " Header data
      header-ref_doc_no = wa_rbkp-belnr.
      header-doc_date    = wa_rbkp-bldat.
      header-pstng_date  = wa_rbkp-budat.
      header-gross_amount = ( v_deb_amt + v_tax ).
      header-comp_code   = wa_rbkp-bukrs.
      header-currency    = wa_rbkp-waers.
      header-bline_date  = wa_rbkp-zfbdt.
      header-po_ref_no   = wa_rseg-ebeln.
      header-calc_tax_ind = 'X'.
      "Line item data
      wa_itemdata-invoice_doc_item = wa_rseg-ebelp.
      wa_itemdata-po_number        = wa_rseg-ebeln.
      wa_itemdata-po_item          = wa_rseg-ebelp.
      wa_itemdata-de_cre_ind       = 'X'.
      wa_itemdata-tax_code         = wa_rbkp-mwskz1.
      wa_itemdata-item_amount      = ( v_deb_amt )." + v_tax ).
      wa_itemdata-quantity         = wa_ekbe-menge.
      wa_itemdata-po_unit          = wa_rseg-bstme.
      wa_itemdata-ref_doc          = wa_ekbe-lfbnr.
      wa_itemdata-ref_doc_year     = wa_ekbe-gjahr.
      wa_itemdata-ref_doc_it     = wa_ekbe-ebelp.

      APPEND wa_itemdata TO it_itemdata.

      IF it_itemdata[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
          EXPORTING
            headerdata       = header
          IMPORTING
            invoicedocnumber = invoicedocnumber
            fiscalyear       = fiscalyear
          TABLES
            itemdata         = it_itemdata[]
            return           = it_return[].

        IF invoicedocnumber IS NOT INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        ENDIF.

        IF it_return[] IS INITIAL.
          MOVE-CORRESPONDING wa_final TO wa_deb_data.
          wa_deb_data-doc = invoicedocnumber.
          wa_deb_data-doc_year = fiscalyear.

          CONCATENATE 'Document no' wa_deb_data-doc 'in fiscal year' wa_deb_data-doc_year INTO v_doc_msg SEPARATED BY space.
          MESSAGE v_doc_msg TYPE 'I'.
          wa_final-flag = 'X'.
          MODIFY it_final FROM wa_final.
          INSERT ztb_deb_note FROM wa_deb_data.
          COMMIT WORK.
        ENDIF.
      ENDIF.

    ENDIF.
    CLEAR: wa_final,wa_view.
  ENDLOOP.

ENDFORM.                    " POST_DBNOTE
