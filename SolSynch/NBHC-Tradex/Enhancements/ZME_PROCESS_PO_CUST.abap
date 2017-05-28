METHOD if_ex_me_process_po_cust~process_account.
*  break ftabap.
*** Get Qty in SOW and check if total PO qnty exceeds it
  IF sy-tcode = 'ME21N' OR sy-tcode = 'ME22N'.

    TYPES: BEGIN OF ty_valtab,
            data(100),
           END OF ty_valtab.

    DATA: re_item TYPE REF TO if_purchase_order_item_mm,
          re_itemdet TYPE mepoitem,
          re_data TYPE mepoaccounting,
          v_qty TYPE mepoitem-menge,
          v_so TYPE mepoaccounting-vbeln,
          v_so_line TYPE mepoaccounting-vbelp,
          v_ebeln   TYPE mepoitem-ebeln,
          v_ebelp   TYPE mepoitem-ebelp,
          wa_vbap TYPE vbap,
          wa_vbak TYPE vbak,
          v_sow_qty TYPE vbap-kwmeng,
          v_msg TYPE string,
          it_fields TYPE STANDARD TABLE OF help_value,  " for popup table display
          wa_fields TYPE help_value,
          it_valtab TYPE STANDARD TABLE OF ty_valtab,   " for popup table display
          wa_valtab TYPE ty_valtab.

    CALL METHOD im_account->get_item
      RECEIVING
        re_item = re_item.

    CALL METHOD re_item->get_data
      RECEIVING
        re_data = re_itemdet.

    CALL METHOD im_account->get_data
      RECEIVING
        re_data = re_data.

    v_ebeln = re_itemdet-ebeln.
    v_ebelp = re_itemdet-ebelp.
    v_qty = re_itemdet-menge.
    v_so = re_data-vbeln.
    v_so_line = re_data-vbelp.

    "added by Saurabh
    DATA : v_sumqty TYPE mepoitem-menge,
           v_difqty TYPE string.  "mepoitem-menge.

    IF  v_so IS NOT INITIAL AND v_so_line IS NOT INITIAL.

      SELECT SINGLE *
        FROM vbap
        INTO wa_vbap
        WHERE vbeln = v_so
        AND posnr = v_so_line.

      SELECT SINGLE *
        FROM vbak
        INTO wa_vbak
        WHERE vbeln = v_so.

      IF wa_vbap IS NOT INITIAL AND wa_vbap IS NOT INITIAL AND re_itemdet-matnr IS NOT INITIAL.
        IF wa_vbap-matnr NE re_itemdet-matnr.
          CONCATENATE 'Material does not match with' v_so '/' v_so_line '-' 'Expected:' wa_vbap-matnr INTO v_msg SEPARATED BY space.
          MESSAGE v_msg TYPE 'E'.
        ELSE.
          v_sow_qty = wa_vbap-kwmeng.
        ENDIF.
      ELSEIF wa_vbap IS NOT INITIAL AND re_itemdet-matnr IS INITIAL..
        CONCATENATE 'Material for' v_so '/' v_so_line ':' INTO v_msg SEPARATED BY space.

        " Build valtab from wa_vbap for popup table display
        MOVE wa_vbap-vbeln TO wa_valtab-data.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbap-posnr TO wa_valtab-data.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbak-kunnr TO wa_valtab-data.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbap-matnr TO wa_valtab-data.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbap-arktx TO wa_valtab-data.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbap-kwmeng TO wa_valtab-data.
        SHIFT wa_valtab LEFT DELETING LEADING space.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbap-vrkme TO wa_valtab-data.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbap-werks TO wa_valtab-data.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbap-netpr TO wa_valtab-data.
        SHIFT wa_valtab LEFT DELETING LEADING space.
        APPEND wa_valtab TO it_valtab.

        MOVE wa_vbap-waerk TO wa_valtab-data.
        APPEND wa_valtab TO it_valtab.

        " Build field-tab from vbap for popup table display
        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'VBELN'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'POSNR'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAK'.
        wa_fields-fieldname = 'KUNNR'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'MATNR'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'ARKTX'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'KWMENG'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'VRKME'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'WERKS'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'NETPR'.
        APPEND wa_fields TO it_fields.

        wa_fields-tabname = 'VBAP'.
        wa_fields-fieldname = 'WAERK'.
        APPEND wa_fields TO it_fields.

        CALL FUNCTION 'POPUP_TO_SHOW_DB_DATA_IN_TABLE'
          EXPORTING
            title_text        = v_msg
          TABLES
            fields            = it_fields
            valuetab          = it_valtab
          EXCEPTIONS
            field_not_in_ddic = 1
            OTHERS            = 2.
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.

      SELECT SUM( menge )
        FROM ekkn
        INTO v_sumqty
        WHERE vbeln = v_so
        AND   vbelp = v_so_line
        AND   ( ebeln NE v_ebeln
        AND   ebelp NE v_ebelp ).

      IF v_qty IS NOT INITIAL.
        v_qty = v_qty + v_sumqty.
        IF v_qty GT v_sow_qty.
          v_difqty = v_qty - v_sow_qty.
          CLEAR v_msg.
          CONCATENATE 'Quantity exceeds total contract qty by' v_difqty INTO v_msg SEPARATED BY space.
          MESSAGE v_msg TYPE 'E'.
        ENDIF.
        "till here
      ENDIF.

    ENDIF.

    EXPORT v_so FROM v_so TO MEMORY ID 'VSO'.

  ENDIF.
ENDMETHOD.
