*----------------------------------------------------------------------*
***INCLUDE Z6MM006R_PURCHASE_ORDER_ADOF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ADOBE_PRINT_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XDRUVO  text
*      -->P_ENT_SCREEN  text
*      -->P_L_XFZ  text
*      <--P_ENT_RETCO  text
*----------------------------------------------------------------------*
FORM ADOBE_PRINT_OUTPUT  USING    P_XDRUVO
                                  P_ENT_SCREEN
                                  P_L_XFZ
                         CHANGING P_ENT_RETCO.

  data : fp_controlparams type SSFCTRLOP,
         fp_outputparams type SSFCOMPOP.

  data : it_job_output_info type SSFCRESCL.
  data : it_otfdata type TABLE OF SSFCRESCL-otfdata.
  data : wa_otfdata type ITCOO.


  if  nast-nacha EQ 5 OR nast-tdarmod = 2 OR  nast-tdarmod = 3  OR
nast-nacha EQ 2 .
* Setting output parameters
    fp_controlparams-getotf = 'X'.
    fp_controlparams-no_dialog = 'X'.
    fp_controlparams-device = 'PRINTER'.
* Specific setting for FAX
    IF nast-nacha EQ 2.
*      fp_outputparams-device = 'TELEFAX'.
*      IF nast-telfx EQ space.
*        fp_outputparams-nodialog = ' '.
*      ENDIF.
    ENDIF.
  ENDIF.
  FP_OUTPUTPARAMS-TDIMMED = 'X'.
  FP_OUTPUTPARAMS-TDNEWID = 'X'.
  FP_OUTPUTPARAMS-TDDEST = 'LOCL'.


  DATA: lf_fm_name TYPE rs38l_fnam.
  READ TABLE i_ekpo INDEX 1.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING  formname           = 'Z6MM006S_PURCHASE_ORDER'
*                 variant            = ' '
*                 direct_call        = ' '
       IMPORTING  fm_name            = lf_fm_name
       EXCEPTIONS no_form            = 1
                  no_function_module = 2
                  OTHERS             = 3.
  CALL FUNCTION lf_fm_name
  EXPORTING
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
    CONTROL_PARAMETERS         = fp_controlparams
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
    OUTPUT_OPTIONS             = fp_outputparams
*   USER_SETTINGS              = 'X'
 wa_komv_jvcs    = wa_komv_jvcs
  IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
    JOB_OUTPUT_INFO            = it_job_output_info
*   JOB_OUTPUT_OPTIONS         =

    TABLES
      x_mdsb                     =  i_mdsb
      x_ekko                     =  i_ekko
      x_ekpo                     =  i_ekpo
      x_ml_esll                  =  i_ml_esll
      x_konv                     =  i_konv
      x_komv                     =  i_komv
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  else.



    CALL FUNCTION 'CONVERT_OTF'
  EXPORTING
    FORMAT                      = 'PDF'
    MAX_LINEWIDTH               = 132
*   ARCHIVE_INDEX               = ' '
*   COPYNUMBER                  = 0
*   ASCII_BIDI_VIS2LOG          = ' '
*   PDF_DELETE_OTFTAB           = ' '
*   PDF_USERNAME                = ' '
  IMPORTING
    BIN_FILESIZE                = wrk_filesiz
*   BIN_FILE                    =
      TABLES
        OTF                         = IT_job_output_info-otfdata[]
        LINES                       = it_pdfdata
 EXCEPTIONS
   ERR_MAX_LINEWIDTH           = 1
   ERR_FORMAT                  = 2
   ERR_CONV_NOT_POSSIBLE       = 3
   ERR_BAD_OTF                 = 4
   OTHERS                      = 5
              .
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    else.


    ENDIF.

  ENDIF.


ENDFORM.                    " ADOBE_PRINT_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  sending_mail_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form sending_mail_new .

  data :  lv_emailaddr type adr6-smtp_addr,
          v_adrnr type lfa1-adrnr.

  DATA: objpack LIKE sopcklsti1 OCCURS  2 WITH HEADER LINE.

  DATA: objhead LIKE solisti1   OCCURS  1 WITH HEADER LINE.

  DATA: objbin  LIKE solisti1   OCCURS 10 WITH HEADER LINE.

  DATA: objtxt  LIKE solisti1   OCCURS 10 WITH HEADER LINE.

  DATA: reclist LIKE somlreci1  OCCURS  5 WITH HEADER LINE.

  DATA: doc_chng LIKE sodocchgi1.

  DATA: tab_lines LIKE sy-tabix.

  DATA: n TYPE i.


  DOC_CHNG-OBJ_NAME = 'INT'.

  DOC_CHNG-OBJ_DESCR = 'Purchase Order Intimation Letter'.

  OBJTXT = 'Please Find The Attached Document'.

  APPEND OBJTXT.


  DESCRIBE TABLE OBJTXT LINES TAB_LINES.

  READ TABLE OBJTXT INDEX TAB_LINES.

  DOC_CHNG-DOC_SIZE = ( TAB_LINES - 1 ) * 255 + STRLEN( OBJTXT ).


  OBJPACK-HEAD_START = 1.

  OBJPACK-HEAD_NUM   = 0.

  OBJPACK-BODY_START = 1.

  OBJPACK-BODY_NUM   = TAB_LINES.

  OBJPACK-DOC_TYPE   = 'RAW'.

  APPEND OBJPACK.


  CALL FUNCTION 'QCE1_CONVERT'
    TABLES
      t_source_tab         = it_pdfdata
      t_target_tab         = objbin
    EXCEPTIONS
      convert_not_possible = 1
      OTHERS               = 2.



  DESCRIBE TABLE OBJBIN LINES TAB_LINES.


  OBJHEAD = 'Attachment.PDF'. APPEND OBJHEAD.

* Creating the entry for the compressed attachment

  OBJPACK-TRANSF_BIN = 'X'.

  OBJPACK-HEAD_START = 1.

  OBJPACK-HEAD_NUM   = 1.

  OBJPACK-BODY_START = 1.

  OBJPACK-BODY_NUM   = TAB_LINES.

  OBJPACK-DOC_TYPE   = 'PDF'.

  OBJPACK-OBJ_NAME   = 'ATTACHMENT'.

  OBJPACK-OBJ_DESCR = 'PDF ATTACHMENT'.

  OBJPACK-DOC_SIZE   = wrk_filesiz.

  APPEND OBJPACK..

  READ TABLE i_ekko INDEX 1.
  if sy-subrc eq 0.
    select single adrnr from lfa1 into v_adrnr where lifnr = i_ekko-lifnr.
    if sy-subrc eq 0.
      SELECT SINGLE smtp_addr FROM adr6 INTO lv_emailaddr WHERE addrnumber = v_adrnr.
    endif.

  endif.

  RECLIST-RECEIVER =  lv_emailaddr.

  RECLIST-REC_TYPE = 'U'.

  APPEND RECLIST.

  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'

       EXPORTING

            DOCUMENT_DATA = DOC_CHNG

            PUT_IN_OUTBOX = 'X'

*          COMMIT_WORK   = 'X'

       TABLES

            PACKING_LIST  = OBJPACK

            OBJECT_HEADER = OBJHEAD

            CONTENTS_BIN  = OBJBIN

            CONTENTS_TXT  = OBJTXT

            RECEIVERS     = RECLIST

       EXCEPTIONS

        TOO_MANY_RECEIVERS = 1

            DOCUMENT_NOT_SENT  = 2

            OPERATION_NO_AUTHORIZATION = 4

            OTHERS = 99.


  IF SY-SUBRC = 0.

*SUBMIT rsconn01
*  WITH mode EQ 'INT'
*  AND RETURN.
**MESSAGE i075.
**SET SCREEN 0.
**LEAVE SCREEN.

  ENDIF.

endform.                    "sending_mail_new
