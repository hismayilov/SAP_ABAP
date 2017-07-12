*&---------------------------------------------------------------------*
*&      Module  VALIDATE_INDIA_GST_FIELDS  INPUT
*&---------------------------------------------------------------------*
*       Module created by Note 2376723
*----------------------------------------------------------------------*
MODULE VALIDATE_INDIA_GST_FIELDS INPUT.

  DATA: lv_status       TYPE flag,
        wa_table1       TYPE cxtab_column,
        lv_hsn_sac      TYPE acgl_item-hsn_sac.
  CLEAR: wa_table1, lv_hsn_sac.

  LOOP AT table-cols INTO wa_table1.

    IF  wa_table1-screen-name = 'ACGL_ITEM-HSN_SAC'.
* Passing bkpf for country code check, & acgl_item if require any validations.
      CALL FUNCTION 'J_1IG_VALIDATE_INPUT'
        EXPORTING
          IM_BKPF = BKPF
        IMPORTING
          FIELD_VIS_STATUS  = LV_STATUS.

        IF lv_status EQ 'X' AND bkpf-glvor NE 'RMRP'. "Hide field for PO g/l tab, as it's in PO ref tab
          wa_table1-invisible =  ''.

          IF acgl_item-bschl IS NOT INITIAL AND acgl_item-koart IS NOT INITIAL.
            CALL FUNCTION 'J_1IG_CHECK_ITEM'
              EXPORTING
                IM_ACGL_ITEM         = ACGL_ITEM
              IMPORTING
                EX_HSN_SAC           = lv_hsn_sac.

            IF acgl_item-hsn_sac IS INITIAL.
               acgl_item-hsn_sac = lv_hsn_sac. "Posting
               bseg-hsn_sac      = lv_hsn_sac. "Screen population
            ENDIF.
          ENDIF.

        ELSE.
          wa_table1-invisible =  'X'.
        ENDIF.
*{   INSERT         IRDK927968                                        1
* ---- Make HSN/SAC code mandatory ---- *
        DATA: account      TYPE invfo-accnt,
              accountgrp(4)  TYPE c.
        FIELD-SYMBOLS: <account>   TYPE invfo-accnt.

        CLEAR: account, accountgrp.

        UNASSIGN: <account>.
        IF sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65'.
          ASSIGN ('(SAPLJ_1IG_VENDOR_SUBSCR)INVFO-ACCNT') TO <account> .
*        ELSEIF sy-tcode EQ 'FB70' OR sy-tcode EQ 'FB75'.
*          ASSIGN ('(SAPLJ_1IG_CUSTOMER_SUBSCR)INVFO-ACCNT') TO <account> .
        ENDIF.

        IF <account> IS ASSIGNED.
          account = <account>.

          IF sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65'.
            SELECT SINGLE ktokk
              FROM lfa1
              INTO accountgrp
              WHERE lifnr EQ account.
*          ELSEIF sy-tcode EQ 'FB70' OR sy-tcode EQ 'FB75'.
*            SELECT SINGLE ktokd
*              FROM kna1
*              INTO accountgrp
*              WHERE lifnr EQ account.
          ENDIF.
          IF bkpf-budat GT '20170630' AND accountgrp NE 'EMPL'.
            IF sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65' OR sy-tcode EQ 'FB70' OR sy-tcode EQ 'FB75'.
              IF sy-ucomm EQ 'BS' OR sy-ucomm EQ 'BU' OR sy-ucomm EQ 'BP'.
                IF acgl_item-hkont IS NOT INITIAL AND acgl_item-bschl IS NOT INITIAL AND acgl_item-koart IS NOT INITIAL.
                  IF acgl_item-hsn_sac IS INITIAL.
                    MESSAGE 'HSN/SAC code is mandatory' TYPE 'E'.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
*}   INSERT

        MODIFY table-cols FROM wa_table1.
    ENDIF.
  ENDLOOP.
  CLEAR lv_status.

ENDMODULE.
