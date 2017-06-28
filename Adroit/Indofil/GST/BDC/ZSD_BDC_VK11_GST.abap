* Author - Saurabh Khare (Adroit Infotech Pvt. Ltd) *
* Date - Tuesday, June 27, 2017 23:42:40 *

REPORT zmm_bdc_mek1_delimit
       NO STANDARD PAGE HEADING LINE-SIZE 255.

* Include *
INCLUDE bdcrecx1.

* Data Declaration *
* Types *
TYPES: BEGIN OF ty_tab,
         kschl(20) TYPE c,
         reswk(20) TYPE c,
         matnr(20) TYPE c,
         kbetr(20) TYPE c,
         konwa(20) TYPE c,
         datab(20) TYPE c,
         datbi(20) TYPE c,
       END OF ty_tab.

* Tables *
DATA: it_tab  TYPE TABLE OF ty_tab,
      wa_tab  TYPE ty_tab,

      it_temp LIKE it_tab,
      wa_temp LIKE wa_tab,

      it_a518 TYPE TABLE OF a518,
      wa_a518 TYPE a518,

      it_konp TYPE TABLE OF konp,
      wa_konp TYPE konp.

* Variables *
DATA: indx(4)   TYPE c,
      fname(20) TYPE c.

START-OF-SELECTION.

  PERFORM get_data.
  PERFORM process_data.
  IF it_tab[] IS INITIAL.
    MESSAGE 'No data found' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    PERFORM bdc.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
  SELECT *
    FROM a518
    INTO TABLE it_a518
    WHERE kappl EQ 'M'
    AND   kschl IN ('STRD', 'ZEX1', 'ZEX2', 'ZEX3')
    AND   datbi > '20170630'
    AND   datab <= sy-datum.

  IF sy-subrc = 0 AND it_a518[] IS NOT INITIAL.
    SELECT *
      FROM konp
      INTO TABLE it_konp
      FOR ALL ENTRIES IN it_a518
      WHERE knumh = it_a518-knumh
      AND   kappl = it_a518-kappl
      AND   kschl = it_a518-kschl.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data .
  SORT it_a518 ASCENDING BY knumh.
  SORT it_konp ASCENDING BY knumh.

  IF it_a518[] IS NOT INITIAL AND it_konp[] IS NOT INITIAL.
    LOOP AT it_a518 INTO wa_a518.
      MOVE-CORRESPONDING wa_a518 TO wa_tab.

      CLEAR: wa_tab-datab, wa_tab-datbi.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = wa_a518-datab
        IMPORTING
          date_external            = wa_tab-datab
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      wa_tab-datbi = '30.06.2017'.

      READ TABLE it_konp INTO wa_konp WITH KEY knumh = wa_a518-knumh BINARY SEARCH.
      IF sy-subrc = 0.
        wa_tab-kbetr = wa_konp-kbetr / 10.
        SHIFT wa_tab-kbetr LEFT DELETING LEADING space.
        wa_tab-konwa = wa_konp-konwa.
      ENDIF.
      APPEND wa_tab TO it_tab.
      CLEAR: wa_tab, wa_a518, wa_konp.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bdc .

  SORT it_tab ASCENDING BY kschl.
  REFRESH it_temp[].
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
                                  wa_tab-kschl."'ZEX1'.

    PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=WEIT'.

    LOOP AT it_temp INTO wa_temp WHERE kschl = wa_tab-kschl.

      PERFORM bdc_dynpro      USING 'SAPMV13A' '1518'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    fname."'RV13A-DATBI(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=NEWP'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KOMG-RESWK(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KOMG-RESWK(01)'
                                    wa_temp-reswk."'1101'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KOMG-MATNR(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KOMG-MATNR(01)'
                                    wa_temp-matnr."'000000000020000001'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KONP-KBETR(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-KBETR(01)'
                                    wa_temp-kbetr."'            12.5'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KONP-KONWA(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-KONWA(01)'
                                    wa_temp-konwa."'%'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'RV13A-DATAB(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'RV13A-DATAB(01)'
                                    wa_temp-datab."'01.03.2015'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'RV13A-DATBI(01)'
                                    wa_temp-datbi."'30.06.2017'.


      ADD 1 TO indx.

      IF indx > 3.
        MOVE 3 TO indx.
      ENDIF.
      SHIFT indx LEFT DELETING LEADING space.

      CLEAR wa_temp.
    ENDLOOP.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1518'.

    CLEAR: fname.
    SUBTRACT 1 FROM indx.
    SHIFT indx LEFT DELETING LEADING space.
    CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  fname."'RV13A-DATBI(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=SICH'.
    PERFORM bdc_transaction USING 'MEK1'.

    PERFORM close_group.

    DELETE it_tab WHERE kschl = wa_tab-kschl.
    DELETE it_temp WHERE kschl = wa_tab-kschl.
    CLEAR: wa_tab.
  ENDLOOP.
ENDFORM.
