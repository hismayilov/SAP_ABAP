*&---------------------------------------------------------------------*
*& Report  ZFOREX_GAINLOSS
*& Created By : Priya(NBS)
*&---------------------------------------------------------------------*
*& Date : 2 April 2013
*&
*&---------------------------------------------------------------------*

REPORT  zforex_gainloss.
TYPE-POOLS: slis.
TABLES: bsak, lfa1, bkpf, bsad,kna1.

DATA: return_tab TYPE STANDARD TABLE OF ddshretval.

****************** Types Declaration ***********************************
TYPES: BEGIN OF ty_bsak,
         bukrs TYPE bsak-bukrs, "company code
         lifnr TYPE bsak-lifnr, " vendor acc no
         augbl TYPE bsak-augbl, " clearing doc no
         gjahr TYPE bsak-gjahr, " fiscal year
         belnr TYPE bsak-belnr, " doc no
         budat TYPE bsak-budat, " posting date
         waers TYPE bsak-waers, " currency key
         xblnr TYPE bsak-xblnr, " ref doc no
         blart TYPE bsak-blart, " doc type
         dmbtr TYPE bsak-dmbtr, " amt in local curr
         wrbtr TYPE bsak-wrbtr, " amt in doc curr
       END OF ty_bsak,

       BEGIN OF ty_lfa1,
          lifnr TYPE lfa1-lifnr,
          name1 TYPE lfa1-name1, " vendor name
       END OF ty_lfa1,

       BEGIN OF ty_bkpf,
          belnr TYPE bkpf-belnr,
          budat TYPE bkpf-budat,
          kursf TYPE bkpf-kursf, " exchange rate
       END OF ty_bkpf,

       BEGIN OF ty_bsad,
          bukrs TYPE bsad-bukrs,
          kunnr TYPE bsad-kunnr,
          augbl TYPE bsad-augbl,
          gjahr TYPE bsad-gjahr,
          belnr TYPE bsad-belnr,
          budat TYPE bsad-budat,
          waers TYPE bsad-waers,
          xblnr TYPE bsad-xblnr,
          blart TYPE bsad-blart,
          dmbtr TYPE bsad-dmbtr,
          wrbtr TYPE bsad-wrbtr,
       END OF ty_bsad,

       BEGIN OF ty_kna1,
         kunnr TYPE kna1-kunnr,
         name1 TYPE kna1-name1,
       END OF ty_kna1,

      BEGIN OF ty_final,
        bukrs TYPE bsak-bukrs, " Company code
        belnr TYPE bsak-belnr, " Invoice no
        xblnr TYPE bsak-xblnr, " Ref no
        party_cd TYPE lfa1-lifnr, " Party code
        name1 TYPE lfa1-name1, " Party name
        budat_inv TYPE bsak-budat, " Invoice date
        waers TYPE bsak-waers, " Doc currency
        inv_doc_amt TYPE bsak-wrbtr,   " Invoice amount
        kursf_bk TYPE bkpf-kursf,       " Booking exc rate
        inv_loc_amt TYPE bsak-dmbtr, " Invoice local amount
        augbl TYPE bsak-augbl,       " Clearing doc
        budat_set TYPE bsak-budat,   " Settlment date
        rec_doc_amt TYPE bsak-wrbtr,   " Doc Recieved amt
        kursf_set TYPE bkpf-kursf,   " Settlment exc rate
        rec_loc_amt TYPE bsak-dmbtr, " Received local amt
        gainloss TYPE bsak-dmbtr,    " Exchange gain/loss
     END OF ty_final.


***************** Internal Table Declaration ****************************

DATA: itab_bsak TYPE TABLE OF ty_bsak,
      itab_lfa1 TYPE TABLE OF ty_lfa1 WITH HEADER LINE,
      itab_bkpf TYPE TABLE OF ty_bkpf,
      itab_bsad TYPE TABLE OF ty_bsad,
      itab_kna1 TYPE TABLE OF ty_kna1 WITH HEADER LINE,
      itab_final TYPE TABLE OF ty_final.

***************** Work Area Declaration *********************************
DATA: wa_bsak TYPE ty_bsak,
      wa_lfa1 TYPE ty_lfa1,
      wa_bkpf TYPE ty_bkpf,
      wa_bsad TYPE ty_bsad,
      wa_kna1 TYPE ty_kna1,
      wa_final TYPE ty_final.



***************** ALV Data Declaration  ****************************
DATA: it_fcat TYPE slis_t_fieldcat_alv,
      it_event TYPE slis_t_event,
      it_header TYPE slis_t_listheader.

DATA: wa_fcat TYPE slis_fieldcat_alv,
      wa_layo TYPE slis_layout_alv,
      wa_event LIKE LINE OF it_event,
      wa_header TYPE slis_listheader.


****************** Selection screen declaration ******************

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.

SELECT-OPTIONS: s_bukrs FOR bsak-bukrs, "no INTERVALS no-EXTENSION.
                s_gjahr FOR bsak-gjahr,
                s_budat FOR bsak-budat,
                s_kunnr  FOR itab_kna1-kunnr MODIF ID int,
                s_lifnr FOR itab_lfa1-lifnr MODIF ID ant.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS: rb_kunnr RADIOBUTTON GROUP rb1 USER-COMMAND int1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(15) text-001.

PARAMETERS: rb_lifnr RADIOBUTTON GROUP rb1 .
SELECTION-SCREEN COMMENT 25(20) text-002.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN END OF BLOCK b1.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.

    IF screen-group1 = 'INT' AND rb_kunnr = 'X'.
      screen-name = 'S_KUNNR'.
      screen-active = 1.
      MODIFY SCREEN.

    ELSEIF screen-group1 = 'INT' AND rb_kunnr = ' '.
      screen-name = 'S_KUNNR'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.


    IF screen-group1 = 'ANT' AND rb_lifnr = 'X'.
      screen-name = 'S_LIFNR'.
      screen-active = 1.
      MODIFY SCREEN.

    ELSEIF screen-group1 = 'ANT' AND rb_lifnr = ' '.
      screen-name = 'S_LIFNR'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

START-OF-SELECTION.

  PERFORM header.
  PERFORM fetch_data.
  PERFORM append_data.
  PERFORM display_data.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM header.

  DATA: w_str1 TYPE string,
        w_str3 TYPE string,

        dat_low(10) TYPE c,
        dat_high(10) TYPE c,

        fis_low(4) TYPE c,
        fis_high(4) TYPE c.



  CLEAR wa_header.

  REFRESH it_header.

  wa_header-typ = 'H'.
  wa_header-info = 'On Time International Logistics Private Limited'.
  APPEND wa_header TO it_header.
  CLEAR wa_header.

  wa_header-typ = 'S'.
  wa_header-info = 'Atual Exchange(Gain/Loss)'.
  APPEND wa_header TO it_header.
  CLEAR wa_header.

  IF s_budat IS NOT INITIAL OR s_gjahr EQ ' '.

    w_str1 = 'From Date'.
    CONCATENATE s_budat-low+6(2) '/' s_budat-low+4(2) '/' s_budat-low(4) INTO dat_low.
    CONCATENATE s_budat-high+6(2) '/' s_budat-high+4(2) '/' s_budat-high(4) INTO dat_high.

    wa_header-typ = 'S'.
    CONCATENATE w_str1 dat_low 'To' dat_high '.' INTO wa_header-info SEPARATED BY space.
    APPEND wa_header TO it_header.
    CLEAR wa_header.

  ELSEIF  s_budat IS NOT INITIAL and s_gjahr is not INITIAL.

    w_str1 = 'From Date'.
    CONCATENATE s_budat-low+6(2) '/' s_budat-low+4(2) '/' s_budat-low(4) INTO dat_low.
    CONCATENATE s_budat-high+6(2) '/' s_budat-high+4(2) '/' s_budat-high(4) INTO dat_high.

    wa_header-typ = 'S'.
    CONCATENATE w_str1 dat_low 'To' dat_high '.' INTO wa_header-info SEPARATED BY space.
    APPEND wa_header TO it_header.
    CLEAR wa_header.

  ELSEIF  s_gjahr IS NOT INITIAL OR s_budat EQ ' '.
    w_str1 = 'For Fiscal Year 01/04/'.
    wa_header-typ = 'S'.
    IF s_gjahr-high EQ ' '.

      s_gjahr-high = s_gjahr-low(4) + 1.
    ELSE.
      CONCATENATE w_str1 s_gjahr-low 'To 31/03/' s_gjahr-high '.' INTO wa_header-info.
    ENDIF.
    APPEND wa_header TO it_header.
    CLEAR wa_header.

  ENDIF.




  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary       = it_header
*   I_LOGO                   =
*   I_END_OF_LIST_GRID       =
*   I_ALV_FORM               =
            .

ENDFORM.                    "HEADER

*&---------------------------------------------------------------------*
*&      Form  fetch_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fetch_data.

  IF rb_lifnr = 'X'.

    SELECT bukrs lifnr augbl gjahr belnr budat waers xblnr blart dmbtr wrbtr
      FROM bsak INTO CORRESPONDING FIELDS OF TABLE itab_bsak
      WHERE bukrs IN s_bukrs
      AND gjahr IN s_gjahr
      AND budat IN s_budat
      AND lifnr IN s_lifnr
      AND blart = 'KR'
      AND waers NE 'INR'.

    SELECT lifnr name1 FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE itab_lfa1
      FOR ALL ENTRIES IN itab_bsak
      WHERE lifnr = itab_bsak-lifnr.

    SELECT belnr budat kursf FROM bkpf
      INTO CORRESPONDING FIELDS OF TABLE itab_bkpf
      FOR ALL ENTRIES IN itab_bsak
      WHERE ( belnr = itab_bsak-belnr
      OR belnr = itab_bsak-augbl )
      AND bukrs = itab_bsak-bukrs.

    SORT itab_bsak BY belnr lifnr.
    SORT itab_lfa1 BY lifnr.
    SORT itab_bkpf BY belnr.

    LOOP AT itab_bsak INTO wa_bsak.
      wa_final-bukrs = wa_bsak-bukrs.
      wa_final-party_cd = wa_bsak-lifnr.
      wa_final-belnr = wa_bsak-belnr.
      wa_final-xblnr = wa_bsak-xblnr.
      wa_final-budat_inv = wa_bsak-budat.
      wa_final-waers = wa_bsak-waers.
      wa_final-inv_doc_amt = wa_bsak-wrbtr.
      wa_final-inv_loc_amt = wa_bsak-dmbtr.
      wa_final-augbl = wa_bsak-augbl.
*      wa_final-budat_set = wa_bsak-budat.
      wa_final-rec_doc_amt = wa_bsak-wrbtr.
*      wa_final-rec_loc_amt = wa_bsak-dmbtr.

      READ TABLE itab_lfa1 INTO wa_lfa1 WITH KEY lifnr = wa_final-party_cd BINARY SEARCH.
      wa_final-name1 = wa_lfa1-name1.


      READ TABLE itab_bkpf INTO wa_bkpf WITH KEY belnr =  wa_final-belnr BINARY SEARCH.
      wa_final-kursf_bk = wa_bkpf-kursf.

      READ TABLE itab_bkpf INTO wa_bkpf WITH KEY  belnr = wa_final-augbl BINARY SEARCH.
      wa_final-budat_set = wa_bkpf-budat.
      wa_final-kursf_set = wa_bkpf-kursf.


      wa_final-rec_loc_amt = wa_final-rec_doc_amt * wa_final-kursf_set .

      wa_final-gainloss = wa_final-inv_loc_amt - wa_final-rec_loc_amt.
      APPEND wa_final TO itab_final.
      CLEAR wa_final.

    ENDLOOP.

  ELSEIF rb_kunnr = 'X'.

    SELECT bukrs kunnr augbl gjahr belnr budat waers xblnr blart dmbtr wrbtr
      FROM bsad INTO TABLE itab_bsad
      WHERE bukrs IN s_bukrs
      AND gjahr IN s_gjahr
      AND budat IN s_budat
      AND kunnr IN s_kunnr
      AND blart = 'DR'
      AND waers NE 'INR'.

    SELECT kunnr name1 FROM kna1
      INTO TABLE itab_kna1
      FOR ALL ENTRIES IN itab_bsad
      WHERE kunnr = itab_bsad-kunnr.

    SELECT belnr budat kursf FROM bkpf
       INTO TABLE itab_bkpf
       FOR ALL ENTRIES IN itab_bsad
       WHERE ( belnr = itab_bsad-belnr
       OR belnr = itab_bsad-augbl )
      AND bukrs = itab_bsad-bukrs.

    SORT itab_bsad BY belnr kunnr.
    SORT itab_kna1 BY kunnr.
    SORT itab_bkpf BY belnr.

    LOOP AT itab_bsad INTO wa_bsad.
      wa_final-bukrs = wa_bsad-bukrs.
      wa_final-party_cd = wa_bsad-kunnr.
      wa_final-belnr = wa_bsad-belnr.
      wa_final-xblnr = wa_bsad-xblnr.
      wa_final-budat_inv = wa_bsad-budat.
      wa_final-waers = wa_bsad-waers.
      wa_final-inv_doc_amt = wa_bsad-wrbtr.
      wa_final-inv_loc_amt = wa_bsad-dmbtr.
      wa_final-augbl = wa_bsad-augbl.
*      wa_final-budat_set = wa_bsad-budat.
      wa_final-rec_doc_amt = wa_bsad-wrbtr.
*      wa_final-rec_loc_amt = wa_bsad-dmbtr.

      READ TABLE itab_kna1 INTO wa_kna1 WITH KEY kunnr = wa_final-party_cd BINARY SEARCH.
      wa_final-name1 = wa_kna1-name1.

      READ TABLE itab_bkpf INTO wa_bkpf WITH KEY belnr =  wa_final-belnr BINARY SEARCH.
      wa_final-kursf_bk = wa_bkpf-kursf.

      READ TABLE itab_bkpf INTO wa_bkpf WITH KEY  belnr = wa_final-augbl BINARY SEARCH.
      wa_final-budat_set = wa_bkpf-budat.
      wa_final-kursf_set = wa_bkpf-kursf.


      wa_final-rec_loc_amt = wa_final-rec_doc_amt * wa_final-kursf_set .


      wa_final-gainloss = wa_final-inv_loc_amt - wa_final-rec_loc_amt.
      APPEND wa_final TO itab_final.
      CLEAR wa_final.

    ENDLOOP.

  ENDIF.

ENDFORM.                    "fetch_data


*&---------------------------------------------------------------------*
*&      Form  append_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM append_data.

  wa_fcat-fieldname = 'BUKRS'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Company Code'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'BELNR'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Invoice No'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'XBLNR'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Reference Doc No'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'PARTY_CD'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Party Code'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'NAME1'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Party Name'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'BUDAT_INV'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Date of Invoice'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'WAERS'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Document Currency'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'INV_DOC_AMT'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Invoice Amt'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'KURSF_BK'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Booking Ex Rate'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.


  wa_fcat-fieldname = 'INV_LOC_AMT'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Invoice Amt in INR'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'AUGBL'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Clearing Document'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'BUDAT_SET'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Date of Receipt'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'REC_DOC_AMT'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Received Amt'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'KURSF_SET'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Exchange Rate'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'REC_LOC_AMT'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Received Amt in INR'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_fcat-fieldname = 'GAINLOSS'.
  wa_fcat-tabname = 'ITAB_FINAL'.
  wa_fcat-seltext_l = 'Exchange(Gain/Loss)'.
  wa_fcat-do_sum = 'X'.
  APPEND wa_fcat TO it_fcat.
  CLEAR wa_fcat.

  wa_event-name = 'TOP_OF_PAGE'.
  wa_event-form = 'HEADER'.
  APPEND wa_event TO it_event.

ENDFORM.                    "append_data


*&---------------------------------------------------------------------*
*&      Form  display_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_data.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
     i_callback_program                = sy-repid
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
*    IS_LAYOUT                         = wa_layo
    it_fieldcat                       = it_fcat[]
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
    it_events                         = it_event
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
      t_outtab                          = itab_final[]
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    "display_data
