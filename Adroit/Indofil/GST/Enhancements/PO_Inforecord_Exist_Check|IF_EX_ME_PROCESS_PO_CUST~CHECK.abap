DATA : ls_header TYPE mepoheader.
DATA : l_items TYPE purchase_order_items.
DATA : l_items_header TYPE mepoitem.

ls_header = im_header->get_data( ).
CALL METHOD im_header->get_items
    RECEIVING
      re_items = l_items.
*{   INSERT         IRPK900480                                        6

IF ls_header-bsart = 'ZSTO' OR ls_header-bsart = 'YSTO' .

  DATA: it_eina TYPE TABLE OF eina,
        wa_eina TYPE eina,

        it_eine TYPE TABLE OF eine,
        wa_eine TYPE eine.

  DATA: lv_reswk TYPE eina-lifnr,
        v_msg TYPE string.
*Saurabh
  LOOP AT l_items INTO l_single.
    CLEAR: l_items_header, lv_reswk.
    CALL METHOD l_single-item->get_data
      RECEIVING
        re_data = l_items_header.

    CONCATENATE 'V' ls_header-reswk INTO lv_reswk.

    SELECT *
      FROM eina
      INTO TABLE it_eina
      WHERE matnr = l_items_header-matnr
      AND   lifnr = lv_reswk.

    IF sy-subrc = 0 AND it_eina IS NOT INITIAL.
      SELECT *
        FROM eine
        INTO TABLE it_eine
        FOR ALL ENTRIES IN it_eina
        WHERE infnr = it_eina-infnr
        AND   ekorg = ls_header-ekorg
        AND   werks = l_items_header-werks.
    ENDIF.

    IF it_eine[] IS INITIAL.
      CLEAR v_msg.
      SHIFT l_items_header-ebelp LEFT DELETING LEADING '0'.
      CONCATENATE 'Item' l_items_header-ebelp 'Maintain Inforecord against'
      ls_header-reswk '/' l_items_header-werks 'in STO'
      INTO v_msg SEPARATED BY space.
      MESSAGE  v_msg TYPE 'E'.
    ENDIF.

    REFRESH: it_eina[], it_eine[].
  ENDLOOP.
ENDIF.

*}   INSERT
