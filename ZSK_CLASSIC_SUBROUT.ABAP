*&---------------------------------------------------------------------*
*& Report  ZSK_CLASSIC_SUBROUT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

***CLASSICAL REPORT WITH 2 TABLES USING SUB-ROUTINES
REPORT  ZSK_CLASSIC_SUBROUT.

***DECLARATION OF TABLES USED
TABLES: MARA,
        MAKT.

***DECLARATION OF STRUCTURES FOR INTERNAL TABLES
TYPES: BEGIN OF TY_MARA,
        MATNR TYPE MARA-MATNR,
        MTART TYPE MARA-MTART,
        MBRSH TYPE MARA-MBRSH,
        MATKL TYPE MARA-MATKL,
        MEINS TYPE MARA-MEINS,
      END OF TY_MARA.

TYPES: BEGIN OF TY_MAKT,
        MATNR TYPE MAKT-MATNR,
        MAKTX TYPE MAKT-MAKTX,
      END OF TY_MAKT.

TYPES: BEGIN OF TY_FINAL,
        MATNR TYPE MARA-MATNR,
        MTART TYPE MARA-MTART,
        MBRSH TYPE MARA-MBRSH,
        MATKL TYPE MARA-MATKL,
        MEINS TYPE MARA-MEINS,
        MAKTX TYPE MAKT-MAKTX,
      END OF TY_FINAL.

***CREATE INTERNAL TABLES DATA OBJECTS
DATA: IT_MARA TYPE TABLE OF TY_MARA,
      WA_MARA LIKE LINE OF IT_MARA.

DATA: IT_MAKT TYPE TABLE OF TY_MAKT,
      WA_MAKT LIKE LINE OF IT_MAKT.

DATA: IT_FINAL TYPE TABLE OF TY_FINAL,
      WA_FINAL LIKE LINE OF IT_FINAL.

***SELECTION SCREEN
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_MATNR FOR MARA-MATNR.
PARAMETERS: P_MBRSH TYPE MARA-MBRSH.
SELECTION-SCREEN END OF BLOCK B1.

***BEGIN MAIN EXECUTION
START-OF-SELECTION.
***SUBROUTINE DECLARATIONS AND CALLS.
  PERFORM GET_DATA. " FOR DEFINITION D-CLICK SUB-ROUTINE NAME HERE AND SELECT(LEFT-MOST) MAIN-PROG
  PERFORM PROCESS_DATA.
  PERFORM DISPLAY_DATA.
END-OF-SELECTION.

***BEGIN SUBROUTINE DEFINITIONS
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  SELECT MATNR
         MTART
         MBRSH
         MATKL
         MEINS FROM MARA INTO TABLE IT_MARA WHERE MATNR IN S_MATNR AND MBRSH = P_MBRSH.

  IF IT_MARA IS NOT INITIAL.
    SORT IT_MARA ASCENDING BY MATNR.
    SELECT MATNR
           MAKTX FROM MAKT INTO TABLE IT_MAKT FOR ALL ENTRIES IN IT_MARA WHERE MATNR = IT_MARA-MATNR.
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
FORM PROCESS_DATA .
  LOOP AT IT_MARA INTO WA_MARA.
    CLEAR WA_FINAL.
    WA_FINAL-MATNR = WA_MARA-MATNR.
    WA_FINAL-MTART = WA_MARA-MTART.
    WA_FINAL-MBRSH = WA_MARA-MBRSH.
    WA_FINAL-MATKL = WA_MARA-MATKL.
    WA_FINAL-MEINS = WA_MARA-MEINS.

    READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_FINAL-MATNR BINARY SEARCH.

    WA_FINAL-MAKTX = WA_MAKT-MAKTX.

    APPEND WA_FINAL TO IT_FINAL.
  ENDLOOP.
ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .
  ULINE AT /(109). " HORIZONTOL LINE - 109 CHARACHTERS LONG

  WRITE : AT /1 SY-VLINE, 2'MATERIAL NUMBER', 20 SY-VLINE, 21'MATERIAL TYPE',34 SY-VLINE, 35'INDUSTRY SECTOR',
          50 SY-VLINE, 51'MATERIAL GROUP', 65 SY-VLINE, 66'BASE UNIT OF MEASURE', 87 SY-VLINE, 88'MATERIAL DESCRIPTION',
          109 SY-VLINE. " SY-VLINE - VERTICAL LINE

  ULINE AT /(109).

  LOOP AT IT_FINAL INTO WA_FINAL.
    WRITE: AT /1 SY-VLINE, 2 WA_FINAL-MATNR, 20 SY-VLINE, 21 WA_FINAL-MTART, 34 SY-VLINE, 35 WA_FINAL-MBRSH,
           50 SY-VLINE, 51 WA_FINAL-MATKL, 65 SY-VLINE, 66 WA_FINAL-MEINS, 87 SY-VLINE, 88 WA_FINAL-MAKTX, 109 SY-VLINE.

    ULINE AT /(109).
  ENDLOOP.
ENDFORM.                    " DISPLAY_DATA
