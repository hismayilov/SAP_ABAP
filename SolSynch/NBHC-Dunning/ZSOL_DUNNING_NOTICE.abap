*&---------------------------------------------------------------------*
*& Report  ZSOL_DUNNING_NOTICE
*&
*&---------------------------------------------------------------------*
*& Author: SaurabhK
*& Created On: 12.04.17 05:22 PM
*&---------------------------------------------------------------------*

REPORT  zsol_dunning_notice.

TYPES: BEGIN OF ty_notice,
         kunnr   TYPE bsid-kunnr,
         vbeln   TYPE bsid-vbeln,
         budat   TYPE bsid-budat,
         totamt  TYPE bsid-wrbtr,
         waers   TYPE bsid-waers,
         pendamt TYPE bsid-wrbtr,
         arrears TYPE i,
         intamt  TYPE bsid-wrbtr,
       END OF ty_notice.

DATA: it_bsid TYPE TABLE OF bsid,
      wa_bsid TYPE bsid,

      it_temp TYPE TABLE OF bsid,
      wa_temp TYPE bsid,

      it_notice   TYPE TABLE OF ty_notice,
      wa_notice   TYPE ty_notice,

      it_nottemp  TYPE TABLE OF ty_notice,
      wa_nottemp  TYPE ty_notice,

      it_notfinal TYPE TABLE OF ty_notice,
      wa_notfinal TYPE ty_notice,

      it_intrate TYPE TABLE OF t056z,
      wa_intrate TYPE t056z,

      it_kna1    TYPE TABLE OF kna1,
      wa_kna1    TYPE kna1,

      it_adr6    TYPE TABLE OF adr6,
      wa_adr6    TYPE adr6.

DATA: v_totamt    TYPE bsid-wrbtr,
      v_pendamt   TYPE bsid-wrbtr,
      v_paidamt   TYPE bsid-wrbtr,
      kunnr       TYPE bsid-kunnr,
      v_diff      TYPE i,
      v_arrears   TYPE i,
      v_intamt    TYPE bsid-wrbtr,
      v_name      TYPE kna1-name1,
      txt         TYPE string,
      v_date(10)  TYPE c,
      msg         TYPE string.

* ---- SF Data ---- *
DATA: fname   TYPE tdsfname VALUE 'ZSOL_DUNNING_NOTICE',
      fm_name TYPE rs38l_fnam.

DATA: lw_control_parameters TYPE ssfctrlop,
      lw_output_options TYPE ssfcompop,
      lw_ssfcrescl TYPE ssfcrescl,
      v_devtype TYPE rspoptype.

* ---- Mail Declaration ---- *
DATA: li_otf          TYPE TABLE OF itcoo,
      li_pdf_tab      TYPE TABLE OF tline,
      lv_bin_filesize TYPE i,
      lv_bin_file     TYPE xstring,
      li_bin_tab      TYPE solix_tab,
      lv_sender       TYPE ad_smtpadr VALUE 'nbhcbillingdesk@nbhcindia.com',
      lv_recevr       TYPE ad_smtpadr VALUE IS INITIAL,
      lv_sent_to_all  TYPE os_boolean,
      lv_sub_mail     TYPE so_obj_des,
      lv_sub_att      TYPE so_obj_des,
      lo_send_request TYPE REF TO cl_bcs,
      lo_document     TYPE REF TO cl_document_bcs,
      lo_sender       TYPE REF TO if_sender_bcs,
      lo_recipient    TYPE REF TO if_recipient_bcs,
      lt_message_body TYPE bcsy_text,
      lx_document_bcs TYPE REF TO cx_document_bcs VALUE IS INITIAL,
      lx_send_req_bcs TYPE REF TO cx_send_req_bcs VALUE IS INITIAL,
      lx_address_bcs  TYPE REF TO cx_address_bcs  VALUE IS INITIAL,
      x_root          TYPE REF TO cx_root.

* ---- Initialisation ---- *
INITIALIZATION.
  SELECT *
    FROM t056z
    INTO TABLE it_intrate.

  " Get client specific FM for SF
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = fname
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
   EXPORTING
     i_language                   = sy-langu
*     I_APPLICATION                = 'SAPDEFAULT'
   IMPORTING
     e_devtype                    = v_devtype
   EXCEPTIONS
     no_language                  = 1
     language_not_installed       = 2
     no_devtype_found             = 3
     system_error                 = 4
     OTHERS                       = 5
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  " Set SF o/p & control parameters
*/.. Get OTF data
  lw_control_parameters-getotf     = 'X'.
*/.. To supress preview
  lw_control_parameters-no_dialog  = 'X'.
  lw_control_parameters-langu      = sy-langu.
  lw_output_options-tdnoprev       = 'X'.
  lw_output_options-tddest         = v_devtype.


*  SELECTION-SCREEN BEGIN OF BLOCK b1.
*    SELECT-OPTIONS: s_kunnr FOR kunnr.
*  SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.
  SELECT *
    FROM bsid
    INTO TABLE it_bsid
    WHERE ( blart EQ 'RV'
    OR blart EQ 'DZ' ).
*    AND kunnr IN s_kunnr.

  IF sy-subrc = 0.
    SELECT *
      FROM kna1
      INTO TABLE it_kna1
      FOR ALL ENTRIES IN it_bsid
      WHERE kunnr = it_bsid-kunnr.

    IF sy-subrc = 0.
      SELECT *
        FROM adr6
        INTO TABLE it_adr6
        FOR ALL ENTRIES IN it_kna1
        WHERE addrnumber = it_kna1-adrnr.
    ENDIF.

    SORT it_bsid[] BY kunnr ASCENDING.
    it_temp[] = it_bsid[].
  ELSE.
    MESSAGE 'Customers with open invoices not found.' TYPE 'E'.
  ENDIF.

  LOOP AT it_bsid INTO wa_bsid WHERE blart = 'RV'.
    v_totamt  = wa_bsid-wrbtr.
    LOOP AT it_temp INTO wa_temp WHERE kunnr = wa_bsid-kunnr
                                 AND   vbeln = wa_bsid-vbeln
                                 AND   blart = 'DZ'.
      v_paidamt = v_paidamt + wa_temp-wrbtr.
      CLEAR wa_temp.
    ENDLOOP.
    v_pendamt = v_totamt - v_paidamt.

    CALL FUNCTION 'DAYS_BETWEEN_TWO_DATES'
      EXPORTING
        i_datum_bis             = sy-datum
        i_datum_von             = wa_bsid-budat
      IMPORTING
        e_tage                  = v_diff
      EXCEPTIONS
        days_method_not_defined = 1
        OTHERS                  = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSEIF sy-subrc = 0 AND v_pendamt IS NOT INITIAL.
      v_arrears  = v_diff - 45.
      IF v_arrears > 0.
        READ TABLE it_intrate INTO wa_intrate WITH KEY waers = wa_bsid-waers
                                                       vzskz = '02'.
        IF sy-subrc = 0.
          v_intamt = ( ( v_pendamt * v_arrears ) / 365 ) * ( wa_intrate-zinha / 100 ).
          MOVE: wa_bsid-kunnr   TO wa_notice-kunnr,
                wa_bsid-vbeln   TO wa_notice-vbeln,
                wa_bsid-budat   TO wa_notice-budat,
                v_totamt        TO wa_notice-totamt,
                wa_bsid-waers   TO wa_notice-waers,
                v_pendamt       TO wa_notice-pendamt,
                v_arrears       TO wa_notice-arrears,
                v_intamt        TO wa_notice-intamt.

          APPEND wa_notice TO it_notice.
          CLEAR: wa_notice.
        ENDIF.
      ENDIF.
    ENDIF.
    DELETE it_bsid WHERE kunnr = wa_bsid-kunnr
                   AND   vbeln = wa_bsid-vbeln.
    CLEAR: wa_bsid, v_totamt, v_pendamt, v_paidamt, v_diff, v_arrears, v_intamt, wa_intrate.
  ENDLOOP.

  " Calc interest
  " Send a dunning notice
  IF it_notice[] IS NOT INITIAL.
    SORT it_notice[] BY kunnr ASCENDING.
    it_nottemp[] = it_notice[].
    LOOP AT it_notice INTO wa_notice.
      LOOP AT it_nottemp INTO wa_nottemp WHERE kunnr = wa_notice-kunnr.
        MOVE-CORRESPONDING wa_nottemp TO wa_notfinal.
        APPEND wa_notfinal TO it_notfinal.
        CLEAR: wa_nottemp, wa_notfinal.
      ENDLOOP.

      " Call SF with it_notfinal
      CALL FUNCTION fm_name "'/1BCDWB/SF00000056'
        EXPORTING
          control_parameters = lw_control_parameters
          output_options     = lw_output_options
        IMPORTING
          job_output_info    = lw_ssfcrescl
        TABLES
          it_notice          = it_notfinal
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      " Get OTF data to convert to PDF
      CLEAR : lv_bin_filesize.
      REFRESH li_otf[].

      li_otf[] = lw_ssfcrescl-otfdata[].

      " Convert otf to binary
      CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
        IMPORTING
          bin_filesize          = lv_bin_filesize
          bin_file              = lv_bin_file
        TABLES
          otf                   = li_otf
          lines                 = li_pdf_tab
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          err_bad_otf           = 4
          OTHERS                = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = lv_bin_file
        TABLES
          binary_tab = li_bin_tab.

      " Get reciever email address
      READ TABLE it_kna1 INTO wa_kna1 WITH KEY kunnr = wa_notice-kunnr.
      IF sy-subrc = 0.
        v_name = wa_kna1-name1.
        READ TABLE it_adr6 INTO wa_adr6 WITH KEY addrnumber = wa_kna1-adrnr
                                                 flgdefault = 'X'.
        IF sy-subrc = 0.
          lv_recevr = wa_adr6-smtp_addr.
          CLEAR: wa_adr6.
        ELSE.
          CLEAR msg.
          CONCATENATE wa_notice-kunnr ': Email address not found' INTO msg SEPARATED BY space.
          MESSAGE msg TYPE 'S'.
          DELETE it_notice WHERE kunnr = wa_notice-kunnr.
          CONTINUE.
        ENDIF.
        CLEAR: wa_kna1.
      ENDIF.

      " Mail processing
      TRY .
          lo_send_request = cl_bcs=>create_persistent( ).
        CATCH cx_send_req_bcs INTO lx_send_req_bcs.
          MESSAGE 'Could not instantiate persistent send request' TYPE 'S'.
          CONTINUE.
      ENDTRY.

      " Contruct mail subject and body
      CLEAR: lv_sub_mail, lv_sub_att.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = sy-datum
        IMPORTING
          date_external            = v_date
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CONCATENATE 'Outstanding_Invoices_as_on_' v_date INTO lv_sub_mail.  " Mail Subject
      CONCATENATE 'Outstanding_Invoices_as_on_' v_date INTO lv_sub_att.   " Att. Subject

      REFRESH: lt_message_body[].
      CONCATENATE 'Dear ' v_name INTO v_name SEPARATED BY space.
      CONCATENATE v_name ',' INTO v_name.
      APPEND v_name TO lt_message_body.
      APPEND INITIAL LINE TO lt_message_body.
      CONCATENATE 'Please find the attached file listing the details of your outstanding invoices with NBHC Pvt. Ltd.'
      'In case of any clarification, please send an email to accountsreceivable@nbhcindia.com.'
      INTO txt SEPARATED BY space.
      APPEND txt TO lt_message_body.
      APPEND INITIAL LINE TO lt_message_body.
      APPEND  'This is an auto generated email. Kindly do not reply.' TO lt_message_body.
      APPEND INITIAL LINE TO lt_message_body.
      APPEND 'Thanks,' TO lt_message_body.
      APPEND 'Account Receivable Team' TO lt_message_body.
      APPEND 'NBHC Pvt. Ltd.' TO lt_message_body.           " Mail body

      CLEAR: v_name.

      " Create mail
      TRY.
          lo_document = cl_document_bcs=>create_document(
              i_type        = 'RAW'
              i_subject     = lv_sub_mail
              i_text        = lt_message_body ).
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

      " Add attachment to document
      TRY.
          CALL METHOD lo_document->add_attachment
            EXPORTING
              i_attachment_type    = 'PDF'
              i_attachment_subject = lv_sub_att
              i_att_content_hex    = li_bin_tab.
        CATCH cx_document_bcs INTO lx_document_bcs.
      ENDTRY.

      " Pass the document to send request
      TRY.
          lo_send_request->set_document( lo_document ).
        CATCH cx_send_req_bcs INTO lx_send_req_bcs.
      ENDTRY.

      " Create Sender
      TRY.
          lo_sender = cl_cam_address_bcs=>create_internet_address( lv_sender ).
        CATCH cx_send_req_bcs INTO lx_send_req_bcs.
      ENDTRY.

      " Set Sender
      TRY.
          CALL METHOD lo_send_request->set_sender(
            EXPORTING
              i_sender = lo_sender ).
        CATCH cx_send_req_bcs INTO lx_send_req_bcs.
      ENDTRY.

      " Create Reciever
      TRY .
          lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_recevr ).
        CATCH cx_address_bcs INTO lx_address_bcs.
      ENDTRY.

      " Set Reciever
      TRY.
          CALL METHOD lo_send_request->add_recipient(
            EXPORTING
              i_recipient = lo_recipient
              i_express   = 'X').
        CATCH cx_send_req_bcs INTO lx_send_req_bcs.
      ENDTRY.

      " Send Mail
      CLEAR txt.
      TRY .
          CALL METHOD lo_send_request->send(
            EXPORTING
              i_with_error_screen = 'X'
            RECEIVING
              result = lv_sent_to_all ).

          COMMIT WORK.

        CATCH cx_root INTO x_root.
          txt = x_root->get_text( ).
      ENDTRY.

      DELETE it_notice WHERE kunnr = wa_notice-kunnr.
      CLEAR: wa_notice.
      REFRESH: it_notfinal[].
    ENDLOOP.
  ENDIF.
