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
          wa_eine TYPE eine,

          v_gstno TYPE kna1-stcd3.

    DATA: lv_reswk    TYPE eina-lifnr,
          v_msg       TYPE string,
          lifnr       TYPE bdcdata-fval,
          matnr       TYPE bdcdata-fval,
          ekorg       TYPE bdcdata-fval,
          werks       TYPE bdcdata-fval,
          ekgrp       TYPE bdcdata-fval,
          netpr       TYPE bdcdata-fval,
          subrc       LIKE sy-subrc,
          messages    TYPE TABLE OF bdcmsgcoll,
          lw_messages TYPE bdcmsgcoll,
          v_supplnt   TYPE kna1-kunnr,
          v_recplnt   TYPE kna1-kunnr.

*Saurabh
    LOOP AT l_items INTO l_single.
      CLEAR: l_items_header, lv_reswk, v_supplnt, v_recplnt.
      CALL METHOD l_single-item->get_data
        RECEIVING
          re_data = l_items_header.
* Make GST No mandatory for supplying, recieving plant *
      CONCATENATE 'V' ls_header-reswk INTO lv_reswk.
      CONCATENATE 'C' ls_header-reswk INTO v_supplnt.
      CONCATENATE 'C' l_items_header-werks INTO v_recplnt.

      IF v_supplnt IS NOT INITIAL.
        CLEAR v_gstno.
        SELECT SINGLE stcd3
          FROM kna1
          INTO v_gstno
          WHERE kunnr = v_supplnt.
        IF v_gstno IS INITIAL.
          CLEAR msg.
          CONCATENATE 'GSTIN No. not maintained for plant' ls_header-reswk INTO msg SEPARATED BY space.
          MESSAGE msg TYPE 'E'.
        ENDIF.
      ENDIF.

      IF v_recplnt IS NOT INITIAL.
        CLEAR v_gstno.
        SELECT SINGLE stcd3
          FROM kna1
          INTO v_gstno
          WHERE kunnr = v_recplnt.
        IF v_gstno IS INITIAL.
          CLEAR msg.
          CONCATENATE 'GSTIN No. not maintained for plant' l_items_header-werks INTO msg SEPARATED BY space.
          MESSAGE msg TYPE 'E'.
        ENDIF.
      ENDIF.
* Maintain inforecord for material, purch org, plnt before saving if not maintained *
      SELECT *
        FROM eina
        INTO TABLE it_eina
        WHERE matnr = l_items_header-matnr
        AND   lifnr = lv_reswk
        AND   loekz NE 'X'.

      IF sy-subrc = 0 AND it_eina IS NOT INITIAL.
        SELECT *
          FROM eine
          INTO TABLE it_eine
          FOR ALL ENTRIES IN it_eina
          WHERE infnr = it_eina-infnr
          AND   ekorg = ls_header-ekorg
          AND   werks = l_items_header-werks
          AND   loekz NE 'X'.
      ENDIF.

      IF it_eine[] IS INITIAL.
        CLEAR v_msg.
        SHIFT l_items_header-ebelp LEFT DELETING LEADING '0'.
        CONCATENATE 'Item' l_items_header-ebelp 'Maintaining Inforecord against'
        ls_header-reswk '/' l_items_header-werks 'in STO...'
        INTO v_msg SEPARATED BY space.
        MESSAGE  v_msg TYPE 'S'.

        CLEAR: lifnr, matnr, ekorg, werks, ekgrp, netpr.
        MOVE: lv_reswk TO lifnr,
              l_items_header-matnr TO matnr,
              ls_header-ekorg TO ekorg,
              l_items_header-werks TO werks,
              ls_header-ekgrp TO ekgrp,
              l_items_header-netpr TO netpr.

        SHIFT netpr LEFT DELETING LEADING space.

        CALL FUNCTION 'ZFM_INFORECORD_ME11_PO'
          EXPORTING
*           mode      = 'N'
            lifnr_001 = lifnr  "'V1101'
            matnr_002 = matnr  "'20000096'
            ekorg_003 = ekorg  "'1000'
            werks_004 = werks  "'1201'
            ekgrp_011 = ekgrp  "'302'
*           mwskz_012 = 'G3'
            netpr_015 = netpr  "'             1'
          IMPORTING
            subrc     = subrc
          TABLES
            messtab   = messages.

        REFRESH: it_eina[], it_eine[].

        SELECT *
        FROM eina
        INTO TABLE it_eina
        WHERE matnr = l_items_header-matnr
        AND   lifnr = lv_reswk.

        IF sy-subrc = 0 AND it_eina[] IS NOT INITIAL.
          SELECT *
            FROM eine
            INTO TABLE it_eine
            FOR ALL ENTRIES IN it_eina
            WHERE infnr = it_eina-infnr
            AND   ekorg = ls_header-ekorg
            AND   werks = l_items_header-werks.
        ENDIF.

        IF it_eine[] IS NOT INITIAL.
          CLEAR v_msg.
          SHIFT l_items_header-ebelp LEFT DELETING LEADING '0'.
          CONCATENATE 'Item' l_items_header-ebelp 'Inforecord maintained against'
          ls_header-reswk '/' l_items_header-werks 'in STO...'
          INTO v_msg SEPARATED BY space.
          MESSAGE  v_msg TYPE 'S'.
        ELSE.
          CLEAR v_msg.
          SHIFT l_items_header-ebelp LEFT DELETING LEADING '0'.
          CONCATENATE 'Item' l_items_header-ebelp 'Inforecord not maintained against'
          ls_header-reswk '/' l_items_header-werks 'in STO...'
          INTO v_msg SEPARATED BY space.
          MESSAGE  v_msg TYPE 'E'.
        ENDIF.

      ENDIF.

      REFRESH: it_eina[], it_eine[], messages[].
    ENDLOOP.
  ENDIF.

*}   INSERT
