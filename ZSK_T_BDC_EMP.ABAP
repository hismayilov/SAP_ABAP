***CORRESPONDING RECORDING ZSK_EMP_REC

report ZSK_T_BDC_EMP
       no standard page heading line-size 255.

***DATA DECLARATIONS
***TABLES USED
TABLES: ZSK_EMP_TAB.

***TYPE-POOLS
TYPE-POOLS: TRUXS.

***STRUCTURE DECLARATIONS
TYPES: BEGIN OF TY_TAB,
        EMPNO TYPE ZSK_EMP_TAB-EMPNO,
        ENAME TYPE ZSK_EMP_TAB-ENAME,
        JOB TYPE ZSK_EMP_TAB-JOB,
        HDATE TYPE ZSK_EMP_TAB-HDATE,
        SAL TYPE ZSK_EMP_TAB-SAL,
        DEPTNO TYPE ZSK_EMP_TAB-DEPTNO,
      END OF TY_TAB.

***BEGIN DATA OBJECT CREATION
***IT TO STORE CONVERTED DATA(XLS TO SAP)
DATA: IT_TAB TYPE TABLE OF TY_TAB,
      WA_TAB LIKE LINE OF IT_TAB.

DATA: IT_DATA TYPE TRUXS_T_TEXT_DATA. " PASS EMPTY IN CONVERSION FUCNTION AS I_TAB_RAW_DATA
" USED FOR INTERNAL CONBVERSION IN THAT FUNCTION

DATA: IT_ERROR TYPE TABLE OF BDCMSGCOLL,
      WA_ERROR LIKE LINE OF IT_ERROR.

DATA: BDCDATA TYPE TABLE OF BDCDATA WITH HEADER LINE.
" STORES THE CONVERTED DATA FROM IT_TAB, IS PASSED TO CALL TRANSACTION USED IN PERFORMING THE BATCH PROCESSING
" BDCDATA WILL HAVE CONVERTED DATA FROM IT_TAB + SCREEN/S INFO(FROM RECORDING),
" CALL TRANSACTION NEEDS DATA IN THE BDCDATA FORMAT FOR THE BATCH PROCESSING, HENCE DATA IS TRANSFERRED FIRST
" FROM IT_TAB TO BDCDATA AND THEN BDCDATA IS USED IN THE ACTUAL BATCH PROCESSING.

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
      I_TAB_RAW_DATA             = IT_DATA  " PASSED EMPTY FOR INTERNAL USE
      I_FILENAME                 = P_FILE
    TABLES
      I_TAB_CONVERTED_DATA       = IT_TAB " OUTPUT TABLE, STORES CONVERTED DATA
   EXCEPTIONS
     CONVERSION_FAILED          = 1
     OTHERS                     = 2
            .
  IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDIF.

" include bdcrecx1.

start-of-selection.

LOOP AT IT_TAB INTO WA_TAB.
" perform open_group.
REFRESH BDCDATA.

perform bdc_dynpro      using 'SAPMSRD0' '0102'.
perform bdc_field       using 'BDC_CURSOR'
                              'RSRD1-TBMA_VAL'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SHOW'.
perform bdc_field       using 'RSRD1-TBMA'
                              'X'.
perform bdc_field       using 'RSRD1-TBMA_VAL'
                              'ZSK_EMP_TAB'.
perform bdc_field       using 'RSRD1-DDTYPE_VAL'
                              'ZSK_JOB_DE'.
perform bdc_field       using 'RSRD1-DOMA_VAL'
                              'ZSK_JOB_DOM'.
perform bdc_dynpro      using 'SAPLSD41' '2200'.
perform bdc_field       using 'BDC_CURSOR'
                              'DD02D-TABCLTEXT'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TDED'.
perform bdc_dynpro      using '/1BCDWB/DBZSK_EMP_TAB' '0101'.
perform bdc_field       using 'BDC_CURSOR'
                              'ZSK_EMP_TAB-DEPTNO'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SAVE'.
perform bdc_field       using 'ZSK_EMP_TAB-EMPNO'
                               WA_TAB-EMPNO. " '210'
perform bdc_field       using 'ZSK_EMP_TAB-ENAME'
                               WA_TAB-ENAME.  " 'TOM'
perform bdc_field       using 'ZSK_EMP_TAB-JOB'
                               WA_TAB-JOB.  " 'MANAGER'
perform bdc_field       using 'ZSK_EMP_TAB-HDATE'
                               WA_TAB-HDATE.  " '11.10.2005'
perform bdc_field       using 'ZSK_EMP_TAB-SAL'
                               WA_TAB-SAL.  " '70000'
perform bdc_field       using 'ZSK_EMP_TAB-DEPTNO'
                               WA_TAB-DEPTNO.  " '20'
perform bdc_dynpro      using '/1BCDWB/DBZSK_EMP_TAB' '0101'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EBACK'.
perform bdc_field       using 'BDC_CURSOR'
                              'ZSK_EMP_TAB-EMPNO'.
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
                              'ZSK_EMP_TAB'.
perform bdc_field       using 'RSRD1-DDTYPE_VAL'
                              'ZSK_JOB_DE'.
perform bdc_field       using 'RSRD1-DOMA_VAL'
                              'ZSK_JOB_DOM'.
"perform bdc_transaction using 'SE11'.

"perform close_group.

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
