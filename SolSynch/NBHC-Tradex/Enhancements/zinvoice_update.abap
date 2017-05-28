METHOD if_ex_invoice_update~change_at_save.
******************************************************************************************************************************************
*****Added by Prasad Gurjar on 09.12.2016
*****Desc: Pass debit note as per deduction %
******************************************************************************************************************************************

  "Declaration for bapi
  DATA : header TYPE bapi_incinv_create_header,
         it_itemdata TYPE TABLE OF bapi_incinv_create_item,
         wa_itemdata TYPE bapi_incinv_create_item ,
         it_return TYPE TABLE OF bapiret2.

  "Data declaration
  DATA: it_ekbe TYPE TABLE OF ekbe,
        wa_ekbe TYPE ekbe,
        it_specs TYPE TABLE OF ztb_trd_specs,
        wa_specs TYPE ztb_trd_specs,
        v_percent TYPE p DECIMALS 3,
        v_deb_amt TYPE bseg-wrbtr,
        v_tax TYPE bset-fwste,
        v_bukrs    TYPE bkpf-bukrs,
        v_taxcode  TYPE bseg-mwskz,
        v_curr     TYPE bkpf-waers.

  DATA: t_mwdat TYPE TABLE OF rtax1u15.

  "For deduction percentage debit note
  break ftabap.
  IF sy-tcode = 'MIRO'.
*     AND ( sy-ucomm = 'BU' OR sy-ucomm = 'PB' ).

    IF ti_rseg_new[] IS NOT INITIAL.
      SELECT *
        FROM ekbe
        INTO CORRESPONDING FIELDS OF TABLE it_ekbe
        FOR ALL ENTRIES IN ti_rseg_new
        WHERE ebeln EQ ti_rseg_new-ebeln.
    ENDIF.

    IF it_ekbe[] IS NOT INITIAL.
      SELECT *
        FROM ekkn
        INTO CORRESPONDING FIELDS OF TABLE it_ekkn
        FOR ALL ENTRIES IN it_ekbe
        WHERE ebeln EQ it_ekbe-ebeln
        AND   ebelp EQ it_ekbe-ebelp.
    ENDIF.

    IF it_ekkn[] IS NOT INITIAL.
      SELECT *
        FROM ztb_trd_specs
        INTO CORRESPONDING FIELDS OF TABLE it_specs
        FOR ALL ENTRIES IN it_ekkn
        WHERE vbeln EQ it_ekkn-vbeln
        AND   posnr EQ it_ekkn-vbelp.
    ENDIF.

    IF sy-subrc = 0. "This is to check PO is related with contract of type YSOW

      LOOP AT it_specs INTO wa_specs.
        v_percent = v_percent + wa_specs-act_dect.  "Get total deduction % of all the characteristics
      ENDLOOP.

      READ TABLE ti_rseg_new INTO wa_rseg INDEX 1.

      v_deb_amt = ( wa_rseg-wrbtr * v_percent ) / 100. "Calculate debit note amt.

    ENDIF.
**--------------------------------------------------------------------------------------------------------------------------------------
****Debit note: Deduction percentage
**--------------------------------------------------------------------------------------------------------------------------------------
    IF v_deb_amt IS NOT INITIAL.

*********Commented by Prasad with **

**        v_bukrs   = s_rbkp_new-bukrs.
**        v_taxcode = s_rbkp_new-mwskz1.
**        v_curr    = s_rbkp_new-waers.
**
**        "To calculate tax for the debit amt.that we have calculated
**        CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
**          EXPORTING
**            i_bukrs = v_bukrs
**            i_mwskz = v_taxcode
**            i_waers = v_curr
**            i_wrbtr = v_deb_amt
**          IMPORTING
**            e_fwste = v_tax
**          TABLES
**            t_mwdat = t_mwdat.
**
**        IF sy-subrc <> 0.
*** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**        ENDIF.
**
**        " Header data
**        header-doc_date    = s_rbkp_new-bldat.
**        header-pstng_date  = s_rbkp_new-budat.
**        header-gross_amount = ( v_deb_amt + v_tax ).
**        header-comp_code   = s_rbkp_new-bukrs.
**        header-currency    = s_rbkp_new-waers.
**        header-bline_date  = s_rbkp_new-zfbdt.
**        header-po_ref_no   = wa_rseg-ebeln.
**
**        "Line item data
**        wa_itemdata-invoice_doc_item = wa_rseg-ebelp.
**        wa_itemdata-po_number        = wa_rseg-ebeln.
**        wa_itemdata-po_item          = wa_rseg-ebelp.
**        wa_itemdata-de_cre_ind       = 'X'.
**        wa_itemdata-tax_code         = s_rbkp_new-mwskz1.
**        wa_itemdata-item_amount      = ( v_deb_amt ). " + v_tax ).
**        wa_itemdata-quantity         = wa_rseg-menge.
**        wa_itemdata-po_unit          = wa_rseg-bstme.
**
**        APPEND wa_itemdata TO it_itemdata.
**
**        EXPORT header FROM header TO MEMORY ID 'HEADER'.
**        EXPORT it_itemdata FROM it_itemdata TO MEMORY ID 'ITEM'.

**********Till here
**-----------------------------------------------------------------------------------------------------------------------------------------
****Debit Note: For invocie qty greater than GRN qty.
**-----------------------------------------------------------------------------------------------------------------------------------------
    ELSE.

      DATA: v_migo_qty TYPE ekbe-menge,
            v_ext_qty TYPE ekbe-menge,
            v_migo_amt TYPE ekbe-dmbtr,
            v_ext_amt TYPE ekbe-dmbtr.

      READ TABLE ti_rseg_new INTO wa_rseg INDEX 1.

      LOOP AT it_ekbe INTO wa_ekbe WHERE bwart = '101'.
        v_migo_qty = v_migo_qty + wa_ekbe-menge. "Total migo qty.
        v_migo_amt = v_migo_amt + wa_ekbe-dmbtr. "Total migo amt.
      ENDLOOP.

      v_ext_qty = wa_rseg-menge - v_migo_qty.                 "Difference between GRN qty and invocie qty.

      v_ext_amt = ( ( v_migo_amt * v_ext_qty ) / v_migo_qty )."Debit note to be posted for this differential amt.

      IF v_ext_amt IS NOT INITIAL.
        v_bukrs   = s_rbkp_new-bukrs.
        v_taxcode = s_rbkp_new-mwskz1.
        v_curr    = s_rbkp_new-waers.

        "To calculate tax for the debit amt.that we have calculated
        CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
          EXPORTING
            i_bukrs = v_bukrs
            i_mwskz = v_taxcode
            i_waers = v_curr
            i_wrbtr = v_ext_amt
          IMPORTING
            e_fwste = v_tax
          TABLES
            t_mwdat = t_mwdat.

        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        " Header data
        header-doc_date    = s_rbkp_new-bldat.
        header-pstng_date  = s_rbkp_new-budat.
        header-gross_amount = ( v_ext_amt + v_tax ).
        header-comp_code   = s_rbkp_new-bukrs.
        header-currency    = s_rbkp_new-waers.
        header-bline_date  = s_rbkp_new-zfbdt.
        header-po_ref_no   = wa_rseg-ebeln.

        "Line item data
        wa_itemdata-invoice_doc_item = wa_rseg-ebelp.
        wa_itemdata-po_number        = wa_rseg-ebeln.
        wa_itemdata-po_item          = wa_rseg-ebelp.
        wa_itemdata-de_cre_ind       = 'X'.
        wa_itemdata-tax_code         = s_rbkp_new-mwskz1.
        wa_itemdata-item_amount      = ( v_ext_amt ). " + v_tax ).
        wa_itemdata-quantity         = v_ext_qty.
        wa_itemdata-po_unit          = wa_rseg-bstme.

        wa_itemdata-ref_doc          = wa_ekbe-lfbnr.
        wa_itemdata-ref_doc_year     = wa_ekbe-gjahr.
        wa_itemdata-ref_doc_it     = wa_ekbe-ebelp.

        APPEND wa_itemdata TO it_itemdata.

        EXPORT header FROM header TO MEMORY ID 'HEADER'.
        EXPORT it_itemdata FROM it_itemdata TO MEMORY ID 'ITEM'.
      ENDIF.
*    ENDIF.
    ENDIF.
  ENDIF.
*************************************************************************************************PG

ENDMETHOD.

METHOD if_ex_invoice_update~change_before_update.

************************************************************************************************************************************
***** Added by Prasad Gurjar on 9.12.2016
***** Desc: Pass debit entry as per the deduction %
************************************************************************************************************************************
  IF sy-tcode = 'MIRO'.
BREAK ftabap.
    "BAPI declaration
    DATA : header TYPE bapi_incinv_create_header,
           it_itemdata TYPE TABLE OF bapi_incinv_create_item,
           wa_itemdata TYPE bapi_incinv_create_item ,
           it_return TYPE TABLE OF bapiret2.

    "Data declaration
    DATA:invoicedocnumber TYPE  bapi_incinv_fld-inv_doc_no,
         fiscalyear       TYPE bapi_incinv_fld-fisc_year,
         cr(8)            TYPE c.

    IMPORT header TO header FROM MEMORY ID 'HEADER'.
    IMPORT it_itemdata TO it_itemdata FROM MEMORY ID 'ITEM'.

    IF it_itemdata[] IS NOT INITIAL.
      header-ref_doc_no = s_rbkp_new-belnr.

      COMMIT WORK.
      "This will call new task(session) to process debit note with the invoice reference
      CALL FUNCTION 'ZBAPI_INCOMINGINVOICE_CREATE' STARTING NEW TASK cr DESTINATION 'NONE'
        EXPORTING
          headerdata = header
        TABLES
          itemdata   = it_itemdata[]
          return     = it_return[].

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.
  ENDIF.
*************************************************************************************************************************************

ENDMETHOD.
