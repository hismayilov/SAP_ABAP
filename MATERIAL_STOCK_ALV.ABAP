*&---------------------------------------------------------------------*
*& REPORT  ZAB_FS_ALV_2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZAB_FS_ALV_2.

TYPE-POOLS: SLIS.

TABLES : MBEW,
         MAKT,
         EIPA,
         MSEG,
         MARD,
         MARA.

TYPES: BEGIN OF TY_MBEW,
        MATNR TYPE MBEW-MATNR,
        SALK3 TYPE MBEW-SALK3,
        VERPR TYPE MBEW-VERPR,
        PEINH TYPE MBEW-PEINH,
      END OF TY_MBEW.

TYPES: BEGIN OF TY_MAKT,
        MATNR TYPE MAKT-MATNR,
        MAKTX TYPE MAKT-MAKTX,
      END OF TY_MAKT.

TYPES: BEGIN OF TY_EIPA,
        EBELN TYPE EIPA-EBELN,
        BEDAT TYPE EIPA-BEDAT,
        PREIS TYPE EIPA-PREIS,
      END OF TY_EIPA.

TYPES: BEGIN OF TY_MSEG,
        MBLNR TYPE MSEG-MBLNR,
        MATNR TYPE MSEG-MATNR,
        EBELN TYPE MSEG-EBELN,
      END OF TY_MSEG.

TYPES: BEGIN OF TY_MARD,
        MATNR TYPE MARD-MATNR,
        LABST TYPE MARD-LABST,
      END OF TY_MARD.

TYPES: BEGIN OF TY_MARA,
        MATNR TYPE MARA-MATNR,
        MEINS TYPE MARA-MEINS,
      END OF TY_MARA.

TYPES: BEGIN OF TY_FINAL,
        MATNR TYPE MBEW-MATNR,
        MAKTX TYPE MAKT-MAKTX,
        VERPR TYPE MBEW-VERPR,
        PREISL TYPE EIPA-PREIS,
        PREISA TYPE EIPA-PREIS,
        EBELN TYPE MSEG-EBELN,
        MBLNR TYPE MSEG-MBLNR,
        LABST TYPE MARD-LABST,
        SALK3 TYPE MBEW-SALK3,
        MEINS TYPE MARA-MEINS,
        PEINH TYPE MBEW-PEINH,
      END OF TY_FINAL.

DATA: IT_MBEW TYPE TABLE OF TY_MBEW,
      WA_MBEW TYPE TY_MBEW,

      IT_MAKT TYPE TABLE OF TY_MAKT,
      WA_MAKT TYPE TY_MAKT,

      IT_EIPA TYPE TABLE OF TY_EIPA,
      WA_EIPA TYPE TY_EIPA,

      IT_MSEG TYPE TABLE OF TY_MSEG,
      WA_MSEG TYPE TY_MSEG,

      IT_MARD TYPE TABLE OF TY_MARD,
      WA_MARD TYPE TY_MARD,

      IT_MARA TYPE TABLE OF TY_MARA,
      WA_MARA TYPE TY_MARA,

      IT_FINAL TYPE TABLE OF TY_FINAL,
      WA_FINAL TYPE TY_FINAL,

      IT_FLDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FLDCAT TYPE SLIS_FIELDCAT_ALV,

      IT_LAYOUT TYPE SLIS_LAYOUT_ALV.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: P_MATNR FOR MBEW-MATNR.
SELECTION-SCREEN END OF BLOCK B1.


START-OF-SELECTION.
PERFORM GET_DATA.
PERFORM PROCESS_DATA.
PERFORM DISPLAY_DATA.

*&---------------------------------------------------------------------*
*&      FORM  GET_DATA
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*  -->  P1        TEXT
*  <--  P2        TEXT
*----------------------------------------------------------------------*
FORM GET_DATA .

SELECT MATNR
       SALK3
       VERPR
       PEINH
       FROM MBEW INTO TABLE IT_MBEW
       WHERE MATNR IN P_MATNR.

IF IT_MBEW IS NOT INITIAL.
  SORT IT_MBEW BY MATNR.
  SELECT MATNR
         MAKTX
         FROM MAKT INTO TABLE IT_MAKT
         FOR ALL ENTRIES IN IT_MBEW
         WHERE MATNR = IT_MBEW-MATNR.

    SELECT MBLNR
           MATNR
           EBELN
           FROM MSEG INTO TABLE IT_MSEG
           FOR ALL ENTRIES IN IT_MBEW
           WHERE MATNR = IT_MBEW-MATNR.


     IF IT_MSEG IS NOT INITIAL.
       SORT IT_MSEG BY EBELN.
       SELECT MBLNR
              MATNR
              EBELN
              FROM MSEG INTO TABLE IT_MSEG
              FOR ALL ENTRIES IN IT_MSEG
              WHERE EBELN = IT_MSEG-EBELN AND MATNR = IT_MSEG-MATNR. "AND EBELN <> ' ' AND MATNR <> ' '.

       SELECT EBELN
              BEDAT
              PREIS
              FROM EIPA INTO TABLE IT_EIPA
              FOR ALL ENTRIES IN IT_MSEG
              WHERE EBELN = IT_MSEG-EBELN.

     ENDIF.

*     IF IT_EIPA IS NOT INITIAL.
*
*       SORT IT_EIPA BY BEDAT DESCENDING.
*       READ TABLE IT_EIPA INTO WA_EIPA INDEX 1.
*
*     ENDIF.

     SELECT MATNR
            LABST
            FROM MARD INTO TABLE IT_MARD
            FOR ALL ENTRIES IN IT_MBEW
            WHERE MATNR = IT_MBEW-MATNR.

     SELECT MATNR
            MEINS
            FROM MARA INTO TABLE IT_MARA
            FOR ALL ENTRIES IN IT_MBEW
            WHERE MATNR = IT_MBEW-MATNR.

ENDIF.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      FORM  PROCESS_DATA
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*  -->  P1        TEXT
*  <--  P2        TEXT
*----------------------------------------------------------------------*
FORM PROCESS_DATA .
LOOP AT IT_MBEW INTO WA_MBEW.
  CLEAR WA_FINAL.
  WA_FINAL-MATNR = WA_MBEW-MATNR.
  WA_FINAL-VERPR = WA_MBEW-VERPR.
  WA_FINAL-SALK3 = WA_MBEW-SALK3.
  WA_FINAL-PEINH = WA_MBEW-PEINH.
  "==============================="
  READ TABLE IT_MAKT INTO WA_MAKT WITH KEY MATNR = WA_FINAL-MATNR.
  WA_FINAL-MAKTX = WA_MAKT-MAKTX.

  READ TABLE IT_MARD INTO WA_MARD WITH KEY MATNR = WA_FINAL-MATNR.
  WA_FINAL-LABST = WA_MARD-LABST.

  READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_FINAL-MATNR.
  WA_FINAL-MEINS = WA_MARA-MEINS.



  LOOP AT IT_MSEG INTO WA_MSEG WHERE MATNR = WA_FINAL-MATNR.
    WA_FINAL-EBELN = WA_MSEG-EBELN.
    WA_FINAL-MBLNR = WA_MSEG-MBLNR.
*     LOOP AT IT_EIPA INTO WA_EIPA WHERE EBELN = WA_FINAL-EBELN.
*       WA_FINAL-PREISL = WA_EIPA-PREIS.
*       WA_FINAL-PREISA = WA_EIPA-PREIS.
*       APPEND WA_FINAL TO IT_FINAL.
*      ENDLOOP.
      READ TABLE IT_EIPA INTO WA_EIPA WITH KEY EBELN = WA_FINAL-EBELN.
        WA_FINAL-PREISL = WA_EIPA-PREIS.
        WA_FINAL-PREISA = WA_EIPA-PREIS.
     APPEND WA_FINAL TO IT_FINAL.

  ENDLOOP.

APPEND WA_FINAL TO IT_FINAL.
DELETE ADJACENT DUPLICATES FROM IT_FINAL COMPARING ALL FIELDS.

ENDLOOP.
ENDFORM.                    " PROCESS_DATA
**&---------------------------------------------------------------------*
**&      FORM  DISPLAY_DATA
**&---------------------------------------------------------------------*
**       TEXT
**----------------------------------------------------------------------*
**  -->  P1        TEXT
**  <--  P2        TEXT
**----------------------------------------------------------------------*
FORM DISPLAY_DATA .

WA_FLDCAT-COL_POS   = 1.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'MATERIAL NUMBER'.
WA_FLDCAT-FIELDNAME = 'MATNR'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 2.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'MATERIAL DESCRIPTION'.
WA_FLDCAT-FIELDNAME = 'MAKTX'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 3.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'AVERAGE PRICE'.
WA_FLDCAT-FIELDNAME = 'VERPR'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 4.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'LAST PURCHASE PRICE'.
WA_FLDCAT-FIELDNAME = 'PREISL'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 5.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'ACTUAL PURCHASE PRICE'.
WA_FLDCAT-FIELDNAME = 'PREISA'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 6.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'PURCHASE ORDER NO'.
WA_FLDCAT-FIELDNAME = 'EBELN'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 7.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'GR NO'.
WA_FLDCAT-FIELDNAME = 'MBLNR'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 8.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'STOCK QTY'.
WA_FLDCAT-FIELDNAME = 'LABST'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 9.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'STOCK VALUE'.
WA_FLDCAT-FIELDNAME = 'SALK3'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 10.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'BASE UNIT'.
WA_FLDCAT-FIELDNAME = 'MEINS'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

WA_FLDCAT-COL_POS   = 11.
WA_FLDCAT-TABNAME   = 'IT_FINAL'.
WA_FLDCAT-SELTEXT_M = 'PEINH'.
WA_FLDCAT-FIELDNAME = 'PRICE PER UNIT'.
APPEND WA_FLDCAT TO IT_FLDCAT.
CLEAR WA_FLDCAT.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
   I_CALLBACK_PROGRAM                = SY-REPID
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
*   IS_LAYOUT                         =
   IT_FIELDCAT                       = IT_FLDCAT
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB                          = IT_FINAL
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.


ENDFORM.                    " DISPLAY_DATA
