class ZCL_IM__MB_MIGO_BADI definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_MIGO_BADI .
protected section.
private section.

  data GV_INIT type C .
  data GV_EBELN type GOITEM-EBELN .
  data GV_MODE type GOACTION .
  data GT_ITEMS type ZTY_GT_ITEMS .
ENDCLASS.



CLASS ZCL_IM__MB_MIGO_BADI IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~CHECK_HEADER
* +-------------------------------------------------------------------------------------------------+
* | [<-->] ET_BAPIRET2                    TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~CHECK_HEADER.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~CHECK_ITEM
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_LINE_ID                      TYPE        MB_LINE_ID
* | [<-->] ET_BAPIRET2                    TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~check_item.

* ---- Changed by SaurabhK on 15.02.2017 for tolerance change ---- *
*************For Quality Criteria tab***************
  DATA: str(10) TYPE c,
        wgt(10) TYPE c,
        sum(10) TYPE c,
        wum(10) TYPE c.

  DATA: str_val   TYPE zmigo_qlty-stren,    "BRGEW,
        str_tol   TYPE zmigo_qlty-stren,    "BRGEW,
        wgt_val   TYPE zmigo_qlty-weight,   "BRGEW,
        wgt_tol   TYPE zmigo_qlty-weight.   "BRGEW,

  DATA : wa_qlty  TYPE zmigo_qlty,               " maintained qlty param for current mat
         wa_temp  TYPE ztb_migo_temp,            " data for current line from temp ztab
         wa_items LIKE LINE OF gt_items,
         ls_bapiret TYPE bapiret2.              " error messages

  DATA : strflg(1) TYPE c,  " flag for stren input ok
         wgtflg(1) TYPE c,  " flag for wgt input ok
         strok(1)  TYPE c,  " flag for stren check ok
         wgtok(1)  TYPE c.  " flag for wgt check ok

  IF gv_mode = 'A01'. " Goods Receipt
***** get current line item data from temp qlty criteria tab *****
    SELECT SINGLE *
        FROM ztb_migo_temp
        INTO CORRESPONDING FIELDS OF wa_temp
        WHERE lineid = i_line_id
              AND ebeln = gv_ebeln. " ebeln considered for concurrency

    IF sy-subrc = 0.

      CLEAR : strflg, wgtflg, strok, wgtok.
***** get qlty param maintained for current mat *****
      SELECT SINGLE *
            FROM zmigo_qlty
            INTO CORRESPONDING FIELDS OF wa_qlty
            WHERE matnr EQ wa_temp-matnr.

      IF sy-subrc = 0.  " Check if quality parameters maintained for material

        str = wa_temp-stren.
        wgt = wa_temp-weight.
        sum = wa_temp-stum.
        wum = wa_temp-wum.

        SHIFT str LEFT DELETING LEADING space.
        SHIFT wgt LEFT DELETING LEADING space.

        IF str = '0.000'. " display blank instead of 0.000
          CLEAR str.
        ENDIF.

        IF wgt = '0.000'. " display blank instead of 0.000
          CLEAR wgt.
        ENDIF.

*******************STRENGTH TOLERANCE CALC**********************
        IF ( str IS NOT INITIAL AND sum IS NOT INITIAL ).
          str_val = ( wa_qlty-stren * 5 ) / 100 .
          str_tol = wa_qlty-stren - str_val.
          strflg = 'X'. " strnth parameters input ok
        ELSEIF ( str IS NOT INITIAL AND sum IS INITIAL ) OR ( str IS INITIAL AND sum IS NOT INITIAL ).
          CLEAR strflg.
***** Append error message for display in pop-up along with other messages *****
          ls_bapiret-type = 'E'. " type error
          ls_bapiret-id = 'ZMIGO_QLTY'. " message class maintained for qlty criteria checks
          ls_bapiret-number = '000'.  " message number
          ls_bapiret-message_v1 = i_line_id.  " line id of line in which error occurs
          APPEND ls_bapiret TO et_bapiret2.
        ENDIF.

*******************WEIGHT TOLERANCE CALC************************
        IF ( wgt IS NOT INITIAL AND wum IS NOT INITIAL ).
          wgt_val = ( wa_qlty-weight * 5 ) / 100 .
          wgt_tol = wa_qlty-weight - wgt_val.
          wgtflg = 'X'. " weight parameters input ok
        ELSEIF ( wgt IS NOT INITIAL AND wum IS INITIAL ) OR ( wgt IS INITIAL AND wum IS NOT INITIAL ).
          CLEAR wgtflg.

          ls_bapiret-type = 'E'.
          ls_bapiret-id = 'ZMIGO_QLTY'.
          ls_bapiret-number = '001'.
          ls_bapiret-message_v1 = i_line_id.
          APPEND ls_bapiret TO et_bapiret2.
        ENDIF.

*******************STRENGTH TOLERANCE CHECK**********************
        IF ( strflg IS NOT INITIAL ). " check str input ok
          IF ( ( str LT str_tol ) OR ( sum NE wa_qlty-stum ) ).
            CLEAR strok.

            ls_bapiret-type = 'E'.
            ls_bapiret-id = 'ZMIGO_QLTY'.
            ls_bapiret-number = '002'.
            ls_bapiret-message_v1 = i_line_id.
            APPEND ls_bapiret TO et_bapiret2.
          ELSE.
            strok = 'X'.  " strnth check success
          ENDIF.
        ENDIF.

*******************WEIGHT TOLERANCE CHECK**********************
        IF ( wgtflg IS NOT INITIAL ). " check wgt input ok
          IF ( ( wgt LT wgt_tol ) OR ( wum NE wa_qlty-wum ) ).
            CLEAR wgtok.

            ls_bapiret-type = 'E'.
            ls_bapiret-id = 'ZMIGO_QLTY'.
            ls_bapiret-number = '003'.
            ls_bapiret-message_v1 = i_line_id.
            APPEND ls_bapiret TO et_bapiret2.
          ELSE.
            wgtok = 'X'.  " weight check success
          ENDIF.
        ENDIF.

        wa_temp-strflg = strflg.
        wa_temp-wgtflg = wgtflg.
        wa_temp-strok  = strok.
        wa_temp-wgtok  = wgtok.

        UPDATE ztb_migo_temp FROM wa_temp.  " update flags in temp. qlty tab for current line

      ENDIF.

    ENDIF.
  ENDIF.

* ---- To check if Qlty parameters are maintained for adopted items ---- *
  CLEAR: wa_temp, wa_qlty.

  IF gv_mode EQ 'A01'.
    READ TABLE gt_items INTO wa_items WITH KEY line_id = i_line_id.
    IF sy-subrc = 0.
      SELECT SINGLE *
              FROM zmigo_qlty
              INTO CORRESPONDING FIELDS OF wa_qlty
              WHERE matnr EQ wa_items-matnr.

      IF sy-subrc = 0.
        SELECT SINGLE *
          FROM ztb_migo_temp
          INTO wa_temp
          WHERE ebeln  = gv_ebeln
          AND   lineid = i_line_id
          AND   ( strflg NE ''
          AND   wgtflg NE '' ).

* ---- Display error if item is adopted and qlty parameters are not maintained ---- *
        IF sy-subrc <> 0.
* ---- In almost all erraneous cases, sy-subrc will not be equal to 0 here as lines with blank qlty... ---- *
* ---- ...parameters are either not inserted into temp table or deleted if initially inserted when not blank ---- *
          ls_bapiret-type = 'E'.
          ls_bapiret-id = 'ZMIGO_QLTY'.
          ls_bapiret-number = '004'.
          ls_bapiret-message_v1 = i_line_id.
          APPEND ls_bapiret TO et_bapiret2.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.
************End For Quality Criteria tab***************

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~HOLD_DATA_DELETE
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_GUID                         TYPE        GUID_22
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~HOLD_DATA_DELETE.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~HOLD_DATA_LOAD
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_GUID                         TYPE        GUID_22
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~HOLD_DATA_LOAD.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~HOLD_DATA_SAVE
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_GUID                         TYPE        GUID_22
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~HOLD_DATA_SAVE.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~INIT
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_INIT                        TYPE        MIGO_BADI_REGISTRATION_TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~init.
*************For Quality Criteria tab***************
  DATA :gf_class_id TYPE migo_class_id VALUE 'MIGO_BADI'. " Class ID for Qlty criteria screen
  APPEND gf_class_id TO ct_init.
************End For Quality Criteria tab***************
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~LINE_DELETE
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_LINE_ID                      TYPE        MB_LINE_ID
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~line_delete.
*************For Quality Criteria tab***************
  DATA : delflg(1) TYPE c.

***** on line delete *****
  IF gv_ebeln IS NOT INITIAL.
    DELETE FROM ztb_migo_temp WHERE lineid = i_line_id AND ebeln = gv_ebeln.  " ebeln considered for concurrency
    delflg = 'X'. " set and export del flag to avoid re-insertion of that line in screen PBO once deleted here
  ENDIF.

  EXPORT delflg FROM delflg TO MEMORY ID 'DEL'.
*************End for Quality Criteria tab***************
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~LINE_MODIFY
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_LINE_ID                      TYPE        MB_LINE_ID
* | [<-->] CS_GOITEM                      TYPE        GOITEM
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~line_modify.

  DATA: wa_vbap TYPE vbap,
        wa_mast TYPE mast,
        wa_stpo TYPE stpo,
        it_mseg TYPE STANDARD TABLE OF mseg,
        wa_mseg TYPE mseg.
*        wa_cs_goitem TYPE cs_goitem.

  DATA: rm_quan TYPE vbap-kwmeng,
        exc_by  TYPE string.

  DATA : str0 TYPE string,
         str1 TYPE string.

  IF cs_goitem-mat_kdauf IS NOT INITIAL AND cs_goitem-bwart EQ '501'.

    SELECT *
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE it_mseg
      WHERE matnr EQ cs_goitem-matnr
      AND   mat_kdauf EQ cs_goitem-mat_kdauf
      AND   werks EQ cs_goitem-werks.

    SELECT SINGLE *
      FROM vbap
      INTO CORRESPONDING FIELDS OF wa_vbap
      WHERE vbeln = cs_goitem-mat_kdauf.

    SELECT SINGLE *
      FROM mast
      INTO CORRESPONDING FIELDS OF wa_mast
      WHERE matnr = wa_vbap-matnr.

    SELECT SINGLE *
      FROM stpo
      INTO CORRESPONDING FIELDS OF wa_stpo
      WHERE stlnr = wa_mast-stlnr
      AND   idnrk = cs_goitem-matnr.

    rm_quan = wa_vbap-kwmeng * wa_stpo-menge.

    SORT it_mseg ASCENDING BY shkzg.

    LOOP AT it_mseg INTO wa_mseg.
      IF wa_mseg-bwart = '501' OR wa_mseg-bwart = '502'.
        IF wa_mseg-shkzg = 'S'.
          rm_quan = rm_quan - wa_mseg-erfmg.
        ELSEIF wa_mseg-shkzg = 'H'.
          rm_quan = rm_quan + wa_mseg-erfmg.
        ENDIF.
        CLEAR wa_mseg-erfmg.
      ENDIF.
    ENDLOOP.

    exc_by = cs_goitem-menge - rm_quan.

    IF cs_goitem-menge > rm_quan.
      IF sy-ucomm = 'OK_GO'.
        CONCATENATE  'Sales order quantity is larger than BOM quan -' cs_goitem-matnr ' by :' exc_by INTO str1.
        MESSAGE str1 TYPE 'I'.
      ENDIF.

      IF sy-ucomm = 'OK_CHECK' OR sy-ucomm =  'OK_POST1' OR sy-ucomm =  'OK_POST'.
        CONCATENATE  'Sales order quantity is larger than BOM quan - ' cs_goitem-matnr INTO str0.
        MESSAGE  str0 TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

*************For Quality Criteria tab***************
  "Added by Prasad, SauarbhK on 04.10.2016

  DATA : wa_items TYPE zst_gt_items,
         mod(1) TYPE c. " gt_item modify indicator

  CLEAR mod.
  gv_ebeln = cs_goitem-ebeln. " set global po number

****** Create gt_items global table for line items *******
  IF i_line_id IS NOT INITIAL.
****** update gt_items from cs_goitem if line already exists ******
    LOOP AT me->gt_items INTO wa_items WHERE line_id = i_line_id.
      wa_items-line_id = i_line_id.
      MOVE-CORRESPONDING cs_goitem TO wa_items.
      MODIFY me->gt_items FROM wa_items.
      mod = 'X'.
    ENDLOOP.
****** append cs_gotitem to gt_items if line does not exist, ******
****** usually only executed when doc is first loaded ******
    IF sy-subrc <> 0 AND mod IS INITIAL.
      wa_items-line_id = i_line_id.
      MOVE-CORRESPONDING cs_goitem TO wa_items.
      APPEND wa_items TO me->gt_items.
    ENDIF.
  ENDIF.
****** End of gt_items creation ******

******* Export parameters for use in PBO of custom screen and other BADI methods *******
  EXPORT i_line_id FROM i_line_id TO MEMORY ID 'LID'.
  EXPORT cs_goitem-ebeln FROM cs_goitem-ebeln TO MEMORY ID 'EBELN'.
  EXPORT cs_goitem-matnr FROM cs_goitem-matnr TO MEMORY ID 'MATNR'.
  EXPORT cs_goitem-take_it FROM cs_goitem-take_it TO MEMORY ID 'ITEMOK'.
  EXPORT cs_goitem-mblnr FROM cs_goitem-mblnr TO MEMORY ID 'MBLNR'.

*************End For Quality Criteria tab***************
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~MODE_SET
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ACTION                       TYPE        GOACTION
* | [--->] I_REFDOC                       TYPE        REFDOC
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~mode_set.
*************For Quality Criteria tab***************
  gv_mode = i_action. " for use in BADI PBO and post methods

  EXPORT i_action FROM i_action TO MEMORY ID 'MODE'.

******  Clear Ztab if user reinitiates migo ******
  IF i_action = 'A01' AND gv_ebeln IS NOT INITIAL.
    DELETE FROM ztb_migo_temp WHERE lineid IS NOT NULL AND ebeln = gv_ebeln. " ebeln considered for concurrency
  ENDIF.
******  Does not execute on first init as the sequence is ->
******  mode_set -> line_modify -> status_header
******  So, ebeln can only be processed in status_header
******  Hence, first ztab clear on init occurs in status_header
*************End for Quality Criteria tab***************
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~PAI_DETAIL
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_LINE_ID                      TYPE        MB_LINE_ID
* | [--->] I_OKCODE                       TYPE        SYUCOMM
* | [<-->] E_FORCE_CHANGE                 TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~pai_detail.
*************For Quality Criteria tab***************
  e_force_change = 'X'.
*************End For Quality Criteria tab***************
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~PAI_HEADER
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_OKCODE                       TYPE        SYUCOMM
* | [--->] IS_GOHEAD                      TYPE        GOHEAD
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~PAI_HEADER.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~PBO_DETAIL
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CLASS_ID                     TYPE        MIGO_CLASS_ID
* | [--->] I_LINE_ID                      TYPE        MB_LINE_ID
* | [<-->] E_CPROG                        TYPE        SYCPROG
* | [<-->] E_DYNNR                        TYPE        SYDYNNR
* | [<-->] E_HEADING                      TYPE        MIGO_BADI_HEADING
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~pbo_detail.

  " changed on 14/11/16 by SaurabhK - > mtpos_mara to mtart for check on mat. type

*************For Quality Criteria tab***************
  DATA : matnr TYPE goitem-matnr,     " material number
         mblnr TYPE goitem-mblnr,     " material doc
         zeile TYPE goitem-zeile,     " line id
         mtart TYPE mara-mtart,       " mat category
         wa_qlty TYPE zmigo_qlty,     " to check if qlty maintained for mat
         wa_disp TYPE zqlty_data,     " to check if mat persisted in migo qlty ztab
         wa_items LIKE LINE OF gt_items,
         valid(1) TYPE c.             " flag - check if qlty screen is valid for current mat

***** get matnr of line id to be displayed from gt_items *****
  IF i_line_id IS NOT INITIAL.
    READ TABLE gt_items INTO wa_items WITH KEY line_id = i_line_id.
    IF sy-subrc = 0.
      matnr = wa_items-matnr.
      mblnr = wa_items-mblnr.
      zeile = wa_items-zeile.
    ENDIF.
  ENDIF.

  IF matnr IS NOT INITIAL.
******To check material is packing material*******
    SELECT SINGLE mtart
      FROM mara
      INTO mtart
      WHERE matnr = matnr.
******To check if qlty criteria is maintained for the material******
    SELECT SINGLE *
      FROM zmigo_qlty
      INTO wa_qlty
      WHERE matnr = matnr.
  ENDIF.

**** Display Qlty Criteria tab only if mat. cat. is 'verp' and mat is maintained in qlty criteria table
  IF sy-subrc = 0 AND mtart = 'VERP' AND wa_qlty IS NOT INITIAL. " material category - packing (verp)
    valid = 'X'.  " used in Screen PBO to disable/enable custom screen
  ELSE.
    CLEAR valid.
  ENDIF.

  IF i_line_id IS NOT INITIAL.

    IF i_class_id EQ 'MIGO_BADI'. " appended in init method
      e_cprog = 'ZSAPLMIGO_SUBSCREEN'.  " used in disp of custom subscreen

      IF gv_mode = 'A01'.   " GOODS RECEIPT
        e_dynnr = '0900'.   " Input screen
      ELSEIF gv_mode = 'A04' OR gv_mode = 'A03'.  " DISPLAY MIGO DOCUMENT / CANCELLATION
***** Display qlty criteria tab only if mater/line id persisted in zqlty_data (qlty criter mat doc) *****
        SELECT SINGLE *
          FROM zqlty_data
          INTO wa_disp
          WHERE mblnr = mblnr
          AND matnr = matnr
          AND zeile = zeile.

        IF sy-subrc = 0.
          e_dynnr = '0901'. " Output screen
        ENDIF.
      ENDIF.

      e_heading = 'Quality Criteria'(010).  " used in disp of custom subscreen
******* line id, and zeile to which user is navigating, exported for use in PBO of screen *******
      EXPORT e_line_id FROM i_line_id TO MEMORY ID 'LNID'.
      EXPORT zeile FROM zeile TO MEMORY ID 'ZEILE'.
    ENDIF.
  ENDIF.

  EXPORT valid FROM valid TO MEMORY ID 'VALID'. " exported for use in screen PBO
*************End For Quality Criteria tab***************
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~PBO_HEADER
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CLASS_ID                     TYPE        MIGO_CLASS_ID
* | [<-->] E_CPROG                        TYPE        SYCPROG
* | [<-->] E_DYNNR                        TYPE        SYDYNNR
* | [<-->] E_HEADING                      TYPE        MIGO_BADI_HEADING
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~PBO_HEADER.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~POST_DOCUMENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_MSEG                        TYPE        TY_T_MSEG
* | [--->] IS_MKPF                        TYPE        MKPF
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~post_document.
ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~PROPOSE_SERIALNUMBERS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_GOITEM                      TYPE        GOITEM
* | [--->] IV_REFDOC                      TYPE        REFDOC
* | [--->] IV_ACTION                      TYPE        GOACTION
* | [<-->] CT_SERMSG                      TYPE        BAPIRETTAB
* | [<-->] CV_NO_CHECK                    TYPE        XFELD
* | [<-->] CT_SERNOS                      TYPE        RSEROB_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~PROPOSE_SERIALNUMBERS.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~PUBLISH_MATERIAL_ITEM
* +-------------------------------------------------------------------------------------------------+
* | [--->] LS_GOITEM                      TYPE        GOITEM
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~PUBLISH_MATERIAL_ITEM.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~RESET
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
method IF_EX_MB_MIGO_BADI~RESET.
endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_IM__MB_MIGO_BADI->IF_EX_MB_MIGO_BADI~STATUS_AND_HEADER
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_LINES_IN_MODEL               TYPE        SYTABIX
* | [--->] IS_GOHEAD                      TYPE        GOHEAD
* | [<-->] E_HOLD_DATA_DISABLE            TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD if_ex_mb_migo_badi~status_and_header.
*************For Quality Criteria tab***************
  " Executes on init and each time a line is modified
****** Clear ztab on first init ******
  IF gv_ebeln IS NOT INITIAL AND gv_init IS INITIAL.
    DELETE FROM ztb_migo_temp WHERE lineid IS NOT NULL AND ebeln = gv_ebeln.  " ebeln for concurrency
    gv_init = 'X'.  " prevents reinit of ztab after first init(Eg for line item change)
  ENDIF.
*************End for Quality Criteria tab***************
ENDMETHOD.
ENDCLASS.
