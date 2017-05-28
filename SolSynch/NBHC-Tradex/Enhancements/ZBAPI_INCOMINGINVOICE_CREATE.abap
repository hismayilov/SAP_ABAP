FUNCTION zbapi_incominginvoice_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(HEADERDATA) LIKE  BAPI_INCINV_CREATE_HEADER STRUCTURE
*"        BAPI_INCINV_CREATE_HEADER
*"  TABLES
*"      ITEMDATA STRUCTURE  BAPI_INCINV_CREATE_ITEM
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
**Added by: Prasad gurjar on 13.12.2016
**Desc.   : Pass debit note

  DATA : header1 TYPE bapi_incinv_create_header,
      it_itemdata1 TYPE TABLE OF bapi_incinv_create_item,
      wa_itemdata TYPE bapi_incinv_create_item ,
      it_return1 TYPE TABLE OF bapiret2.

  DATA:invoicedocnumber TYPE  bapi_incinv_fld-inv_doc_no,
       fiscalyear       TYPE bapi_incinv_fld-fisc_year,
       v_msg            TYPE string.

BREAK ftabap.
  WAIT UP TO 2 SECONDS.

  MOVE-CORRESPONDING headerdata TO header1.

  IF header1 IS NOT INITIAL.
    header1-calc_tax_ind = 'X'.
  ENDIF.

  LOOP AT itemdata INTO wa_itemdata.
    APPEND wa_itemdata TO  it_itemdata1.
  ENDLOOP.

  IF it_itemdata1[] IS NOT INITIAL.
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
    EXPORTING
        headerdata                = header1
***   ADDRESSDATA               =
    IMPORTING
      invoicedocnumber          = invoicedocnumber
     fiscalyear                 = fiscalyear
    TABLES
     itemdata                  = it_itemdata1[]
     return                    = it_return1[].

    IF invoicedocnumber IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.
  ENDIF.
ENDFUNCTION.
