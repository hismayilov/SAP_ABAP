class ZCL_IM_MB_DOCUMENT_BADI definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_DOCUMENT_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_MB_DOCUMENT_BADI IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM_MB_DOCUMENT_BADI->IF_EX_MB_DOCUMENT_BADI~MB_DOCUMENT_BEFORE_UPDATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] XMKPF                          TYPE        TY_T_MKPF
* | [--->] XMSEG                          TYPE        TY_T_MSEG
* | [--->] XVM07M                         TYPE        TY_T_VM07M
* | [--->] XDM07M                         TYPE        TY_T_DM07M(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_document_badi~mb_document_before_update.
********** For Migo Qlty Criteria Tab **********
  DATA : it_temp      TYPE TABLE OF ztb_migo_temp, " temp qlty ztab
         wa_temp      TYPE ztb_migo_temp,
         wa_data      TYPE mseg,                   " wa_xmseg
         wa_qlty      TYPE zqlty_data,             " row to be appended/inserted to migo qlty ztab
         wa_can_qlty  TYPE zqlty_data,
         it_can_qlty  TYPE TABLE OF zqlty_data,  " data for item/s being cancelled from migo qlty ztab
         it_mara      TYPE TABLE OF mara,
         wa_mara      TYPE mara,
         it_migo      TYPE TABLE OF zmigo_qlty,
         wa_migo      TYPE zmigo_qlty,
         ebeln        TYPE goitem-ebeln, " po number
         mblnr        TYPE goitem-mblnr, " doc being cancelled
         mode         TYPE goaction.      " mode -> gr, disp, cancel etc

  DATA : str(10) TYPE c,
         wgt(10) TYPE c,
         sum(10) TYPE c,
         wum(10) TYPE c.

  DATA : strflg(1) TYPE c,
         wgtflg(1) TYPE c,
         strok(1)  TYPE c,
         wgtok(1)  TYPE c.

*** imported from z_mb_migo_badi methods ***
  IMPORT cs_goitem-ebeln TO ebeln FROM MEMORY ID 'EBELN'.
  IMPORT cs_goitem-mblnr TO mblnr FROM MEMORY ID 'MBLNR'. " mat doc no of doc being cancelled
  IMPORT i_action TO mode FROM MEMORY ID 'MODE'.

  IF sy-tcode = 'MIGO'.
    IF mode = 'A01'.  " GR
      IF ebeln IS NOT INITIAL.
        SELECT *
          FROM ztb_migo_temp
          INTO TABLE it_temp
          WHERE ebeln = ebeln
          AND itemok IS NOT NULL. " only consider items adopted in current doc
      ENDIF.
*** ztemp tab will have data only if qlty is maintained for atleast one line item ***
*** migo data will be inserted in ztab (zqlty_data) only in that case ***
      IF sy-subrc = 0.
        LOOP AT xmseg INTO wa_data.
          MOVE-CORRESPONDING wa_data TO wa_qlty.

          READ TABLE it_temp INTO wa_temp
            WITH KEY lineid = wa_data-line_id  " xmseg = only adopted line items, get only those items from temp
                     matnr = wa_data-matnr.
          IF sy-subrc = 0.
            str    = wa_temp-stren.
            wgt    = wa_temp-weight.
            sum    = wa_temp-stum.
            wum    = wa_temp-wum.
            " to check qlty status for current item
            strflg = wa_temp-strflg.
            wgtflg = wa_temp-wgtflg.
            strok  = wa_temp-strok.
            wgtok  = wa_temp-wgtok.

********Insert quality param for current row only if either one qual param is not blank and correct*********
            IF ( strflg IS NOT INITIAL AND strok IS NOT INITIAL ) OR ( wgtflg IS NOT INITIAL AND wgtok IS NOT INITIAL ).
              wa_qlty-stren   = str.
              wa_qlty-stum    = sum.
              wa_qlty-weight  = wgt.
              wa_qlty-wum     = wum.
            ENDIF.

            INSERT INTO zqlty_data VALUES wa_qlty.  " outside temp loop, but within xmseg loop,
            " to insert all rows of the current qlty eligible migo in ztab
          ENDIF.
          CLEAR : wa_qlty,str,wgt,sum,wum.
        ENDLOOP.  " Endloop xmseg
      ELSE.
* ---- Add migo lines to ztable ieven if now qlty data is maintained but material is qlty eligible ---- *
        SELECT *
          FROM mara
          INTO TABLE it_mara
          FOR ALL ENTRIES IN xmseg
          WHERE matnr EQ xmseg-matnr
          AND   mtart EQ 'VERP'.

        IF sy-subrc = 0.
          SELECT *
            FROM zmigo_qlty
            INTO TABLE it_migo
            FOR ALL ENTRIES IN it_mara
            WHERE matnr = it_mara-matnr.
        ENDIF.
        LOOP AT xmseg INTO wa_data.
          READ TABLE it_migo INTO wa_migo WITH KEY matnr = wa_data-matnr.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING wa_data TO wa_qlty.
            INSERT INTO zqlty_data VALUES wa_qlty.
          ENDIF.
          CLEAR: wa_data, wa_migo, wa_qlty.
        ENDLOOP.
      ENDIF.
    ENDIF.
*****  For cancellation - del relevant rows from ztab *****
***** Insert cancelled migo with cancelled line items in migo qlty ztab ****
    IF mode = 'A03'.  " Cancellation
***** get data for migo being cancelled from migo qlty ztab
      SELECT *
        FROM zqlty_data
        INTO CORRESPONDING FIELDS OF TABLE it_can_qlty
        FOR ALL ENTRIES IN xmseg
        WHERE mblnr = xmseg-smbln
        AND ebeln = xmseg-ebeln.

      IF sy-subrc = 0.  " check if such a migo exists in zqlty tab = qlty eligible migo persisted before
        LOOP AT xmseg INTO wa_data. " xmseg will have only rows being cancelled

          READ TABLE it_can_qlty INTO wa_can_qlty  " append qlty data from zqlty only for those rows
            WITH KEY line_id = wa_data-line_id
                     matnr = wa_data-matnr.
          IF sy-subrc = 0. " insert/delete only those rows as new  mblnr/from old mblnr in zqlty tab
            MOVE-CORRESPONDING wa_data TO wa_qlty.
            wa_qlty-stren   = wa_can_qlty-stren.
            wa_qlty-stum    = wa_can_qlty-stum.
            wa_qlty-weight  = wa_can_qlty-weight.
            wa_qlty-wum     = wa_can_qlty-wum.

            INSERT INTO zqlty_data VALUES wa_qlty.  " new mblnr/being created
            DELETE FROM zqlty_data WHERE mblnr = mblnr AND line_id = wa_data-line_id. " old mblnr/being cancelled
          ENDIF.
          CLEAR : wa_qlty,wa_can_qlty.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

********** End for Migo Qlty Criteria Tab **********
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM_MB_DOCUMENT_BADI->IF_EX_MB_DOCUMENT_BADI~MB_DOCUMENT_UPDATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] XMKPF                          TYPE        TY_T_MKPF
* | [--->] XMSEG                          TYPE        TY_T_MSEG
* | [--->] XVM07M                         TYPE        TY_T_VM07M
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_DOCUMENT_BADI~MB_DOCUMENT_UPDATE.
endmethod.
ENDCLASS.
