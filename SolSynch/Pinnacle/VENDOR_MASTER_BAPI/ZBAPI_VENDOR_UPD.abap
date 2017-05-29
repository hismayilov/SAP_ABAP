FUNCTION zbapi_vendor_upd.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CTU) LIKE  APQI-PUTACTIVE DEFAULT 'X'
*"     VALUE(MODE) LIKE  APQI-PUTACTIVE DEFAULT 'A'
*"     VALUE(UPDATE) LIKE  APQI-PUTACTIVE DEFAULT 'L'
*"     VALUE(GROUP) LIKE  APQI-GROUPID OPTIONAL
*"     VALUE(USER) LIKE  APQI-USERID OPTIONAL
*"     VALUE(KEEP) LIKE  APQI-QERASE OPTIONAL
*"     VALUE(HOLDDATE) LIKE  APQI-STARTDATE OPTIONAL
*"     VALUE(NODATA) LIKE  APQI-PUTACTIVE DEFAULT '/'
*"     VALUE(LIFNR_001) LIKE  BDCDATA-FVAL
*"     VALUE(D0110_002) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(USE_ZAV_004) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(TITLE_MEDI_005) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(NAME1_006) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(NAME2_007) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(NAME3_008) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(NAME4_009) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(STREET_011) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(POST_CODE1_012) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(CITY1_013) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(CITY2_026) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(REGION_027) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(COUNTRY_028) LIKE  BDCDATA-FVAL DEFAULT 'IN'
*"     VALUE(TEL_NUMBER_018) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(MOB_NUMBER_019) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(FAX_NUMBER_020) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(SMTP_ADDR_021) LIKE  BDCDATA-FVAL OPTIONAL
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------

  subrc = 0.

  PERFORM bdc_nodata      USING nodata.

  PERFORM open_group      USING group user keep holddate ctu.

  PERFORM bdc_dynpro      USING 'SAPMF02K' '0101'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF02K-D0130'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF02K-LIFNR'
                                lifnr_001.
  PERFORM bdc_field       USING 'RF02K-D0110'
                                d0110_002.
  PERFORM bdc_field       USING 'USE_ZAV'
                                use_zav_004.
  PERFORM bdc_dynpro      USING 'SAPMF02K' '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=VW'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'SZA1_D0100-SMTP_ADDR'.
  PERFORM bdc_field       USING 'SZA1_D0100-TITLE_MEDI'
                                title_medi_005.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'
                                name1_006.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'
                                name2_007.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME3'
                                name3_008.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME4'
                                name4_009.
  PERFORM bdc_field       USING 'ADDR1_DATA-STREET'
                                street_011.
  PERFORM bdc_field       USING 'ADDR1_DATA-POST_CODE1'
                                post_code1_012.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'
                                city1_013.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY2'
                                city2_026.
  PERFORM bdc_field       USING 'ADDR1_DATA-REGION'
                                region_027.
  PERFORM bdc_field       USING 'ADDR1_DATA-COUNTRY'
                                country_028.
  PERFORM bdc_field       USING 'SZA1_D0100-TEL_NUMBER'
                                tel_number_018.
  PERFORM bdc_field       USING 'SZA1_D0100-MOB_NUMBER'
                                mob_number_019.
  PERFORM bdc_field       USING 'SZA1_D0100-FAX_NUMBER'
                                fax_number_020.
  PERFORM bdc_field       USING 'SZA1_D0100-SMTP_ADDR'
                                smtp_addr_021.
  PERFORM bdc_transaction TABLES messtab
  USING                         'XK02'
                                ctu
                                mode
                                update.
  IF sy-subrc <> 0.
    subrc = sy-subrc.
    " exit.           " Continue updating next vendor
  ENDIF.

  PERFORM close_group USING     ctu.

ENDFUNCTION.
INCLUDE bdcrecxy .
