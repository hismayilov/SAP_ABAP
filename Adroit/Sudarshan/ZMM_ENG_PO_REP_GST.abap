*======================================================================*
*&      Form process                                                   *
*======================================================================*
FORM process.
...

*************************SERVICE PO - Added by SaurabhK****************************
      IF wa_ekpo-pstyp EQ '9'.
        READ TABLE it_esll INTO wa_esll WITH  KEY packno = wa_ekpo-packno.

        IF sy-subrc EQ 0.

          LOOP AT it_eskl INTO wa_eskl WHERE packno = wa_esll-sub_packno.
            READ TABLE it_serv INTO wa_serv WITH KEY packno = wa_eskl-packno
                                                     introw = wa_eskl-introw.
            IF sy-subrc = 0.
              MOVE-CORRESPONDING wa_serv TO wa_serv_final.
              wa_serv_final-ebelp    = wa_ekpo-ebelp.
              READ TABLE it_asmd INTO wa_asmd WITH KEY asnum = wa_serv-srvpos.
              IF sy-subrc = 0.
                wa_serv_final-hsncod = wa_asmd-taxtariffcode.
              ENDIF.
*              wa_serv_final-extrow   = wa_serv-extrow.
*              wa_serv_final-srvpos   = wa_serv-srvpos.
*              wa_serv_final-ktext1   = wa_serv-ktext1.
*              wa_serv_final-menge    = wa_serv-menge.
*              wa_serv_final-meins    = wa_serv-meins.
*              wa_serv_final-tbtwr    = wa_serv-tbtwr.
*              wa_serv_final-netwr    = wa_serv-netwr.

              APPEND wa_serv_final TO it_serv_final.
              CLEAR: wa_serv, wa_serv_final.
            ENDIF.
            CLEAR: wa_eskl.
          ENDLOOP.
        ENDIF.
      ENDIF.

***********************************SERVICE PO****************************
...
*******************************Additions by SaurabhK*******************************************************
        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JIUG'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-ugrate = wa_komv-kbetr / 10.
          wa_final-ugval =  wa_komv-kwert.
        ENDIF.

        " Non - Deductible
        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JICN'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-ncgrate = wa_komv-kbetr / 10.
          wa_final-ncgval =  wa_komv-kwert.
        ENDIF.

        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JISN'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-nsgrate = wa_komv-kbetr / 10.
          wa_final-nsgval =  wa_komv-kwert.
        ENDIF.

        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JIIN'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-nigrate = wa_komv-kbetr / 10.
          wa_final-nigval =  wa_komv-kwert.
        ENDIF.

        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JIUN'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-nugrate = wa_komv-kbetr / 10.
          wa_final-nugval =  wa_komv-kwert.
        ENDIF.

        " RCM
        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JICR'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-rcgrate = wa_komv-kbetr / 10.
          wa_final-rcgval =  wa_komv-kwert.
        ENDIF.

        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JISR'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-rsgrate = wa_komv-kbetr / 10.
          wa_final-rsgval =  wa_komv-kwert.
        ENDIF.

        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JIIR'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-rigrate = wa_komv-kbetr / 10.
          wa_final-rigval =  wa_komv-kwert.
        ENDIF.

        CLEAR: wa_komv.
        READ TABLE it_komv WITH KEY kschl = 'JIUR'
                                               kposn = wa_ekpo-ebelp
                                               kinak = ''
                                               kstat = '' INTO wa_komv.
        IF sy-subrc = 0.
          wa_final-rugrate = wa_komv-kbetr / 10.
          wa_final-rugval =  wa_komv-kwert.
        ENDIF.
*********************************************************************************************************
...
ENDFORM.                    "PROCESS

*&---------------------------------------------------------------------*
*&      Form  MATSPECS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM matspecs .
  IF it_final[] IS NOT INITIAL.
    REFRESH it_specs[].

    SELECT *
      FROM mapl
      INTO TABLE it_mapl
      FOR ALL ENTRIES IN it_final
      WHERE matnr = it_final-matnr
      AND   werks = it_final-werks
      AND   loekz = space.

    IF sy-subrc = 0.
      SELECT *
        FROM plko
        INTO TABLE it_plko
        FOR ALL ENTRIES IN it_mapl
        WHERE plnty = it_mapl-plnty
        AND   plnal = it_mapl-plnal
        AND   plnnr = it_mapl-plnnr
        AND   loekz = space.

      IF sy-subrc = 0.
        DELETE it_plko[] WHERE verwe NE '5'.

        LOOP AT it_final INTO wa_final.
          LOOP AT it_mapl INTO wa_mapl WHERE matnr = wa_final-matnr AND
                                             werks = wa_final-werks.

            READ TABLE it_plko INTO wa_plko WITH KEY plnty = wa_mapl-plnty
                                                     plnal = wa_mapl-plnal
                                                     plnnr = wa_mapl-plnnr.
            IF sy-subrc = 0.
              REFRESH it_plmk[].
              SELECT *
                FROM plmk
                INTO TABLE it_plmk
                WHERE plnty = wa_plko-plnty AND
                      plnnr = wa_plko-plnnr AND
                      plnkn = wa_plko-plnal AND
                      verwmerkm = space AND
                      loekz NE 'X'.
              IF sy-subrc = 0.
                SORT it_plmk[] BY plnnr merknr gueltigab.
                DELETE ADJACENT DUPLICATES FROM it_plmk[] COMPARING merknr.
                LOOP AT it_plmk INTO wa_plmk.
                  wa_specs-kurztext = wa_plmk-kurztext.
                  IF wa_plmk-steuerkz+2(1) = 'X'.       "Characteristic is Qualitative.
                    PERFORM get_qualitative_data.
                  ELSE.
                    PERFORM get_quantitative_data.
                  ENDIF.
                  MOVE sy-tabix TO wa_specs-srno.
                  wa_specs-matnr = wa_final-matnr.
                  wa_specs-werks = wa_final-werks.

                  APPEND wa_specs TO it_specs.
                  CLEAR: wa_specs, wa_plmk.
                ENDLOOP.
              ENDIF.
              CLEAR: wa_plko.
            ENDIF.
            CLEAR: wa_mapl.
          ENDLOOP.
          CLEAR: wa_final.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  IF it_specs[] IS NOT INITIAL.
    SORT it_specs[] ASCENDING.
    DELETE ADJACENT DUPLICATES FROM it_specs[] COMPARING ALL FIELDS.
  ENDIF.
ENDFORM.                    " MATSPECS

*&---------------------------------------------------------------------*
*&      Form  GET_QUALITATIVE_DATA
*&---------------------------------------------------------------------*
*   Get Data for Qualitatitve Characteristics
*----------------------------------------------------------------------*
FORM get_qualitative_data.
  SELECT SINGLE * FROM qpac INTO wa_qpac WHERE  werks      = wa_plmk-auswmgwrk1 AND
                                                katalogart = wa_plmk-katalgart1 AND
                                                auswahlmge = wa_plmk-auswmenge1 AND
                                                auswirkung <> space.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM qpct INTO wa_qpct WHERE  katalogart = wa_qpac-katalogart AND
                                                  codegruppe = wa_qpac-codegruppe AND
                                                  code       = wa_qpac-code AND
                                                  sprache    = sy-langu AND
                                                  version    = wa_qpac-versionam.
    MOVE wa_qpct-kurztext TO wa_specs-codetext.
  ELSE.
    CLEAR: wa_qpac, wa_qpct.
  ENDIF.
ENDFORM.                               " GET_QUALITATIVE_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_QUANTITATIVE_DATA
*&---------------------------------------------------------------------*
*   Get Data for Quantitatitve Characteristics
*----------------------------------------------------------------------*
FORM get_quantitative_data.

  MOVE:wa_plmk-toleranzun TO wa_specs-toleranzun,
       wa_plmk-toleranzob TO wa_specs-toleranzob,
       wa_plmk-sollwert   TO wa_specs-sollwert,
       wa_plmk-stellen    TO wa_specs-stellen,
       wa_plmk-masseinhsw TO wa_specs-masseinhsw.
ENDFORM.                               " GET_QUANTITATIVE_DATA
