*&---------------------------------------------------------------------*
*& Report  ZSK_ALV_3TAB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

***Create a grid alv report using 3 tables
REPORT  ZSK_ALV_3TAB.

***BEGIN DATA DECLARATIONS
***TYPE-POOLS USED
TYPE-POOLS: SLIS.
***TABLE DECLARATIONS
TABLES: MARA, " GENERAL MATERIAL DATA
        VBRK, " Billing Document: Header Data
        VBRP. " Billing Document: Item Data

***STRUCTURE DECLARATIONS
TYPES: BEGIN OF TY_MARA,
        MATNR TYPE MARA-MATNR,  " Material Number " Field common in vbrp and mara
        MTART TYPE MARA-MTART,  " Material Type
        MBRSH TYPE MARA-MBRSH,  " Industry sector
        MATKL TYPE MARA-MATKL,  " Material Group
        MEINS TYPE MARA-MEINS,  " Base Unit of Measure
      END OF TY_MARA.

TYPES: BEGIN OF TY_VBRK,
        FKART TYPE VBRK-FKART,  " Billing Type
        VBELN TYPE VBRK-VBELN,  " Billing Document  " Field common in vbrk and vbrp
        VBTYP TYPE VBRK-VBTYP,  " SD document category
        VKORG TYPE VBRK-VKORG,  " Sales Organization
        VTWEG TYPE VBRK-VTWEG,  " Distribution Channel
        BELNR TYPE VBRK-BELNR,  " Accounting Document Number
      END OF TY_VBRK.

TYPES: BEGIN OF TY_VBRP,
        VBELN TYPE VBRP-VBELN,  " Billing Document  " Field common in vbrk and vbrp
        GSBER TYPE VBRP-GSBER,  " Business Area
        VOLUM TYPE VBRP-VOLUM,  " Volume
        MATNR TYPE VBRP-MATNR,  " Material Number " Field common in vbrp and mara
      END OF TY_VBRP.

TYPES: BEGIN OF TY_FINAL,
        VBELN TYPE VBRK-VBELN,  " Billing Document  " <=====Key
        FKART TYPE VBRK-FKART,  " Billing Type
        VBTYP TYPE VBRK-VBTYP,  " SD document category
        VKORG TYPE VBRK-VKORG,  " Sales Organization
        VTWEG TYPE VBRK-VTWEG,  " Distribution Channel
        BELNR TYPE VBRK-BELNR,  " Accounting Document Number
        GSBER TYPE VBRP-GSBER,  " Business Area
        VOLUM TYPE VBRP-VOLUM,  " Volume
        MATNR TYPE VBRP-MATNR,  " Material Number "<======Key
        MTART TYPE MARA-MTART,  " Material Type
        MBRSH TYPE MARA-MBRSH,  " Industry sector
        MATKL TYPE MARA-MATKL,  " Material Group
        MEINS TYPE MARA-MEINS,  " Base Unit of Measure
      END OF TY_FINAL.

***CREATE INTERNAL TABLE DATA OBJECTS
DATA: IT_MARA TYPE TABLE OF TY_MARA,
      WA_MARA LIKE LINE OF IT_MARA.

DATA: IT_VBRK TYPE TABLE OF TY_VBRK,
      WA_VBRK LIKE LINE OF IT_VBRK.

DATA: IT_VBRP TYPE TABLE OF TY_VBRP,
      WA_VBRP LIKE LINE OF IT_VBRP.

DATA: IT_FINAL TYPE TABLE OF TY_FINAL,
      WA_FINAL LIKE LINE OF IT_FINAL.

DATA: IT_FLDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FLDCAT TYPE SLIS_FIELDCAT_ALV.

DATA: WA_LAYOUT TYPE SLIS_LAYOUT_ALV.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: S_VBELN FOR VBRK-VBELN.
  PARAMETERS: P_FKART TYPE VBRK-FKART.
SELECTION-SCREEN END OF BLOCK B1.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM PROCESS_DATA.
  PERFORM DISPLAY_DATA.
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  SELECT FKART  " Get data from vbrk into it_vbrk based on user input
         VBELN
         VBTYP
         VKORG
         VTWEG
         BELNR FROM VBRK INTO TABLE IT_VBRK WHERE VBELN IN S_VBELN AND FKART =  P_FKART.

  IF IT_VBRK IS NOT INITIAL.
    SORT IT_VBRK ASCENDING BY VBELN.  " The following select on the dependent table works faster because
    " the search is lighter due to sorted data

    SELECT VBELN  " Get data from vbrp into it_vbrp based on data in vbrk(vbeln common field)
           GSBER
           VOLUM
           MATNR FROM VBRP INTO TABLE IT_VBRP FOR ALL ENTRIES IN IT_VBRK WHERE VBELN = IT_VBRK-VBELN.

    IF IT_VBRP IS NOT INITIAL.
      SORT IT_VBRP ASCENDING BY MATNR.

      SELECT MATNR  " Get data from mara into it_mara based on data in vbrk(matnr common field)
             MTART
             MBRSH
             MATKL
             MEINS FROM MARA INTO TABLE IT_MARA FOR ALL ENTRIES IN IT_VBRP WHERE MATNR = IT_VBRP-MATNR.

    ENDIF.
  ENDIF.
ENDFORM.                      " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_DATA .
  LOOP AT IT_VBRK INTO WA_VBRK.
    CLEAR WA_FINAL.
    WA_FINAL-VBELN = WA_VBRK-VBELN.
    WA_FINAL-FKART = WA_VBRK-FKART.
    WA_FINAL-BELNR = WA_VBRK-BELNR.
    WA_FINAL-VBTYP = WA_VBRK-VBTYP.
    WA_FINAL-VKORG = WA_VBRK-VKORG.
    WA_FINAL-VTWEG = WA_VBRK-VTWEG.
    
    " Read one row into wa_vbrp from vbrp based on current value of vbeln in wa_final/vbrk
    READ TABLE IT_VBRP INTO WA_VBRP WITH KEY VBELN = WA_FINAL-VBELN BINARY SEARCH.
    "WA_FINAL-GSBER = WA_VBRP-GSBER.
    WA_FINAL-VOLUM = WA_VBRP-VOLUM.
    WA_FINAL-MATNR = WA_VBRP-MATNR.

    " Read one row into wa_mara from mara based on current value of matnr in wa_final/vbrp
    READ TABLE IT_MARA INTO WA_MARA WITH KEY MATNR = WA_FINAL-MATNR BINARY SEARCH.
    WA_FINAL-MTART = WA_MARA-MTART.
    WA_FINAL-MBRSH = WA_MARA-MBRSH.
    WA_FINAL-MATKL = WA_MARA-MATKL.
    WA_FINAL-MEINS = WA_MARA-MEINS.

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

  "SET FIELD CATALOG PARAMETERS
  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '1'.
  WA_FLDCAT-FIELDNAME = 'VBELN'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'BILLING DOCUMENT'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '2'.
  WA_FLDCAT-FIELDNAME = 'FKART'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'BILLING TYPE'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '3'.
  WA_FLDCAT-FIELDNAME = 'VBTYP'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'SD DOCUMENT CATEGORY'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '4'.
  WA_FLDCAT-FIELDNAME = 'VKORG'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'SALES ORGANIZATION'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '5'.
  WA_FLDCAT-FIELDNAME = 'VTWEG'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'DISTRIBUTION CHANNEL'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '6'.
  WA_FLDCAT-FIELDNAME = 'BELNR'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'ACCOUNTING DOCUMENT NUMBER'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '7'.
  WA_FLDCAT-FIELDNAME = 'GSBER'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'BUSINESS AREA'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '8'.
  WA_FLDCAT-FIELDNAME = 'VOLUM'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'VOLUME'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '9'.
  WA_FLDCAT-FIELDNAME = 'MATNR'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'MATERIAL NUMBER'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '10'.
  WA_FLDCAT-FIELDNAME = 'MTART'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'MATERIAL TYPE'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '11'.
  WA_FLDCAT-FIELDNAME = 'MBRSH'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'INDUSTRY SECTOR'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '12'.
  WA_FLDCAT-FIELDNAME = 'MATKL'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'MATERIAL GROUP'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

  CLEAR WA_FLDCAT.
  WA_FLDCAT-COL_POS = '13'.
  WA_FLDCAT-FIELDNAME = 'MEINS'.
  WA_FLDCAT-TABNAME = 'IT-FINAL'.
  WA_FLDCAT-SELTEXT_L = 'BASE UNIT OF MEASURE'.
  APPEND WA_FLDCAT TO IT_FLDCAT.

" CALL FUNCTION TO DISPLAY THE REPORT USING THE INFO IN FIELD CATALOG
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
      I_CALLBACK_PROGRAM                = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
      IS_LAYOUT                         = WA_LAYOUT
      IT_FIELDCAT                       = IT_FLDCAT
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
      T_OUTTAB                          = IT_FINAL
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " DISPLAY_DATA
