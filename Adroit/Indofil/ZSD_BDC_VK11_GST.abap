* Author - Saurabh Khare (Adroit Infotech Pvt. Ltd) *
* Date - Monday, June 26, 2017 14:20:27 *

REPORT zsd_bdc_vk11_gst
       NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE bdcrecx1.

* Data Declaration *

* Type - Pools *
TYPE-POOLS: truxs.

* Types *
TYPES: BEGIN OF ty_tab,
        kschl TYPE char20,
        aland TYPE char20,
        wkreg TYPE char20,
        taxk1 TYPE char20,
        taxm1 TYPE char20,  " Skip for JOIG type 2
        regio TYPE char20,
        steuc TYPE char20,  " Skip for JOIG type 2
        matnr TYPE char20,  " Required for JOIG type 2
        kbetr TYPE char20,
        konwa TYPE char20,
        datab TYPE char20,
        datbi TYPE char20,
        mwsk1 TYPE char20,
       END OF ty_tab.

* Tables *
DATA: it_tab TYPE TABLE OF ty_tab,
      wa_tab TYPE ty_tab,

      it_temp LIKE it_tab,
      wa_temp LIKE wa_tab,

      it_joig2 LIKE it_tab,
      wa_joig2 LIKE wa_tab,

      it_raw TYPE truxs_t_text_data.

* Variables *
DATA: indx(4)   TYPE c,
      fname(20) TYPE c.

* Selection Screen *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  PARAMETERS: p_file TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
CALL FUNCTION 'F4_FILENAME'
 EXPORTING
   program_name        = syst-cprog
   dynpro_number       = syst-dynnr
   field_name          = 'P_FILE'
 IMPORTING
   file_name           = p_file.

* Start of selection *
START-OF-SELECTION.
IF p_file IS NOT INITIAL.
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR          =
      i_line_header              = 'X'
      i_tab_raw_data             = it_raw
      i_filename                 = p_file
    TABLES
      i_tab_converted_data       = it_tab
   EXCEPTIONS
     conversion_failed          = 1
     OTHERS                     = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ELSE.
  MESSAGE 'File cannot be empty' TYPE 'S' DISPLAY LIKE 'E'.
  EXIT.
ENDIF.

IF it_tab[] IS NOT INITIAL.
  REFRESH: it_temp[], it_joig2[].

  LOOP AT it_tab INTO wa_tab WHERE matnr IS NOT INITIAL.
    MOVE-CORRESPONDING wa_tab TO wa_joig2.
    APPEND wa_joig2 TO it_joig2.
    DELETE it_tab.
    CLEAR: wa_tab, wa_joig2.
  ENDLOOP.

  SORT it_tab[] ASCENDING BY kschl aland wkreg taxk1 taxm1 regio.
  it_temp[] = it_tab[].

  LOOP AT it_tab INTO wa_tab.
    CLEAR: indx, fname.
    MOVE 1 TO indx.

    PERFORM open_group.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ANTA'.
    PERFORM bdc_field       USING 'RV13A-KSCHL'
                                  wa_tab-kschl."'JOCG'.

    PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(01)'.
    PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                  'X'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=WEIT'.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1768'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KOMG-REGIO'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KOMG-ALAND'
                                  wa_tab-aland."'IN'.
    PERFORM bdc_field       USING 'KOMG-WKREG'
                                  wa_tab-wkreg."'13'.
    PERFORM bdc_field       USING 'KOMG-TAXK1'
                                  wa_tab-taxk1."'0'.
    PERFORM bdc_field       USING 'KOMG-TAXM1'
                                  wa_tab-taxm1."'0'.
    PERFORM bdc_field       USING 'KOMG-REGIO'
                                  wa_tab-regio."'13'.

    LOOP AT it_temp INTO wa_temp  WHERE kschl = wa_tab-kschl
                                  AND   aland = wa_tab-aland
                                  AND   wkreg = wa_tab-wkreg
                                  AND   taxk1 = wa_tab-taxk1
                                  AND   taxm1 = wa_tab-taxm1
                                  AND   regio = wa_tab-regio.

      IF indx >= 10.
        PERFORM bdc_dynpro      USING 'SAPMV13A' '1768'.

        CLEAR: fname.
        MOVE 11 TO indx.
        SHIFT indx LEFT DELETING LEADING space.
        CONCATENATE 'KONP-MWSK1(' indx  ')' INTO fname.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      fname."'KONP-MWSK1(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=P+'.
      ENDIF.

      PERFORM bdc_dynpro      USING 'SAPMV13A' '1768'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KONP-MWSK1(' indx ')' INTO fname.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    fname."'KONP-MWSK1(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=NEWP'.
      CLEAR: fname.
      CONCATENATE 'KOMG-STEUC(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KOMG-STEUC(01)'
                                    wa_temp-steuc."'39069090'.

      CLEAR: fname.
      CONCATENATE 'KOMG-KBSTAT(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KOMG-KBSTAT(01)'
                                    ''.

      CLEAR: fname.
      CONCATENATE 'KONP-KBETR(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-KBETR(01)'
                                    wa_temp-kbetr."'               9'.

      CLEAR: fname.
      CONCATENATE 'KONP-KONWA(' indx ')' INTO fname.
      IF wa_temp-konwa IS INITIAL.
        wa_temp-konwa = '%'.
      ENDIF.
      PERFORM bdc_field       USING fname"'KONP-KONWA(01)'
                                    wa_temp-konwa."'%'.

      CLEAR: fname.
      CONCATENATE 'RV13A-DATAB(' indx ')' INTO fname.
      IF wa_temp-datab IS INITIAL.
        wa_temp-datab = sy-datum.
      ENDIF.
      PERFORM bdc_field       USING fname"'RV13A-DATAB(01)'
                                    wa_temp-datab."'26.06.2017'.

      CLEAR: fname.
      CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
      IF wa_temp-datbi IS INITIAL.
        wa_temp-datbi = '31.12.9999'.
      ENDIF.
      PERFORM bdc_field       USING fname"'RV13A-DATBI(01)'
                                    wa_temp-datbi."'31.12.9999'.

      CLEAR: fname.
      CONCATENATE 'KONP-MWSK1(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-MWSK1(01)'
                                    wa_temp-mwsk1."'HD'.

      IF indx >= 10.
        CLEAR indx.
        MOVE 2 TO indx.
      ENDIF.

      ADD 1 TO indx.
      SHIFT indx LEFT DELETING LEADING space.
      CLEAR wa_temp.
    ENDLOOP.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1768'.

    CLEAR: fname.
    SUBTRACT 1 FROM indx.
    SHIFT indx LEFT DELETING LEADING space.
    CONCATENATE 'KONP-MWSK1(' indx ')' INTO fname.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  fname."'KONP-MWSK1(02)'.

    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=SICH'.
    PERFORM bdc_transaction USING 'VK11'.

    PERFORM close_group.

    DELETE it_tab WHERE kschl = wa_tab-kschl
                  AND   aland = wa_tab-aland
                  AND   wkreg = wa_tab-wkreg
                  AND   taxk1 = wa_tab-taxk1
                  AND   taxm1 = wa_tab-taxm1
                  AND   regio = wa_tab-regio.

    DELETE it_temp  WHERE kschl = wa_tab-kschl
                    AND   aland = wa_tab-aland
                    AND   wkreg = wa_tab-wkreg
                    AND   taxk1 = wa_tab-taxk1
                    AND   taxm1 = wa_tab-taxm1
                    AND   regio = wa_tab-regio.

    CLEAR wa_tab.
  ENDLOOP.

  REFRESH: it_temp[].
  SORT it_joig2[] ASCENDING BY kschl aland wkreg taxk1 regio.
  it_temp[] = it_joig2[].

  LOOP AT it_joig2 INTO wa_joig2.
      CLEAR: indx, fname.
    MOVE 1 TO indx.

    PERFORM open_group.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ANTA'.
    PERFORM bdc_field       USING 'RV13A-KSCHL'
                                  wa_joig2-kschl."'JOIG'.

    PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(01)'.
    PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                  ''.
    PERFORM bdc_field       USING 'RV130-SELKZ(02)'
                                  'X'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=WEIT'.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1777'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KOMG-REGIO'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KOMG-ALAND'
                                  wa_joig2-aland."'IN'.
    PERFORM bdc_field       USING 'KOMG-WKREG'
                                  wa_joig2-wkreg."'13'.
    PERFORM bdc_field       USING 'KOMG-REGIO'
                                  wa_joig2-regio."'13'.
    PERFORM bdc_field       USING 'KOMG-TAXK1'
                                  wa_joig2-taxk1."'0'.

    LOOP AT it_temp INTO wa_temp  WHERE kschl = wa_joig2-kschl
                                  AND   aland = wa_joig2-aland
                                  AND   wkreg = wa_joig2-wkreg
                                  AND   taxk1 = wa_joig2-taxk1
                                  AND   regio = wa_joig2-regio.

      IF indx >= 10.
        PERFORM bdc_dynpro      USING 'SAPMV13A' '1777'.

        CLEAR: fname.
        MOVE 11 TO indx.
        SHIFT indx LEFT DELETING LEADING space.
        CONCATENATE 'KONP-MWSK1(' indx  ')' INTO fname.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      fname."'KONP-MWSK1(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=P+'.
      ENDIF.

      PERFORM bdc_dynpro      USING 'SAPMV13A' '1777'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KONP-MWSK1(' indx ')' INTO fname.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    fname."'KONP-MWSK1(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=NEWP'.
      CLEAR: fname.
      CONCATENATE 'KOMG-MATNR(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KOMG-MATNR(01)'
                                    wa_temp-matnr."'20000096'.

      CLEAR: fname.
      CONCATENATE 'KOMG-KBSTAT(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KOMG-KBSTAT(01)'
                                    ''.

      CLEAR: fname.
      CONCATENATE 'KONP-KBETR(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-KBETR(01)'
                                    wa_temp-kbetr."'               9'.

      CLEAR: fname.
      CONCATENATE 'KONP-KONWA(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-KONWA(01)'
                                    wa_temp-konwa."'INR'.

      CLEAR: fname.
      CONCATENATE 'RV13A-DATAB(' indx ')' INTO fname.
      IF wa_temp-datab IS INITIAL.
        wa_temp-datab = sy-datum.
      ENDIF.
      PERFORM bdc_field       USING fname"'RV13A-DATAB(01)'
                                    wa_temp-datab."'26.06.2017'.

      CLEAR: fname.
      CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
      IF wa_temp-datab IS INITIAL.
        wa_temp-datbi = '31.12.9999'.
      ENDIF.
      PERFORM bdc_field       USING fname"'RV13A-DATBI(01)'
                                    wa_temp-datbi."'31.12.9999'.

      CLEAR: fname.
      CONCATENATE 'KONP-MWSK1(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-MWSK1(01)'
                                    wa_temp-mwsk1."'H3'.

      IF indx >= 10.
        CLEAR indx.
        MOVE 2 TO indx.
      ENDIF.

      ADD 1 TO indx.
      SHIFT indx LEFT DELETING LEADING space.
      CLEAR wa_temp.
    ENDLOOP.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1777'.

    CLEAR: fname.
    SUBTRACT 1 FROM indx.
    SHIFT indx LEFT DELETING LEADING space.
    CONCATENATE 'KONP-MWSK1(' indx ')' INTO fname.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  fname."'KONP-MWSK1(02)'.

    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=SICH'.
    PERFORM bdc_transaction USING 'VK11'.

    PERFORM close_group.

    DELETE it_joig2 WHERE kschl = wa_joig2-kschl
                    AND   aland = wa_joig2-aland
                    AND   wkreg = wa_joig2-wkreg
                    AND   taxk1 = wa_joig2-taxk1
                    AND   regio = wa_joig2-regio.

    DELETE it_temp  WHERE kschl = wa_joig2-kschl
                    AND   aland = wa_joig2-aland
                    AND   wkreg = wa_joig2-wkreg
                    AND   taxk1 = wa_joig2-taxk1
                    AND   regio = wa_joig2-regio.

    CLEAR wa_joig2.
  ENDLOOP.
ENDIF.
