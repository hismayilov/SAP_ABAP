*&---------------------------------------------------------------------*
*& Report  Z6MM001R_PURCHASE_ORDER
*&
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* OBJECT DESCRIPTION: Purchase Order Printing
* OBJECT TYPE       : Layout Program   FUNC. CONSULTANT  : Girish
*          DEVELOPER: Ramakrishna
*      CREATION DATE: 10.06.2009
*        DEV REQUEST: IRDK900092
*              TCODE: ME21N,ME22N,ME23N
*----------------------------------------------------------------------*
* REVISION HISTORY-----------------------------------------------------*
*
*        REVISION NO:   R***
*          DEVELOPER:                        DATE:   DD.MM.YYYY
*        DESCRIPTION:
*----------------------------------------------------------------------*

***********************************************************************
*  Program Name : Z6MM001R_PURCHASE_ORDER                             *
*  Program Title: Purchase Order Printing                             *
*  Program type : layout Program                                      *
*  Functional Consultant : Girish                                     *
*  Technical  Consultant : Naveen kumar                               *
*  Create Date  : 26.08.2009                                          *
*  Request No.  : FEDK900324                                          *
*  T.Code       : ME21N,ME22N,ME23N                                   *
*  Description  : Purchase Order Printing                             *
*----------------------------------------------------------------------
REPORT  ZMM_PURCHASE_ORDER_PRG_GST.
TABLES: NAST ,
        EKPO ,
        EKKO.

DATA : I_EKKO LIKE EKKO OCCURS 0 WITH HEADER LINE.
DATA: WA_EKKO LIKE LINE OF I_EKKO.
DATA : IT_PDFDATA LIKE TLINE OCCURS 0 WITH HEADER LINE.
DATA : I_EKPO LIKE EKPO OCCURS 0 WITH HEADER LINE.
DATA : I_ML_ESLL LIKE ML_ESLL OCCURS 0 WITH HEADER LINE.
DATA : I_KONV LIKE KONV OCCURS 0 WITH HEADER LINE.
DATA : I_KOMV LIKE KOMV OCCURS 0 WITH HEADER LINE.
DATA : TT_KOMV TYPE KOMV_ITAB.
DATA : WA_KOMV TYPE KOMV,
       WA_KOMV_JVCS TYPE KOMV.
DATA : I_MDSB LIKE MDSB OCCURS 0 WITH HEADER LINE.
DATA : WA_LFM1 LIKE LFM1.
DATA : WRK_FILESIZ(10) TYPE C.

DATA: PO_CODE    TYPE EKPO-EBELN.

DATA mwsbp TYPE komp-mwsbp .

*---------------------------------------------------------------------*
*       Form  YMPR_PO_PRINT
*---------------------------------------------------------------------*
FORM ENTRY_NEU
  USING ENT_RETCO
        ENT_SCREEN.
  PERFORM CLEAR_REFRESH.
  PO_CODE = NAST-OBJKY(10) .
  PERFORM GETDATA_INTO_EKKO_EKPO.

  PERFORM PRINT_SMART_FORM.
  CLEAR ENT_RETCO .

ENDFORM.                    "entry_neu

*---------------------------------------------------------------------*
*      -->ENT_RETCO  text
*      -->ENT_SCREEN text
*---------------------------------------------------------------------*
FORM ADOBE_ENTRY_NEU USING ENT_RETCO  LIKE SY-SUBRC
                           ENT_SCREEN TYPE C.
  DATA: XDRUVO TYPE C,
        L_XFZ TYPE C.

  IF NAST-AENDE EQ SPACE.
    XDRUVO = '1'.
  ELSE.
    XDRUVO = '2'.
  ENDIF.
  PERFORM CLEAR_REFRESH.
  PO_CODE = NAST-OBJKY(10) .
  PERFORM GETDATA_INTO_EKKO_EKPO.

  PERFORM ADOBE_PRINT_OUTPUT USING    XDRUVO
                                      ENT_SCREEN
                                      L_XFZ
                             CHANGING ENT_RETCO.
  PERFORM SENDING_MAIL_NEW.
ENDFORM.                    "adobe_entry_neu
*&---------------------------------------------------------------------*
*&      Form  CLEAR_REFRESH
*&---------------------------------------------------------------------*
FORM CLEAR_REFRESH .
  CLEAR :
            I_EKKO , I_EKPO , I_KONV , I_KOMV ,
            PO_CODE, WA_LFM1.
  REFRESH :
            I_EKKO , I_EKPO , I_KONV , I_KOMV
            .
ENDFORM.                    " CLEAR_REFRESH
*&---------------------------------------------------------------------*
*&      Form  GETDATA_INTO_EKKO_EKPO
*&---------------------------------------------------------------------*
FORM GETDATA_INTO_EKKO_EKPO .
  SELECT * INTO TABLE I_EKKO
           FROM EKKO
           WHERE EBELN = PO_CODE
           AND LOEKZ = ''.
  SELECT * INTO TABLE I_EKPO
         FROM EKPO
         WHERE EBELN = PO_CODE
         AND   LOEKZ = '' .
  READ TABLE I_EKKO INDEX 1.
  IF SY-SUBRC = 0 .
    IF I_EKKO-FRGKE = 'B'.
      MESSAGE E398(00) WITH 'Released the PO' '' '' ''..
    ENDIF.

    SELECT SINGLE * FROM LFM1 INTO WA_LFM1 WHERE LIFNR = I_EKKO-LIFNR.
    SELECT * FROM KONV
        INTO CORRESPONDING FIELDS OF TABLE I_KONV
        WHERE KNUMV = I_EKKO-KNUMV.

  ENDIF.

*  hide below conditions in PO Print
*  develeoper: Punam S
   DELETE I_KONV WHERE KSCHL = 'ZBPC'. " BP CIF for Import
   DELETE I_KONV WHERE KSCHL = 'ZBPL'. " Basic price
   DELETE I_KONV WHERE KSCHL = 'ZBPP'. " basic price

    IF I_EKKO-BSART = 'ZSTO'.
       if I_EKKO-EKGRP = '304'.
         DELETE I_KONV WHERE KSCHL = 'P101'. " Val.Price Supply.Pln
       endif.
    ENDIF.

  IF I_EKKO-BSART <> 'ZSTO'.
    DELETE I_KONV WHERE KSCHL = 'FRA2' AND LIFNR <> I_EKKO-LIFNR." AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'FRB2' AND LIFNR <> I_EKKO-LIFNR." AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'FRC2' AND LIFNR <> I_EKKO-LIFNR." AND lifnr NE ''.
*    ----added by supriya on 29/7/10
    DELETE I_KONV WHERE KSCHL = 'ZFBT' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'FRA1' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'FRB1' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'FRC1' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'JOCM' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'ZJO2' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'ZUN2' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'ZDN2' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'ZOC2' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'ZLBT' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
    DELETE I_KONV WHERE KSCHL = 'ZETX' AND LIFNR <> I_EKKO-LIFNR ."AND lifnr NE ''.
*   ----
  ENDIF.
  IF NOT I_EKPO[] IS INITIAL.
    SELECT *
         FROM ML_ESLL
         INTO CORRESPONDING FIELDS OF TABLE I_ML_ESLL
         FOR ALL ENTRIES IN I_EKPO
         WHERE EBELN = I_EKPO-EBELN AND
         DEL NE 'X'.
    SELECT *
         FROM MDSB
         INTO CORRESPONDING FIELDS OF TABLE I_MDSB
         FOR ALL ENTRIES IN I_EKPO
         WHERE EBELN = I_EKPO-EBELN AND
         XLOEK NE 'X'.
  ENDIF.

*    CALL FUNCTION 'Z_M_TAXES_PRICING'
*      EXPORTING
*        yebeln = po_code
*      TABLES
*        ytkomv = i_komv.

  CLEAR TT_KOMV.

  CALL FUNCTION 'Z6MM_PO_CAL_TAX'
    EXPORTING
      I_EBELN       = PO_CODE
*    I_EBELP       =
    IMPORTING
      TT_KOMV       = TT_KOMV
            .


  IF NOT TT_KOMV[] IS INITIAL.

    LOOP AT TT_KOMV INTO WA_KOMV.
      MOVE-CORRESPONDING WA_KOMV TO I_KOMV.
      APPEND I_KOMV.
      CLEAR  I_KOMV.
    ENDLOOP.

  ENDIF.

  clear: WA_KOMV_JVCS.
*  ---read jvcs
  READ TABLE I_KOMV INTO WA_KOMV WITH KEY
  KSCHL = 'JVCS'.
  IF SY-SUBRC = 0.
    WA_KOMV_JVCS = WA_KOMV.
    CLEAR WA_KOMV.
  ENDIF.

*    DELETE i_komv WHERE kwert EQ 0
*        OR kschl EQ 'BASB'
*        OR kschl EQ 'JMX1'
*        OR kschl EQ 'JMX2'
*        OR kschl EQ 'JAX1'
*        OR kschl EQ 'JAX2'
*        OR kschl EQ 'JSX1'
*        OR kschl EQ 'JSX2'
*        OR kschl EQ 'JEX1'
*        OR kschl EQ 'JEX2'
*        OR kschl EQ 'JHX1'
*        OR kschl EQ 'JHX2'
*        OR kschl EQ 'NAVS'
*        OR kschl EQ 'NAVM'.

  DELETE I_KOMV WHERE KWERT EQ 0
     OR KSCHL EQ 'JMX1'
     OR KSCHL EQ 'JMX2'
     OR KSCHL EQ 'JAX1'
     OR KSCHL EQ 'JAX2'
     OR KSCHL EQ 'JSX1'
     OR KSCHL EQ 'JSX2'
     OR KSCHL EQ 'JEX1'
     OR KSCHL EQ 'JEX2'
     OR KSCHL EQ 'JHX1'
     OR KSCHL EQ 'JHX2'
     OR KSCHL EQ 'NAVS'
     OR KSCHL EQ 'NAVM'.

  DELETE I_KOMV WHERE KOAID EQ 'A'.
  CLEAR  I_KOMV.

  DELETE I_KONV WHERE KWERT EQ 0
      OR KSCHL EQ 'JEXS'.

  IF WA_LFM1-KALSK = '02'.
    IF WA_LFM1-LIFNR = '0020000367'.
      READ TABLE I_EKPO INDEX 1.
      IF SY-SUBRC = 0.
        IF I_EKPO-WERKS = '1101'.
          DELETE I_KONV WHERE NOT ( KSCHL EQ 'PB00'
              OR   KSCHL EQ 'PBXX'
              OR   KSCHL EQ 'R000'
              OR   KSCHL EQ 'R001'
              OR   KSCHL EQ 'R002'
              OR   KSCHL EQ 'R003'
              OR   KSCHL EQ 'KR00'
              OR   KSCHL EQ 'K000'
              OR   KSCHL EQ 'ZPK1'
              OR   KSCHL EQ 'ZPK2'
              OR   KSCHL EQ 'ZPK3'
              OR   KSCHL EQ 'FRC1'
              ).
        ENDIF.
      ENDIF.
    ELSE.
      DELETE I_KONV WHERE NOT ( KSCHL EQ 'PB00'
          OR   KSCHL EQ 'PBXX'
          OR   KSCHL EQ 'R000'
          OR   KSCHL EQ 'R001'
          OR   KSCHL EQ 'R002'
          OR   KSCHL EQ 'R003'
          OR   KSCHL EQ 'KR00'
          OR   KSCHL EQ 'K000'
          OR   KSCHL EQ 'ZPK1'
          OR   KSCHL EQ 'ZPK2'
          OR   KSCHL EQ 'ZPK3'
          or   kschl eq 'IFR2'
          ).

    ENDIF.
  ENDIF.


ENDFORM.                    " GETDATA_INTO_EKKO_EKPO
*&---------------------------------------------------------------------*
*&      Form  PRINT_SMART_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_SMART_FORM .

  DATA: LF_FM_NAME TYPE RS38L_FNAM.
  READ TABLE I_EKPO INDEX 1.

  READ TABLE I_EKKO INTO WA_EKKO INDEX 1.
  IF SY-SUBRC = 0.

    IF WA_EKKO-BSART = 'ZSTO'.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
              EXPORTING  FORMNAME           = 'Z6MM006S_STOCK_TRANS_ORDER'
*                 variant            = ' '
*                 direct_call        = ' '
               IMPORTING  FM_NAME            = LF_FM_NAME
               EXCEPTIONS NO_FORM            = 1
                          NO_FUNCTION_MODULE = 2
                          OTHERS             = 3.
      CALL FUNCTION LF_FM_NAME
     EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
*   OUTPUT_OPTIONS             =
*   USER_SETTINGS              = 'X'
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
        WA_KOMV_JVCS    = WA_KOMV_JVCS
        TABLES
          X_MDSB                     =  I_MDSB
          X_EKKO                     =  I_EKKO
          X_EKPO                     =  I_EKPO
          X_ML_ESLL                  =  I_ML_ESLL
          X_KONV                     =  I_KONV
          X_KOMV                     =  I_KOMV
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
                .
      IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ELSEIF WA_EKKO-BSART = 'ZIMP'.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
             EXPORTING  FORMNAME           = 'ZMM_IMPORT_PO_GST_SF' "'Z6MM006S_IMPORT_PO_PRINT'
*                 variant            = ' '
*                 direct_call        = ' '
              IMPORTING  FM_NAME            = LF_FM_NAME
              EXCEPTIONS NO_FORM            = 1
                         NO_FUNCTION_MODULE = 2
                         OTHERS             = 3.
      CALL FUNCTION LF_FM_NAME
     EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
*   OUTPUT_OPTIONS             =
*   USER_SETTINGS              = 'X'
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
        WA_KOMV_JVCS    = WA_KOMV_JVCS
        TABLES
          X_MDSB                     =  I_MDSB
          X_EKKO                     =  I_EKKO
          X_EKPO                     =  I_EKPO
          X_ML_ESLL                  =  I_ML_ESLL
          X_KONV                     =  I_KONV
          X_KOMV                     =  I_KOMV
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
                .
      IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ELSE.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING  FORMNAME           = 'ZMM_PURCHASE_ORDER_FORM'
*                 variant            = ' '
*                 direct_call        = ' '
           IMPORTING  FM_NAME            = LF_FM_NAME
           EXCEPTIONS NO_FORM            = 1
                      NO_FUNCTION_MODULE = 2
                      OTHERS             = 3.
      CALL FUNCTION LF_FM_NAME
     EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
*   OUTPUT_OPTIONS             =
*   USER_SETTINGS              = 'X'
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
        WA_KOMV_JVCS    = WA_KOMV_JVCS
        TABLES
          X_MDSB                     =  I_MDSB
          X_EKKO                     =  I_EKKO
          X_EKPO                     =  I_EKPO
          X_ML_ESLL                  =  I_ML_ESLL
          X_KONV                     =  I_KONV
          X_KOMV                     =  I_KOMV
* EXCEPTIONS
*   FORMATTING_ERROR           = 1
*   INTERNAL_ERROR             = 2
*   SEND_ERROR                 = 3
*   USER_CANCELED              = 4
*   OTHERS                     = 5
                .
      IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " PRINT_SMART_FORM

INCLUDE Z6MM006R_PURCHASE_ORDER_ADOF01.

INCLUDE Z6MM006R_PURCHASE_ORDER_FILF01.
