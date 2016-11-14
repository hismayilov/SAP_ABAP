  method if_ex_me_purchdoc_posted~posted.

*    break abap_dev.
    data : it_ekpo  type table of ekpo,
           wa_ekpo type ekpo.

    data :  return  type table of bapiret2,
            poitem  type table of bapimepoitem,
            wa_item type bapimepoitem,
            poitemx	type table of	bapimepoitemx,
            wa_itemx type   bapimepoitemx.


    select * from ekpo into table it_ekpo
      where ebeln = im_ekko-ebeln.
    if im_ekko-procstat = '08'.

      loop at it_ekpo into wa_ekpo.
        wa_item-po_item = wa_ekpo-ebelp.
        wa_item-no_more_gr = 'X'.
        append wa_item to poitem.
        wa_itemx-po_item = wa_ekpo-ebelp.
        wa_itemx-no_more_gr = 'X'.
        append wa_itemx to poitemx.
        clear wa_ekpo.
      endloop.

      call function 'BAPI_PO_CHANGE' in background task
        exporting
          purchaseorder = im_ekko-ebeln
        tables
          return        = return
          poitem        = poitem
          poitemx       = poitemx.
      if sy-subrc = 0.
        call function 'BAPI_TRANSACTION_COMMIT'.

      endif.

    elseif im_ekko_old-procstat = '08' and im_ekko-procstat = '03'.


      loop at it_ekpo into wa_ekpo.
        wa_item-po_item = wa_ekpo-ebelp.
        wa_item-no_more_gr = ''.
        append wa_item to poitem.
        wa_itemx-po_item = wa_ekpo-ebelp.
        wa_itemx-no_more_gr = 'X'.
        append wa_itemx to poitemx.
        clear wa_ekpo.
      endloop.

      call function 'BAPI_PO_CHANGE' in background task
        exporting
          purchaseorder = im_ekko-ebeln
        tables
          return        = return
          poitem        = poitem
          poitemx       = poitemx.
      if sy-subrc = 0.
        call function 'BAPI_TRANSACTION_COMMIT'.

      endif.
    endif.


  endmethod.
