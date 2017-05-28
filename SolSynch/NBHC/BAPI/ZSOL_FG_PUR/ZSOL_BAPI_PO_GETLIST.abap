FUNCTION zsol_bapi_po_getlist.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(DOC_TYPE) TYPE  ZSOL_DOCTYPE OPTIONAL
*"     VALUE(C_DATE) TYPE  ZSOL_CDATE
*"  EXPORTING
*"     VALUE(PO_HEADERS) TYPE  ZSOL_TT_BAPIEKKO
*"     VALUE(PO_ITEMS) TYPE  ZSOL_TT_BAPIEKPO
*"     VALUE(PO_ADDRESSES) TYPE  ZSOL_TT_BAPIADDR
*"     VALUE(PO_ACCOUNTS) TYPE  ZSOL_TT_BAPIEKKN
*"     VALUE(PO_SCHEDULES) TYPE  ZSOL_TT_BAPIEKET
*"     VALUE(RETURN) TYPE  ZTT_BAPIRETURN
*"----------------------------------------------------------------------
  TYPES: BEGIN OF ty_ebeln,
           ebeln TYPE ekko-ebeln,
         END OF ty_ebeln.

  DATA: it_cdhdr TYPE TABLE OF cdhdr,
        wa_cdhdr TYPE cdhdr,

        it_cdpos TYPE TABLE OF cdpos,
        wa_cdpos TYPE cdpos,

        it_ekko  TYPE TABLE OF ekko,
        wa_ekko  TYPE ekko,

        it_ekpo  TYPE TABLE OF ekpo,
        wa_ekpo  TYPE ekpo,

        it_ekkn  TYPE TABLE OF ekkn,
        wa_ekkn  TYPE ekkn,

        it_eket  TYPE TABLE OF eket,
        wa_eket  TYPE eket,

        it_ebeln TYPE TABLE OF ty_ebeln,
        wa_ebeln TYPE ty_ebeln,

        po_header   LIKE LINE OF po_headers,

        po_item     LIKE LINE OF po_items,

        po_account  LIKE LINE OF po_accounts,

        po_schedule LIKE LINE OF po_schedules,

        po_address  LIKE LINE OF po_addresses,

        wa_address  LIKE addr1_val,

        wa_return   LIKE LINE OF return.

  RANGES: chngdate FOR cdhdr-udate,
          doctype   FOR ekko-bsart.

  IF c_date IS NOT INITIAL.
    chngdate-low = c_date-cdate_from.
    chngdate-high = c_date-cdate_to.
    IF chngdate-high < chngdate-low AND chngdate-high IS NOT INITIAL.
      chngdate-low = c_date-cdate_to.
      chngdate-high = c_date-cdate_from.
    ENDIF.
    chngdate-sign = 'I'.
    IF chngdate-high IS INITIAL.
      chngdate-option = 'EQ'.
    ELSE.
      chngdate-option = 'BT'.
    ENDIF.
    APPEND chngdate.
  ELSE.
    CLEAR wa_return.

    wa_return-type        = 'E'.
    wa_return-id          = '00'.
    wa_return-number      = '001'.
    wa_return-message_v1  = 'Change date is mandatory'.
    wa_return-message_v2  = ''.
    wa_return-message_v3  = ''.
    wa_return-message_v4  = ''.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = wa_return-type
        cl     = wa_return-id
        number = wa_return-number
        par1   = wa_return-message_v1
        par2   = wa_return-message_v2
        par3   = wa_return-message_v3
        par4   = wa_return-message_v4
      IMPORTING
        return = wa_return.

    IF wa_return IS NOT INITIAL.
      APPEND wa_return TO return.
    ENDIF.

    EXIT.
  ENDIF.

  IF doc_type IS NOT INITIAL.
    TRANSLATE doc_type-typ_from TO UPPER CASE.
    TRANSLATE doc_type-typ_to TO UPPER CASE.
    doctype-low = doc_type-typ_from.
    doctype-high = doc_type-typ_to.
    IF doctype-high < doctype-low AND doctype-high IS NOT INITIAL.
      doctype-low = doc_type-typ_to.
      doctype-high = doc_type-typ_from.
    ENDIF.
    doctype-sign = 'I'.
    IF doctype-high IS INITIAL.
      doctype-option = 'EQ'.
    ELSE.
      doctype-option = 'BT'.
    ENDIF.
    APPEND doctype.
  ENDIF.

  SELECT *
    FROM cdhdr
    INTO TABLE it_cdhdr
    WHERE objectclas EQ 'EINKBELEG'
    AND udate IN chngdate
    AND ( tcode EQ 'ME29N'
    OR  tcode EQ 'ME28' ).

  IF sy-subrc <> 0 AND it_cdhdr[] IS INITIAL.
    CLEAR wa_return.

    wa_return-type        = 'E'.
    wa_return-id          = '00'.
    wa_return-number      = '001'.
    wa_return-message_v1  = 'No Purchase orders released in the specified period'.
    wa_return-message_v2  = ''.
    wa_return-message_v3  = ''.
    wa_return-message_v4  = ''.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = wa_return-type
        cl     = wa_return-id
        number = wa_return-number
        par1   = wa_return-message_v1
        par2   = wa_return-message_v2
        par3   = wa_return-message_v3
        par4   = wa_return-message_v4
      IMPORTING
        return = wa_return.

    IF wa_return IS NOT INITIAL.
      APPEND wa_return TO return.
    ENDIF.

    EXIT.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM it_cdhdr COMPARING objectclas objectid.

  SELECT *
    FROM cdpos
    INTO TABLE it_cdpos
    FOR ALL ENTRIES IN it_cdhdr
    WHERE objectclas EQ 'EINKBELEG'
    AND   objectid EQ it_cdhdr-objectid
    AND   changenr EQ it_cdhdr-changenr
    AND   tabname EQ 'EKKO'
    AND   fname EQ 'FRGZU'.

  IF sy-subrc <> 0 AND it_cdpos[] IS INITIAL.
    CLEAR wa_return.

    wa_return-type        = 'E'.
    wa_return-id          = '00'.
    wa_return-number      = '001'.
    wa_return-message_v1  = 'No Purchase orders released in the given period'.
    wa_return-message_v2  = ''.
    wa_return-message_v3  = ''.
    wa_return-message_v4  = ''.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = wa_return-type
        cl     = wa_return-id
        number = wa_return-number
        par1   = wa_return-message_v1
        par2   = wa_return-message_v2
        par3   = wa_return-message_v3
        par4   = wa_return-message_v4
      IMPORTING
        return = wa_return.

    IF wa_return IS NOT INITIAL.
      APPEND wa_return TO return.
    ENDIF.

    EXIT.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM it_cdpos COMPARING objectclas objectid.

  LOOP AT it_cdpos INTO wa_cdpos.
    MOVE wa_cdpos-objectid TO wa_ebeln-ebeln.
    APPEND wa_ebeln TO it_ebeln.
    CLEAR: wa_ebeln, wa_cdpos.
  ENDLOOP.

  IF it_ebeln IS NOT INITIAL.
    DELETE ADJACENT DUPLICATES FROM it_ebeln COMPARING ebeln.

    SELECT *
      FROM ekko
      INTO TABLE it_ekko
      FOR ALL ENTRIES IN it_ebeln
      WHERE ebeln EQ it_ebeln-ebeln
      AND   bsart IN doctype.
    " Further filter can be applied on release indicator, release status

    " Additional query for just created but not yet released PO's
*  SELECT *
*    FROM ekko
*    APPENDING TABLE it_ekko
*    WHERE aedat IN chngdate
*    AND   bsart IN doctype.
    IF sy-subrc = 0 AND it_ekko IS NOT INITIAL.
      DELETE ADJACENT DUPLICATES FROM it_ekko COMPARING ALL FIELDS.

      SELECT *
        FROM ekpo
        INTO TABLE it_ekpo
        FOR ALL ENTRIES IN it_ekko
        WHERE ebeln EQ it_ekko-ebeln.

      IF sy-subrc = 0.
        SELECT *
          FROM ekkn
          INTO TABLE it_ekkn
          FOR ALL ENTRIES IN it_ekpo
          WHERE ebeln = it_ekpo-ebeln
          AND   ebelp = it_ekpo-ebelp.

        IF sy-subrc <> 0.
          CLEAR wa_return.

          wa_return-type        = 'I'.
          wa_return-id          = '00'.
          wa_return-number      = '001'.
          wa_return-message_v1  = 'No accounting data found for purchase orders'.
          wa_return-message_v2  = ''.
          wa_return-message_v3  = ''.
          wa_return-message_v4  = ''.

          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = wa_return-type
              cl     = wa_return-id
              number = wa_return-number
              par1   = wa_return-message_v1
              par2   = wa_return-message_v2
              par3   = wa_return-message_v3
              par4   = wa_return-message_v4
            IMPORTING
              return = wa_return.

          IF wa_return IS NOT INITIAL.
            APPEND wa_return TO return.
          ENDIF.
        ENDIF.

        SELECT *
          FROM eket
          INTO TABLE it_eket
          FOR ALL ENTRIES IN it_ekpo
          WHERE ebeln = it_ekpo-ebeln
          AND   ebelp = it_ekpo-ebelp.

        IF sy-subrc <> 0.
          CLEAR wa_return.

          wa_return-type        = 'I'.
          wa_return-id          = '00'.
          wa_return-number      = '001'.
          wa_return-message_v1  = 'No scheduling data found for purchase orders'.
          wa_return-message_v2  = ''.
          wa_return-message_v3  = ''.
          wa_return-message_v4  = ''.

          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = wa_return-type
              cl     = wa_return-id
              number = wa_return-number
              par1   = wa_return-message_v1
              par2   = wa_return-message_v2
              par3   = wa_return-message_v3
              par4   = wa_return-message_v4
            IMPORTING
              return = wa_return.

          IF wa_return IS NOT INITIAL.
            APPEND wa_return TO return.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR wa_return.

      wa_return-type        = 'E'.
      wa_return-id          = '00'.
      wa_return-number      = '001'.
      wa_return-message_v1  = 'No purchase orders found'.
      wa_return-message_v2  = ''.
      wa_return-message_v3  = ''.
      wa_return-message_v4  = ''.

      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = wa_return-type
          cl     = wa_return-id
          number = wa_return-number
          par1   = wa_return-message_v1
          par2   = wa_return-message_v2
          par3   = wa_return-message_v3
          par4   = wa_return-message_v4
        IMPORTING
          return = wa_return.

      IF wa_return IS NOT INITIAL.
        APPEND wa_return TO return.
      ENDIF.

      EXIT.
    ENDIF.
  ENDIF.

  IF it_ekko IS NOT INITIAL.
    " Move ekko to po_headers
    LOOP AT it_ekko INTO wa_ekko.
      MOVE: wa_ekko-ebeln TO  po_header-po_number,
            wa_ekko-bukrs TO  po_header-co_code,
            wa_ekko-bstyp TO  po_header-doc_cat,
            wa_ekko-bsart TO  po_header-doc_type,
            wa_ekko-bsakz TO  po_header-cntrl_ind,
            wa_ekko-loekz TO  po_header-delete_ind,
            wa_ekko-statu TO  po_header-status,
            wa_ekko-aedat TO  po_header-created_on,
            wa_ekko-ernam TO  po_header-created_by,
            wa_ekko-pincr TO  po_header-item_intvl,
            wa_ekko-lponr TO  po_header-last_item,
            wa_ekko-lifnr TO  po_header-vendor,
            wa_ekko-spras TO  po_header-language,
            wa_ekko-zterm TO  po_header-pmnttrms,
            wa_ekko-zbd1t TO  po_header-dscnt1_to,
            wa_ekko-zbd2t TO  po_header-dscnt2_to,
            wa_ekko-zbd3t TO  po_header-dscnt3_to,
            wa_ekko-zbd1p TO  po_header-cash_disc1,
            wa_ekko-zbd2p TO  po_header-cash_disc2,
            wa_ekko-ekorg TO  po_header-purch_org,
            wa_ekko-ekgrp TO  po_header-pur_group,
            wa_ekko-waers TO  po_header-currency.

      PERFORM rate_to_external USING    wa_ekko-bukrs
                                        wa_ekko-bedat
                                        wa_ekko-waers
                                        wa_ekko-wkurs
                               CHANGING po_header-exch_rate
                                        po_header-exch_rate_cm.

      MOVE: wa_ekko-kufix TO po_header-ex_rate_fx,
            wa_ekko-bedat TO po_header-doc_date,
            wa_ekko-kdatb TO po_header-vper_start,
            wa_ekko-kdate TO po_header-vper_end,
            wa_ekko-bwbdt TO po_header-applic_by,
            wa_ekko-angdt TO po_header-quot_dead,
            wa_ekko-bnddt TO po_header-bindg_per,
            wa_ekko-gwldt TO po_header-warranty,
            wa_ekko-ausnr TO po_header-bidinv_no,
            wa_ekko-angnr TO po_header-quotation,
            wa_ekko-ihran TO po_header-quot_date,
            wa_ekko-ihrez TO po_header-ref_1,
            wa_ekko-verkf TO po_header-sales_pers,
            wa_ekko-telf1 TO po_header-telephone,
            wa_ekko-llief TO po_header-suppl_vend,
            wa_ekko-kunnr TO po_header-customer,
            wa_ekko-konnr TO po_header-agreement,
            wa_ekko-abgru TO po_header-rej_reason,
            wa_ekko-autlf TO po_header-compl_dlv,
            wa_ekko-weakt TO po_header-gr_message,
            wa_ekko-reswk TO po_header-suppl_plnt,
            wa_ekko-lblif TO po_header-rcvg_vend,
            wa_ekko-inco1 TO po_header-incoterms1,
            wa_ekko-inco2 TO po_header-incoterms2,
            wa_ekko-submi TO po_header-coll_no,
            wa_ekko-knumv TO po_header-doc_cond,
            wa_ekko-kalsm TO po_header-procedure,
            wa_ekko-stafo TO po_header-update_grp,
            wa_ekko-lifre TO po_header-diff_inv,
            wa_ekko-exnum TO po_header-export_no,
            wa_ekko-unsez TO po_header-our_ref,
            wa_ekko-logsy TO po_header-logsystem,
            wa_ekko-upinc TO po_header-subitemint,
            wa_ekko-stako TO po_header-mast_cond,
            wa_ekko-frggr TO po_header-rel_group,
            wa_ekko-frgsx TO po_header-rel_strat,
            wa_ekko-frgke TO po_header-rel_ind,
            wa_ekko-frgzu TO po_header-rel_status,
            wa_ekko-frgrl TO po_header-subj_to_r,
            wa_ekko-lands TO po_header-taxr_cntry,
            wa_ekko-lphis TO po_header-sched_ind.
      PERFORM value_to_external USING wa_ekko-ktwrt wa_ekko-waers
                                      po_header-target_val.
      APPEND po_header TO po_headers.

      CALL FUNCTION 'MM_ADDRESS_GET'
        EXPORTING
          i_ekko    = wa_ekko
        IMPORTING
          e_address = wa_address
        EXCEPTIONS
          OTHERS    = 0.

      MOVE-CORRESPONDING wa_address TO po_address.
      po_address-po_number = wa_ekko-ebeln.
      po_address-vendor    = wa_ekko-lifnr.
      APPEND po_address TO po_addresses.

      CLEAR: wa_ekko, po_header, po_address.
    ENDLOOP.

    IF po_headers[] IS NOT INITIAL.
      SORT po_headers BY po_number.
    ENDIF.
  ENDIF.

  IF it_ekpo IS NOT INITIAL.
    " Move ekpo to po_items
    LOOP AT it_ekpo INTO wa_ekpo.
      MOVE: wa_ekpo-ebeln     TO    po_item-po_number,
            wa_ekpo-ebelp     TO    po_item-po_item,
            wa_ekpo-loekz     TO    po_item-delete_ind,
            wa_ekpo-statu     TO    po_item-status,
            wa_ekpo-aedat     TO    po_item-changed_on,
            wa_ekpo-txz01     TO    po_item-short_text,
            wa_ekpo-matnr     TO    po_item-material,
            wa_ekpo-ematn     TO    po_item-pur_mat,
            wa_ekpo-bukrs     TO    po_item-co_code,
            wa_ekpo-werks     TO    po_item-plant,
            wa_ekpo-lgort     TO    po_item-store_loc,
            wa_ekpo-bednr     TO    po_item-trackingno,
            wa_ekpo-matkl     TO    po_item-mat_grp,
            wa_ekpo-infnr     TO    po_item-info_rec,
            wa_ekpo-idnlf     TO    po_item-vend_mat,
            wa_ekpo-ktmng     TO    po_item-target_qty,
            wa_ekpo-menge     TO    po_item-quantity,
            wa_ekpo-meins     TO    po_item-unit,
            wa_ekpo-bprme     TO    po_item-orderpr_un,
            wa_ekpo-bpumz     TO    po_item-conv_num1,
            wa_ekpo-bpumn     TO    po_item-conv_den1,
            wa_ekpo-umrez     TO    po_item-conv_num2,
            wa_ekpo-umren     TO    po_item-conv_den2,
            wa_ekpo-peinh     TO    po_item-price_unit,
            wa_ekpo-agdat     TO    po_item-quot_dead,
            wa_ekpo-webaz     TO    po_item-gr_pr_time,
            wa_ekpo-mwskz     TO    po_item-tax_code,
            wa_ekpo-bonus     TO    po_item-sett_grp1,
            wa_ekpo-insmk     TO    po_item-qual_insp,
            wa_ekpo-spinf     TO    po_item-info_upd,
            wa_ekpo-prsdr     TO    po_item-prnt_price,
            wa_ekpo-schpr     TO    po_item-est_price,
            wa_ekpo-mahnz     TO    po_item-num_remind,
            wa_ekpo-mahn1     TO    po_item-reminder1,
            wa_ekpo-mahn2     TO    po_item-reminder2,
            wa_ekpo-mahn3     TO    po_item-reminder3,
            wa_ekpo-uebto     TO    po_item-overdeltol,
            wa_ekpo-uebtk     TO    po_item-unlimited,
            wa_ekpo-untto     TO    po_item-under_tol,
            wa_ekpo-bwtar     TO    po_item-val_type,
            wa_ekpo-bwtty     TO    po_item-val_cat,
            wa_ekpo-abskz     TO    po_item-rej_ind,
            wa_ekpo-agmem     TO    po_item-comment,
            wa_ekpo-elikz     TO    po_item-del_compl,
            wa_ekpo-erekz     TO    po_item-final_inv,
            wa_ekpo-pstyp     TO    po_item-item_cat,
            wa_ekpo-knttp     TO    po_item-acctasscat,
            wa_ekpo-kzvbr     TO    po_item-consumpt,
            wa_ekpo-vrtkz     TO    po_item-distrib,
            wa_ekpo-twrkz     TO    po_item-part_inv,
            wa_ekpo-wepos     TO    po_item-gr_ind,
            wa_ekpo-weunb     TO    po_item-gr_non_val,
            wa_ekpo-repos     TO    po_item-ir_ind,
            wa_ekpo-webre     TO    po_item-gr_basediv,
            wa_ekpo-kzabs     TO    po_item-ackn_reqd,
            wa_ekpo-labnr     TO    po_item-acknowl_no,
            wa_ekpo-konnr     TO    po_item-agreement,
            wa_ekpo-ktpnr     TO    po_item-agmt_item,
            wa_ekpo-abdat     TO    po_item-recon_date,
            wa_ekpo-abftz     TO    po_item-agrcumqty,
            wa_ekpo-etfz1     TO    po_item-firm_zone,
            wa_ekpo-etfz2     TO    po_item-trade_off,
            wa_ekpo-kzstu     TO    po_item-bom_expl,
            wa_ekpo-notkz     TO    po_item-exclusion,
            wa_ekpo-lmein     TO    po_item-base_unit,
            wa_ekpo-evers     TO    po_item-shipping,
            wa_ekpo-abmng     TO    po_item-relord_qty,
            wa_ekpo-prdat     TO    po_item-price_date,
            wa_ekpo-bstyp     TO    po_item-doc_cat,
            wa_ekpo-xoblr     TO    po_item-commitment,
            wa_ekpo-kunnr     TO    po_item-customer,
            wa_ekpo-adrnr     TO    po_item-address,
            wa_ekpo-ekkol     TO    po_item-cond_group,
            wa_ekpo-sktof     TO    po_item-no_c_disc,
            wa_ekpo-stafo     TO    po_item-update_grp,
            wa_ekpo-plifz     TO    po_item-plan_del,
            wa_ekpo-ntgew     TO    po_item-net_weight,
            wa_ekpo-gewei     TO    po_item-weightunit,
            wa_ekpo-txjcd     TO    po_item-tax_jur_cd,
            wa_ekpo-etdrk     TO    po_item-print_rel,
            wa_ekpo-sobkz     TO    po_item-spec_stock,
            wa_ekpo-arsnr     TO    po_item-setreserno,
            wa_ekpo-arsps     TO    po_item-settlitmno,
            wa_ekpo-insnc     TO    po_item-not_chgbl,
            wa_ekpo-ssqss     TO    po_item-ctr_key_qm,
            wa_ekpo-zgtyp     TO    po_item-cert_type,
            wa_ekpo-ean11     TO    po_item-ean_upc,
            wa_ekpo-bstae     TO    po_item-conf_ctrl,
            wa_ekpo-revlv     TO    po_item-rev_lev,
            wa_ekpo-geber     TO    po_item-fund,
            wa_ekpo-fistl     TO    po_item-funds_ctr,
            wa_ekpo-grant_nbr TO    po_item-grant_nbr,
            wa_ekpo-ko_gsber  TO    po_item-ba_partner,
            wa_ekpo-ko_pargb  TO    po_item-ptr_ass_ba,
            wa_ekpo-ko_prctr  TO    po_item-profit_ctr,
            wa_ekpo-ko_pprctr TO    po_item-partner_pc,
            wa_ekpo-meprf     TO    po_item-price_ctr,
            wa_ekpo-brgew     TO    po_item-gross_wght,
            wa_ekpo-volum     TO    po_item-volume,
            wa_ekpo-voleh     TO    po_item-volumeunit,
            wa_ekpo-inco1     TO    po_item-incoterms1,
            wa_ekpo-inco2     TO    po_item-incoterms2,
            wa_ekpo-vorab     TO    po_item-advance,
            wa_ekpo-kolif     TO    po_item-prior_vend,
            wa_ekpo-ltsnr     TO    po_item-sub_range,
            wa_ekpo-packno    TO    po_item-pckg_no,
            wa_ekpo-stapo     TO    po_item-statistic,
            wa_ekpo-uebpo     TO    po_item-hl_item,
            wa_ekpo-lewed     TO    po_item-gr_to_date,
            wa_ekpo-emlif     TO    po_item-suppl_vend,
            wa_ekpo-lblkz     TO    po_item-sc_vendor,
            wa_ekpo-satnr     TO    po_item-conf_matl,
            wa_ekpo-attyp     TO    po_item-mat_cat,
            wa_ekpo-kanba     TO    po_item-kanban_ind,
            wa_ekpo-adrn2     TO    po_item-address2,
            wa_ekpo-cuobj     TO    po_item-int_obj_no,
            wa_ekpo-xersy     TO    po_item-ers,
            wa_ekpo-eildt     TO    po_item-grsettfrom,
            wa_ekpo-drdat     TO    po_item-last_trans,
            wa_ekpo-druhr     TO    po_item-trans_time,
            wa_ekpo-drunr     TO    po_item-ser_no,
            wa_ekpo-aktnr     TO    po_item-promotion,
            wa_ekpo-abeln     TO    po_item-alloc_tbl,
            wa_ekpo-abelp     TO    po_item-at_item,
            wa_ekpo-anzpu     TO    po_item-points,
            wa_ekpo-punei     TO    po_item-points_un,
            wa_ekpo-saiso     TO    po_item-season_ty,
            wa_ekpo-saisj     TO    po_item-season_yr,
            wa_ekpo-ebon2     TO    po_item-sett_grp_2,
            wa_ekpo-ebon3     TO    po_item-sett_grp_3,
            wa_ekpo-ebonf     TO    po_item-sett_item,
            wa_ekpo-mlmaa     TO    po_item-ml_akt,
            wa_ekpo-mhdrz     TO    po_item-remshlife,
            wa_ekpo-anfnr     TO    po_item-rfq,
            wa_ekpo-anfps     TO    po_item-rfq_item,
            wa_ekpo-kzkfg     TO    po_item-config_org,
            wa_ekpo-usequ     TO    po_item-quotausage,
            wa_ekpo-umsok     TO    po_item-spstck_phy,
            wa_ekpo-banfn     TO    po_item-preq_no,
            wa_ekpo-bnfpo     TO    po_item-preq_item,
            wa_ekpo-mtart     TO    po_item-mat_type,
            wa_ekpo-uptyp     TO    po_item-si_cat,
            wa_ekpo-upvor     TO    po_item-sub_items,
            wa_ekpo-sikgr     TO    po_item-subitm_key,
            wa_ekpo-mfzhi     TO    po_item-max_cmg,
            wa_ekpo-ffzhi     TO    po_item-max_cpgo,
            wa_ekpo-retpo     TO    po_item-ret_item,
            wa_ekpo-aurel     TO    po_item-at_relev,
            wa_ekpo-bsgru     TO    po_item-ord_reas,
            wa_ekpo-lfret     TO    po_item-del_typ_rt,
            wa_ekpo-mfrgr     TO    po_item-prdte_ctrl.

*----- Convert Long FM Fields   --------------------------------------*
      CALL FUNCTION 'FUNC_AREA_CONVERSION_OUTBOUND'
        EXPORTING
          i_func_area_long = wa_ekpo-fkber
        IMPORTING
          e_func_area_long = po_item-func_area_long.

      CALL FUNCTION 'CMMT_ITEM_CONVERSION_OUTBOUND'
        EXPORTING
          i_cmmt_item      = wa_ekpo-fipos
        IMPORTING
          e_cmmt_item_long = po_item-cmmt_item_long
          e_cmmt_item      = po_item-cmmt_item.

* read po_headers to determine the currency
      READ TABLE po_headers INTO po_header WITH KEY po_number = wa_ekpo-ebeln BINARY SEARCH.

* no entry in po_headers - read currency from database
      IF sy-subrc NE 0.
        SELECT SINGLE waers FROM ekko INTO po_header-currency
                                      WHERE ebeln EQ wa_ekpo-ebeln.
      ENDIF.

      PERFORM value_to_external USING wa_ekpo-netpr po_header-currency
                                      po_item-net_price.
      PERFORM value_to_external USING wa_ekpo-netwr po_header-currency
                                      po_item-net_value.
      PERFORM value_to_external USING wa_ekpo-brtwr po_header-currency
                                      po_item-gros_value.
      PERFORM value_to_external USING wa_ekpo-zwert po_header-currency
                                      po_item-outl_targv.
      PERFORM value_to_external USING wa_ekpo-navnw po_header-currency
                                      po_item-nond_itax.
      PERFORM value_to_external USING wa_ekpo-effwr po_header-currency
                                      po_item-eff_value.
      PERFORM value_to_external USING wa_ekpo-kzwi1 po_header-currency
                                      po_item-subtotal_1.
      PERFORM value_to_external USING wa_ekpo-kzwi2 po_header-currency
                                      po_item-subtotal_2.
      PERFORM value_to_external USING wa_ekpo-kzwi3 po_header-currency
                                      po_item-subtotal_3.
      PERFORM value_to_external USING wa_ekpo-kzwi4 po_header-currency
                                      po_item-subtotal_4.
      PERFORM value_to_external USING wa_ekpo-kzwi5 po_header-currency
                                      po_item-subtotal_5.
      PERFORM value_to_external USING wa_ekpo-kzwi6 po_header-currency
                                      po_item-subtotal_6.

      APPEND po_item TO po_items.
      CLEAR: wa_ekpo, po_item, po_header.
    ENDLOOP.

    IF po_items[] IS NOT INITIAL.
      SORT po_items BY po_number.
    ENDIF.
  ENDIF.

  IF it_ekkn IS NOT INITIAL.
    " move ekkn to po_accounts
    LOOP AT it_ekkn INTO wa_ekkn.
      MOVE: wa_ekkn-ebeln        TO po_account-po_number,
            wa_ekkn-ebelp        TO po_account-po_item,
            wa_ekkn-zekkn        TO po_account-serial_no,
            wa_ekkn-menge        TO po_account-quantity,
            wa_ekkn-vproz        TO po_account-distr_perc,
            wa_ekkn-sakto        TO po_account-g_l_acct,
            wa_ekkn-gsber        TO po_account-bus_area,
            wa_ekkn-kostl        TO po_account-cost_ctr,
            wa_ekkn-vbeln        TO po_account-sd_doc,
            wa_ekkn-vbelp        TO po_account-sdoc_item,
            wa_ekkn-veten        TO po_account-sched_line,
            wa_ekkn-anln1        TO po_account-asset_no,
            wa_ekkn-anln2        TO po_account-sub_number,
            wa_ekkn-aufnr        TO po_account-order_no,
            wa_ekkn-wempf        TO po_account-gr_rcpt,
            wa_ekkn-ablad        TO po_account-unload_pt,
            wa_ekkn-kokrs        TO po_account-co_area,
            wa_ekkn-xbkst        TO po_account-to_costctr,
            wa_ekkn-xbauf        TO po_account-to_order,
            wa_ekkn-xbpro        TO po_account-to_project,
            wa_ekkn-kstrg        TO po_account-cost_obj,
            wa_ekkn-paobjnr      TO po_account-prof_segm,
            wa_ekkn-prctr        TO po_account-profit_ctr,
            wa_ekkn-nplnr        TO po_account-network,
            wa_ekkn-aufpl        TO po_account-routing_no,
            wa_ekkn-imkey        TO po_account-rl_est_key,
            wa_ekkn-aplzl        TO po_account-counter,
            wa_ekkn-vptnr        TO po_account-part_acct,
            wa_ekkn-recid        TO po_account-rec_ind,
            wa_ekkn-fistl        TO po_account-funds_ctr,
            wa_ekkn-geber        TO po_account-fund,
            wa_ekkn-grant_nbr    TO po_account-grant_nbr,
            wa_ekkn-dabrz        TO po_account-ref_date,
            wa_ekkn-kblnr        TO po_account-funds_res,
            wa_ekkn-kblpos       TO po_account-res_item.

*----- Convert Long FM Fields   --------------------------------------*
      CALL FUNCTION 'FUNC_AREA_CONVERSION_OUTBOUND'
        EXPORTING
          i_func_area_long = wa_ekkn-fkber
        IMPORTING
          e_func_area      = po_account-func_area
          e_func_area_long = po_account-func_area_long.

      CALL FUNCTION 'CMMT_ITEM_CONVERSION_OUTBOUND'
        EXPORTING
          i_cmmt_item      = wa_ekkn-fipos
        IMPORTING
          e_cmmt_item_long = po_account-cmmt_item_long
          e_cmmt_item      = po_account-cmmt_item.

      IF NOT wa_ekkn-ps_psp_pnr IS INITIAL.
        CALL FUNCTION 'PSPNUM_INTERN_TO_EXTERN_CONV'
          EXPORTING
            int_num = wa_ekkn-ps_psp_pnr
          IMPORTING
            ext_num = po_account-wbs_elem_e.
      ENDIF.
      IF NOT wa_ekkn-aufpl IS INITIAL AND
         NOT wa_ekkn-aplzl IS INITIAL.
        CALL FUNCTION 'READ_NETWORK_NPLNR_VORNR'
          EXPORTING
            aplzl     = wa_ekkn-aplzl
            aufpl     = wa_ekkn-aufpl
          IMPORTING
            nplnr     = po_account-network
            vornr     = po_account-activity
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc <> 0.
          CLEAR: po_account-network,
                 po_account-activity.
        ENDIF.
      ENDIF.

      APPEND po_account TO po_accounts.
      CLEAR: wa_ekkn, po_account.
    ENDLOOP.
  ENDIF.

  IF it_eket[] IS NOT INITIAL.
    " move eket to po_schedules
    LOOP AT it_eket INTO wa_eket.
      MOVE: wa_eket-ebeln TO po_schedule-po_number,
            wa_eket-ebelp TO po_schedule-po_item,
            wa_eket-etenr TO po_schedule-serial_no,
            wa_eket-eindt TO po_schedule-deliv_date,
            wa_eket-lpein TO po_schedule-del_datcat,
            wa_eket-menge TO po_schedule-quantity,
            wa_eket-uzeit TO po_schedule-deliv_time,
            wa_eket-banfn TO po_schedule-preq_no,
            wa_eket-bnfpo TO po_schedule-preq_item,
            wa_eket-estkz TO po_schedule-create_ind,
            wa_eket-qunum TO po_schedule-quota_no,
            wa_eket-qupos TO po_schedule-quota_item,
            wa_eket-rsnum TO po_schedule-reserv_no,
            wa_eket-sernr TO po_schedule-bomexpl_no,
            wa_eket-charg TO po_schedule-batch,
            wa_eket-licha TO po_schedule-vend_batch,
            wa_eket-verid TO po_schedule-version.
* convert internal delivery date category to external format
      PERFORM date_category_convert_external USING
                   po_schedule-del_datcat_ext
                   wa_eket-lpein.

      APPEND po_schedule TO po_schedules.
      CLEAR: wa_eket, po_schedule.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
