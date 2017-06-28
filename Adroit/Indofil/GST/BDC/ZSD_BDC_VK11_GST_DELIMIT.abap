* Author - Saurabh Khare (Adroit Infotech Pvt. Ltd) *
* Date - Tuesday, June 27, 2017 15:53:38 *

REPORT zsd_bdc_vk11_gst_delimit
       NO STANDARD PAGE HEADING LINE-SIZE 255.

* Include *
INCLUDE bdcrecx1.

* Data Declaration *
* Types *
 TYPES: BEGIN OF ty_tab,
         kschl(20) TYPE c,"a357-kschl,
         aland(20) TYPE c,"a357-aland,
         werks(20) TYPE c,"a357-werks,
         steuc(20) TYPE c,"a357-steuc,
         kbetr(20) TYPE c,"konp-kbetr,
         konwa(20) TYPE c,"konp-konwa,
         datab(20) TYPE c,"a357-datab,
         datbi(20) TYPE c,"a357-datbi,
       END OF ty_tab,

       BEGIN OF ty_tab_salorg,
         kschl(20)    TYPE c,
         vkorgau(20)  TYPE c,
         werks(20)    TYPE c,
         kbetr(20)    TYPE c,
         konwa(20)    TYPE c,
         datab(20)    TYPE c,
         datbi(20)    TYPE c,
       END OF ty_tab_salorg.

* Tables *
DATA: it_tab TYPE TABLE OF ty_tab,
      wa_tab TYPE ty_tab,

      it_temp LIKE it_tab,
      wa_temp LIKE wa_tab,

      it_tab_salorg TYPE TABLE OF ty_tab_salorg,
      wa_tab_salorg TYPE ty_tab_salorg,

      it_temp_salorg LIKE it_tab_salorg,
      wa_temp_salorg LIKE wa_tab_salorg,

      it_a357 TYPE TABLE OF a357,
      wa_a357 TYPE a357,

      it_a056 TYPE TABLE OF a056,
      wa_a056 TYPE a056,

      it_konp TYPE TABLE OF konp,
      wa_konp TYPE konp.

* Variables *
DATA: indx(4)   TYPE c,
      fname(20) TYPE c.

START-OF-SELECTION.

PERFORM get_data.
PERFORM process_data.
IF it_tab[] IS INITIAL AND it_tab_salorg[] IS INITIAL.
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
    FROM a357
    INTO TABLE it_a357
    WHERE kappl EQ 'V'
    AND   kschl IN ('JEAP', 'JEXP', 'JEXT', 'JCET', 'ZCET', 'UTXJ', 'JCED', 'JESP', 'JCEP', 'ZCEP')
    AND   datbi > '20170630'
    AND   datab <= sy-datum.

  IF sy-subrc = 0 AND it_a357[] IS NOT INITIAL.
    SELECT *
      FROM konp
      INTO TABLE it_konp
      FOR ALL ENTRIES IN it_a357
      WHERE knumh = it_a357-knumh
      AND   kappl = it_a357-kappl
      AND   kschl = it_a357-kschl.
  ENDIF.

  SELECT *
    FROM a056
    INTO TABLE it_a056
    WHERE kappl EQ 'V'
    AND   kschl EQ 'ZACD'
    AND   datbi > '20170630'
    AND   datab <= sy-datum.

  IF sy-subrc = 0 AND it_a056[] IS NOT INITIAL.
    SELECT *
      FROM konp
      APPENDING TABLE it_konp
      FOR ALL ENTRIES IN it_a056
      WHERE knumh = it_a056-knumh
      AND   kappl = it_a056-kappl
      AND   kschl = it_a056-kschl.
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
  SORT it_a357 ASCENDING BY knumh.
  SORT it_konp ASCENDING BY knumh.

  IF it_a357[] IS NOT INITIAL AND it_konp[] IS NOT INITIAL.
    LOOP AT it_a357 INTO wa_a357.
      MOVE-CORRESPONDING wa_a357 TO wa_tab.

      CLEAR: wa_tab-datab, wa_tab-datbi.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
       EXPORTING
         date_internal                  = wa_a357-datab
       IMPORTING
         date_external                  = wa_tab-datab
       EXCEPTIONS
         date_internal_is_invalid       = 1
         OTHERS                         = 2
                .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      wa_tab-datbi = '30.06.2017'.

      READ TABLE it_konp INTO wa_konp WITH KEY knumh = wa_a357-knumh BINARY SEARCH.
      IF sy-subrc = 0.
        wa_tab-kbetr = wa_konp-kbetr / 10.
        SHIFT wa_tab-kbetr LEFT DELETING LEADING space.
        wa_tab-konwa = wa_konp-konwa.
      ENDIF.
      APPEND wa_tab TO it_tab.
      CLEAR: wa_tab, wa_a357, wa_konp.
    ENDLOOP.
  ENDIF.

  SORT it_a056[] ASCENDING BY kschl vkorgau.

  IF it_a056[] IS NOT INITIAL AND it_konp[] IS NOT INITIAL.
    LOOP AT it_a056 INTO wa_a056.
      MOVE-CORRESPONDING wa_a056 TO wa_tab_salorg.

      CLEAR: wa_tab_salorg-datab, wa_tab_salorg-datbi.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
       EXPORTING
         date_internal                  = wa_a056-datab
       IMPORTING
         date_external                  = wa_tab_salorg-datab
       EXCEPTIONS
         date_internal_is_invalid       = 1
         OTHERS                         = 2
                .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      wa_tab_salorg-datbi = '30.06.2017'.

      READ TABLE it_konp INTO wa_konp WITH KEY knumh = wa_a056-knumh BINARY SEARCH.
      IF sy-subrc = 0.
        wa_tab_salorg-kbetr = wa_konp-kbetr / 10.
        SHIFT wa_tab_salorg-kbetr LEFT DELETING LEADING space.
        wa_tab_salorg-konwa = wa_konp-konwa.
      ENDIF.
      APPEND wa_tab_salorg TO it_tab_salorg.
      CLEAR: wa_tab_salorg, wa_a056, wa_konp.
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
  IF it_tab[] IS NOT INITIAL.
  REFRESH: it_temp[].

  SORT it_tab ASCENDING BY kschl aland werks.
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
                                  wa_tab-kschl."'JEAP'.

    PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(08)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=WEIT'.
    PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                  ''.
    PERFORM bdc_field       USING 'RV130-SELKZ(08)'
                                  'X'.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1357'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KOMG-WERKS'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KOMG-ALAND'
                                  wa_tab-aland."'IN'.
    PERFORM bdc_field       USING 'KOMG-WERKS'
                                  wa_tab-werks."'1101'.

    LOOP AT it_temp INTO wa_temp
      WHERE kschl = wa_tab-kschl
      AND aland = wa_tab-aland
      AND werks = wa_tab-werks.

      PERFORM bdc_dynpro      USING 'SAPMV13A' '1357'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    fname."'RV13A-DATBI(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=NEWP'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KOMG-STEUC(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KOMG-STEUC(01)'
                                    wa_temp-steuc."'15020000'.

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

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1357'.

    CLEAR: fname.
    SUBTRACT 1 FROM indx.
    SHIFT indx LEFT DELETING LEADING space.
    CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  fname."'RV13A-DATBI(02)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=SICH'.
    PERFORM bdc_transaction USING 'VK11'.

    PERFORM close_group.

    DELETE it_tab WHERE kschl = wa_tab-kschl
                  AND   aland = wa_tab-aland
                  AND   werks = wa_tab-werks.

    DELETE it_temp  WHERE kschl = wa_tab-kschl
                    AND   aland = wa_tab-aland
                    AND   werks = wa_tab-werks.

    CLEAR wa_tab.
  ENDLOOP.
  ENDIF.

  IF it_tab_salorg[] IS NOT INITIAL.
  REFRESH: it_temp_salorg[].

  SORT it_tab_salorg ASCENDING BY kschl vkorgau.
  it_temp_salorg[] = it_tab_salorg[].

  LOOP AT it_tab_salorg INTO wa_tab_salorg.
    CLEAR: indx, fname.
    MOVE 1 TO indx.
    PERFORM open_group.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV13A-KSCHL'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ANTA'.
    PERFORM bdc_field       USING 'RV13A-KSCHL'
                                  wa_tab_salorg-kschl."'ZACD'.

    PERFORM bdc_dynpro      USING 'SAPLV14A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RV130-SELKZ(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=WEIT'.
    PERFORM bdc_field       USING 'RV130-SELKZ(01)'
                                  'X'.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1056'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KOMG-VKORGAU'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KOMG-VKORGAU'
                                  wa_tab_salorg-vkorgau."'1000'.

    LOOP AT it_temp_salorg INTO wa_temp_salorg
      WHERE kschl = wa_tab_salorg-kschl
      AND vkorgau = wa_tab_salorg-vkorgau.

      PERFORM bdc_dynpro      USING 'SAPMV13A' '1056'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    fname."'RV13A-DATBI(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=NEWP'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KOMG-WERKS(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KOMG-WERKS(01)'
                                    wa_temp_salorg-werks."'1101'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KONP-KBETR(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-KBETR(01)'
                                    wa_temp_salorg-kbetr."'            4'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'KONP-KONWA(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'KONP-KONWA(01)'
                                    wa_temp_salorg-konwa."'%'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'RV13A-DATAB(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'RV13A-DATAB(01)'
                                    wa_temp_salorg-datab."'01.03.2015'.

      CLEAR: fname.
      SHIFT indx LEFT DELETING LEADING space.
      CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
      PERFORM bdc_field       USING fname"'RV13A-DATBI(01)'
                                    wa_temp_salorg-datbi."'30.06.2017'.

      ADD 1 TO indx.

      IF indx > 3.
        MOVE 3 TO indx.
      ENDIF.
      SHIFT indx LEFT DELETING LEADING space.

      CLEAR wa_temp_salorg.
    ENDLOOP.

    PERFORM bdc_dynpro      USING 'SAPMV13A' '1056'.

    CLEAR: fname.
    SUBTRACT 1 FROM indx.
    SHIFT indx LEFT DELETING LEADING space.
    CONCATENATE 'RV13A-DATBI(' indx ')' INTO fname.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  fname."'RV13A-DATBI(02)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=SICH'.
    PERFORM bdc_transaction USING 'VK11'.

    PERFORM close_group.

    DELETE it_tab_salorg WHERE kschl = wa_tab_salorg-kschl
                         AND   vkorgau = wa_tab_salorg-vkorgau.

    DELETE it_temp_salorg  WHERE kschl = wa_tab_salorg-kschl
                           AND   vkorgau = wa_tab_salorg-vkorgau.

    CLEAR wa_tab.
  ENDLOOP.
ENDIF.
ENDFORM.
