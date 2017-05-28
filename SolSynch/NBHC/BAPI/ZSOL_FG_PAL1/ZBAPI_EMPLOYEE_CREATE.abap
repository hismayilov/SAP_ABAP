FUNCTION ZBAPI_EMPLOYEE_CREATE .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CTU) LIKE  APQI-PUTACTIVE DEFAULT 'X'
*"     VALUE(MODE) LIKE  APQI-PUTACTIVE DEFAULT 'N'
*"     VALUE(UPDATE) LIKE  APQI-PUTACTIVE DEFAULT 'L'
*"     VALUE(GROUP) LIKE  APQI-GROUPID OPTIONAL
*"     VALUE(USER) LIKE  APQI-USERID OPTIONAL
*"     VALUE(KEEP) LIKE  APQI-QERASE OPTIONAL
*"     VALUE(HOLDDATE) LIKE  APQI-STARTDATE OPTIONAL
*"     VALUE(NODATA) LIKE  APQI-PUTACTIVE DEFAULT '/'
*"     VALUE(PERNR_001) LIKE  BDCDATA-FVAL
*"     VALUE(EINDA_002) LIKE  BDCDATA-FVAL
*"     VALUE(SELEC_01_003) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(PERNR_004) LIKE  BDCDATA-FVAL
*"     VALUE(BEGDA_005) LIKE  BDCDATA-FVAL
*"     VALUE(ENDDA_006) LIKE  BDCDATA-FVAL DEFAULT '31.12.9999'
*"     VALUE(MASSN_007) LIKE  BDCDATA-FVAL DEFAULT 'L1'
*"     VALUE(WERKS_008) LIKE  BDCDATA-FVAL DEFAULT '1003'
*"     VALUE(PERSG_009) LIKE  BDCDATA-FVAL DEFAULT '1'
*"     VALUE(PERSK_010) LIKE  BDCDATA-FVAL DEFAULT 'Y1'
*"     VALUE(BEGDA_011) LIKE  BDCDATA-FVAL
*"     VALUE(ENDDA_012) LIKE  BDCDATA-FVAL DEFAULT '31.12.9999'
*"     VALUE(BTRTL_013) LIKE  BDCDATA-FVAL DEFAULT '1010'
*"     VALUE(ABKRS_014) LIKE  BDCDATA-FVAL DEFAULT '99'
*"     VALUE(BEGDA_015) LIKE  BDCDATA-FVAL
*"     VALUE(ENDDA_016) LIKE  BDCDATA-FVAL DEFAULT '31.12.9999'
*"     VALUE(ANREX_017) LIKE  BDCDATA-FVAL
*"     VALUE(NACHN_018) LIKE  BDCDATA-FVAL
*"     VALUE(VORNA_019) LIKE  BDCDATA-FVAL
*"     VALUE(GESCH_020) LIKE  BDCDATA-FVAL DEFAULT '1'
*"     VALUE(SPRSL_021) LIKE  BDCDATA-FVAL DEFAULT 'EN'
*"     VALUE(GBDAT_022) LIKE  BDCDATA-FVAL
*"     VALUE(NATIO_023) LIKE  BDCDATA-FVAL DEFAULT 'IN'
*"     VALUE(BEGDA_024) LIKE  BDCDATA-FVAL
*"     VALUE(ENDDA_025) LIKE  BDCDATA-FVAL DEFAULT '31.12.9999'
*"     VALUE(ORT01_026) LIKE  BDCDATA-FVAL
*"     VALUE(LAND1_027) LIKE  BDCDATA-FVAL DEFAULT 'IN'
*"     VALUE(TELNR_034) LIKE  BDCDATA-FVAL
*"     VALUE(BEGDA_028) LIKE  BDCDATA-FVAL
*"     VALUE(ENDDA_029) LIKE  BDCDATA-FVAL DEFAULT '31.12.9999'
*"     VALUE(VKORG_030) LIKE  BDCDATA-FVAL DEFAULT '1003'
*"     VALUE(BEGDA_031) LIKE  BDCDATA-FVAL
*"     VALUE(ENDDA_032) LIKE  BDCDATA-FVAL DEFAULT '31.12.9999'
*"     VALUE(USRID_LONG_033) LIKE  BDCDATA-FVAL
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------

subrc = 0.

perform bdc_nodata      using NODATA.

perform open_group      using GROUP USER KEEP HOLDDATE CTU.

perform bdc_dynpro      using 'SAPMP50A' '2000'.
perform bdc_field       using 'BDC_CURSOR'
                              'T529T-MNTXT(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_field       using 'RP50G-PERNR'
                              PERNR_001.
perform bdc_field       using 'RP50G-EINDA'
                              EINDA_002.
perform bdc_field       using 'RP50G-SELEC(01)'
                              SELEC_01_003.
perform bdc_dynpro      using 'MP000000' '2000'.
perform bdc_field       using 'BDC_CURSOR'
                              'PSPAR-PERNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPD'.
perform bdc_field       using 'PSPAR-PERNR'
                              PERNR_004.
perform bdc_field       using 'P0000-BEGDA'
                              BEGDA_005.
perform bdc_field       using 'P0000-ENDDA'
                              ENDDA_006.
perform bdc_field       using 'P0000-MASSN'
                              MASSN_007.
perform bdc_field       using 'PSPAR-WERKS'
                              WERKS_008.
perform bdc_field       using 'PSPAR-PERSG'
                              PERSG_009.
perform bdc_field       using 'PSPAR-PERSK'
                              PERSK_010.
perform bdc_dynpro      using 'MP000100' '2000'.
perform bdc_field       using 'BDC_CURSOR'
                              'P0001-ABKRS'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPD'.
perform bdc_field       using 'P0001-BEGDA'
                              BEGDA_011.
perform bdc_field       using 'P0001-ENDDA'
                              ENDDA_012.
perform bdc_field       using 'P0001-BTRTL'
                              BTRTL_013.
perform bdc_field       using 'P0001-ABKRS'
                              ABKRS_014.
perform bdc_dynpro      using 'MP000200' '2040'.
perform bdc_field       using 'BDC_CURSOR'
                              'P0002-GBDAT'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPD'.
perform bdc_field       using 'P0002-BEGDA'
                              BEGDA_015.
perform bdc_field       using 'P0002-ENDDA'
                              ENDDA_016.
perform bdc_field       using 'Q0002-ANREX'
                              ANREX_017.
perform bdc_field       using 'P0002-NACHN'
                              NACHN_018.
perform bdc_field       using 'P0002-VORNA'
                              VORNA_019.
perform bdc_field       using 'P0002-GESCH'
                              GESCH_020.
perform bdc_field       using 'P0002-SPRSL'
                              SPRSL_021.
perform bdc_field       using 'P0002-GBDAT'
                              GBDAT_022.
perform bdc_field       using 'P0002-NATIO'
                              NATIO_023.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '04/04'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_dynpro      using 'MP000600' '2000'.
perform bdc_field       using 'BDC_CURSOR'
                              'P0006-ORT01'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPD'.
perform bdc_field       using 'P0006-BEGDA'
                              BEGDA_024.
perform bdc_field       using 'P0006-ENDDA'
                              ENDDA_025.
perform bdc_field       using 'P0006-ORT01'
                              ORT01_026.
perform bdc_field       using 'P0006-LAND1'
                              LAND1_027.
perform bdc_field       using 'P0006-TELNR'
                              TELNR_034.
perform bdc_dynpro      using 'MP090000' '2000'.
perform bdc_field       using 'BDC_CURSOR'
                              'P0900-BEGDA'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPD'.
perform bdc_field       using 'P0900-BEGDA'
                              BEGDA_028.
perform bdc_field       using 'P0900-ENDDA'
                              ENDDA_029.
perform bdc_field       using 'P0900-VKORG'
                              VKORG_030.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '10/05'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_dynpro      using 'MP010500' '2000'.
perform bdc_field       using 'BDC_CURSOR'
                              'P0105-USRID_LONG'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPD'.
perform bdc_field       using 'P0105-BEGDA'
                              BEGDA_031.
perform bdc_field       using 'P0105-ENDDA'
                              ENDDA_032.
perform bdc_field       using 'P0105-USRID_LONG'
                              USRID_LONG_033.
perform bdc_dynpro      using 'SAPMP50A' '2000'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EBCK'.
perform bdc_field       using 'BDC_CURSOR'
                              'RP50G-PERNR'.
perform bdc_transaction tables messtab
using                         'PAL1'
                              CTU
                              MODE
                              UPDATE.
if sy-subrc <> 0.
  subrc = sy-subrc.
  exit.
endif.

perform close_group using     CTU.





ENDFUNCTION.
INCLUDE BDCRECXY .
