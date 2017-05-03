*&---------------------------------------------------------------------*
*& Report ZSOL_MATERIAL_START
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsol_material_start.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: rad1 RADIOBUTTON GROUP grp DEFAULT 'X',
            rad2 RADIOBUTTON GROUP grp,
            rad3 RADIOBUTTON GROUP grp,
            rad4 RADIOBUTTON GROUP grp.
SELECTION-SCREEN END OF BLOCK b1.


IF rad1 EQ 'X'.
  CALL TRANSACTION 'ZMAT_REQ'.
ELSEIF rad2 EQ 'X'.
  CALL TRANSACTION 'ZMAT_DISP'.
ELSEIF rad3 EQ 'X'.
  CALL TRANSACTION 'ZMAT_APPR'.
ELSEIF rad4 EQ 'X'.
  CALL TRANSACTION 'ZMAT_CREATE'.
ENDIF.
