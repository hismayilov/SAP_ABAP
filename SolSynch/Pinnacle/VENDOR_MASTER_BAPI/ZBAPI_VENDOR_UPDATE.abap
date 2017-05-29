FUNCTION zbapi_vendor_update.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(T_GENDET) TYPE  ZTTGENDET_UPD
*"     VALUE(T_EXCDET) TYPE  ZTTEXCDET_UPD OPTIONAL
*"     VALUE(T_BANKDET) TYPE  ZTTBANKDET_UPD OPTIONAL
*"     VALUE(T_COMPDET) TYPE  ZTTCOMPDET_UPD OPTIONAL
*"  EXPORTING
*"     VALUE(RETURN) TYPE  ZTTRETURN
*"----------------------------------------------------------------------

  TYPES: BEGIN OF gen,
           vend     TYPE bdc_fval,
           title    TYPE bdc_fval,
           vendname TYPE bdc_fval,
           sort     TYPE bdc_fval,
           telno    TYPE bdc_fval,
           mobno    TYPE bdc_fval,
           faxno    TYPE bdc_fval,
           addr     TYPE bdc_fval,
           addr1    TYPE bdc_fval,
           addr2    TYPE bdc_fval,
           street   TYPE bdc_fval,
           city     TYPE bdc_fval,
           dist     TYPE bdc_fval,
           pin      TYPE bdc_fval,
           email    TYPE bdc_fval,    " xadr6
           state    TYPE bdc_fval,
           country  TYPE bdc_fval,
         END OF gen,

         BEGIN OF excise,
           vend         TYPE bdc_fval,
           pan          TYPE bdc_fval,
           sertaxregno  TYPE bdc_fval,
           excreg       TYPE bdc_fval,
           excdiv       TYPE bdc_fval,
           excrng       TYPE bdc_fval,
           eccno        TYPE bdc_fval,
           censaltaxno  TYPE bdc_fval,
           locsaltaxno  TYPE bdc_fval,
           taxind       TYPE bdc_fval,
           ssistat      TYPE bdc_fval,
           ventyp       TYPE bdc_fval,
         END OF excise,

         BEGIN OF comp,
           vend    TYPE bdc_fval,
           compc   TYPE bdc_fval,
           paymeth TYPE bdc_fval,
         END OF comp.

  DATA: tabix(10)   TYPE c,
        subrc       TYPE sy-subrc,
        messtab     TYPE TABLE OF bdcmsgcoll WITH HEADER LINE,
        wa_return   TYPE bapiret2,
        wa_gendet   LIKE LINE OF t_gendet,
        wa_bankdet  LIKE LINE OF t_bankdet,
        wa_excdet   LIKE LINE OF t_excdet,
        wa_compdet  LIKE LINE OF t_compdet.

  DATA: xlfa1 TYPE TABLE OF gen         WITH HEADER LINE,
        ylfa1 TYPE TABLE OF lfa1        WITH HEADER LINE,
        xlfb1 TYPE TABLE OF comp        WITH HEADER LINE,
        ylfb1 TYPE TABLE OF lfb1        WITH HEADER LINE,
        yadr6 TYPE TABLE OF adr6        WITH HEADER LINE,
        xexc  TYPE TABLE OF excise      WITH HEADER LINE,
        yexc  TYPE TABLE OF j_1imovend  WITH HEADER LINE.

  DATA: bankdata_get TYPE TABLE OF lfbk WITH HEADER LINE,
        bnka_get TYPE TABLE OF bnka WITH HEADER LINE,
        bankdata_add TYPE TABLE OF lfbk WITH HEADER LINE,
        bankdata_change TYPE TABLE OF lfbk WITH HEADER LINE,
        bankmsg TYPE TABLE OF ebpp_messages WITH HEADER LINE.

  DATA: vendor TYPE lfa1-lifnr.

  IF t_gendet[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      INTO TABLE ylfa1
      FOR ALL ENTRIES IN t_gendet
      WHERE lifnr = t_gendet-vend.

    IF sy-subrc = 0.
      SELECT *
        FROM lfb1
        INTO TABLE ylfb1
        FOR ALL ENTRIES IN t_compdet
        WHERE lifnr = t_compdet-vend.

      SELECT *
        FROM adr6
        INTO TABLE yadr6
        FOR ALL ENTRIES IN ylfa1
        WHERE addrnumber = ylfa1-adrnr.

      LOOP AT ylfa1.
        CHECK ylfa1-lifnr IS NOT INITIAL.
        xlfa1-vend      = ylfa1-lifnr.
        xlfa1-title     = ylfa1-anred.
        xlfa1-vendname  = ylfa1-name1.
        xlfa1-telno     = ylfa1-telf1.
        xlfa1-mobno     = ylfa1-telf2.
        xlfa1-faxno     = ylfa1-telfx.
        xlfa1-addr      = ylfa1-name2.
        xlfa1-addr1     = ylfa1-name3.
        xlfa1-addr2     = ylfa1-name4.
        xlfa1-street    = ylfa1-stras.
        xlfa1-city      = ylfa1-ort01.
        xlfa1-dist      = ylfa1-ort02.
        xlfa1-pin       = ylfa1-pstlz.
        xlfa1-state     = ylfa1-regio.
        xlfa1-country   = ylfa1-land1.

        READ TABLE yadr6 WITH KEY addrnumber = ylfa1-adrnr
                                  flgdefault = 'X'.
        IF sy-subrc = 0.
          xlfa1-email = yadr6-smtp_addr.
        ENDIF.

        READ TABLE t_gendet INTO wa_gendet WITH KEY vend = ylfa1-lifnr.
        CHECK wa_gendet-vend IS NOT INITIAL.
        IF sy-subrc = 0.
*          xlfa1-vend      = wa_gendet-vend.
          IF wa_gendet-title IS NOT INITIAL.
            xlfa1-title     = wa_gendet-title.
          ENDIF.
          IF wa_gendet-vendname IS NOT INITIAL.
            xlfa1-vendname  = wa_gendet-vendname.
          ENDIF.
          IF wa_gendet-telno IS NOT INITIAL.
            xlfa1-telno     = wa_gendet-telno.
          ENDIF.
          IF wa_gendet-mobno IS NOT INITIAL.
            xlfa1-mobno     = wa_gendet-mobno.
          ENDIF.
          IF wa_gendet-faxno IS NOT INITIAL.
            xlfa1-faxno     = wa_gendet-faxno.
          ENDIF.
          IF wa_gendet-addr IS NOT INITIAL.
            xlfa1-addr      = wa_gendet-addr.
          ENDIF.
          IF wa_gendet-addr1 IS NOT INITIAL.
            xlfa1-addr1     = wa_gendet-addr1.
          ENDIF.
          IF wa_gendet-addr2 IS NOT INITIAL.
            xlfa1-addr2     = wa_gendet-addr2.
          ENDIF.
          IF wa_gendet-street IS NOT INITIAL.
            xlfa1-street    = wa_gendet-street.
          ENDIF.
          IF wa_gendet-city IS NOT INITIAL.
            xlfa1-city      = wa_gendet-city.
          ENDIF.
          IF wa_gendet-dist IS NOT INITIAL.
            xlfa1-dist      = wa_gendet-dist.
          ENDIF.
          IF wa_gendet-pin IS NOT INITIAL.
            xlfa1-pin       = wa_gendet-pin.
          ENDIF.
          IF wa_gendet-email IS NOT INITIAL.
            xlfa1-email     = wa_gendet-email.
          ENDIF.
          IF wa_gendet-state IS NOT INITIAL.
            xlfa1-state     = wa_gendet-state.
          ENDIF.
          IF wa_gendet-country IS NOT INITIAL.
            xlfa1-country     = wa_gendet-country.
          ENDIF.
        ENDIF.
        APPEND xlfa1.
        CLEAR: xlfa1, ylfa1, yadr6, wa_gendet.
      ENDLOOP.
    ENDIF.

    IF xlfa1[] IS NOT INITIAL.
      LOOP AT xlfa1.
        CHECK xlfa1-vend IS NOT INITIAL.

        vendor = xlfa1-vend.

        CALL FUNCTION 'ZBAPI_VENDOR_UPD'
          EXPORTING
            ctu            = 'X'
            mode           = 'N'
            update         = 'L'
*           GROUP          =
*           USER           =
*           KEEP           =
*           HOLDDATE       =
            nodata         = '/'
            lifnr_001      = xlfa1-vend         " 'VA10001'    " Vendor No.
            d0110_002      = 'X'                               " Gen Data - Address checkbox
            use_zav_004    = 'X'
            title_medi_005 = xlfa1-title                       " 'Mr'         " Title
            name1_006      = xlfa1-vendname                    " 'XYZ Corp.'  " Name1
            name2_007      = xlfa1-addr
            name3_008      = xlfa1-addr1
            name4_009      = xlfa1-addr2
            street_011     = xlfa1-street
            post_code1_012 = xlfa1-pin
            city1_013      = xlfa1-city
            city2_026      = xlfa1-dist
            region_027     = xlfa1-state
            country_028    = xlfa1-country
            tel_number_018 = xlfa1-telno
            mob_number_019 = xlfa1-mobno
            fax_number_020 = xlfa1-faxno
            smtp_addr_021  = xlfa1-email
          IMPORTING
            subrc          = subrc
          TABLES
            messtab        = messtab.

        IF subrc <> 0.
          " Error handling, build return table
          wa_return-type = 'E'.
          wa_return-id = 'ZVENBAPUPD_XK02'.
          wa_return-number = 001.
          wa_return-message_v1 = vendor.

          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = wa_return-type
              cl     = wa_return-id
              number = wa_return-number
              par1   = wa_return-message_v1
            IMPORTING
              return = wa_return.

          IF sy-subrc = 0.
            APPEND wa_return TO return.
          ENDIF.

          CLEAR wa_return.

          LOOP AT messtab WHERE msgtyp = 'E'.
            wa_return-type        = messtab-msgtyp.
            wa_return-id          = messtab-msgid.
            wa_return-number      = messtab-msgnr.
            wa_return-message_v1  = messtab-msgv1.
            wa_return-message_v2  = messtab-msgv2.
            wa_return-message_v3  = messtab-msgv3.
            wa_return-message_v4  = messtab-msgv4.

            CALL FUNCTION 'BALW_BAPIRETURN_GET2'
              EXPORTING
                type   = wa_return-type
                cl     = wa_return-id
                number = wa_return-number
                par1   = wa_return-message_v1
                par2   = wa_return-message_v2
                par3   = wa_return-message_v3
                par4   = wa_return-message_v4
              IMPORTING
                return = wa_return.

            IF sy-subrc = 0.
              CONCATENATE vendor wa_return-message INTO wa_return-message SEPARATED BY space.
              APPEND wa_return TO return.
            ENDIF.

            CLEAR: wa_return, messtab.
          ENDLOOP.
        ELSE.
          wa_return-type = 'S'.
          wa_return-id = 'ZVENBAPUPD_XK02'.
          wa_return-number = 000.
          wa_return-message_v1 = vendor.

          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = wa_return-type
              cl     = wa_return-id
              number = wa_return-number
              par1   = wa_return-message_v1
            IMPORTING
              return = wa_return.

          IF sy-subrc = 0.
            APPEND wa_return TO return.
          ENDIF.

          CLEAR wa_return.
        ENDIF.

        REFRESH messtab[].
        REFRESH bankmsg[].

        CALL FUNCTION 'FIN_AP_AR_GET_BANK'
          EXPORTING
            i_koart      = 'K'
            i_account    = vendor
*           I_XTECH_ACCNO       =
          IMPORTING
            e_returncode = subrc
          TABLES
            e_bankdata   = bankdata_get
            e_bnka       = bnka_get
            t_messages   = bankmsg.

        IF subrc = 0.
          LOOP AT t_bankdet INTO wa_bankdet WHERE vend = vendor.
            tabix = sy-tabix.
            SHIFT tabix LEFT DELETING LEADING space.
            READ TABLE bankdata_get WITH KEY lifnr = wa_bankdet-vend
                                             banks = wa_bankdet-cntkey
                                             bankl = wa_bankdet-bname
                                             bankn = wa_bankdet-accno.
            IF sy-subrc = 0.
              MOVE-CORRESPONDING bankdata_get TO bankdata_change.
              IF wa_bankdet-accno IS NOT INITIAL.
                bankdata_change-bankn = wa_bankdet-accno.
              ENDIF.
              IF wa_bankdet-accname IS NOT INITIAL.
                bankdata_change-koinh = wa_bankdet-accname.
              ENDIF.
              IF wa_bankdet-acctype IS NOT INITIAL.
                bankdata_change-bkont = wa_bankdet-acctype.
              ENDIF.
              IF wa_bankdet-bname IS NOT INITIAL.
                bankdata_change-bankl = wa_bankdet-bname.
              ENDIF.
              IF wa_bankdet-cntkey IS NOT INITIAL.
                bankdata_change-banks = wa_bankdet-cntkey.
              ENDIF.

              REFRESH bankmsg[].

              CALL FUNCTION 'FIN_AP_AR_CHANGE_BANK'
                EXPORTING
                  i_koart           = 'K'
                  i_bankdata_new    = bankdata_change
                  i_bankdata_old    = bankdata_get
                  i_confirm_changes = 'X'
*                 I_CHECKMODUS      = ' '
                IMPORTING
                  e_returncode      = subrc
                TABLES
                  t_messages        = bankmsg.

              READ TABLE bankmsg WITH KEY msgty = 'E' TRANSPORTING NO FIELDS.
              IF sy-subrc = 0.
                wa_return-type = 'E'.
                wa_return-id = 'ZVENBAPUPD_XK02'.
                wa_return-number = 003.
                wa_return-message_v1 = vendor.
                wa_return-message_v2 = tabix.

                CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                  EXPORTING
                    type   = wa_return-type
                    cl     = wa_return-id
                    number = wa_return-number
                    par1   = wa_return-message_v1
                    par2   = wa_return-message_v2
                  IMPORTING
                    return = wa_return.

                IF sy-subrc = 0.
                  APPEND wa_return TO return.
                ENDIF.

                CLEAR wa_return.

                LOOP AT bankmsg WHERE msgty = 'E'.
                  wa_return-type        = bankmsg-msgty.
                  wa_return-id          = bankmsg-msgid.
                  wa_return-number      = bankmsg-msgno.
                  wa_return-message_v1  = bankmsg-msgv1.
                  wa_return-message_v2  = bankmsg-msgv2.
                  wa_return-message_v3  = bankmsg-msgv3.
                  wa_return-message_v4  = bankmsg-msgv4.

                  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                    EXPORTING
                      type   = wa_return-type
                      cl     = wa_return-id
                      number = wa_return-number
                      par1   = wa_return-message_v1
                      par2   = wa_return-message_v2
                      par3   = wa_return-message_v3
                      par4   = wa_return-message_v4
                    IMPORTING
                      return = wa_return.

                  IF sy-subrc = 0.
                    CONCATENATE vendor wa_return-message '- line' tabix INTO wa_return-message SEPARATED BY space.
                    APPEND wa_return TO return.
                  ENDIF.

                  CLEAR: wa_return, bankmsg.
                ENDLOOP.
              ELSE.
                wa_return-type = 'S'.
                wa_return-id = 'ZVENBAPUPD_XK02'.
                wa_return-number = 002.
                wa_return-message_v1 = vendor.
                wa_return-message_v2 = tabix.

                CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                  EXPORTING
                    type   = wa_return-type
                    cl     = wa_return-id
                    number = wa_return-number
                    par1   = wa_return-message_v1
                    par2   = wa_return-message_v2
                  IMPORTING
                    return = wa_return.

                IF sy-subrc = 0.
                  APPEND wa_return TO return.
                ENDIF.

                CLEAR wa_return.
              ENDIF.
            ELSE.
              bankdata_add-mandt = sy-mandt.
              bankdata_add-lifnr = vendor.
              IF wa_bankdet-accno IS NOT INITIAL.
                bankdata_add-bankn = wa_bankdet-accno.
              ENDIF.
              IF wa_bankdet-accname IS NOT INITIAL.
                bankdata_add-koinh = wa_bankdet-accname.
              ENDIF.
              IF wa_bankdet-acctype IS NOT INITIAL.
                bankdata_add-bkont = wa_bankdet-acctype.
              ENDIF.
              IF wa_bankdet-bname IS NOT INITIAL.
                bankdata_add-bankl = wa_bankdet-bname.
              ENDIF.
              IF wa_bankdet-cntkey IS NOT INITIAL.
                bankdata_add-banks = wa_bankdet-cntkey.
              ELSE.
                bankdata_add-banks = 'IN'.
              ENDIF.

              REFRESH bankmsg[].

              CALL FUNCTION 'FIN_AP_AR_ADD_BANK'
                EXPORTING
                  i_koart           = 'K'
                  i_bankdata        = bankdata_add
                  i_confirm_changes = 'X'
*                 I_CHECKMODUS      = ' '
                IMPORTING
                  e_returncode      = subrc
                TABLES
                  t_messages        = bankmsg.

              READ TABLE bankmsg WITH KEY msgty = 'E' TRANSPORTING NO FIELDS.
              IF sy-subrc = 0.
                wa_return-type = 'E'.
                wa_return-id = 'ZVENBAPUPD_XK02'.
                wa_return-number = 003.
                wa_return-message_v1 = vendor.
                wa_return-message_v2 = tabix.

                CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                  EXPORTING
                    type   = wa_return-type
                    cl     = wa_return-id
                    number = wa_return-number
                    par1   = wa_return-message_v1
                    par2   = wa_return-message_v2
                  IMPORTING
                    return = wa_return.

                IF sy-subrc = 0.
                  APPEND wa_return TO return.
                ENDIF.

                CLEAR wa_return.

                LOOP AT bankmsg WHERE msgty = 'E'.
                  wa_return-type        = bankmsg-msgty.
                  wa_return-id          = bankmsg-msgid.
                  wa_return-number      = bankmsg-msgno.
                  wa_return-message_v1  = bankmsg-msgv1.
                  wa_return-message_v2  = bankmsg-msgv2.
                  wa_return-message_v3  = bankmsg-msgv3.
                  wa_return-message_v4  = bankmsg-msgv4.

                  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                    EXPORTING
                      type   = wa_return-type
                      cl     = wa_return-id
                      number = wa_return-number
                      par1   = wa_return-message_v1
                      par2   = wa_return-message_v2
                      par3   = wa_return-message_v3
                      par4   = wa_return-message_v4
                    IMPORTING
                      return = wa_return.

                  IF sy-subrc = 0.
                    CONCATENATE vendor wa_return-message '- line' tabix INTO wa_return-message SEPARATED BY space.
                    APPEND wa_return TO return.
                  ENDIF.

                  CLEAR: wa_return, bankmsg.
                ENDLOOP.
              ELSE.
                wa_return-type = 'S'.
                wa_return-id = 'ZVENBAPUPD_XK02'.
                wa_return-number = 002.
                wa_return-message_v1 = vendor.
                wa_return-message_v2 = tabix.

                CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                  EXPORTING
                    type   = wa_return-type
                    cl     = wa_return-id
                    number = wa_return-number
                    par1   = wa_return-message_v1
                    par2   = wa_return-message_v2
                  IMPORTING
                    return = wa_return.

                IF sy-subrc = 0.
                  APPEND wa_return TO return.
                ENDIF.

                CLEAR wa_return.
              ENDIF.
            ENDIF.
            CLEAR: wa_bankdet, bankdata_get, bankdata_change, bankdata_add.
          ENDLOOP.
        ENDIF.

        IF ylfb1[] IS NOT INITIAL.
          LOOP AT t_compdet INTO wa_compdet WHERE vend = vendor.
            READ TABLE ylfb1 WITH KEY lifnr = wa_compdet-vend
                                      bukrs = wa_compdet-compc.
            IF sy-subrc = 0.
              xlfb1-vend    = ylfb1-lifnr.
              xlfb1-compc   = ylfb1-bukrs.
              xlfb1-paymeth = ylfb1-zwels.
              IF wa_compdet-paymeth IS NOT INITIAL.
                xlfb1-paymeth = wa_compdet-paymeth.
              ENDIF.
              IF xlfb1 IS NOT INITIAL.
                CALL FUNCTION 'ZSOL_VENDOR_PAYMETH'
                  EXPORTING
                    ctu       = 'X'
                    mode      = 'N'
                    update    = 'L'
*                   GROUP     =
*                   USER      =
*                   KEEP      =
*                   HOLDDATE  =
*                   NODATA    = '/'
                    lifnr_001 = xlfb1-vend
                    bukrs_002 = xlfb1-compc
*                   D0215_003 = 'X'
                    zwels_005 = xlfb1-paymeth
                  IMPORTING
                    subrc     = subrc
                  TABLES
                    messtab   = messtab.

                IF subrc <> 0.
                  " Error handling, build return table
                  wa_return-type = 'E'.
                  wa_return-id = 'ZVENBAPUPD_XK02'.
                  wa_return-number = 007.
                  wa_return-message_v1 = vendor.

                  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                    EXPORTING
                      type   = wa_return-type
                      cl     = wa_return-id
                      number = wa_return-number
                      par1   = wa_return-message_v1
                    IMPORTING
                      return = wa_return.

                  IF sy-subrc = 0.
                    APPEND wa_return TO return.
                  ENDIF.

                  CLEAR wa_return.

                  LOOP AT messtab WHERE msgtyp = 'E'.
                    wa_return-type        = messtab-msgtyp.
                    wa_return-id          = messtab-msgid.
                    wa_return-number      = messtab-msgnr.
                    wa_return-message_v1  = messtab-msgv1.
                    wa_return-message_v2  = messtab-msgv2.
                    wa_return-message_v3  = messtab-msgv3.
                    wa_return-message_v4  = messtab-msgv4.

                    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                      EXPORTING
                        type   = wa_return-type
                        cl     = wa_return-id
                        number = wa_return-number
                        par1   = wa_return-message_v1
                        par2   = wa_return-message_v2
                        par3   = wa_return-message_v3
                        par4   = wa_return-message_v4
                      IMPORTING
                        return = wa_return.

                    IF sy-subrc = 0.
                      CONCATENATE vendor wa_return-message INTO wa_return-message SEPARATED BY space.
                      APPEND wa_return TO return.
                    ENDIF.

                    CLEAR: wa_return, messtab.
                  ENDLOOP.
                ELSE.
                  wa_return-type = 'S'.
                  wa_return-id = 'ZVENBAPUPD_XK02'.
                  wa_return-number = 006.
                  wa_return-message_v1 = vendor.

                  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                    EXPORTING
                      type   = wa_return-type
                      cl     = wa_return-id
                      number = wa_return-number
                      par1   = wa_return-message_v1
                    IMPORTING
                      return = wa_return.

                  IF sy-subrc = 0.
                    APPEND wa_return TO return.
                  ENDIF.

                  CLEAR wa_return.
                ENDIF.
              ENDIF.
            ENDIF.
            REFRESH messtab[].
            CLEAR: xlfb1, ylfb1, wa_compdet.
          ENDLOOP.
        ENDIF.

        CLEAR xlfa1.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF t_excdet[] IS NOT INITIAL.
    SELECT *
      FROM j_1imovend
      INTO TABLE yexc
      FOR ALL ENTRIES IN t_excdet
      WHERE lifnr = t_excdet-vend.

    IF sy-subrc = 0.
      LOOP AT yexc.
        CHECK yexc IS NOT INITIAL.
        xexc-vend         = yexc-lifnr.
        xexc-pan          = yexc-j_1ipanno.
        xexc-sertaxregno  = yexc-j_1isern.
        xexc-excreg       = yexc-j_1iexrn.
        xexc-excdiv       = yexc-j_1iexdi.
        xexc-excrng       = yexc-j_1iexrg.
        xexc-eccno        = yexc-j_1iexcd.
        xexc-censaltaxno  = yexc-j_1icstno.
        xexc-locsaltaxno  = yexc-j_1ilstno.
        xexc-taxind       = yexc-j_1iexcive.
        xexc-ssistat      = yexc-j_1issist.
        xexc-ventyp       = yexc-j_1ivtyp.

        READ TABLE t_excdet INTO wa_excdet WITH KEY vend = yexc-lifnr.
        CHECK wa_excdet-vend IS NOT INITIAL.
        IF sy-subrc = 0.
*          xexc-vend         = wa_excdet-vend.
          IF wa_excdet-pan IS NOT INITIAL.
            xexc-pan          = wa_excdet-pan.
          ENDIF.
          IF wa_excdet-sertaxregno IS NOT INITIAL.
            xexc-sertaxregno  = wa_excdet-sertaxregno.
          ENDIF.
          IF wa_excdet-excreg IS NOT INITIAL.
            xexc-excreg       = wa_excdet-excreg.
          ENDIF.
          IF wa_excdet-excdiv IS NOT INITIAL.
            xexc-excdiv       = wa_excdet-excdiv.
          ENDIF.
          IF wa_excdet-excrng IS NOT INITIAL.
            xexc-excrng       = wa_excdet-excrng.
          ENDIF.
          IF wa_excdet-eccno IS NOT INITIAL.
            xexc-eccno        = wa_excdet-eccno.
          ENDIF.
          IF wa_excdet-censaltaxno IS NOT INITIAL.
            xexc-censaltaxno  = wa_excdet-censaltaxno.
          ENDIF.
          IF wa_excdet-locsaltaxno IS NOT INITIAL.
            xexc-locsaltaxno  = wa_excdet-locsaltaxno.
          ENDIF.
          IF wa_excdet-taxind IS NOT INITIAL.
            xexc-taxind       = wa_excdet-taxind.
          ENDIF.
          IF wa_excdet-ssistat IS NOT INITIAL.
            xexc-ssistat      = wa_excdet-ssistat.
          ENDIF.
          IF wa_excdet-ventyp IS NOT INITIAL.
            xexc-ventyp       = wa_excdet-ventyp.
          ENDIF.
        ENDIF.
        APPEND xexc.
        CLEAR xexc.
      ENDLOOP.
    ENDIF.

    IF xexc[] IS NOT INITIAL.
      LOOP AT xexc.
        CHECK xexc-vend IS NOT INITIAL.

        CALL FUNCTION 'ZBAPI_VENDOR_EXC_UPD'
          EXPORTING
            ctu               = 'X'
            mode              = 'N'   " change to N later
            update            = 'L'
*           group             =
*           user              =
*           KEEP              =
*           holddate          =
            nodata            = '/'
            rb11_001          = ''
            rb6_002           = 'X'
            value_01_003      = xexc-vend
            j_1iexcd_01_004   = xexc-eccno
            j_1iexrn_01_005   = xexc-excreg
            j_1iexrg_01_006   = xexc-excrng
            j_1iexdi_01_007   = xexc-excdiv
            j_1icstno_01_008  = xexc-censaltaxno
            j_1ilstno_01_009  = xexc-locsaltaxno
            j_1ipanno_01_010  = xexc-pan
            j_1iexcive_01_011 = xexc-taxind
            j_1issist_01_012  = xexc-ssistat
            j_1ivtyp_01_013   = xexc-ventyp
            j_1isern_01_014   = xexc-sertaxregno
          IMPORTING
            subrc             = subrc
          TABLES
            messtab           = messtab.

        IF subrc <> 0.
          " Error handling, build return table
          wa_return-type = 'E'.
          wa_return-id = 'ZVENBAPUPD_XK02'.
          wa_return-number = 005.
          wa_return-message_v1 = vendor.

          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = wa_return-type
              cl     = wa_return-id
              number = wa_return-number
              par1   = wa_return-message_v1
            IMPORTING
              return = wa_return.

          IF sy-subrc = 0.
            APPEND wa_return TO return.
          ENDIF.

          CLEAR wa_return.

          LOOP AT messtab WHERE msgtyp = 'E'.
            wa_return-type        = messtab-msgtyp.
            wa_return-id          = messtab-msgid.
            wa_return-number      = messtab-msgnr.
            wa_return-message_v1  = messtab-msgv1.
            wa_return-message_v2  = messtab-msgv2.
            wa_return-message_v3  = messtab-msgv3.
            wa_return-message_v4  = messtab-msgv4.

            CALL FUNCTION 'BALW_BAPIRETURN_GET2'
              EXPORTING
                type   = wa_return-type
                cl     = wa_return-id
                number = wa_return-number
                par1   = wa_return-message_v1
                par2   = wa_return-message_v2
                par3   = wa_return-message_v3
                par4   = wa_return-message_v4
              IMPORTING
                return = wa_return.

            IF sy-subrc = 0.
              CONCATENATE vendor wa_return-message INTO wa_return-message SEPARATED BY space.
              APPEND wa_return TO return.
            ENDIF.

            CLEAR: wa_return, messtab.
          ENDLOOP.
        ELSE.
          wa_return-type = 'S'.
          wa_return-id = 'ZVENBAPUPD_XK02'.
          wa_return-number = 004.
          wa_return-message_v1 = vendor.

          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = wa_return-type
              cl     = wa_return-id
              number = wa_return-number
              par1   = wa_return-message_v1
            IMPORTING
              return = wa_return.

          IF sy-subrc = 0.
            APPEND wa_return TO return.
          ENDIF.

          CLEAR wa_return.
        ENDIF.

        REFRESH messtab[].
        CLEAR xexc.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFUNCTION.
