FUNCTION ZBAPI_VENDOR_EXC_UPD.
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
*"     VALUE(RB11_001) LIKE  BDCDATA-FVAL DEFAULT ''
*"     VALUE(RB6_002) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(VALUE_01_003) LIKE  BDCDATA-FVAL
*"     VALUE(J_1IEXCD_01_004) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1IEXRN_01_005) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1IEXRG_01_006) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1IEXDI_01_007) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1ICSTNO_01_008) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1ILSTNO_01_009) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1IPANNO_01_010) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1IEXCIVE_01_011) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1ISSIST_01_012) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1IVTYP_01_013) LIKE  BDCDATA-FVAL OPTIONAL
*"     VALUE(J_1ISERN_01_014) LIKE  BDCDATA-FVAL OPTIONAL
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------

subrc = 0.

perform bdc_nodata      using NODATA.

perform open_group      using GROUP USER KEEP HOLDDATE CTU.

perform bdc_dynpro      using 'SAPMJ1ID' '0200'.
perform bdc_field       using 'BDC_CURSOR'
                              'RB6'.
perform bdc_field       using 'BDC_OKCODE'
                              '=EX'.
perform bdc_field       using 'RB11'
                              RB11_001.
perform bdc_field       using 'RB6'
                              RB6_002.
perform bdc_dynpro      using 'SAPLJ1I0' '0800'.
perform bdc_field       using 'BDC_CURSOR'
                              'J_1IMOVEND-J_1IEXCD(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=POSI'.
perform bdc_dynpro      using 'SAPLSPO4' '0300'.
perform bdc_field       using 'BDC_CURSOR'
                              'SVALD-VALUE(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=FURT'.
perform bdc_field       using 'SVALD-VALUE(01)'
                              VALUE_01_003.
perform bdc_dynpro      using 'SAPLJ1I0' '0800'.
perform bdc_field       using 'BDC_CURSOR'
                              'J_1IMOVEND-J_1ISERN(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SAVE'.
perform bdc_field       using 'J_1IMOVEND-J_1IEXCD(01)'
                              J_1IEXCD_01_004.
perform bdc_field       using 'J_1IMOVEND-J_1IEXRN(01)'
                              J_1IEXRN_01_005.
perform bdc_field       using 'J_1IMOVEND-J_1IEXRG(01)'
                              J_1IEXRG_01_006.
perform bdc_field       using 'J_1IMOVEND-J_1IEXDI(01)'
                              J_1IEXDI_01_007.
perform bdc_field       using 'J_1IMOVEND-J_1ICSTNO(01)'
                              J_1ICSTNO_01_008.
perform bdc_field       using 'J_1IMOVEND-J_1ILSTNO(01)'
                              J_1ILSTNO_01_009.
perform bdc_field       using 'J_1IMOVEND-J_1IPANNO(01)'
                              J_1IPANNO_01_010.
perform bdc_field       using 'J_1IMOVEND-J_1IEXCIVE(01)'
                              J_1IEXCIVE_01_011.
perform bdc_field       using 'J_1IMOVEND-J_1ISSIST(01)'
                              J_1ISSIST_01_012.
perform bdc_field       using 'J_1IMOVEND-J_1IVTYP(01)'
                              J_1IVTYP_01_013.
perform bdc_field       using 'J_1IMOVEND-J_1ISERN(01)'
                              J_1ISERN_01_014.
perform bdc_dynpro      using 'SAPLJ1I0' '0800'.
perform bdc_field       using 'BDC_CURSOR'
                              'J_1IMOVEND-J_1ISERN(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BACK'.
perform bdc_dynpro      using 'SAPMJ1ID' '0200'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EEXIT'.
perform bdc_field       using 'BDC_CURSOR'
                              'EXCISE'.
perform bdc_transaction tables messtab
using                         'J1ID'
                              CTU
                              MODE
                              UPDATE.
if sy-subrc <> 0.
  subrc = sy-subrc.
  " exit.                 " Continue updating next vendor
endif.

perform close_group using     CTU.





ENDFUNCTION.
