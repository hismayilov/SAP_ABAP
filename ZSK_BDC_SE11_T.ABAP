report ZSK_BDC_SE11
       no standard page heading line-size 255.

TABLES: ZSAURABH_BDCTAB.

TYPE-POOLS: TRUXS.

TYPES: BEGIN OF TY_TAB,
        MATNR TYPE ZSAURABH_BDCTAB-MATNR,
        MTART TYPE ZSAURABH_BDCTAB-MTART,
        MBRSH TYPE ZSAURABH_BDCTAB-MBRSH,
        MEINS TYPE ZSAURABH_BDCTAB-MEINS,
        SPART TYPE ZSAURABH_BDCTAB-SPART,
      END OF TY_TAB.

DATA: IT_TAB TYPE TABLE OF TY_TAB,
      WA_TAB LIKE LINE OF IT_TAB.

DATA: IT_DATA TYPE TRUXS_T_TEXT_DATA.

DATA: IT_ERROR TYPE TABLE OF BDCMSGCOLL,
      WA_ERROR LIKE LINE OF IT_ERROR.

DATA: BDCDATA TYPE TABLE OF BDCDATA WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
    PARAMETERS: P_FILE TYPE RLGRAP-FILENAME.
SELECTION-SCREEN END OF BLOCK B1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

 CALL FUNCTION 'F4_FILENAME'
 EXPORTING
   PROGRAM_NAME        = SYST-CPROG
   DYNPRO_NUMBER       = SYST-DYNNR
   FIELD_NAME          = 'P_FILE'
 IMPORTING
   FILE_NAME           = P_FILE
            .
  IF P_FILE IS NOT INITIAL.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
       I_FIELD_SEPERATOR          = 'X'
       I_LINE_HEADER              = 'X'
       I_TAB_RAW_DATA             = IT_DATA
       I_FILENAME                 = P_FILE
      TABLES
       I_TAB_CONVERTED_DATA       = IT_TAB
     EXCEPTIONS
       CONVERSION_FAILED          = 1
       OTHERS                     = 2
              .
    IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
 " IF FVAL <> NODATA.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
 " ENDIF.
ENDFORM.


" include bdcrecx1.

start-of-selection.

LOOP AT IT_TAB INTO WA_TAB.

  REFRESH BDCDATA.
" perform open_group.

perform bdc_dynpro      using 'SAPMSRD0' '0102'.
perform bdc_field       using 'BDC_CURSOR'
                              'RSRD1-ENQU_VAL'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SHOW'.
perform bdc_field       using 'RSRD1-TBMA'
                              'X'.
perform bdc_field       using 'RSRD1-TBMA_VAL'
                              'ZSAURABH_BDCTAB'.
perform bdc_dynpro      using 'SAPLSD41' '2200'.
perform bdc_field       using 'BDC_CURSOR'
                              'DD02D-TABCLTEXT'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TDED'.
perform bdc_dynpro      using '/1BCDWB/DBZSAURABH_BDCTAB' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'ZSAURABH_BDCTAB-SPART'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SAVE'.
perform bdc_field       using 'ZSAURABH_BDCTAB-MATNR'
                               WA_TAB-MATNR." '1'.
perform bdc_field       using 'ZSAURABH_BDCTAB-MTART'
                               WA_TAB-MTART." 'FERT'.
perform bdc_field       using 'ZSAURABH_BDCTAB-MBRSH'
                               WA_TAB-MBRSH." 'M'.
perform bdc_field       using 'ZSAURABH_BDCTAB-MEINS'
                               WA_TAB-MEINS." 'EA'.
perform bdc_field       using 'ZSAURABH_BDCTAB-SPART'
                               WA_TAB-SPART." 'NK'.
perform bdc_dynpro      using '/1BCDWB/DBZSAURABH_BDCTAB' '0101'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EBACK'.
perform bdc_field       using 'BDC_CURSOR'
                              'ZSAURABH_BDCTAB-MATNR'.
perform bdc_dynpro      using 'SAPLSD41' '2200'.
perform bdc_field       using 'BDC_CURSOR'
                              'DD02D-TABCLTEXT'.
perform bdc_field       using 'BDC_OKCODE'
                              '=WB_BACK'.
perform bdc_dynpro      using 'SAPMSRD0' '0102'.
perform bdc_field       using 'BDC_CURSOR'
                              'RSRD1-TBMA_VAL'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BACK'.
perform bdc_field       using 'RSRD1-TBMA'
                              'X'.
perform bdc_field       using 'RSRD1-TBMA_VAL'
                              'ZSAURABH_BDCTAB'.
" perform bdc_transaction using 'SE11'.

" perform close_group.

CALL TRANSACTION 'SE11' USING BDCDATA MODE 'A' UPDATE 'S' MESSAGES INTO IT_ERROR.
ENDLOOP.

LOOP AT IT_ERROR INTO WA_ERROR WHERE MSGTYP EQ 'E'.

CALL FUNCTION 'MESSAGE_TEXT_BUILD'
  EXPORTING
    MSGID                     = WA_ERROR-MSGID
    MSGNR                     = WA_ERROR-MSGNR
   MSGV1                     = WA_ERROR-MSGV1
   MSGV2                     = WA_ERROR-MSGV2
   MSGV3                     = WA_ERROR-MSGV3
   MSGV4                     = WA_ERROR-MSGV4
 IMPORTING
   MESSAGE_TEXT_OUTPUT       = WA_ERROR
          .


ENDLOOP.
