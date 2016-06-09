*&---------------------------------------------------------------------*
*& Report  ZSK_ALV
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZSK_ALV.

***BEGIN DATA DECLARATIONS

***TYPE POOLS USED
TYPE-POOLS: SLIS. " SLIS is a type group for ALV and especially used to build Field Catalogs,LAYOUT
" FIELD CATALOG WILL HANDLE PRESENTAION/DISPLAY FOR US INSTEAD OF WRITE STATEMENTS AND CAN BE REUSED
" SLIS contains definations for types, structures and tables/INTERNAL TABLES which we use in ALV.

***TABLE DECLARATIONS
TABLES: MARA,
        MAKT.

***BEGIN STRUCTURE DECLARATIONS FOR INTERNAL TABLES
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

***BEGIN INTERNAL TABLE DATA OBJECT CREATION
DATA: IT_MARA TYPE TABLE OF TY_MARA,
      WA_MARA LIKE LINE OF IT_MARA.

DATA: IT_MAKT TYPE TABLE OF TY_MAKT,
      WA_MAKT LIKE LINE OF IT_MAKT.

DATA: IT_FINAL TYPE TABLE OF TY_FINAL,
      WA_FINAL LIKE LINE OF IT_FINAL.

DATA: IT_FLDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FLDCAT TYPE SLIS_FIELDCAT_ALV. " OR LIKE LINE OF IT_FLDCAT
***SLIS_T_FIELDCAT_ALV IS THE INTERNAL TABLE FOR FIELD THAT IS ALREADY DEFINED(AND OBJECT CREATED) IN SLIS
***TYPE POOL. IT IS CREATED USING THE STRUCTURE SLIS_FIELDCAT_ALV IN SLIS. WE CREATE OUR INTERNAL TABLE
***IT_FLDCAT FOR FIELDCATALOG FROM THE PREDEFINED INTERNAL TABLE SLIS_T_FIELDCAT_ALV AND WE CREATE THE
***WORK AREA FOR OUR INTERNAL TABLE IT_FIELDCAT FROM THE STRCUTURE SLIS_FIELDCAT_ALV WHICH IS USED TO CREATE
***THE PREDEFINED INTERNAL TABLE SLIS_T_FIELDCAT_ALV.

DATA: IT_LAYOUT TYPE TABLE OF SLIS_LAYOUT_ALV,
      WA_LAYOUT LIKE LINE OF IT_LAYOUT. " OR DIRECTLY WA_LAYOUT TYPE SLIS_LAYOUT_ALV
***SLIS_LAYOUT_ALV IS PRE-DEFINED STRUCTURE IN SLIS. USED TO CUSTOMISE THE LOOK/FEEL AND LAYOUT OF REPORT.

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
  " SET LAYOUT
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-ZEBRA = 'X'.

  " SET FIELD CATALOG PARAMETERS
  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '1'.
  WA_FLDCAT-FIELDNAME = 'MATNR'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'MATERIAL NUMBER'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '2'.
  WA_FLDCAT-FIELDNAME = 'MTART'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'MATERIAL TYPE'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '3'.
  WA_FLDCAT-FIELDNAME = 'MBRSH'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'INDUSTRY SECTOR'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '4'.
  WA_FLDCAT-FIELDNAME = 'MATKL'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'MATERIAL GROUP'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '5'.
  WA_FLDCAT-FIELDNAME = 'MEINS'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'BASE UNIT OF MEASURE'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '6'.
  WA_FLDCAT-FIELDNAME = 'MAKTX'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'MATERIAL DESCRIPTION'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  " CALL FUNCTION TO DISPLAY THE REPORT USING THE INFO IN FIELD CATALOG
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' " GRID ALV
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
      I_CALLBACK_PROGRAM                = SY-REPID "CURRENT REPORT/CALLING PROGRAM
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
      IS_LAYOUT                         = WA_LAYOUT " LAYOUT TO USE
      IT_FIELDCAT                       = IT_FLDCAT " FIELD CATALOG TO USE
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB                          = IT_FINAL " CONTENT TABLE TO USE
    EXCEPTIONS
      PROGRAM_ERROR                     = 1
      OTHERS                            = 2
            .
   IF SY-SUBRC <> 0.
   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

*CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY' " LIST ALV
*  EXPORTING
**   I_INTERFACE_CHECK              = ' '
**   I_BYPASSING_BUFFER             =
**   I_BUFFER_ACTIVE                = ' '
*    I_CALLBACK_PROGRAM             = SY_REPID
**   I_CALLBACK_PF_STATUS_SET       = ' '
**   I_CALLBACK_USER_COMMAND        = ' '
**   I_STRUCTURE_NAME               =
*    IS_LAYOUT                      = WA_FLDCAT
*    IT_FIELDCAT                    = IT_FLDCAT
**   IT_EXCLUDING                   =
**   IT_SPECIAL_GROUPS              =
**   IT_SORT                        =
**   IT_FILTER                      =
**   IS_SEL_HIDE                    =
**   I_DEFAULT                      = 'X'
**   I_SAVE                         = ' '
**   IS_VARIANT                     =
**   IT_EVENTS                      =
**   IT_EVENT_EXIT                  =
**   IS_PRINT                       =
**   IS_REPREP_ID                   =
**   I_SCREEN_START_COLUMN          = 0
**   I_SCREEN_START_LINE            = 0
**   I_SCREEN_END_COLUMN            = 0
**   I_SCREEN_END_LINE              = 0
**   IR_SALV_LIST_ADAPTER           =
**   IT_EXCEPT_QINFO                =
**   I_SUPPRESS_EMPTY_DATA          = ABAP_FALSE
** IMPORTING
**   E_EXIT_CAUSED_BY_CALLER        =
**   ES_EXIT_CAUSED_BY_USER         =
*  TABLES
*    T_OUTTAB                       = IT_FINAL
** EXCEPTIONS
**   PROGRAM_ERROR                  = 1
**   OTHERS                         = 2
*          .
*IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.

ENDFORM.                    " DISPLAY_DATA
