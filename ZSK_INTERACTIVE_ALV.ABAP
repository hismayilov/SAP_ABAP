*&---------------------------------------------------------------------*
*& Report  ZNIL_INTERACTIVE1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZNIL_INTERACTIVE1.

TABLES: VBAP ,
        VBAK.

TYPE-POOLS: SLIS.

TYPES: BEGIN OF TY_VBAK, " VBAK STRUCTURE/L1
        VBELN TYPE VBAK-VBELN,  " SALES DOCUMENT
        ERNAM TYPE VBAK-ERNAM,  " CREATOR NAME
        VKORG TYPE VBAK-VKORG,  " SALES ORG.
        SPART TYPE VBAK-SPART,  " DIVISION
       END OF TY_VBAK,

       BEGIN OF TY_VBAP,  " VBAP STRUCTURE/L2
        VBELN TYPE VBAP-VBELN,  " SALES DOCUMENT
        POSNR TYPE VBAP-POSNR,  " SALES DOC. ITEM
       END OF TY_VBAP.

DATA: IT_VBAP TYPE TABLE OF TY_VBAP,
      WA_VBAP TYPE TY_VBAP,
      IT_VBAK TYPE TABLE OF TY_VBAK,
      WA_VBAK TYPE TY_VBAK,
      IT_FCAT_L1 TYPE SLIS_T_FIELDCAT_ALV, " INTERNAL TAB FOR LEVEL 1 FIELDCAT
      WA_FCAT_L1 TYPE SLIS_FIELDCAT_ALV,
      IT_FCAT_L2 TYPE SLIS_T_FIELDCAT_ALV, " INTERNAL TAB FOR LEVEL 2 FIELDCAT
      WA_FCAT_L2 TYPE SLIS_FIELDCAT_ALV,
      WA_LAYOUT TYPE SLIS_LAYOUT_ALV,
      SFIELD_VALUE TYPE VBAK-VBELN. " SELECTED FIELD VALUE(IN FCAT L1 - FIRST TABLE)

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.

    SELECT-OPTIONS: S_VBELN FOR VBAK-VBELN. " INPUT PARAMTERS

SELECTION-SCREEN END OF BLOCK B1.

START-OF-SELECTION.

"============ PROCESS AND DISP FCAT FOR VBAK ============"
PERFORM PROCESS_FCAT_L1. " LEVEL 1 FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  DISP_FCAT_L1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PROCESS_FCAT_L1 . " LEVEL 1 FIELDCAT
  SELECT VBELN
         ERNAM
         VKORG
         SPART
         FROM VBAK INTO TABLE IT_VBAK WHERE VBELN IN S_VBELN.

  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

  " GENERATE LEVEL 1 FIELDCAT
  PERFORM FCAT_L1 USING: 'VBELN' 'IT_VBAK' 'SALES DOCUMENT'  'X',
                         'ERNAM' 'IT_VBAK' 'CREATOR NAME'  '',
                         'VKORG' 'IT_VBAK' 'SALES ORG.'  '',
                         'SPART' 'IT_VBAK' 'DIVISION'  ''.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
     I_CALLBACK_PROGRAM                = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = ' '
     I_CALLBACK_USER_COMMAND           = 'PROCESS_FCAT_L2'
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
     IS_LAYOUT                         = WA_LAYOUT
     IT_FIELDCAT                       = IT_FCAT_L1
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
      T_OUTTAB                          = IT_VBAK
*   EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS                            = 2
            .
  IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " PROCESS_FCAT_L1

"============= PROCESS AND DISP FCAT FOR VBAP =============="
FORM PROCESS_FCAT_L2 USING UCOMM TYPE SY-UCOMM " LEVEL 2 FIELDCAT
      SELFIELD TYPE SLIS_SELFIELD. " STRUCTURE FOR SELECTED FIELD ATTRIBUTES

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' " GET VALUE OF SELECTED FIELD
    EXPORTING
      INPUT         = SELFIELD-VALUE
   IMPORTING
     OUTPUT         = SFIELD_VALUE
            .

 SELECT VBELN
        POSNR
        FROM VBAP INTO TABLE IT_VBAP WHERE VBELN = SFIELD_VALUE.

  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

PERFORM FCAT_L2 USING: 'VBELN' 'IT_VBAP' 'SALES DOCUMENT',
                       'POSNR' 'IT_VBAP' 'SALES DOC. ITEM'.

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
   IS_LAYOUT                         = WA_LAYOUT
   IT_FIELDCAT                       = IT_FCAT_L2
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
    T_OUTTAB                          = IT_VBAP
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

CLEAR IT_FCAT_L2.

ENDFORM.

"===========BEGIN SUBROUTINE DEFINITIONS FOR FCAT CREATION============"
*** CREATE FCAT 2 ***
*&---------------------------------------------------------------------*
*&      Form  FCAT_L1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0133   text
*      -->P_0134   text
*      -->P_0135   text
*      -->P_0136   text
*----------------------------------------------------------------------*
FORM FCAT_L1  USING    VALUE(FNAME)
                       VALUE(TNAME)
                       VALUE(STEXT)
                       VALUE(HSPOT).

  WA_FCAT_L1-FIELDNAME = FNAME.
  WA_FCAT_L1-TABNAME = TNAME.
  WA_FCAT_L1-SELTEXT_L = STEXT.
  WA_FCAT_L1-HOTSPOT = HSPOT.

  APPEND WA_FCAT_L1 TO IT_FCAT_L1.
ENDFORM.                    " FCAT_L1

*** CREATE FCAT 2 ***
*&---------------------------------------------------------------------*
*&      Form  FCAT_L2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0251   text
*      -->P_0252   text
*      -->P_0253   text
*----------------------------------------------------------------------*
FORM FCAT_L2  USING    VALUE(FNAME)
                       VALUE(TNAME)
                       VALUE(STEXT).

  WA_FCAT_L2-FIELDNAME = FNAME.
  WA_FCAT_L2-TABNAME = TNAME.
  WA_FCAT_L2-SELTEXT_L = STEXT.

  APPEND WA_FCAT_L2 TO IT_FCAT_L2.

ENDFORM.                    " FCAT_L2
