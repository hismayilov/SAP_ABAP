*&---------------------------------------------------------------------*
*& Report  ZTEST_SK04_SEL_SCR2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZTEST_SK04_SEL_SCR2.
TABLES: bsid, pa0001.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
SELECT-OPTIONS: s_kunnr FOR bsid-kunnr,
                s_bukrs FOR bsid-bukrs DEFAULT '1003',
                s_pernr FOR pa0001-pernr MODIF ID op1 OBLIGATORY NO INTERVALS.
PARAMETERS: p_keydat TYPE bsid-budat DEFAULT sy-datlo.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE t2.
PARAMETERS: p_all  TYPE c RADIOBUTTON GROUP rd USER-COMMAND abcd DEFAULT 'X',
            p_man  TYPE c RADIOBUTTON GROUP rd.
SELECTION-SCREEN END OF BLOCK blk2.

SELECTION-SCREEN BEGIN OF BLOCK blk3 WITH FRAME TITLE t3.
PARAMETERS: p_gen  TYPE c RADIOBUTTON GROUP rd1 DEFAULT 'X',
            p_aud  TYPE c RADIOBUTTON GROUP rd1.
SELECTION-SCREEN END OF BLOCK blk3.

INITIALIZATION.
  t1 = 'Input Data'.
  t2 = 'Run For'.
  t3 = 'Select no.of days'.

AT SELECTION-SCREEN OUTPUT.

LOOP AT SCREEN.
  IF SCREEN-group1 = 'OP1'.
    IF P_ALL = 'X'.
      SCREEN-ACTIVE = 0.
    ELSEIF P_MAN = 'X'.
      SCREEN-ACTIVE = 1.
    ENDIF.
    MODIFY SCREEN.
  ENDIF.
ENDLOOP.

"===========================

*  IF p_all = 'X'.
*    LOOP AT SCREEN.
*     IF screen-group1 = 'OP1'.
*          screen-input = 0.
*          screen-invisible = 1.
*          MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*  IF p_man = 'X'.
*    LOOP AT SCREEN.
*      IF screen-group1 = 'OP1'.
*          screen-input = 1.
*          screen-invisible = 0.
*          MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
