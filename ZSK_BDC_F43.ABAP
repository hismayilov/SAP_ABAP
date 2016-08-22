report ZSK_BDC_F43
       no standard page heading line-size 255.

***TYPE-POOLS
TYPE-POOLS: TRUXS.


***DECLARATION OF TABLES USED
TABLES: BKPF, RF05A, BSEG, COBL.

***DECLARATION OF STRUCTURES FOR INTERNAL TABLES
TYPES: BEGIN OF TY_TAB,
         "BLDAT TYPE BKPF-BLDAT,
         BLDAT TYPE C LENGTH 10,
         BLART TYPE BKPF-BLART,
         BUKRS TYPE	BKPF-BUKRS,
         "BUDAT TYPE  BKPF-BUDAT,
         BUDAT TYPE C LENGTH 10,
         MONAT TYPE BKPF-MONAT,
         WAERS TYPE BKPF-WAERS,
         NEWBS TYPE	RF05A-NEWBS,
         NEWKO TYPE RF05A-NEWKO,
         WRBTR TYPE BSEG-WRBTR,
         "ZFBDT TYPE  BSEG-ZFBDT,
         ZFBDT TYPE C LENGTH 10,
         NEWBS1 TYPE RF05A-NEWBS,
         NEWKO1 TYPE RF05A-NEWKO,
         GSBER TYPE COBL-GSBER,
       END OF TY_TAB.

***BEGIN DATA OBJECT CREATION
***IT TO STORE CONVERTED DATA(XLS TO SAP)
DATA: IT_TAB TYPE TABLE OF TY_TAB,
      WA_TAB LIKE LINE OF IT_TAB.

DATA: IT_DATA TYPE TRUXS_T_TEXT_DATA.  " PASS EMPTY IN CONVERSION FUNCTION AS I_TAB_RAW_DATA
" USED FOR INTERNAL CONVERSION IN THAT FUNCTION

***INTERNAL TABLE FOR EXCLUSIVE ERROR HANDLING
DATA: IT_ERROR TYPE TABLE OF BDCMSGCOLL,
      WA_ERROR LIKE LINE OF IT_ERROR.

***INTERNAL TABLE TO STORE  CONVERTED DATA FROM IT_TAB + SCREEN/S INFO(FROM RECORDING)
"  DATA IS USED IN THE ACTUAL BATCH PROCESSING
DATA: BDCDATA TYPE TABLE OF BDCDATA WITH HEADER LINE.

***SELECTION SCREEN
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: P_FILE TYPE RLGRAP-FILENAME.
SELECTION-SCREEN END OF BLOCK B1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
" BROWSE FOR AND SELECT INPUT FILE

" READ AND PROCESS INPUT FILE
CALL FUNCTION 'F4_FILENAME'
  EXPORTING
    PROGRAM_NAME      = SYST-CPROG
    DYNPRO_NUMBER     = SYST-DYNNR
    FIELD_NAME        = 'P_FILE'
  IMPORTING
    FILE_NAME         = P_FILE
  .

IF P_FILE IS NOT INITIAL.

" CONVERT READ DATA FROM XLS TO SAP
CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
  EXPORTING
    I_FIELD_SEPERATOR      = 'X'
    I_LINE_HEADER          = 'X'
    I_TAB_RAW_DATA         = IT_DATA " PASSED EMPTY FOR INTERNAL USE IN CONVERSION
    I_FILENAME             = P_FILE
  TABLES
    I_TAB_CONVERTED_DATA   = IT_TAB     " CONVERTED DATA
  EXCEPTIONS
    CONVERSION_FAILED      = 1
    OTHERS                 = 2
  .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDIF.

" include bdcrecx1.

***PROCESS INDIVIDUAL ENTRY INTO BDCTAB PROVIDED FROM LOOP BELOW
*----------------------------------------------------------------------*
* Start new screen *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM = PROGRAM.
  BDCDATA-DYNPRO = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
* Insert field *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
 " IF FVAL <> NODATA.
   CLEAR BDCDATA.
   BDCDATA-FNAM = FNAM.
   BDCDATA-FVAL = FVAL.
   SHIFT BDCDATA-FVAL LEFT DELETING LEADING SPACE.
   APPEND BDCDATA.
 " ENDIF.
ENDFORM.

***START OF MAIN EXECUTION
start-of-selection.

" LOOP THROUGH SCREENS & GENERATE DATA FOR BDCDATA INTERNAL TABLE
LOOP AT IT_TAB INTO WA_TAB.

  REFRESH BDCDATA.
" perform open_group.

perform bdc_dynpro      using 'SAPMF05A' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWKO'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.

*CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
* EXPORTING
*   DATE_INTERNAL                  = WA_TAB-BLDAT
* IMPORTING
*   DATE_EXTERNAL                  = WA_TAB-BLDAT
* EXCEPTIONS
*   DATE_INTERNAL_IS_INVALID       = 1
*   OTHERS                         = 2
*          .
*IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
perform bdc_field       using 'BKPF-BLDAT'
                              WA_TAB-BLDAT. " '16.08.2016'.
perform bdc_field       using 'BKPF-BLART'
                              WA_TAB-BLART. " 'KR'.
perform bdc_field       using 'BKPF-BUKRS'
                              WA_TAB-BUKRS. " '2'.

*CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
* EXPORTING
*   DATE_INTERNAL                  = WA_TAB-BUDAT
* IMPORTING
*   DATE_EXTERNAL                  = WA_TAB-BUDAT
* EXCEPTIONS
*   DATE_INTERNAL_IS_INVALID       = 1
*   OTHERS                         = 2
*          .
*IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
perform bdc_field       using 'BKPF-BUDAT'
                              WA_TAB-BUDAT. " '16.08.2016'.
perform bdc_field       using 'BKPF-MONAT'
                              WA_TAB-MONAT. " '5'.
perform bdc_field       using 'BKPF-WAERS'
                              WA_TAB-WAERS. " 'INR'.
perform bdc_field       using 'FS006-DOCID'
                              '*'.
perform bdc_field       using 'RF05A-NEWBS'
                              WA_TAB-NEWBS. " '31'.
perform bdc_field       using 'RF05A-NEWKO'
                              WA_TAB-NEWKO. " '01'.
perform bdc_dynpro      using 'SAPMF05A' '0302'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF05A-NEWKO'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BSEG-WRBTR'
                              WA_TAB-WRBTR. " '10000'.

*CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
* EXPORTING
*   DATE_INTERNAL                  = WA_TAB-ZFBDT
* IMPORTING
*   DATE_EXTERNAL                  = WA_TAB-ZFBDT
* EXCEPTIONS
*   DATE_INTERNAL_IS_INVALID       = 1
*   OTHERS                         = 2
*          .
*IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
perform bdc_field       using 'BSEG-ZFBDT'
                              WA_TAB-ZFBDT. " '16.08.2016'.
perform bdc_field       using 'RF05A-NEWBS'
                              WA_TAB-NEWBS1. " '40'.
perform bdc_field       using 'RF05A-NEWKO'
                              WA_TAB-NEWKO1. " '2001'.
perform bdc_dynpro      using 'SAPMF05A' '0300'.
perform bdc_field       using 'BDC_CURSOR'
                              'BSEG-WRBTR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BU'.
perform bdc_field       using 'BSEG-WRBTR'
                              WA_TAB-WRBTR. " '10000'.
perform bdc_field       using 'DKACB-FMORE'
                              'X'.
perform bdc_dynpro      using 'SAPLKACB' '0002'.
perform bdc_field       using 'BDC_CURSOR'
                              'COBL-GSBER'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTE'.
perform bdc_field       using 'COBL-GSBER'
                              WA_TAB-GSBER. " '0001'.

" perform bdc_transaction using 'SE11'.

" perform close_group.

  CALL TRANSACTION 'F-43' USING BDCDATA MODE 'A' UPDATE 'S' MESSAGES INTO IT_ERROR.
ENDLOOP.

***ERROR HANDLING
LOOP AT IT_ERROR INTO WA_ERROR WHERE MSGTYP EQ 'E'.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID = WA_ERROR-MSGID
      MSGNR = WA_ERROR-MSGNR
      MSGV1 = WA_ERROR-MSGV1
      MSGV2 = WA_ERROR-MSGV2
      MSGV3 = WA_ERROR-MSGV3
      MSGV4 = WA_ERROR-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = WA_ERROR
    .

ENDLOOP.
