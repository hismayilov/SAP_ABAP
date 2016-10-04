" Added Gross, Absolute and Total Discount in ZPUREG

" Declaration
" Begin Addition by SaurabhK on 29/09/2016
DATA: v_knumv like ekko-knumv,
      v_kschl like konv-kschl,
      v_kbetr like konv-kbetr.
" End Addition By SaurabhK

DATA : BEGIN OF it_item OCCURS 0,
  .....
        gr-dis TYPE rseg-wrbtr,       " R000 Discount " --> Added by SaurabhK on 29/9/2016
        qty_dis TYPE  bseg-dmbtr,     " R001 Discount " --> Added by SaurabhK on 29/9/2016
        abs-dis TYPE rseg-wrbtr,      " R002 Discount " --> Added by SaurabhK on 29/9/2016
  .....
  
LOOP AT it_item.

......
  " Begin Addition by SaurabhK on 29/09/2016
    " Fetch and add discount data for PO/ Discount Condition Types R000, R001
    IF it_item-menge is NOT INITIAL.

      SELECT SINGLE knumv from ekko into v_knumv where ebeln = it_item-ebeln.

      IF v_knumv is not INITIAL.
        " Gross
         SELECT SINGLE kbetr from konv into v_kbetr where knumv = v_knumv and kschl = 'R000'.
         "it_item-gr-dis = it_item-menge * ( v_kbetr / ( it_item-menge * 100 ) ) * it_item-base_amt.
         it_item-gr-dis = ( v_kbetr /  1000 ) * it_item-base_amt.

         " Qty
         SELECT SINGLE kbetr from konv into v_kbetr where knumv = v_knumv and kschl = 'R001'.
         it_item-qty_dis = it_item-menge * v_kbetr.

         " Absolute
         SELECT SINGLE kbetr from konv into v_kbetr where knumv = v_knumv and kschl = 'R002'.
         it_item-abs-dis = it_item-menge * v_kbetr.
      ENDIF.

    ENDIF.
    " End Addition By SaurabhK

    MODIFY it_item.
  ENDLOOP.
  
*&---------------------------------------------------------------------*
*&      Form  initialize_fieldcat
*&---------------------------------------------------------------------*
FORM initialize_fieldcat .
.....

cnt = cnt + 1.
  PERFORM  fill_alv_fieldcat USING 'GR-DIS' 'IT_ITEM' 'WRBTR' 'RSEG'
                          ' '   'Gross Discount'
                                'Gross Discount'
                                'Gross Discount'
                                '15'    cnt.
  " --> Added by SaurabhK on 29/9/16
  cnt = cnt + 1.
  PERFORM  fill_alv_fieldcat USING 'ABS-DIS' 'IT_ITEM' 'WRBTR' 'RSEG'
                          ' '   'Absolute Discount'
                                'Absolute Discount'
                                'Absolute Discount'
                                '15'    cnt.
  " --> End of Addition

  " --> Added by SaurabhK on 29/9/2016
  cnt = cnt + 1.
  PERFORM  fill_alv_fieldcat USING 'QTY_DIS' 'IT_ITEM' 'WRBTR' 'RSEG'
                          ' '   'Quantity Discount'
                                'Quantity Discount'
                                'Quantity Discount'
                                '12'    cnt.
  "--> End of Addition
  ....
