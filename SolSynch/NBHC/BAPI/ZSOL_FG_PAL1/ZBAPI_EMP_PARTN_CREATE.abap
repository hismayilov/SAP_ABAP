FUNCTION zbapi_emp_partn_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(T_EMP_PAL1) TYPE  ZTTEMP_PAL1
*"  EXPORTING
*"     VALUE(RETURN) TYPE  ZTTRETURN
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_emp_pal1,
          pernr       TYPE bdc_fval,
          anrex       TYPE bdc_fval,
          nachn       TYPE bdc_fval,
          vorna       TYPE bdc_fval,
          gesch       TYPE bdc_fval,
          gbdat       TYPE bdc_fval,
          natio       TYPE bdc_fval,
          ort01       TYPE bdc_fval,
          land1       TYPE bdc_fval,
          telnr       TYPE bdc_fval,
          usrid_long  TYPE bdc_fval,
         END OF ty_emp_pal1.

  DATA: it_emp_pal1 TYPE TABLE OF ty_emp_pal1,
        wa_emp_pal1 LIKE LINE OF it_emp_pal1,
        w_emp_pal1 LIKE LINE OF t_emp_pal1.

  DATA: subrc       TYPE sy-subrc,
        messtab     TYPE TABLE OF bdcmsgcoll WITH HEADER LINE,
        wa_return   TYPE bapiret2.

  DATA: datext TYPE bdc_fval,
        datint TYPE sy-datum,
        einda  TYPE bdc_fval,
        begda  TYPE bdc_fval,
        person TYPE p_pernr.

  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = sy-datum
    IMPORTING
      date_external            = datext
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  einda = datext.
  begda = datext.

  IF t_emp_pal1[] IS NOT INITIAL.

    LOOP AT t_emp_pal1 INTO w_emp_pal1.
      MOVE-CORRESPONDING w_emp_pal1 TO wa_emp_pal1.
      APPEND wa_emp_pal1 TO it_emp_pal1.
    ENDLOOP.

    LOOP AT it_emp_pal1 INTO wa_emp_pal1.

      person = wa_emp_pal1-pernr.
*      SHIFT person LEFT DELETING LEADING '0'.

      datint = wa_emp_pal1-gbdat.

      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = datint
        IMPORTING
          date_external            = datext
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      wa_emp_pal1-gbdat = datext.

      CALL FUNCTION 'ZBAPI_EMPLOYEE_CREATE'
        EXPORTING
*          CTU                  = 'X'
*          MODE                 = 'N'
*          UPDATE               = 'L'
*          GROUP                =
*          USER                 =
*          KEEP                 =
*          HOLDDATE             =
*          NODATA               = '/'
          pernr_001            = wa_emp_pal1-pernr
          einda_002            = einda
*          SELEC_01_003         = 'X'
          pernr_004            = wa_emp_pal1-pernr
          begda_005            = begda
*          ENDDA_006            = '31.12.9999'
*          MASSN_007            = 'L1'
*          WERKS_008            = '1003'
*          PERSG_009            = '1'
*          PERSK_010            = 'Y1'
          begda_011            = begda
*          ENDDA_012            = '31.12.9999'
*          BTRTL_013            = '1010'
*          ABKRS_014            = '99'
          begda_015            = begda
*          ENDDA_016            = '31.12.9999'
          anrex_017            = wa_emp_pal1-anrex     " 'Mr'
          nachn_018            = wa_emp_pal1-nachn
          vorna_019            = wa_emp_pal1-vorna
          gesch_020            = wa_emp_pal1-gesch     " default male = 1
*          SPRSL_021            = 'EN'
          gbdat_022            = wa_emp_pal1-gbdat     " Birth date
          natio_023            = wa_emp_pal1-natio     " 'IN'
          begda_024            = begda
*          ENDDA_025            = '31.12.9999'
          ort01_026            = wa_emp_pal1-ort01
          land1_027            = wa_emp_pal1-land1     " 'IN'
          telnr_034            = wa_emp_pal1-telnr
          begda_028            = begda
*          ENDDA_029            = '31.12.9999'
*          VKORG_030            = '1003'
          begda_031            = begda
*          ENDDA_032            = '31.12.9999'
          usrid_long_033       = wa_emp_pal1-usrid_long
        IMPORTING
          subrc                = subrc
        TABLES
          messtab              = messtab
                       .

      " Error handling - TODO
      IF subrc <> 0.
*        wa_return-type = 'E'.
*        wa_return-id = 'ZEMPL_CREATE'.
*        wa_return-number = 001.
*        wa_return-message_v1 = person.
*
*        CALL FUNCTION 'BALW_BAPIRETURN_GET2'
*          EXPORTING
*            type   = wa_return-type
*            cl     = wa_return-id
*            number = wa_return-number
*            par1   = wa_return-message_v1
*          IMPORTING
*            return = wa_return.
*
*        IF sy-subrc = 0.
*          APPEND wa_return TO return.
*        ENDIF.
*
*        CLEAR wa_return.

        READ TABLE messtab WITH KEY msgid = 'PG' msgnr = '002'.
        IF sy-subrc = 0.
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
            CONCATENATE person wa_return-message INTO wa_return-message SEPARATED BY space.
            APPEND wa_return TO return.
          ENDIF.

          CLEAR: wa_return, messtab.
        ENDIF.

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
            CONCATENATE person wa_return-message INTO wa_return-message SEPARATED BY space.
            APPEND wa_return TO return.
          ENDIF.

          CLEAR: wa_return, messtab.
        ENDLOOP.
      ELSE.
        wa_return-type = 'S'.
        wa_return-id = 'ZEMPL_CREATE'.
        wa_return-number = 000.
        wa_return-message_v1 = person.

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
    ENDLOOP.
  ENDIF.


ENDFUNCTION.
