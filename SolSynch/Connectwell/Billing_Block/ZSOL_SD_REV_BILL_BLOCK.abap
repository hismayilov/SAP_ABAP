*&---------------------------------------------------------------------*
*& Report  ZSOL_SD_REV_BILL_BLOCK
*&
*&---------------------------------------------------------------------*
*& Author: SaurabhK
*& Date/Time: May 2017
*& Description: Reverse bill block after 48 hours of manual release if billing not done
*&---------------------------------------------------------------------*

REPORT zsol_sd_rev_bill_block.

* ---- Data Declaration ---- *

* ---- Tables ---- *
TABLES: zsol_billblock, vbup.

* ---- Types ---- *
TYPES: BEGIN OF ty_log,
         log(256) TYPE c,
       END OF ty_log.

* ---- Internal Tables ---- *
DATA: it_data   TYPE TABLE OF zsol_billblock,
      wa_data   TYPE zsol_billblock,

      it_final  TYPE TABLE OF zsol_billblock,
      wa_final  TYPE zsol_billblock,

      it_bill   TYPE TABLE OF wb2_v_vbak_vbap2,
      wa_bill   TYPE wb2_v_vbak_vbap2,

      wa_update TYPE zsol_billblock,

      it_vbup   TYPE TABLE OF vbup,
      wa_vbup   TYPE vbup,

      it_log    TYPE TABLE OF ty_log,
      wa_log    TYPE ty_log.

* ---- BAPI Related ---- *
DATA: order_headerx TYPE bapisdh1x,
      return        TYPE TABLE OF bapiret2   WITH HEADER LINE,
      order_item    TYPE TABLE OF bapisditm  WITH HEADER LINE,
      order_itemx   TYPE TABLE OF bapisditmx WITH HEADER LINE.

* ---- Local Variables ---- *
DATA: msg   TYPE string,
      diff  TYPE sytabix,
      v_seq TYPE zsol_billblock-sqnce,
      vkorg TYPE vkorg,
      vtweg TYPE vtweg,
      kunnr TYPE kunnr,
      audat TYPE audat,
      cdate TYPE p0001-begda.

RANGES: s_datum FOR sy-datum.

* ---- Selection Screen ---- *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_vkorg FOR vkorg,
                s_vtweg FOR vtweg,
                s_kunnr FOR kunnr,
                s_audat FOR audat.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(2) text-002.
SELECTION-SCREEN END OF LINE.

PARAMETERS: p_sydat TYPE sy-datum.
SELECTION-SCREEN END OF BLOCK b1.

* ---- Initialisation ---- *
AT SELECTION-SCREEN ON p_sydat.
* ---- Calculate date range as date entered minus 1 year ---- *
  IF p_sydat IS NOT INITIAL.
    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = p_sydat       " Eg. 22.05.2017
        days      = 0
        months    = 0
        signum    = '-'
        years     = 1
      IMPORTING
        calc_date = cdate.        " Eg. 22.05.2016

    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = cdate
        days      = 1
        months    = 0
        signum    = '+'
        years     = 0
      IMPORTING
        calc_date = cdate.        " Eg. 23.05.2016

    IF cdate IS NOT INITIAL.
      REFRESH s_datum[].
      s_datum-low    = cdate.
      s_datum-high   = p_sydat.
      s_datum-sign   = 'I'.
      s_datum-option = 'BT'.
      APPEND s_datum.
    ENDIF.

    " Date range eg: 23.05.2016 - 22.05.2017
  ENDIF.

* ---- Begin Main Program ---- *
START-OF-SELECTION.

  PERFORM validation.
  PERFORM get_data.

END-OF-SELECTION.

  IF it_data[] IS NOT INITIAL.
    PERFORM process_data.
    PERFORM display_log.
  ELSE.
    MESSAGE 'No data found.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  IF s_audat IS NOT INITIAL.
    SELECT *
      FROM wb2_v_vbak_vbap2
      INTO TABLE it_bill
      WHERE vkorg IN s_vkorg
      AND   vtweg IN s_vtweg
      AND   kunnr IN s_kunnr
      AND   audat IN s_audat.
  ELSEIF s_datum IS NOT INITIAL.
    SELECT *
      FROM wb2_v_vbak_vbap2
      INTO TABLE it_bill
      WHERE vkorg IN s_vkorg
      AND   vtweg IN s_vtweg
      AND   kunnr IN s_kunnr
    AND   audat IN s_datum.
  ELSE.
    SELECT *
      FROM wb2_v_vbak_vbap2
      INTO TABLE it_bill
      WHERE vkorg IN s_vkorg
      AND   vtweg IN s_vtweg
    AND   kunnr IN s_kunnr.
  ENDIF.

  SELECT DISTINCT *
    FROM zsol_billblock
    INTO TABLE it_data
    WHERE sqnce IN ( SELECT MAX( sqnce )
                       FROM zsol_billblock
                       GROUP BY vbeln posnr ).

  LOOP AT it_data INTO wa_data.
    READ TABLE it_bill INTO wa_bill WITH KEY vbeln_i = wa_data-vbeln
                                             posnr_i = wa_data-posnr.
    IF sy-subrc <> 0.
      DELETE it_data WHERE vbeln = wa_data-vbeln
                     AND   posnr = wa_data-posnr.
    ENDIF.
    CLEAR: wa_data, wa_bill.
  ENDLOOP.

  IF it_data[] IS NOT INITIAL.
    SELECT *
      FROM vbup
      INTO TABLE it_vbup
      FOR ALL ENTRIES IN it_data
      WHERE vbeln = it_data-vbeln
    AND   posnr = it_data-posnr.
  ENDIF.
ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data .
  DELETE it_data[] WHERE faksp EQ 'ZC'.

  IF it_data[] IS NOT INITIAL.
    it_final[] = it_data[].

    SORT it_final BY vbeln posnr.

    DELETE ADJACENT DUPLICATES FROM it_final COMPARING vbeln.

    LOOP AT it_final INTO wa_final.
      CLEAR: order_headerx, wa_log.
      REFRESH : order_item[] , order_itemx[], return[].

      LOOP AT it_data INTO wa_data WHERE vbeln = wa_final-vbeln.
        IF  wa_data-faksp IS INITIAL.
          READ TABLE it_vbup INTO wa_vbup WITH KEY vbeln = wa_data-vbeln
                                                   posnr = wa_data-posnr.
          IF sy-subrc = 0 AND wa_vbup-fksta NE 'C'.
            CLEAR diff.
            CALL FUNCTION 'SWI_DURATION_DETERMINE'
              EXPORTING
                start_date = wa_data-reldat
                end_date   = sy-datum
                start_time = wa_data-reltim
                end_time   = sy-uzeit
              IMPORTING
                duration   = diff.

            IF sy-subrc = 0 AND ( diff / 3600 ) GT 48.
              " Apply Bill Block
              order_headerx-updateflag = 'U'.

              order_item-itm_number = wa_data-posnr.
              order_item-bill_block = 'ZC'.
              APPEND order_item.

              order_itemx-itm_number = wa_data-posnr.
              order_itemx-updateflag = 'U'.
              order_itemx-bill_block = 'X'.
              APPEND order_itemx.
            ELSEIF ( diff / 3600 ) LT 48.
              CLEAR msg.
              CONCATENATE wa_data-vbeln wa_data-posnr ': Billing block still inactive(less than 48 hours elapsed).'
              INTO msg SEPARATED BY space.
              MOVE msg TO wa_log-log.
              PERFORM collect_log.
            ENDIF.
          ELSEIF wa_vbup-fksta EQ 'C'.
            CLEAR msg.
            CONCATENATE wa_data-vbeln wa_data-posnr ': Billing completely processed.' INTO msg SEPARATED BY space.
            MOVE msg TO wa_log-log.
            PERFORM collect_log.
          ENDIF.
        ENDIF.
        CLEAR: order_item, order_itemx, wa_data, wa_vbup, diff.
      ENDLOOP.

      IF order_item[] IS NOT INITIAL.
        CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
          EXPORTING
            salesdocument    = wa_final-vbeln
            order_header_inx = order_headerx
          TABLES
            return           = return
            order_item_in    = order_item
            order_item_inx   = order_itemx.

        READ TABLE return WITH KEY type = 'E'.
        IF sy-subrc <> 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          IF sy-subrc = 0.
            LOOP AT order_item.
              CLEAR msg.
              CONCATENATE wa_final-vbeln  order_item-itm_number ': Billing block re-applied(after 48 hours).' INTO msg
              SEPARATED BY space.
              MOVE msg TO wa_log-log.
              PERFORM collect_log.
              CLEAR order_item.
            ENDLOOP.
          ENDIF.
        ELSE.
          LOOP AT order_item.
            CLEAR msg.
            CONCATENATE wa_final-vbeln  order_item-itm_number ':' return-message INTO msg SEPARATED BY space.
            MOVE msg TO wa_log-log.
            PERFORM collect_log.
            CLEAR order_item.
          ENDLOOP.
        ENDIF.
      ENDIF.

      DELETE it_final WHERE vbeln = wa_final-vbeln.
      CLEAR: wa_final, wa_log.
    ENDLOOP.
  ELSE.
    MESSAGE 'No line items found for blocking.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validation .
  IF s_audat IS NOT INITIAL AND p_sydat IS NOT INITIAL.
    MESSAGE 'Please enter either Document Date or System Date. Not both.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.                    " VALIDATION
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_log .
  IF it_log[] IS NOT INITIAL.
    LOOP AT it_log INTO wa_log.
      WRITE:/ wa_log-log.
      CLEAR: wa_log.
    ENDLOOP.
    REFRESH: it_log[].
  ENDIF.
ENDFORM.                    " DISPLAY_LOG
*&---------------------------------------------------------------------*
*&      Form  COLLECT_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_log .
  APPEND wa_log TO it_log.
ENDFORM.                    " COLLECT_LOG
