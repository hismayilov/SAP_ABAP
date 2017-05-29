FUNCTION ZSOL_VENDOR_PAYMETH.
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
*"     VALUE(LIFNR_001) LIKE  BDCDATA-FVAL
*"     VALUE(BUKRS_002) LIKE  BDCDATA-FVAL
*"     VALUE(D0215_003) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(ZWELS_005) LIKE  BDCDATA-FVAL
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------

subrc = 0.

perform bdc_nodata      using NODATA.

perform open_group      using GROUP USER KEEP HOLDDATE CTU.

perform bdc_dynpro      using 'SAPMF02K' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF02K-D0215'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'RF02K-LIFNR'
                              LIFNR_001.
perform bdc_field       using 'RF02K-BUKRS'
                              BUKRS_002.
perform bdc_field       using 'RF02K-D0215'
                              D0215_003.
perform bdc_dynpro      using 'SAPMF02K' '0215'.
perform bdc_field       using 'BDC_CURSOR'
                              'LFB1-ZWELS'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPDA'.
perform bdc_field       using 'LFB1-ZWELS'
                              ZWELS_005.
perform bdc_transaction tables messtab
using                         'XK02'
                              CTU
                              MODE
                              UPDATE.
if sy-subrc <> 0.
  subrc = sy-subrc.
  exit.
endif.

perform close_group using     CTU.





ENDFUNCTION.
