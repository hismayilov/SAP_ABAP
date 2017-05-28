*&---------------------------------------------------------------------*
*& Report  ZSOL_MM_QLTY_INSP
*&
*&---------------------------------------------------------------------*
*& Developed By : Prasad Gurjar/SaurabhK
*& Developed on : 17.11.2016
*&---------------------------------------------------------------------*

REPORT  zsol_mm_qlty_insp.

*&---------------------------------------------------------------------*
*&  Data Declarations
*&---------------------------------------------------------------------*

TYPE-POOLS : slis.

TABLES: mara,mchb,ztb_trd_specs.

DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid,
      g_save       TYPE c VALUE 'X',
      g_variant    TYPE disvariant,
      gx_variant   TYPE disvariant,
      g_exit       TYPE c,
      ispfli       TYPE TABLE OF spfli.

DATA : w_layout TYPE lvc_s_layo.

TYPES: BEGIN OF ty_final,
        sales_doc   TYPE ztb_trd_specs-vbeln,
        sales_item  TYPE ztb_trd_specs-posnr,
        mat         TYPE ztb_trd_specs-matnr,
        desc        TYPE makt-maktx,
        batch       TYPE ztb_trd_specs-charg,
        char        TYPE ztb_trd_specs-atnam,
        char_name   TYPE cabnt-atbez,
        specs       TYPE ztb_trd_specs-specs,
        low_lim     TYPE ztb_trd_specs-low_lim,
        up_lim      TYPE ztb_trd_specs-up_lim,
        dect        TYPE ztb_trd_specs-dect,
        act_val(30) TYPE c, "cawn-atwrt,
        cur_val     LIKE cha_class_view-sollwert,
        type        TYPE cabn-atfor,
        act_dect    TYPE ztb_trd_specs-dect,
        cur_dect    TYPE ztb_trd_specs-dect,
        movement    TYPE mseg-bwart,
        plant       TYPE mska-werks,
        str_loc     TYPE mseg-lgort,
        qty         TYPE ekbe-menge,
        uom         TYPE mseg-meins,
       END OF ty_final.

TYPES: BEGIN OF ty_makt,
        matnr TYPE makt-matnr,
        maktx TYPE makt-maktx,
       END OF ty_makt.

TYPES: BEGIN OF ty_char,
        atnam TYPE cabn-atnam,
        atbez TYPE cabnt-atbez,
       END OF ty_char.

* ---- For Dynamic F4 ---- *
TYPES: BEGIN OF ty_shmat,
        sow TYPE ztb_trd_specs-vbeln,
        mat TYPE ztb_trd_specs-matnr,
       END OF ty_shmat,

       BEGIN OF ty_shbat,
        sow TYPE ztb_trd_specs-vbeln,
        bat TYPE ztb_trd_specs-charg,
       END OF ty_shbat,

       BEGIN OF ty_shlor,
        sow TYPE ztb_trd_specs-vbeln,
        lor TYPE ztb_trd_specs-lorry_no,
       END OF ty_shlor.

DATA: BEGIN OF t_field OCCURS 0,      "Fieldlist im SELECT-Statement
         fname LIKE dntab-fieldname,
      END OF t_field.

* ---- For Dynamic F4 ---- *
DATA: it_shmat       TYPE TABLE OF ty_shmat,
      it_shbat       TYPE TABLE OF ty_shbat,
      it_shlor       TYPE TABLE OF ty_shlor,
      it_dynpfields  TYPE TABLE OF dynpread WITH HEADER LINE,
      it_shreturn    TYPE TABLE OF ddshretval WITH HEADER LINE.

* ---- Internal Tables ---- *
DATA: it_final  TYPE TABLE OF ty_final,
      wa_final  TYPE ty_final,
      it_mska   TYPE STANDARD TABLE OF mska,
      wa_mska   TYPE mska,
      it_makt   TYPE STANDARD TABLE OF makt,
      wa_makt   TYPE makt,
      wa_inob   TYPE inob,
      wa_klah   TYPE klah,
      wa_kssk   TYPE kssk,
      it_return TYPE TABLE OF bapiret2,
      wa_return TYPE bapiret2,
      it_vbap   TYPE STANDARD TABLE OF vbap,
      wa_vbap   TYPE vbap,
      it_specs  TYPE STANDARD TABLE OF ztb_trd_specs,
      wa_specs  TYPE ztb_trd_specs,
      it_cabn   TYPE STANDARD TABLE OF cabn,
      wa_cabn   TYPE cabn,
      it_ausp   TYPE STANDARD TABLE OF ausp,
      wa_ausp   TYPE ausp,
      it_auth   TYPE STANDARD TABLE OF ztb_trd_auth,
      wa_auth   TYPE ztb_trd_auth.

DATA: desc        TYPE makt-maktx,
      v_status(1) TYPE c,
      v_qty       TYPE mska-kains,
      v_sow       TYPE vbeln,
      gv_vbeln    TYPE ztb_trd_specs-vbeln.   " For Dynamic F4

DATA: mat_doc    TYPE bapi2017_gm_head_ret-mat_doc,
      doc_year   TYPE bapi2017_gm_head_ret-doc_year,
      v_msg(150) TYPE c.

DATA: ref1 TYPE REF TO cl_gui_alv_grid.

DATA: v_accept(1) TYPE c.

DATA: v_obj TYPE inob-objek.

DATA: it_oldvaluesnum  TYPE TABLE OF bapi1003_alloc_values_num,
      it_oldvalueschar TYPE TABLE OF bapi1003_alloc_values_char,
      it_oldvaluescurr TYPE TABLE OF bapi1003_alloc_values_curr,
      wa_oldvaluesnum  TYPE bapi1003_alloc_values_num,
      wa_oldvalueschar TYPE bapi1003_alloc_values_char,
      wa_oldvaluescurr TYPE bapi1003_alloc_values_curr,
      it_newvaluesnum  TYPE TABLE OF bapi1003_alloc_values_num,
      it_newvalueschar TYPE TABLE OF bapi1003_alloc_values_char,
      it_newvaluescurr TYPE TABLE OF bapi1003_alloc_values_curr,
      wa_newvaluesnum  TYPE bapi1003_alloc_values_num,
      wa_newvalueschar TYPE bapi1003_alloc_values_char,
      wa_newvaluescurr TYPE bapi1003_alloc_values_curr.

DATA: v_float TYPE f,
      v_dec   TYPE esecompavg,
      v_str   TYPE char30,
      v_old   TYPE cha_class_view-sollwert.

DATA: v_clnum  TYPE bapi1003_key-classnum,
      v_cltype TYPE bapi1003_key-classtype,
      v_objtab TYPE bapi1003_key-objecttable.

DATA: it_fields TYPE TABLE OF sval,
      wa_fields TYPE sval,
      lgort     TYPE spo_value,
      umlgo     TYPE spo_value.

DATA: wa_head TYPE bapi2017_gm_head_01,
      gm_code TYPE bapi2017_gm_code VALUE '04',
      it_item TYPE TABLE OF bapi2017_gm_item_create,
      wa_item TYPE bapi2017_gm_item_create.

DATA: wa_hold   TYPE ztb_trd_hold,
      cdate(10) TYPE c,
      ctime(10) TYPE c,
      v_held(1) TYPE c,
      v_updby   TYPE xubname,
      v_actval_check(1) TYPE c,
      v_hold_count TYPE i.

*&---------------------------------------------------------------------*
*&  Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
PARAMETERS: p_vbeln LIKE mska-vbeln OBLIGATORY,  " SOW
            p_matnr LIKE mara-matnr OBLIGATORY,  " material
            p_charg LIKE mchb-charg OBLIGATORY,  " Batch
            p_lorry LIKE ztb_trd_specs-lorry_no. " lorry no.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b15 WITH FRAME TITLE text-002 .
PARAMETERS: variant LIKE disvariant-variant NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b15.

*&---------------------------------------------------------------------*
*&  At Selection Screen Events
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_matnr.
  PERFORM dyn_f4 TABLES it_shmat USING 'P_MATNR' 'MATNR'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_charg.
  PERFORM dyn_f4 TABLES it_shbat USING 'P_CHARG' 'CHARG'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_lorry.
  PERFORM dyn_f4 TABLES it_shlor USING 'P_LORRY' 'LORRY_NO'.

*&---------------------------------------------------------------------*
*&  Initialization
*&---------------------------------------------------------------------*

INITIALIZATION.
  gx_variant-report = sy-repid.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    variant = gx_variant-variant.
  ENDIF.

  t1 = 'Input Data'.

*&---------------------------------------------------------------------*
*&  START-OF-SELECTION
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM last_hold_check.
  PERFORM data_retrivel.
  PERFORM build_fieldcatalog.

  IF it_final IS NOT INITIAL.
    PERFORM display_alv_report.
  ELSE.
    MESSAGE 'No data selected' TYPE 'I' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*&---------------------------------------------------------------------*
*&  Subroutines
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_retrivel .

  TRANSLATE p_vbeln TO UPPER CASE.
  TRANSLATE p_matnr TO UPPER CASE.
  TRANSLATE p_charg TO UPPER CASE.
  TRANSLATE p_lorry TO UPPER CASE.

  CONCATENATE p_matnr p_charg INTO v_obj RESPECTING BLANKS.

  IF v_obj IS NOT INITIAL.

    SELECT SINGLE *
      FROM inob
      INTO CORRESPONDING FIELDS OF wa_inob
      WHERE objek EQ v_obj.

    SELECT *
      FROM mska
      INTO CORRESPONDING FIELDS OF TABLE it_mska
      WHERE matnr EQ p_matnr
      AND   charg EQ p_charg
      AND   vbeln EQ p_vbeln
      AND   kains GT 0.

  ENDIF.

  IF it_mska[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE it_makt
      FOR ALL ENTRIES IN it_mska
      WHERE matnr EQ it_mska-matnr.

    SELECT *
      FROM ztb_trd_specs
      INTO CORRESPONDING FIELDS OF TABLE it_specs
      FOR ALL ENTRIES IN it_mska
      WHERE vbeln EQ it_mska-vbeln
      AND   posnr EQ it_mska-posnr
      AND   matnr EQ it_mska-matnr
      AND   lorry_no EQ p_lorry.

    IF it_specs[] IS NOT INITIAL.
      SELECT *
        FROM cabn
        INTO CORRESPONDING FIELDS OF TABLE it_cabn
        FOR ALL ENTRIES IN it_specs
        WHERE atnam = it_specs-atnam.

      IF it_cabn IS NOT INITIAL AND wa_inob IS NOT INITIAL.
        SELECT *
          FROM ausp
          INTO TABLE it_ausp
          FOR ALL ENTRIES IN it_cabn
          WHERE atinn = it_cabn-atinn
          AND objek  = wa_inob-cuobj.
      ENDIF.

      SELECT *
        FROM ztb_trd_auth
        INTO CORRESPONDING FIELDS OF TABLE it_auth
        WHERE user_id EQ sy-uname.
    ENDIF.
  ENDIF.

  IF it_specs[] IS NOT INITIAL.
    LOOP AT it_specs INTO wa_specs.
      READ TABLE it_mska INTO wa_mska WITH KEY vbeln = wa_specs-vbeln
                                               posnr = wa_specs-posnr
                                               matnr = wa_specs-matnr .
      IF sy-subrc = 0.
        v_sow = wa_final-sales_doc = wa_mska-vbeln. " constant assignments
        v_qty = wa_mska-kains.
        wa_final-mat = wa_mska-matnr.
        wa_final-batch = wa_mska-charg.
        wa_final-plant = wa_mska-werks.
        wa_final-str_loc = wa_mska-lgort.
      ENDIF.

      READ TABLE it_makt INTO wa_makt WITH KEY matnr = wa_mska-matnr.
      IF sy-subrc = 0.
        desc = wa_makt-maktx.
      ENDIF.

      READ TABLE it_cabn INTO wa_cabn WITH KEY atnam = wa_specs-atnam.
      IF sy-subrc = 0.
        wa_final-type = wa_cabn-atfor.
        READ TABLE it_ausp INTO wa_ausp WITH KEY atinn = wa_cabn-atinn.
        IF sy-subrc = 0.
          CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
            EXPORTING
              i_number_of_digits = 3
              i_fltp_value       = wa_ausp-atflv
            IMPORTING
              e_char_field       = wa_final-cur_val.
        ENDIF.
      ENDIF.

      wa_final-uom        = wa_specs-meins.
      wa_final-specs      = wa_specs-specs.
      wa_final-low_lim    = wa_specs-low_lim.
      wa_final-up_lim     = wa_specs-up_lim.
      wa_final-dect       = wa_specs-dect.
      wa_final-char       = wa_specs-atnam.
      wa_final-char_name  = wa_specs-atbez.
      wa_final-sales_item = wa_specs-posnr.

      APPEND wa_final TO it_final.
      CLEAR: wa_final, wa_ausp, wa_mska, wa_makt, wa_specs.
    ENDLOOP.

    PERFORM calc_prev_dedc.
  ENDIF.

ENDFORM.                    " DATA_RETRIVEL
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcatalog .

  fieldcatalog-fieldname      = 'CHAR'.
  fieldcatalog-seltext_m      = 'Parameter'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'CHAR_NAME'.
  fieldcatalog-seltext_m      = 'Name'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'SPECS'.
  fieldcatalog-seltext_m      = 'Specification'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'LOW_LIM'.
  fieldcatalog-seltext_m      = 'Lower Limit'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'UP_LIM'.
  fieldcatalog-seltext_m      = 'Upper Limit'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'DECT'.
  fieldcatalog-seltext_m      = 'Dctn.%'.
  gd_layout-colwidth_optimize = 'X'..
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'ACT_VAL'.
  fieldcatalog-seltext_m      = 'Actual Value'.
  fieldcatalog-edit           = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'TYPE'.
  fieldcatalog-seltext_m      = 'Type'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname      = 'ACT_DECT'.
  fieldcatalog-seltext_m      = 'Actual Dedct.'.
  gd_layout-colwidth_optimize = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  IF v_held IS NOT INITIAL.
    fieldcatalog-fieldname      = 'CUR_VAL'.
    fieldcatalog-seltext_m      = 'Previous Value'.
    gd_layout-colwidth_optimize = 'X'.
    APPEND fieldcatalog TO fieldcatalog.
    CLEAR  fieldcatalog.

    fieldcatalog-fieldname      = 'CUR_DECT'.
    fieldcatalog-seltext_m      = 'Previous Dedct.'.
    gd_layout-colwidth_optimize = 'X'.
    APPEND fieldcatalog TO fieldcatalog.
    CLEAR  fieldcatalog.
  ENDIF.

ENDFORM.                    " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_report .

  gd_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = gd_repid
*      is_layout                =
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP-OF-PAGE'
      it_fieldcat              = fieldcatalog[]
      i_save                   = 'X'
      is_variant               = g_variant
    TABLES
      t_outtab                 = it_final[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT
*-------------------------------------------------------------------*
* Form  TOP-OF-PAGE                                                 *
*-------------------------------------------------------------------*
* ALV Report Header                                                 *
*-------------------------------------------------------------------*
FORM top-of-page.
*ALV Header declarations
  DATA: t_header      TYPE slis_t_listheader,
        wa_header     TYPE slis_listheader,
        t_line        LIKE wa_header-info,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c.

*Title
  wa_header-typ  = 'H'.
  wa_header-info = 'Inspection characteristics'.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

*User
  wa_header-typ  = 'S'.
  wa_header-key = 'User: '.
  CONCATENATE  sy-uname ' ' INTO wa_header-info.   "Logged in user
  APPEND wa_header TO t_header.
  CLEAR: wa_header.
*SOW
  wa_header-typ  = 'S'.
  wa_header-key = 'SOW: '.
  wa_header-info = v_sow.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.
*Material
  wa_header-typ  = 'S'.
  wa_header-key = 'Material: '.
  wa_header-info = p_matnr.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.
*Mat Desc
  wa_header-typ  = 'S'.
  wa_header-key = 'Description: '.
  wa_header-info = desc.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.
*Batch
  wa_header-typ  = 'S'.
  wa_header-key = 'CAD: '.
  wa_header-info = p_charg.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

*Lorry No.
  wa_header-typ  = 'S'.
  wa_header-key = 'Lorry No.: '.
  wa_header-info = p_lorry.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.
*Qty in inspect. stock
  wa_header-typ  = 'S'.
  wa_header-key = 'Quantity: '.
  wa_header-info = v_qty.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  IF v_held IS NOT INITIAL.
*Last hold by
    wa_header-typ  = 'S'.
    wa_header-key = 'Last hold by: '.
    wa_header-info = v_updby.
    APPEND wa_header TO t_header.
    CLEAR: wa_header.

*Last hold on
    wa_header-typ  = 'S'.
    wa_header-key = 'Last hold on: '.
    CONCATENATE cdate ctime INTO wa_header-info SEPARATED BY space.
    "wa_header-info = wa_hold-upd_on.
    APPEND wa_header TO t_header.
    CLEAR: wa_header.
  ENDIF.

* Total No. of Records Selected
  DESCRIBE TABLE  it_final LINES ld_lines.
  ld_linesc = ld_lines.
  CONCATENATE 'Total No. of Records Selected: ' ld_linesc INTO t_line SEPARATED BY space.
  wa_header-typ  = 'A'.
  wa_header-info = t_line.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, t_line.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.
ENDFORM.                    "top-of-page
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.        "#EC CALLED
  SET PF-STATUS 'ZINSP_STAT'.
ENDFORM.                    "zage_stat
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield. "#EC CALLED

  IF r_ucomm EQ 'HOLD'.

    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref1.
    CALL METHOD ref1->check_changed_data.

    PERFORM hold.
    IF v_status = '1'.
      IF v_hold_count GT 1.

        PERFORM calc_prev_dedc.
        CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
          EXPORTING
            input  = sy-datum
          IMPORTING
            output = cdate.

        WRITE sy-uzeit TO ctime.

        rs_selfield-refresh = 'X'.
      ELSE.
        rs_selfield-refresh = 'X'.
      ENDIF.
    ENDIF.

  ELSEIF r_ucomm EQ 'HOLD_SAVE' OR r_ucomm EQ '&DATA_SAVE'.

    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref1.
    CALL METHOD ref1->check_changed_data.

    PERFORM hold.
    PERFORM save.

    IF mat_doc IS NOT INITIAL.
      rs_selfield-refresh = 'X'.
      rs_selfield-exit = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  HOLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hold .

  IF it_final[] IS NOT INITIAL.
    LOOP AT it_final INTO wa_final WHERE act_val IS NOT INITIAL.
      v_actval_check = 'X'. " atleast one row has non-initial value in actual value
    ENDLOOP.
  ENDIF.

  IF v_actval_check IS NOT INITIAL. " perform hold only if not all rows are blank for actual value
    PERFORM validation.

    CONCATENATE p_matnr p_charg INTO v_obj RESPECTING BLANKS.

    SELECT SINGLE *
      FROM inob
      INTO CORRESPONDING FIELDS OF wa_inob
      WHERE objek EQ v_obj.

    SELECT SINGLE *
      FROM kssk
      INTO CORRESPONDING FIELDS OF wa_kssk
      WHERE objek EQ wa_inob-cuobj.

    SELECT SINGLE *
      FROM klah
      INTO CORRESPONDING FIELDS OF wa_klah
      WHERE clint EQ wa_kssk-clint.

    IF sy-subrc = 0.
      v_clnum = wa_klah-class.
      v_cltype = wa_inob-klart.
      v_objtab = wa_inob-obtab.

      CALL FUNCTION 'BAPI_OBJCL_GETDETAIL'
        EXPORTING
          objectkey        = v_obj
          objecttable      = v_objtab
          classnum         = v_clnum
          classtype        = v_cltype
          keydate          = sy-datum
          unvaluated_chars = 'X'
          language         = sy-langu
        TABLES
          allocvaluesnum   = it_oldvaluesnum
          allocvalueschar  = it_oldvalueschar
          allocvaluescurr  = it_oldvaluescurr
          return           = it_return.
    ENDIF.

    LOOP AT it_final INTO wa_final.

      IF it_oldvaluesnum[] IS NOT INITIAL.
        READ TABLE it_oldvaluesnum INTO wa_oldvaluesnum WITH KEY charact = wa_final-char.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING wa_oldvaluesnum TO wa_newvaluesnum.

          v_str = wa_final-act_val.

          PERFORM convert_char_to_float.

          IF v_hold_count GE 1.
            PERFORM convert_float_to_char.
            wa_final-cur_val = v_old.
          ENDIF.

          IF v_float IS NOT INITIAL.
            wa_newvaluesnum-value_from = v_float.
            APPEND wa_newvaluesnum TO it_newvaluesnum.
          ELSE.
            APPEND wa_newvaluesnum TO it_newvaluesnum.
          ENDIF.
        ENDIF.
      ENDIF.

      IF it_oldvalueschar[] IS NOT INITIAL.
        READ TABLE it_oldvalueschar INTO wa_oldvalueschar WITH KEY charact = wa_final-char.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING wa_oldvalueschar TO wa_newvalueschar.
          IF wa_final-act_val IS NOT INITIAL.
            wa_newvalueschar-value_char = wa_final-act_val.
            wa_newvalueschar-value_neutral = wa_final-act_val.

            IF v_hold_count GE 1.
              wa_final-cur_val = wa_oldvalueschar-value_char.
            ENDIF.

            APPEND wa_newvalueschar TO it_newvalueschar.
          ELSE.
            APPEND wa_newvalueschar TO it_newvalueschar.
          ENDIF.
        ENDIF.
      ENDIF.

      IF it_oldvaluescurr[] IS NOT INITIAL.
        READ TABLE it_oldvaluescurr INTO wa_oldvaluescurr WITH KEY charact = wa_final-char.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING wa_oldvaluescurr TO wa_newvaluescurr.

          v_str = wa_final-act_val.

          PERFORM convert_char_to_float.

          IF v_hold_count GE 1.
            PERFORM convert_float_to_char.
            wa_final-cur_val = v_old.
          ENDIF.

          IF v_float IS NOT INITIAL.
            wa_newvaluescurr-value_from = v_float.
            APPEND wa_newvaluescurr TO it_newvaluescurr.
          ELSE.
            APPEND wa_newvaluescurr TO it_newvaluescurr.
          ENDIF.
        ENDIF.
      ENDIF.
      IF v_hold_count GE 1.
        MODIFY it_final FROM wa_final.
      ENDIF.
      CLEAR: wa_final, wa_newvaluesnum, wa_newvalueschar, wa_newvaluescurr.
    ENDLOOP.

    CLEAR it_return.

    IF ( it_newvaluesnum[] IS NOT INITIAL OR
         it_newvalueschar[] IS NOT INITIAL OR
         it_newvaluescurr[] IS NOT INITIAL ).

      CALL FUNCTION 'BAPI_OBJCL_CHANGE'
        EXPORTING
          objectkey                = v_obj
          objecttable              = v_objtab
          classnum                 = v_clnum
          classtype                = v_cltype
          status                   = '1'
*   STANDARDCLASS            =
*   CHANGENUMBER             =
          keydate                  = sy-datum
*   NO_DEFAULT_VALUES        = ' '
      IMPORTING
          classif_status           = v_status
        TABLES
          allocvaluesnumnew        = it_newvaluesnum
          allocvaluescharnew       = it_newvalueschar
          allocvaluescurrnew       = it_newvaluescurr
          return                   = it_return
                .
    ELSE.
      CLEAR v_status.
      MESSAGE 'Update unsuccessful. Please check your input!' TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.

    IF v_status = '1'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

      wa_hold-vbeln   = p_vbeln.
      wa_hold-matnr   = p_matnr.
      wa_hold-charg   = p_charg.
      wa_hold-lorry_no   = p_lorry.
      wa_hold-upd_on  = sy-datum.
      wa_hold-upd_by  = sy-uname.
      wa_hold-upd_tim = sy-uzeit.

      INSERT ztb_trd_hold FROM wa_hold.

      ADD 1 TO v_hold_count.

      LOOP AT it_final INTO wa_final WHERE act_val IS NOT INITIAL.
        IF ( wa_final-low_lim IS INITIAL AND wa_final-up_lim IS NOT INITIAL ).
          IF ( wa_final-act_val GT wa_final-specs ).
            wa_final-act_dect = ABS( wa_final-act_val - wa_final-specs ) * wa_final-dect.
          ELSE.
            CLEAR wa_final-act_dect.
          ENDIF.
        ELSEIF ( wa_final-low_lim IS NOT INITIAL AND wa_final-up_lim IS INITIAL ).
          IF ( wa_final-act_val LT wa_final-specs ).
            wa_final-act_dect = ABS( wa_final-act_val - wa_final-specs ) * wa_final-dect.
          ELSE.
            CLEAR wa_final-act_dect.
          ENDIF.
        ENDIF.
        MODIFY it_final FROM wa_final.
        CLEAR wa_final.
      ENDLOOP.
      CLEAR wa_hold.

      COMMIT WORK.
    ENDIF.

**** Display status message ****
    IF v_status = '1'.
      MESSAGE 'Characteristics data saved.' TYPE 'I'.
    ELSE.
      IF it_return IS NOT INITIAL.
        CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
          TABLES
            it_return = it_return.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR v_actval_check.
    MESSAGE 'Input empty. No changes made.' TYPE 'S'.
  ENDIF.

ENDFORM.                    " HOLD
*&---------------------------------------------------------------------*
*&      Form  SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save.

  IF v_status = '1'.

    LOOP AT it_final INTO wa_final. "WHERE act_val IS NOT INITIAL.
      IF wa_final-act_val IS INITIAL AND wa_final-cur_val IS NOT INITIAL.
        wa_final-act_val = wa_final-cur_val.
      ELSEIF wa_final-act_val IS INITIAL AND wa_final-cur_val IS INITIAL.
        CONTINUE.
      ENDIF.
      READ TABLE it_auth INTO wa_auth WITH KEY user_id = sy-uname.
**********
*** CHECK ACT_VAL TYPE
*** ADD FOR CHAR TYPE
      IF wa_auth IS INITIAL.
        wa_auth-ulevel = '0'.
      ENDIF.

      IF ( wa_auth-ulevel EQ '0' ).
        IF ( wa_final-low_lim IS INITIAL AND wa_final-up_lim IS NOT INITIAL ).
          IF ( wa_final-act_val GE wa_final-specs AND wa_final-act_val LE wa_final-up_lim ).
            wa_final-act_dect = ABS( wa_final-act_val - wa_final-specs ) * wa_final-dect.
            v_accept = 'X'.

            PERFORM db_update.
          ELSEIF wa_final-act_val GT wa_final-up_lim.
            CLEAR v_accept.
            MESSAGE 'Deduction out of bounds: You are not authorised to accept.' TYPE 'E'.
          ELSE.
            v_accept = 'X'.
          ENDIF.
        ELSEIF ( wa_final-low_lim IS NOT INITIAL AND wa_final-up_lim IS INITIAL ).
          IF ( wa_final-act_val LE wa_final-specs  AND wa_final-act_val GE wa_final-low_lim ).
            wa_final-act_dect = ABS( wa_final-act_val - wa_final-specs ) * wa_final-dect.
            v_accept = 'X'.

            PERFORM db_update.
          ELSEIF wa_final-act_val LT wa_final-low_lim.
            CLEAR v_accept.
            MESSAGE 'Deduction out of bounds: You are not authorised to accept.' TYPE 'E'.
          ELSE.
            v_accept = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.

      IF wa_auth-ulevel = '1'.
        IF ( wa_final-low_lim IS INITIAL AND wa_final-up_lim IS NOT INITIAL ).
          IF wa_final-act_val GT wa_final-up_lim.
            wa_final-act_dect = ABS( wa_final-act_val - wa_final-specs ) * wa_final-dect. "update ztab with act_dect
            v_accept = 'X'.

            PERFORM db_update.
          ENDIF.
        ELSEIF ( wa_final-low_lim IS NOT INITIAL AND wa_final-up_lim IS INITIAL ).
          IF wa_final-act_val LT wa_final-low_lim.
            wa_final-act_dect = ABS( wa_final-act_val - wa_final-specs ) * wa_final-dect. "update ztab with act_dect
            v_accept = 'X'.

            PERFORM db_update.
          ENDIF.
        ENDIF.
      ENDIF.

      IF wa_auth-ulevel = '2'.
        v_accept = 'X'. " No deduction calc or DB Update
      ENDIF.

      MODIFY it_final FROM wa_final.
      CLEAR wa_final.
    ENDLOOP.

    READ TABLE it_final INTO wa_final INDEX 1.

    IF sy-subrc = 0.
      IF v_accept = 'X'.

        SELECT *
          FROM vbap
          INTO CORRESPONDING FIELDS OF TABLE it_vbap
          FOR ALL ENTRIES IN it_specs
          WHERE vbeln EQ it_specs-vbeln
          AND posnr EQ it_specs-posnr.

        IF it_vbap[] IS NOT INITIAL.

          READ TABLE it_vbap INTO wa_vbap INDEX 1.

          wa_head-pstng_date = sy-datum.
          wa_head-doc_date = sy-datum.

          gm_code = '04'.

          wa_item-material = p_matnr.
          wa_item-plant = wa_final-plant.
          wa_item-stge_loc = wa_final-str_loc.
          wa_item-batch = p_charg.
          wa_item-move_type = '321'.
          wa_item-spec_stock = 'E'.
          wa_item-entry_qnt = v_qty.
          wa_item-entry_uom = wa_vbap-vrkme.
          wa_item-move_stloc = wa_final-str_loc.
          wa_item-val_sales_ord = wa_final-sales_doc.
          wa_item-val_s_ord_item = wa_final-sales_item.

          APPEND wa_item TO it_item.
          REFRESH it_return[].
        ENDIF.
      ENDIF.

      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header               = wa_head
          goodsmvt_code                 = gm_code
*   TESTRUN                       = ' '
*   GOODSMVT_REF_EWM              =
       IMPORTING
*   GOODSMVT_HEADRET              =
          materialdocument              = mat_doc
          matdocumentyear               = doc_year
        TABLES
          goodsmvt_item                 = it_item
*   GOODSMVT_SERIALNUMBER         =
          return                        = it_return
*   GOODSMVT_SERV_PART_DATA       =
*   EXTENSIONIN                   =
                .
      IF mat_doc IS NOT INITIAL AND sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        CONCATENATE 'Doc.' mat_doc 'with' doc_year 'has been created!' INTO v_msg SEPARATED BY space.
        MESSAGE v_msg TYPE 'I'.
      ELSE.
        CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
          TABLES
            it_return = it_return.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " SAVE
*&---------------------------------------------------------------------*
*&      Form  LAST_HOLD_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM last_hold_check .
  SELECT *
      FROM ztb_trd_hold
      INTO wa_hold
      UP TO 1 ROWS
      WHERE vbeln = p_vbeln
      AND matnr = p_matnr
      AND charg = p_charg
      AND lorry_no = p_lorry
      ORDER BY upd_on DESCENDING.
  ENDSELECT.

  IF wa_hold IS NOT INITIAL.
    v_held = 'X'.

    v_updby = wa_hold-upd_by.
    CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
      EXPORTING
        input  = wa_hold-upd_on
      IMPORTING
        output = cdate.

    WRITE wa_hold-upd_tim TO ctime.

    CONCATENATE p_matnr p_charg 'last hold by' wa_hold-upd_by 'on' cdate 'at' ctime INTO v_msg SEPARATED BY space.
    MESSAGE v_msg TYPE 'I'.
  ENDIF.
ENDFORM.                    " LAST_HOLD_CHECK
*&---------------------------------------------------------------------*
*&      Form  DB_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM db_update .
  UPDATE ztb_trd_specs SET act_dect = wa_final-act_dect
              WHERE vbeln = wa_final-sales_doc
              AND   atnam = wa_final-char
              AND   matnr = wa_final-mat
              AND   posnr = wa_final-sales_item
              AND   lorry_no = p_lorry.
  COMMIT WORK.
ENDFORM.                    " DB_UPDATE
*&---------------------------------------------------------------------*
*&      Form  CONVERT_CHAR_TO_FLOAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM convert_char_to_float .
  CALL FUNCTION 'C14W_CHAR_NUMBER_CONVERSION'
    EXPORTING
      i_string                   = v_str
    IMPORTING
      e_float                    = v_float
      e_dec                      = v_dec
    EXCEPTIONS
      wrong_characters           = 1
      first_character_wrong      = 2
      arithmetic_sign            = 3
      multiple_decimal_separator = 4
      thousandsep_in_decimal     = 5
      thousand_separator         = 6
      number_too_big             = 7
      OTHERS                     = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " CONVERT_CHAR_TO_FLOAT
*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validation .
  DATA: out_val(30) TYPE c.
  LOOP AT it_final INTO wa_final WHERE act_val IS NOT INITIAL.
    CASE wa_final-type.
      WHEN 'NUM'.
        CALL FUNCTION 'CATS_NUMERIC_INPUT_CHECK'
          EXPORTING
            input            = wa_final-act_val
*           INTERNAL         = 'X'
          IMPORTING
            output           = out_val
          EXCEPTIONS
            no_numeric       = 1
            OTHERS           = 2
                  .
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        IF out_val IS INITIAL.
          MESSAGE 'Type mismatch in input.' TYPE 'E'.
        ENDIF.
      WHEN 'CHAR'.
        CALL FUNCTION 'CATS_NUMERIC_INPUT_CHECK'
          EXPORTING
            input            = wa_final-act_val
*           INTERNAL         = 'X'
          IMPORTING
            output           = out_val
          EXCEPTIONS
            no_numeric       = 1
            OTHERS           = 2
              .
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
        IF out_val IS NOT INITIAL.
          MESSAGE 'Type mismatch in input.' TYPE 'E'.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " VALIDATION
*&---------------------------------------------------------------------*
*&      Form  CALC_PREV_DEDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM calc_prev_dedc .
  LOOP AT it_final INTO wa_final WHERE cur_val IS NOT INITIAL.
    IF ( wa_final-low_lim IS INITIAL AND wa_final-up_lim IS NOT INITIAL ).
      IF ( wa_final-cur_val GT wa_final-specs ).
        wa_final-cur_dect = ABS( wa_final-cur_val - wa_final-specs ) * wa_final-dect.
      ELSE.
        CLEAR wa_final-cur_dect.
      ENDIF.
    ELSEIF ( wa_final-low_lim IS NOT INITIAL AND wa_final-up_lim IS INITIAL ).
      IF ( wa_final-cur_val LT wa_final-specs ).
        wa_final-cur_dect = ABS( wa_final-cur_val - wa_final-specs ) * wa_final-dect.
      ELSE.
        CLEAR wa_final-cur_dect.
      ENDIF.
    ENDIF.
    MODIFY it_final FROM wa_final.
    CLEAR wa_final.
  ENDLOOP.
ENDFORM.                    " CALC_PREV_DEDC
*&---------------------------------------------------------------------*
*&      Form  CONERT_FLOAT_TO_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM convert_float_to_char .
  CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
    EXPORTING
      i_number_of_digits = 3
      i_fltp_value       = wa_oldvaluescurr-value_from
    IMPORTING
      e_char_field       = v_old.
ENDFORM.                    " CONERT_FLOAT_TO_CHAR

*&---------------------------------------------------------------------*
*&      Form  DYN_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0634   text
*----------------------------------------------------------------------*
FORM dyn_f4  TABLES p_table USING    value(p_field) value(p_fname).

  REFRESH it_dynpfields.

  it_dynpfields-fieldname = 'P_VBELN'.
  APPEND it_dynpfields.

* ---- Get sow value on the selection screen ---- *
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = it_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE it_dynpfields WITH KEY fieldname = 'P_VBELN'.
    IF sy-subrc = 0.
      gv_vbeln = it_dynpfields-fieldvalue.
    ENDIF.
  ENDIF.

  IF gv_vbeln IS NOT INITIAL.
    REFRESH t_field[].
    t_field-fname = 'VBELN'.
    APPEND t_field.
    t_field-fname = p_fname.
    APPEND t_field.

    SELECT DISTINCT (t_field)
      FROM ztb_trd_specs
      INTO TABLE p_table
      WHERE vbeln EQ gv_vbeln.

    IF sy-subrc = 0.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = p_field
          dynpprog        = sy-repid
          dynpnr          = sy-dynnr
          dynprofield     = p_field
          window_title    = 'Select Material'
          value_org       = 'S'
        TABLES
          value_tab       = p_table
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'SOW is mandatory.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
ENDFORM.                                                    " DYN_F4
