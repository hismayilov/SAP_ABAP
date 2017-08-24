REPORT z6fi_f_02
       NO STANDARD PAGE HEADING LINE-SIZE 255.
* TCODE: ZFI_BDCF02

INCLUDE zbdcrecx1.
TYPE-POOLS : slis,truxs.


TYPES : BEGIN OF s_upload,

          bldat(10)," type  BKPF-BLDAT,
          bukrs      TYPE bkpf-bukrs,
          budat(10)," type BKPF-BUDAT,
          waers      TYPE bkpf-waers,
          bktxt      TYPE bkpf-bktxt,
          newbs      TYPE rf05a-newbs, "
          newko      TYPE rf05a-newko, "
          newbw      TYPE rf05a-newbw,
          wrbtr(16)," type BSEG-WRBTR,
          bupla      TYPE bseg-bupla, "
          zuonr      TYPE bseg-zuonr, "
          sgtxt      TYPE bseg-sgtxt, "
          newbs2     TYPE rf05a-newbs, "
          newbk      TYPE rf05a-newbk,
          kostl      TYPE cobl-kostl,
          prctr      TYPE cobl-prctr,
          wrbtr2(16)," type BSEG-WRBTR,"
          bupla2     TYPE bseg-bupla, "
          zuonr2     TYPE bseg-zuonr, "
          sgtxt2     TYPE bseg-sgtxt, "
          kostl2     TYPE cobl-kostl,
          prctr2     TYPE cobl-prctr,
          newko2     TYPE rf05a-newko, "
          newbk2     TYPE rf05a-newbk,

        END   OF s_upload .

DATA : i_upload  TYPE STANDARD TABLE OF  s_upload,
       wa_upload TYPE s_upload, wa_up TYPE s_upload  .

DATA:tran_mode.
DATA : v_filename TYPE ibipparms-path.
DATA: it_raw TYPE truxs_t_text_data.

*Data decleration for Error Message
DATA:
  t_msg2      TYPE TABLE OF bdcmsgcoll,   " Collecting Error messages
  w_msg2      TYPE bdcmsgcoll,
  w_msg12(51).


SELECTION-SCREEN BEGIN OF BLOCK s2 WITH FRAME .

PARAMETERS: p_file  TYPE ibipparms-path OBLIGATORY.
*            E_FILE   TYPE RLGRAP-FILENAME .       " Error File Path.

SELECTION-SCREEN END OF BLOCK s2 .

SELECTION-SCREEN BEGIN OF BLOCK s01 WITH FRAME TITLE text-t01.
PARAMETERS:  p_fore  RADIOBUTTON   GROUP rad DEFAULT 'X',
             p_back  RADIOBUTTON   GROUP rad,
             p_noerr RADIOBUTTON   GROUP rad.

SELECTION-SCREEN END OF BLOCK s01.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_FILE '
    IMPORTING
      file_name     = p_file.

  IF NOT p_file IS INITIAL.
    v_filename = p_file.
  ENDIF.

START-OF-SELECTION.


  PERFORM  f_upload.

  IF i_upload IS NOT INITIAL.

    IF p_fore EQ 'X' .
      tran_mode = 'A' .
    ELSEIF p_back EQ 'X' .
      tran_mode = 'E' .
    ELSEIF p_noerr EQ 'X' .
      tran_mode = 'N' .
    ENDIF .
  ENDIF.

  PERFORM upload_data.


*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_upload .
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     *I_FIELD_SEPERATOR   =
      i_line_header        = 'X'
      i_tab_raw_data       = it_raw
      i_filename           = v_filename
    TABLES
      i_tab_converted_data = i_upload
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc = 0.
*  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " F_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_data .
*perform open_group.
  " Flow ---->>> 2 consequent items is one accounting entry, item 1, 3, 5, .... -> Credit, Item 2, 4, 6,... -> Corresponding Debit
  " Screen 1 >> Header(1st line of Excel) >> Account of 1st line item - Credit >> Begin First Accounting Entry(Begin 1st line of excel)
  " Screen 2 >> Amount/Details of 1st line item - credit amount >> Account of 2nd line item - debit(debit corresponding to first credit) >> Popup
  " Screen 3 >> Amount/Details of 2nd line item - debit amount >> End of first accounting entry(End 1st line of excel) >> Account of 3rd line item - Credit >> Popup
  " Note: Due to incorrect recording, for each debit amount entry screen the flow is as follows
  " Amount and other details are entered >> Press Enter >> Popup >> Comback to the same screen >> Enter remaining(next credit acc details) >> Popup again
  " In case of last line(ind GT > lines ->last acc entry), after we enter the debit amount of the last acc entry,
  " do not fill credit acc of next extry, as there's none, but get popup details from current line as usual and then simulate
  " Lastly post

  CLEAR: bdcdata, bdcdata[].
  READ TABLE i_upload INTO wa_upload INDEX 1.       " Data from first line of excel -> First Accounting Entry Begin
  CHECK sy-subrc = 0.
  " Begin First/Initial Screen of F-02, Header data
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBW'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.  " Enter Key
  PERFORM bdc_field       USING 'BKPF-BLDAT'                              wa_upload-bldat."'31.03.2014'.
  PERFORM bdc_field       USING 'BKPF-BLART'                              'SA'.
  PERFORM bdc_field       USING 'BKPF-BUKRS'                              wa_upload-bukrs."'1000'.
  PERFORM bdc_field       USING 'BKPF-BUDAT'                              wa_upload-budat."'31.03.2014'.
  PERFORM bdc_field       USING 'BKPF-MONAT'                              ''.
  PERFORM bdc_field       USING 'BKPF-WAERS'                              'INR'.
  PERFORM bdc_field       USING 'BKPF-BKTXT'                              wa_upload-bktxt."'test1'.
  " Batch input barcode entry section
  PERFORM bdc_field       USING 'FS006-DOCID'                              '*'.
  " Fisrt Line Item Section('Credit to' of 1st acc entry)
  PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_upload-newbs."' '40'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_upload-newko."'44101001'.
  PERFORM bdc_field       USING 'RF05A-NEWBW'                             '100'.
  " End First/Initial Screen of F-02, Header data

  " Begin 2nd screen after enter on first screen, Add GL account item
  " Item 1 Credit entry section
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr."'1000'.
  PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla."'1000'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr."'100 assignment'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt."'100 assignment txt'.
  PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
  " Next(2nd) line item section('Debit to' of 1st acc entry)
  PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_upload-newbs2."''50'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_upload-newko."'44101001'.
  PERFORM bdc_field       USING 'RF05A-NEWBW'                             '100'.
  PERFORM bdc_field       USING 'RF05A-NEWBK'                             wa_upload-newbk."'2000'.
  " End 2nd screen after enter on first screen, Add GL account item

  " Begin Coding block popup on after enter on 2nd screen
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
*perform bdc_field       using 'BDC_CURSOR'                              'COBL-PS_POSID'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
  PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl."'100101001'.
  PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr. "'100101'.
  " End Coding block popup on after enter on 2nd screen

  " Begin 3rd screen after previous enter, Add GL account item
  " Item 2 Debit entry section
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr2."'1000'.
  PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla2."'2000'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr2."'200 assignment'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt2."'200 assignment txt'.
  PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
  " Next line item section
  PERFORM bdc_field       USING 'RF05A-NEWBS'                              ''.
  PERFORM bdc_field       USING 'RF05A-NEWKO'                              ''.
  " End 3rd screen after previous enter, Add GL account item

  " Begin Coding block popup on after enter on 3rd screen
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-SEGMENT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
*perform bdc_field       using 'COBL-ANLN1'                              ''.
  PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
  PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
  " End Coding block popup on after enter on 3rd screen

  " Back to 3rd screen to fill acc details of next line item
  " (which ideally shoudld have been filled above, this is unnecessary repeat call)
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
  PERFORM bdc_field       USING 'BDCREPORT z6fi_f_02
       NO STANDARD PAGE HEADING LINE-SIZE 255.
* TCODE: ZFI_BDCF02

INCLUDE zbdcrecx1.
TYPE-POOLS : slis,truxs.


TYPES : BEGIN OF s_upload,

          bldat(10)," type  BKPF-BLDAT,
          bukrs      TYPE bkpf-bukrs,
          budat(10)," type BKPF-BUDAT,
          waers      TYPE bkpf-waers,
          bktxt      TYPE bkpf-bktxt,
          newbs      TYPE rf05a-newbs, "
          newko      TYPE rf05a-newko, "
          newbw      TYPE rf05a-newbw,
          wrbtr(16)," type BSEG-WRBTR,
          bupla      TYPE bseg-bupla, "
          zuonr      TYPE bseg-zuonr, "
          sgtxt      TYPE bseg-sgtxt, "
          newbs2     TYPE rf05a-newbs, "
          newbk      TYPE rf05a-newbk,
          kostl      TYPE cobl-kostl,
          prctr      TYPE cobl-prctr,
          wrbtr2(16)," type BSEG-WRBTR,"
          bupla2     TYPE bseg-bupla, "
          zuonr2     TYPE bseg-zuonr, "
          sgtxt2     TYPE bseg-sgtxt, "
          kostl2     TYPE cobl-kostl,
          prctr2     TYPE cobl-prctr,
          newko2     TYPE rf05a-newko, "
          newbk2     TYPE rf05a-newbk,

        END   OF s_upload .

DATA : i_upload  TYPE STANDARD TABLE OF  s_upload,
       wa_upload TYPE s_upload, wa_up TYPE s_upload  .

DATA:tran_mode.
DATA : v_filename TYPE ibipparms-path.
DATA: it_raw TYPE truxs_t_text_data.

*Data decleration for Error Message
DATA:
  t_msg2      TYPE TABLE OF bdcmsgcoll,   " Collecting Error messages
  w_msg2      TYPE bdcmsgcoll,
  w_msg12(51).


SELECTION-SCREEN BEGIN OF BLOCK s2 WITH FRAME .

PARAMETERS: p_file  TYPE ibipparms-path OBLIGATORY.
*            E_FILE   TYPE RLGRAP-FILENAME .       " Error File Path.

SELECTION-SCREEN END OF BLOCK s2 .

SELECTION-SCREEN BEGIN OF BLOCK s01 WITH FRAME TITLE text-t01.
PARAMETERS:  p_fore  RADIOBUTTON   GROUP rad DEFAULT 'X',
             p_back  RADIOBUTTON   GROUP rad,
             p_noerr RADIOBUTTON   GROUP rad.

SELECTION-SCREEN END OF BLOCK s01.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_FILE '
    IMPORTING
      file_name     = p_file.

  IF NOT p_file IS INITIAL.
    v_filename = p_file.
  ENDIF.

START-OF-SELECTION.


  PERFORM  f_upload.

  IF i_upload IS NOT INITIAL.

    IF p_fore EQ 'X' .
      tran_mode = 'A' .
    ELSEIF p_back EQ 'X' .
      tran_mode = 'E' .
    ELSEIF p_noerr EQ 'X' .
      tran_mode = 'N' .
    ENDIF .
  ENDIF.

  PERFORM upload_data.


*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_upload .
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     *I_FIELD_SEPERATOR   =
      i_line_header        = 'X'
      i_tab_raw_data       = it_raw
      i_filename           = v_filename
    TABLES
      i_tab_converted_data = i_upload
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc = 0.
*  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " F_UPLOAD
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_data .
*perform open_group.
  " Flow ---->>> 2 consequent items is one accounting entry, item 1, 3, 5, .... -> Credit, Item 2, 4, 6,... -> Corresponding Debit
  " Screen 1 >> Header(1st line of Excel) >> Account of 1st line item - Credit >> Begin First Accounting Entry(Begin 1st line of excel)
  " Screen 2 >> Amount/Details of 1st line item - credit amount >> Account of 2nd line item - debit(debit corresponding to first credit) >> Popup
  " Screen 3 >> Amount/Details of 2nd line item - debit amount >> End of first accounting entry(End 1st line of excel) >> Account of 3rd line item - Credit >> Popup
  " Note: Due to incorrect recording, for each debit amount entry screen the flow is as follows
  " Amount and other details are entered >> Press Enter >> Popup >> Comback to the same screen >> Enter remaining(next credit acc details) >> Popup again
  " In case of last line(ind GT > lines ->last acc entry), after we enter the debit amount of the last acc entry,
  " do not fill credit acc of next extry, as there's none, but get popup details from current line as usual and then simulate
  " Lastly post

  CLEAR: bdcdata, bdcdata[].
  READ TABLE i_upload INTO wa_upload INDEX 1.       " Data from first line of excel -> First Accounting Entry Begin
  CHECK sy-subrc = 0.
  " Begin First/Initial Screen of F-02, Header data
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBW'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.  " Enter Key
  PERFORM bdc_field       USING 'BKPF-BLDAT'                              wa_upload-bldat."'31.03.2014'.
  PERFORM bdc_field       USING 'BKPF-BLART'                              'SA'.
  PERFORM bdc_field       USING 'BKPF-BUKRS'                              wa_upload-bukrs."'1000'.
  PERFORM bdc_field       USING 'BKPF-BUDAT'                              wa_upload-budat."'31.03.2014'.
  PERFORM bdc_field       USING 'BKPF-MONAT'                              ''.
  PERFORM bdc_field       USING 'BKPF-WAERS'                              'INR'.
  PERFORM bdc_field       USING 'BKPF-BKTXT'                              wa_upload-bktxt."'test1'.
  " Batch input barcode entry section
  PERFORM bdc_field       USING 'FS006-DOCID'                              '*'.
  " Fisrt Line Item Section('Credit to' of 1st acc entry)
  PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_upload-newbs."' '40'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_upload-newko."'44101001'.
  PERFORM bdc_field       USING 'RF05A-NEWBW'                             '100'.
  " End First/Initial Screen of F-02, Header data

  " Begin 2nd screen after enter on first screen, Add GL account item
  " Item 1 Credit entry section
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr."'1000'.
  PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla."'1000'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr."'100 assignment'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt."'100 assignment txt'.
  PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
  " Next(2nd) line item section('Debit to' of 1st acc entry)
  PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_upload-newbs2."''50'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_upload-newko."'44101001'.
  PERFORM bdc_field       USING 'RF05A-NEWBW'                             '100'.
  PERFORM bdc_field       USING 'RF05A-NEWBK'                             wa_upload-newbk."'2000'.
  " End 2nd screen after enter on first screen, Add GL account item

  " Begin Coding block popup on after enter on 2nd screen
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
*perform bdc_field       using 'BDC_CURSOR'                              'COBL-PS_POSID'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
  PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl."'100101001'.
  PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr. "'100101'.
  " End Coding block popup on after enter on 2nd screen

  " Begin 3rd screen after previous enter, Add GL account item
  " Item 2 Debit entry section
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr2."'1000'.
  PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla2."'2000'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr2."'200 assignment'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt2."'200 assignment txt'.
  PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
  " Next line item section
  PERFORM bdc_field       USING 'RF05A-NEWBS'                              ''.
  PERFORM bdc_field       USING 'RF05A-NEWKO'                              ''.
  " End 3rd screen after previous enter, Add GL account item

  " Begin Coding block popup on after enter on 3rd screen
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-SEGMENT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
*perform bdc_field       using 'COBL-ANLN1'                              ''.
  PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
  PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
  " End Coding block popup on after enter on 3rd screen

  " Back to 3rd screen to fill acc details of next line item
  " (which ideally shoudld have been filled above, this is unnecessary repeat call)
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr."'1,000.00'.
  PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla2."'2000'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr2."'200 assignment'.
*perform bdc_field       using 'RF05A-XAABG'                              'X'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt2."'200 assignment txt'.
  PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.

  " Next line item section('Credit to' of 2nd acc entry)
  CLEAR:wa_upload.
  READ TABLE i_upload INTO wa_upload INDEX 2.           " Data from 2nd line of excel -> 2nd Accounting Entry Begin
  CHECK sy-subrc = 0.
  PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_upload-newbs."' '40'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_upload-newko." '44101002'.
  PERFORM bdc_field       USING 'RF05A-NEWBW'                              '100'.
  PERFORM bdc_field       USING 'RF05A-NEWBK'                             wa_upload-newbk2. "WA_UPLOAD-BUPLA."NEWBK. " '1000'.
  " End back to 3rd screen to fill acc details of next line item

  " Repeat popup of after 3rd screen
  CLEAR:wa_upload.
  READ TABLE i_upload INTO wa_upload INDEX 1.       " Come back to first line of excel to fill and complete the details of the first acc entry
  CHECK sy-subrc = 0.                               " As noted earlier, this could have been avoided, if the recording had been done properly
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-KOSTL'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
  PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
  PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
*perform bdc_field       using 'COBL-SEGMENT'                              '1'.
  " End Repeat popup of after 3rd screen
  " End 1st Accounting Entry

  DATA: ind TYPE i.  " Index/Indicator
  DATA: lines TYPE i.

  DESCRIBE TABLE i_upload LINES lines.  " Count excel lines

  " Continue from screen 4, 5, 6....
  " (4)credit amount of 2nd acc entry, 'Debit to'(acc details) of 2nd acc entry
  " (5)debit amount of 2nd acc entry >> end 2nd accounting entry >> 'Credit to'(acc details) of 3rd acc entry
  " (6)credit amount of 3rd acc entry, 'Debit to'(acc details) of 3rd acc entry .....and so on
  LOOP AT i_upload INTO wa_upload .  " Process 2...n acc entries, 1st already processed

    IF sy-tabix > 1 AND sy-tabix LE lines.  " skip first line as 1st acc entry has already been posted above and continue till end of excel
      CLEAR: ind.
      ind = sy-tabix.

      " Continue... credit amount of 2nd, 3rd, 4th... acc entry('Credit to' acc already filled above), screen 4, 6, 8... excel line 2, 3, 4...
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr."'1000'.
      PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla."'1000'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr."'100 assignment'.
      PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt."'100 assignment txt'.
      PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
      " Next line item section('Debit to' of 2nd, 3rd, 4th...acc entry)
      PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_upload-newbs2."''50'.
      PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_upload-newko."'44101001'.
      PERFORM bdc_field       USING 'RF05A-NEWBW'                             '100'.
      PERFORM bdc_field       USING 'RF05A-NEWBK'                             wa_upload-newbk."'2000'.
      " End screen 4, 6, 8...

      " Popup after screen 4, 6, 8...
      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
*perform bdc_field       using 'BDC_CURSOR'                              'COBL-PS_POSID'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
      PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl."'100101001'.
      PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr. "'100101'.
      " End popup

      " Continue... Debit amount of 2nd, 3rd, 4th.... acc entry, screen 5, 7, 9....excel line 2, 3, 4....
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWKO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr2."'1000'.
      PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla2."'2000'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr2."'200 assignment'.
      PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt2."'200 assignment txt'.
      PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
      " Next line item section('Credit to' of 3rd, 4th, 5th  acc entry)
      PERFORM bdc_field       USING 'RF05A-NEWBS'                              ''.
      PERFORM bdc_field       USING 'RF05A-NEWKO'                              ''.
      " End screen 5, 7, 9....(Refer to this screen when you come across 'same screen' blow)

      " Popup after screen 5, 7, 9....
      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-SEGMENT'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
*perform bdc_field       using 'COBL-ANLN1'                              ''.
      PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
      PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
      " End popup

      " Same as 1st acc entry=> Back to the same screen to fill up next line acc section which was left blank before popup due to incorrrect recording
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr."'1,000.00'.
      PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla2."'2000'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr2."'200 assignment'.
*perform bdc_field       using 'RF05A-XAABG'                              'X'.
      PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt2."'200 assignment txt'.
      PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
      CLEAR: wa_up.
      ind = ind + 1.  " next line
      IF ind GT lines.  " check if 'last line' has been reached
        " in which case there's no next acc entry,

        " Do not fill next credit to acc details (as there are none - last line)

        " End of back to same screen

        " Note here we are filling details from wa_upload(current line) not wa_up(next line)
        " Popup of same sreen
        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
        PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-KOSTL'.
        PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
        PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
        PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
        " End popup

        " Simulate
        PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
        PERFORM bdc_field       USING 'BDC_OKCODE'                              '=BS'.
        " End Simulate

        " Popup on simulate
        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-KOSTL'.
        PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
        " End popup
      ELSE. " in which case(not last line) read and fill/complete the details of the next acc entry, as done for 1st, 2nd acc entry above
        " (ind = next line) and 'continue with loop'
        READ TABLE i_upload INTO wa_up INDEX ind. " Fill acc details of 'credit to' of next acc entry (next excel line)
        CHECK sy-subrc = 0.
        PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_up-newbs."' '40'.
        PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_up-newko." '44101002'.
        PERFORM bdc_field       USING 'RF05A-NEWBW'                              '100'.
        PERFORM bdc_field       USING 'RF05A-NEWBK'                             wa_up-newbk2. "WA_UP-bupla. " '1000'.
        " End back to same screen

        " Note here we are filling details from wa_upload(current line) not wa_up(next line)
        " Popup of same sreen
        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
        PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-KOSTL'.
        PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
        PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
        PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
        " End popup
      ENDIF.

*perform bdc_field       using 'COBL-SEGMENT'                              '1'.
    ENDIF.
  ENDLOOP.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0701'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '=BU'.

  IF bdcdata IS NOT INITIAL.
    CALL TRANSACTION 'F-02' USING bdcdata MODE tran_mode UPDATE 'S'
        MESSAGES INTO t_msg2 .
  ENDIF.

ENDFORM.                    " UPLOAD_DATA_OKCODE'                              '/00'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr."'1,000.00'.
  PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla2."'2000'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr2."'200 assignment'.
*perform bdc_field       using 'RF05A-XAABG'                              'X'.
  PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt2."'200 assignment txt'.
  PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.

  " Next line item section('Credit to' of 2nd acc entry)
  CLEAR:wa_upload.
  READ TABLE i_upload INTO wa_upload INDEX 2.           " Data from 2nd line of excel -> 2nd Accounting Entry Begin
  CHECK sy-subrc = 0.
  PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_upload-newbs."' '40'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_upload-newko." '44101002'.
  PERFORM bdc_field       USING 'RF05A-NEWBW'                              '100'.
  PERFORM bdc_field       USING 'RF05A-NEWBK'                             wa_upload-newbk2. "WA_UPLOAD-BUPLA."NEWBK. " '1000'.
  " End back to 3rd screen to fill acc details of next line item

  " Repeat popup of after 3rd screen
  CLEAR:wa_upload.
  READ TABLE i_upload INTO wa_upload INDEX 1.       " Come back to first line of excel to fill and complete the details of the first acc entry
  CHECK sy-subrc = 0.                               " As noted earlier, this could have been avoided, if the recording had been done properly
  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-KOSTL'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
  PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
  PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
*perform bdc_field       using 'COBL-SEGMENT'                              '1'.
  " End Repeat popup of after 3rd screen
  " End 1st Accounting Entry

  DATA: ind TYPE i.  " Index/Indicator
  DATA: lines TYPE i.

  DESCRIBE TABLE i_upload LINES lines.  " Count excel lines

  " Continue from screen 4, 5, 6....
  " (4)credit amount of 2nd acc entry, 'Debit to'(acc details) of 2nd acc entry
  " (5)debit amount of 2nd acc entry >> end 2nd accounting entry >> 'Credit to'(acc details) of 3rd acc entry
  " (6)credit amount of 3rd acc entry, 'Debit to'(acc details) of 3rd acc entry .....and so on
  LOOP AT i_upload INTO wa_upload .  " Process 2...n acc entries, 1st already processed

    IF sy-tabix > 1 AND sy-tabix LE lines.  " skip first line as 1st acc entry has already been posted above and continue till end of excel
      CLEAR: ind.
      ind = sy-tabix.

      " Continue... credit amount of 2nd, 3rd, 4th... acc entry('Credit to' acc already filled above), screen 4, 6, 8... excel line 2, 3, 4...
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr."'1000'.
      PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla."'1000'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr."'100 assignment'.
      PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt."'100 assignment txt'.
      PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
      " Next line item section('Debit to' of 2nd, 3rd, 4th...acc entry)
      PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_upload-newbs2."''50'.
      PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_upload-newko."'44101001'.
      PERFORM bdc_field       USING 'RF05A-NEWBW'                             '100'.
      PERFORM bdc_field       USING 'RF05A-NEWBK'                             wa_upload-newbk."'2000'.
      " End screen 4, 6, 8...

      " Popup after screen 4, 6, 8...
      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
*perform bdc_field       using 'BDC_CURSOR'                              'COBL-PS_POSID'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
      PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl."'100101001'.
      PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr. "'100101'.
      " End popup

      " Continue... Debit amount of 2nd, 3rd, 4th.... acc entry, screen 5, 7, 9....excel line 2, 3, 4....
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWKO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr2."'1000'.
      PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla2."'2000'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr2."'200 assignment'.
      PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt2."'200 assignment txt'.
      PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
      " Next line item section('Credit to' of 3rd, 4th, 5th  acc entry)
      PERFORM bdc_field       USING 'RF05A-NEWBS'                              ''.
      PERFORM bdc_field       USING 'RF05A-NEWKO'                              ''.
      " End screen 5, 7, 9....(Refer to this screen when you come across 'same screen' blow)

      " Popup after screen 5, 7, 9....
      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-SEGMENT'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
*perform bdc_field       using 'COBL-ANLN1'                              ''.
      PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
      PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
      " End popup

      " Same as 1st acc entry=> Back to the same screen to fill up next line acc section which was left blank before popup due to incorrrect recording
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'                              wa_upload-wrbtr."'1,000.00'.
      PERFORM bdc_field       USING 'BSEG-BUPLA'                              wa_upload-bupla2."'2000'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'                              wa_upload-zuonr2."'200 assignment'.
*perform bdc_field       using 'RF05A-XAABG'                              'X'.
      PERFORM bdc_field       USING 'BSEG-SGTXT'                              wa_upload-sgtxt2."'200 assignment txt'.
      PERFORM bdc_field       USING 'DKACB-FMORE'                              'X'.
      CLEAR: wa_up.
      ind = ind + 1.  " next line
      IF ind GT lines.  " check if 'last line' has been reached
        " in which case there's no next acc entry,

        " Do not fill next credit to acc details (as there are none - last line)

        " End of back to same screen

        " Note here we are filling details from wa_upload(current line) not wa_up(next line)
        " Popup of same sreen
        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
        PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-KOSTL'.
        PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
        PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
        PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
        " End popup

        " Simulate
        PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBK'.
        PERFORM bdc_field       USING 'BDC_OKCODE'                              '=BS'.
        " End Simulate

        " Popup on simulate
        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-KOSTL'.
        PERFORM bdc_field       USING 'BDC_OKCODE'                              '/00'.
        " End popup
      ELSE. " in which case(not last line) read and fill/complete the details of the next acc entry, as done for 1st, 2nd acc entry above
        " (ind = next line) and 'continue with loop'
        READ TABLE i_upload INTO wa_up INDEX ind. " Fill acc details of 'credit to' of next acc entry (next excel line)
        CHECK sy-subrc = 0.
        PERFORM bdc_field       USING 'RF05A-NEWBS'                             wa_up-newbs."' '40'.
        PERFORM bdc_field       USING 'RF05A-NEWKO'                             wa_up-newko." '44101002'.
        PERFORM bdc_field       USING 'RF05A-NEWBW'                              '100'.
        PERFORM bdc_field       USING 'RF05A-NEWBK'                             wa_up-newbk2. "WA_UP-bupla. " '1000'.
        " End back to same screen

        " Note here we are filling details from wa_upload(current line) not wa_up(next line)
        " Popup of same sreen
        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
        PERFORM bdc_field       USING 'BDC_CURSOR'                              'COBL-KOSTL'.
        PERFORM bdc_field       USING 'BDC_OKCODE'                              '=ENTE'.
        PERFORM bdc_field       USING 'COBL-KOSTL'                              wa_upload-kostl2."'200101001'.
        PERFORM bdc_field       USING 'COBL-PRCTR'                              wa_upload-prctr2. "'200101'.
        " End popup
      ENDIF.

*perform bdc_field       using 'COBL-SEGMENT'                              '1'.
    ENDIF.
  ENDLOOP.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0701'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                              'RF05A-NEWBS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                              '=BU'.

  IF bdcdata IS NOT INITIAL.
    CALL TRANSACTION 'F-02' USING bdcdata MODE tran_mode UPDATE 'S'
        MESSAGES INTO t_msg2 .
  ENDIF.

ENDFORM.                    " UPLOAD_DATA
