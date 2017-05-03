*---- POF1 Upload Prog. ----*
*---- Author: SaurabhK for Solsynch Technologies ----*
*---- Description: BDC for POf1 (pack. instr.) upload ---- *

REPORT ztest_pof1
       NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE bdcrecx1.

TYPE-POOLS: slis.

TYPES: BEGIN OF ty_data,
         matnr(40) TYPE c,
       END OF ty_data.

DATA: it_data TYPE TABLE OF ty_data,
      wa_data TYPE ty_data,

      it_raw  TYPE truxs_t_text_data.

DATA: indx(4)   TYPE c,
      fname(20) TYPE c.

SELECTION-SCREEN BEGIN OF BLOCK b1.
PARAMETERS: file TYPE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'FILE'
    IMPORTING
      file_name     = file.

INITIALIZATION.
  indx = 1.

START-OF-SELECTION.

  IF file IS NOT INITIAL.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = 'X'
        i_line_header        = 'X'
        i_tab_raw_data       = it_raw
        i_filename           = file
      TABLES
        i_tab_converted_data = it_data
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.

  PERFORM open_group.

  PERFORM bdc_dynpro      USING 'SAPMV13P' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'P000-KSCHL'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'P000-KSCHL'
                                'SHIP'.
  PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(03)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM bdc_field       USING 'RV130-SELKZ(03)'
                                'X'.
  PERFORM bdc_dynpro      USING 'SAPMV13P' '1001'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KONDP-PACKNR(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'P000-DATAB'
                                '02.05.2017'. " Verify upload(valid from) Date
  PERFORM bdc_field       USING 'P000-DATBI'
                                '31.12.9999'.
* ---- Loop for Table Control ---- *
  LOOP AT it_data INTO wa_data.
    CLEAR: fname.
    SHIFT indx LEFT DELETING LEADING space.
    CONCATENATE 'KOMGP-MATNR(' indx ')' INTO fname. " 'KOMGP-MATNR(1)', 'KOMGP-MATNR(2)', 'KOMGP-MATNR(3)' ...
    PERFORM bdc_field       USING fname
                                  wa_data-matnr.
    CLEAR: fname.
    CONCATENATE 'KONDP-PACKNR(' indx ')' INTO fname. " 'KONDP-PACKNR(1)', 'KONDP-PACKNR(2)', 'KONDP-PACKNR(3)'...
    PERFORM bdc_field       USING fname
                                  'COMMON'.
    PERFORM bdc_dynpro      USING 'SAPMV13P' '1001'.

    indx = indx + 1.  " Go to next line in table control
    SHIFT indx LEFT DELETING LEADING space.
    CONCATENATE 'KONDP-PACKNR(' indx ')' INTO fname.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  fname.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    CLEAR: wa_data.
  ENDLOOP.
* ---- Endloop ---- *
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM bdc_transaction USING 'POF1'.

  PERFORM close_group.
