PROCESS BEFORE OUTPUT.
 MODULE STATUS_0100.
   LOOP AT IT_MARA INTO WA_MARA WITH CONTROL TABCTRL.
     MODULE DISP_TABCONTROL.
   ENDLOOP.
*
PROCESS AFTER INPUT.
 MODULE USER_COMMAND_0100.
   LOOP AT IT_MARA.
   ENDLOOP.
=======================================================================
*&---------------------------------------------------------------------*
*& Module Pool       ZTABCONTROL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  ZTABCONTROL.
"CALL SCREEN 100.

TABLES: MARA.

TYPES: BEGIN OF TY_MARA,
        MATNR TYPE MARA-MATNR,
        MTART TYPE MARA-MTART,
        MBRSH TYPE MARA-MBRSH,
        MATKL TYPE MARA-MATKL,
        MEINS TYPE MARA-MEINS,
       END OF TY_MARA.

DATA: IT_MARA TYPE TABLE OF TY_MARA,
      WA_MARA TYPE TY_MARA,
      INPUT TYPE MARA-MATNR, " INPUT FIELD ON SCREEN 100
      OK_CODE TYPE SY-UCOMM.

CONTROLS: TABCTRL TYPE TABLEVIEW USING SCREEN 100.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'STATUS_100'.
  SET TITLEBAR 'TITLE'.

  SELECT MATNR
         MTART
         MBRSH
         MATKL
         MEINS
         FROM MARA INTO TABLE IT_MARA WHERE MATNR = INPUT.
    " CLEAR WORKS WHEN SELECT DONE HERE.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

CASE OK_CODE.
  WHEN 'DISP'.
*    SELECT MATNR
*           MTART
*           MBRSH
*           MATKL
*           MEINS
*           FROM MARA INTO TABLE IT_MARA WHERE MATNR = INPUT.
    " CLEAR DOESN'T WORK WHEN SELECT DONE HERE.
    CALL SCREEN 100. " PROCESS SCREEN 100(AGAIN) WITH SPECIFIED INPUT

  WHEN 'CLR'.
    CLEAR: INPUT, MARA-MATNR, MARA-MTART, MARA-MBRSH, MARA-MATKL, MARA-MEINS.

  WHEN 'BACK'.
    LEAVE TO SCREEN 0.
  "WHEN OTHERS.
ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISP_TABCONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISP_TABCONTROL OUTPUT.
  MARA-MATNR = WA_MARA-MATNR.
  MARA-MTART = WA_MARA-MTART.
  MARA-MBRSH = WA_MARA-MBRSH.
  MARA-MATKL = WA_MARA-MATKL.
  MARA-MEINS = WA_MARA-MEINS.

  CLEAR WA_MARA.
ENDMODULE.                 " DISP_TABCONTROL  OUTPUT
