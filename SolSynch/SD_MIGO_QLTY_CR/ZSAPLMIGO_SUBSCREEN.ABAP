*&---------------------------------------------------------------------*
*& Module Pool       ZSAPLMIGO_SUBSCREEN
*&
*&---------------------------------------------------------------------*
*& Developed by : Prasad, SaurabhK on 04/10/2016 - 08/11/2016
*& Description: For quality criteria tab in migo
*&---------------------------------------------------------------------*

PROGRAM  zsaplmigo_subscreen.

DATA: str(10) TYPE c,
      wgt(10) TYPE c,
      sum(10) TYPE c,
      wum(10) TYPE c,
      note(100) TYPE c.

DATA : lineid TYPE mb_line_id,      " line id to which user is navigating
       lid TYPE mb_line_id,         " current line id
       delflg(1) TYPE c,            " del flag for current line
       matnr TYPE goitem-matnr,     " mat number
       ebeln TYPE goitem-ebeln,     " po number
       zeile TYPE goitem-zeile,     " item number
       itemok TYPE goitem-take_it,  " item adopted in current document
       valid(1) TYPE c.

DATA : wa_temp TYPE ztb_migo_temp,  " inserted or updated to temp tab
       wa_temp1 TYPE ztb_migo_temp. " to check if line exists in temp tab
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0900 INPUT.
************PAI - not reqd**********
ENDMODULE.                 " USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0900 OUTPUT.  " Goods Receipt Screen
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  IMPORT e_line_id TO lineid FROM MEMORY ID 'LNID'. " line id to which user is navigating, from BADI PBO
  IMPORT i_line_id TO lid FROM MEMORY ID 'LID'.     " current line id, from line_modify
  IMPORT cs_goitem-ebeln TO ebeln FROM MEMORY ID 'EBELN'. " po number
  IMPORT cs_goitem-matnr TO matnr FROM MEMORY ID 'MATNR'. " mat number
  IMPORT cs_goitem-take_it TO itemok FROM MEMORY ID 'ITEMOK'. " item adoption in doc status
  IMPORT delflg TO delflg FROM MEMORY ID 'DEL'. " del indicator for current line
  IMPORT valid TO valid FROM MEMORY ID 'VALID'. " indicates whether material is qlty eligible

*** Execution sequence -> Screen PAI -> line_modify -> BADI PBO -> Screen PBO ***
*** For post/check -> line_modify -> check -> line_modify -> check ->...-> post
*** Basic flow is insert or update current line and get and display data for line to which user is navigating ***

*** check if material is qlty eligible and enable/disbale screen accordingly.
  IF valid IS INITIAL.
    LOOP AT SCREEN.
      screen-input = 0.
      note = 'Note: Quality input not possible for this material.'.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE 'Quality input not possible for this material' TYPE 'S'.
  ELSE.
    LOOP AT SCREEN.
      screen-input = 1.
      note = 'Note: Please press enter after entering quality parameters'.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

***** Insert or Update in temp ztab for line items *****
  IF ( lid IS NOT INITIAL AND matnr IS NOT INITIAL AND ebeln IS NOT INITIAL ).
**** Check if atleast one qlty param. for current line is not empty ****
    IF ( str IS NOT INITIAL AND sum IS NOT INITIAL ) OR ( str IS NOT INITIAL AND sum IS INITIAL ) OR ( str IS INITIAL AND sum IS NOT INITIAL )
      OR ( wgt IS NOT INITIAL AND wum IS NOT INITIAL ) OR ( wgt IS NOT INITIAL AND wum IS INITIAL ) OR ( wgt IS INITIAL AND wum IS NOT INITIAL ).
      wa_temp-lineid  = lid.    " line id
      wa_temp-matnr   = matnr.  " mat number
      wa_temp-ebeln   = ebeln.  " po number
      wa_temp-stren   = str.    " strnth
      wa_temp-stum    = sum.    " strnth unit
      wa_temp-weight  = wgt.    " weight
      wa_temp-wum     = wum.    " wgt unit
      wa_temp-itemok  = itemok. " item adoption status

      SELECT SINGLE lineid
                    matnr
                    FROM ztb_migo_temp
                    INTO CORRESPONDING FIELDS OF wa_temp1
                    WHERE lineid = lid  " current line/ line from which user is navigating
                    AND matnr = matnr
                    AND ebeln = ebeln.  " ebeln considered for concurrency
**** update if current line exists in temp qlty tab ****
      IF sy-subrc EQ 0 AND  wa_temp1 IS NOT INITIAL.
        UPDATE ztb_migo_temp FROM wa_temp.
**** insert other wise, but donot re-insert if del flg is set
      ELSEIF delflg IS INITIAL.
        INSERT ztb_migo_temp FROM wa_temp.
      ENDIF.
    ELSE. " when user clears qlty criteria for current line
      SELECT SINGLE lineid
                    matnr
                    FROM ztb_migo_temp
                    INTO CORRESPONDING FIELDS OF wa_temp1
                    WHERE lineid = lid  " current line/ line from which user is navigating
                    AND matnr = matnr
                    AND ebeln = ebeln.  " ebeln considered for concurrency
      IF sy-subrc = 0 .
        DELETE FROM ztb_migo_temp WHERE lineid = lid AND matnr = matnr AND ebeln = ebeln.  " ebeln considered for concurrency
      ENDIF.
    ENDIF.  " end if for existence of atleast one qlty param for current line

  ENDIF.  " end parent if

**** Fetch and display qlty data from temp ztab when renavigating to the line item ****
  IF lineid IS NOT INITIAL.

    SELECT SINGLE * FROM ztb_migo_temp
      INTO CORRESPONDING FIELDS OF wa_temp
      WHERE lineid = lineid " line to which user is navigating
      AND ebeln = ebeln.  " ebeln considered for concurrency

    IF sy-subrc = 0 AND wa_temp IS NOT INITIAL.
      str = wa_temp-stren.
      wgt = wa_temp-weight.
      sum = wa_temp-stum.
      wum = wa_temp-wum.
    ELSE. " display blank
      CLEAR : str, wgt, sum, wum.
    ENDIF.
  ENDIF.

  SHIFT str LEFT DELETING LEADING space.
  SHIFT wgt LEFT DELETING LEADING space.

  IF str = '0.000'. " display blank instead of 0.000
    CLEAR str.
  ENDIF.

  IF wgt = '0.000'.
    CLEAR wgt.
  ENDIF.

  FREE MEMORY ID 'DEL'. " clear del indicator for consecutive lines
  CLEAR: delflg.

ENDMODULE.                 " STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0901  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0901 OUTPUT.  " Display/Cancellation Screen
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  DATA : wa_disp_data TYPE zqlty_data,  " data from persistence for qlty mat doc
         mblnr TYPE goitem-mblnr.

  IMPORT cs_goitem-mblnr TO mblnr FROM MEMORY ID 'MBLNR'. " mat doc number
  IMPORT zeile TO zeile FROM MEMORY ID 'ZEILE'. " item number of goto line, exported from BADI PBO

**** Fetch and display data for current line from persistence ****
  SELECT SINGLE * FROM zqlty_data
    INTO CORRESPONDING FIELDS OF wa_disp_data
    WHERE mblnr EQ mblnr
    AND   zeile EQ zeile. " item number, since lineid will not work for cancelled documents

  IF sy-subrc = 0 AND wa_disp_data IS NOT INITIAL.

    str = wa_disp_data-stren.
    wgt = wa_disp_data-weight.

    SHIFT str LEFT DELETING LEADING space.
    SHIFT wgt LEFT DELETING LEADING space.

    IF str = '0.000'. " display blank for 0.000
      CLEAR str.
    ENDIF.

    IF wgt = '0.000'.
      CLEAR wgt.
    ENDIF.

    sum = wa_disp_data-stum.
    wum = wa_disp_data-wum.
  ENDIF.

ENDMODULE.                 " STATUS_0901  OUTPUT
