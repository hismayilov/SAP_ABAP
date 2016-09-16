*&---------------------------------------------------------------------*
*& Report  ZTEST_SK04
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztest_sk04_sel_scr1.

TABLES: bsak, kna1, lfa1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS: s_bukrs FOR bsak-bukrs, " no INTERVALS no-EXTENSION
                s_gjahr FOR bsak-gjahr,
                s_budat FOR bsak-budat,
                s_kunnr  FOR kna1-kunnr MODIF ID int, " replace int with any 3 letter literal
                s_lifnr FOR lfa1-lifnr MODIF ID ant.  " replace ant with any 3 letter literal
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

PARAMETERS: rb_kunnr TYPE c RADIOBUTTON GROUP rb1 USER-COMMAND int1 DEFAULT 'X'.
PARAMETERS: rb_lifnr TYPE c RADIOBUTTON GROUP rb1 .

SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-group1 = 'INT'. " INT is name given to Customer input field, So for INT...
      IF rb_kunnr = 'X'.      " ...If customer radio button is selected
        screen-active = 1.    " activate INT/customer input field
      ELSEIF rb_lifnr = 'X'.  " If vendor radio button is selected
        screen-active = 0.    " de-activate INT/customer input field
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'ANT'. " ANT is name given to vendor input field, So for ANT...
      IF rb_lifnr = 'X'.      " ...If vendor radio button is selected
        screen-active = 1.    " activate ANT/vendor input field
      ELSEIF rb_kunnr = 'X'.  " If customer radio button is selected
        screen-active = 0.    " de-activate ANT/vendor input field
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  " ============================================

*    IF rb_kunnr = 'X'.
*      LOOP AT SCREEN.
*        IF screen-group1 = 'INT'.
*        screen-active = 1.
*        screen-invisible = 0.
*        MODIFY SCREEN.
*        ENDIF.
*        IF screen-group1 = 'ANT'.
*        screen-ACTIVE = 0.
*        screen-invisible = 1.
*        MODIFY SCREEN.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*
*    IF rb_LIFNR = 'X'.
*      LOOP AT SCREEN.
*        IF screen-group1 = 'INT'.
*        screen-active = 0.
*        screen-invisible = 1.
*        MODIFY SCREEN.
*        ENDIF.
*        IF screen-group1 = 'ANT'.
*        screen-ACTIVE = 1.
*        screen-invisible = 0.
*        MODIFY SCREEN.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

  "==============================================

*    IF screen-group1 = 'INT' AND rb_kunnr = 'X'.
*      screen-name = 'S_KUNNR'.
*      screen-active = 1.
*      MODIFY SCREEN.
*
*    ELSEIF screen-group1 = 'INT' AND rb_kunnr = ' '.
*      screen-name = 'S_KUNNR'.
*      screen-active = 0.
*      MODIFY SCREEN.
*    ENDIF.
*
*
*    IF screen-group1 = 'ANT' AND rb_lifnr = 'X'.
*      screen-name = 'S_LIFNR'.
*      screen-active = 1.
*      MODIFY SCREEN.
*
*    ELSEIF screen-group1 = 'ANT' AND rb_lifnr = ' '.
*      screen-name = 'S_LIFNR'.
*      screen-active = 0.
*      MODIFY SCREEN.
*    ENDIF.
*
*  ENDLOOP.
