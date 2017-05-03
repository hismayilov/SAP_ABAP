*&---------------------------------------------------------------------*
*& Modulpool ZSOL_MATERIAL_REQUEST
*&---------------------------------------------------------------------*
*& Author: Saurabh Khare
*& Creation Date: 06.03.2017
*& Description: Request ZERT Type Materials - Material Code generation(attributes)
*& TCODE: ZMAT_REQ
*&---------------------------------------------------------------------*
PROGRAM zsol_material_request.

TABLES: zsol_div_attr, zsol_mmcreate, t023, tspat.

TYPE-POOLS: vrm.

TYPES: BEGIN OF ty_tc_attr,
         attr(20)  TYPE c,
         value(10) TYPE c,
       END OF ty_tc_attr,

       BEGIN OF ty_shelp,
         name  TYPE zsol_mmname,
         descr TYPE zsol_mmdescr,
       END OF ty_shelp,

       BEGIN OF ty_matnr,
         matnr TYPE mara-matnr,
       END OF ty_matnr.

DATA: it_tc_attr       TYPE TABLE OF ty_tc_attr,
      wa_tc_attr       TYPE ty_tc_attr,

      it_tc_attr_temp  TYPE TABLE OF ty_tc_attr,
      wa_tc_attr_temp  TYPE ty_tc_attr,

      it_div_attr      TYPE TABLE OF zsol_div_attr,
      wa_div_attr      TYPE zsol_div_attr,

      it_mmcreate      TYPE TABLE OF zsol_mmcreate,
      wa_mmcreate      TYPE zsol_mmcreate,

      it_matnr         TYPE TABLE OF ty_matnr,
      wa_matnr         TYPE ty_matnr,

      it_denier        TYPE TABLE OF zsol_denier,
      wa_denier        TYPE zsol_denier,

      it_filament      TYPE TABLE OF zsol_filament,
      wa_filament      TYPE zsol_filament,

      it_luster        TYPE TABLE OF zsol_luster,
      wa_luster        TYPE zsol_luster,

      it_cross_section TYPE TABLE OF zsol_cross_sect,
      wa_cross_section TYPE zsol_cross_sect,

      it_grade         TYPE TABLE OF zsol_grade,
      wa_grade         TYPE zsol_grade,

      it_shade         TYPE TABLE OF zsol_shade,
      wa_shade         TYPE zsol_shade,

      it_twist         TYPE TABLE OF zsol_twist,
      wa_twist         TYPE zsol_twist,

      it_ply           TYPE TABLE OF zsol_ply,
      wa_ply           TYPE zsol_ply,

      it_text          TYPE TABLE OF zsol_text,
      wa_text          TYPE zsol_text,

      it_tpm           TYPE TABLE OF zsol_tpm,
      wa_tpm           TYPE zsol_tpm,

      it_ply_type      TYPE TABLE OF zsol_ply_type,
      wa_ply_type      TYPE zsol_ply_type,

      wa_mara          TYPE mara,

      wa_update        TYPE zsol_mmcreate.

DATA: name       TYPE vrm_id,
      list       TYPE vrm_values,
      value      LIKE LINE OF list,
      count(2)   TYPE c,
      v_line     TYPE i,
      divkey(2)  TYPE c,
      attrval    TYPE string,
      cursor     TYPE i,
      msg        TYPE string,
      title(100) TYPE c,
      date(10)   TYPE c,
      index      TYPE c,
      lus_desc   TYPE char40.

DATA: matnr   TYPE mara-matnr,
      maktx   TYPE makt-maktx,
      matnr_a TYPE mara-matnr,
      maktx_a TYPE makt-maktx,
      matnr_b TYPE mara-matnr,
      maktx_b TYPE makt-maktx,
      matnr_c TYPE mara-matnr,
      maktx_c TYPE makt-maktx,
      matnr_d TYPE mara-matnr,
      maktx_d TYPE makt-maktx,
      matnr_e TYPE mara-matnr,
      maktx_e TYPE makt-maktx.

DATA: div TYPE zsol_div_attr-spart.             " Division

DATA: go_struct TYPE REF TO cl_abap_structdescr,
      gt_comp   TYPE abap_component_tab,
      gs_comp   TYPE abap_componentdescr.

DATA: it_shelp TYPE TABLE OF ty_shelp,
      wa_shelp TYPE ty_shelp,

      it_shret TYPE TABLE OF ddshretval,
      wa_shret TYPE ddshretval,

      it_tspat TYPE TABLE OF tspat,
      wa_tspat TYPE tspat.

DATA: tabl_name LIKE dd02l-tabname,
      wa_name   TYPE string.

FIELD-SYMBOLS: <table> TYPE table,
               <wa>    TYPE any,
               <fs>    TYPE any.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_ATTR' ITSELF
CONTROLS: tc_attr TYPE TABLEVIEW USING SCREEN 0100.

DATA:     ok_code LIKE sy-ucomm.

LOAD-OF-PROGRAM.
* ---- Initialisation(Execute only once) ---- *
  SELECT *
    FROM zsol_mmcreate
    INTO CORRESPONDING FIELDS OF TABLE it_mmcreate.

  SELECT *
    FROM zsol_denier
    INTO TABLE it_denier.

  SELECT *
    FROM zsol_filament
    INTO TABLE it_filament.

  SELECT *
    FROM zsol_luster
    INTO TABLE it_luster.

  SELECT *
    FROM zsol_cross_sect
    INTO TABLE it_cross_section.

  SELECT *
    FROM zsol_grade
    INTO TABLE it_grade.

  SELECT *
    FROM zsol_shade
    INTO TABLE it_shade.

  SELECT *
    FROM zsol_twist
    INTO TABLE it_twist.

  SELECT *
    FROM zsol_ply
    INTO TABLE it_ply.

  SELECT *
    FROM zsol_text
    INTO TABLE it_text.

  SELECT *
    FROM zsol_tpm
    INTO TABLE it_tpm.

  SELECT *
    FROM tspat
    INTO TABLE it_tspat
    WHERE spras EQ sy-langu.


*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ATTR'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_attr_change_tc_attr OUTPUT.
  DESCRIBE TABLE it_tc_attr LINES tc_attr-lines.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZMAT_REQ'.
  SET TITLEBAR 'TITLE'.

  name = 'ZSOL_DIV_ATTR-SPART'.
  IF list[] IS INITIAL.
    SELECT *
        FROM zsol_div_attr
        INTO TABLE it_div_attr.

    IF sy-subrc = 0.
      LOOP AT it_div_attr INTO wa_div_attr.
        count = count + 1.
        value-key  = count.
        value-text = wa_div_attr-spart.
        APPEND value TO list.
        CLEAR: wa_div_attr, value.
      ENDLOOP.

      IF list IS NOT INITIAL.
        SORT list BY text.
        CLEAR count.
        LOOP AT list INTO value.
          CLEAR value-key.
          ADD 1 TO count.
          value-key = count.
          MODIFY list FROM value TRANSPORTING key.
          CLEAR: value.
        ENDLOOP.
      ENDIF.

      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = name
          values = list.

      CLEAR zsol_div_attr-spart.
    ELSE.
      MESSAGE 'No Divisions Found' TYPE 'E'.
    ENDIF.
  ENDIF.

  IF div IS INITIAL.
    LOOP AT SCREEN.
      IF screen-name EQ 'ZSOL_MMCREATE-ACT_DENIER'
      OR screen-name EQ 'ZSOL_MMCREATE-DENIER_DESC'
      OR screen-name EQ 'T023-MATKL'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* ---- Disable Save button if all fields not filled ---- *
*  IF it_tc_attr[] IS NOT INITIAL.
*    LOOP AT it_tc_attr INTO wa_tc_attr.
*      IF wa_tc_attr-value IS INITIAL.
*        LOOP AT SCREEN.
*          IF screen-name EQ 'CRT'.
*            screen-input = 0.
*            MODIFY SCREEN.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*      CLEAR wa_tc_attr.
*    ENDLOOP.
*  ENDIF.
*
*  IF zsol_mmcreate-act_denier  IS INITIAL OR
*     zsol_mmcreate-denier_desc IS INITIAL OR
*     t023-matkl IS INITIAL.
*    LOOP AT SCREEN.
*      IF screen-name EQ 'CRT'.
*        screen-input = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'DIV'.
      PERFORM populate_tc.
    WHEN 'CRT' OR 'SPOS' OR 'ONLI'.
      IF it_tc_attr IS NOT INITIAL.
        PERFORM input_validation.

        REFRESH it_tc_attr_temp[].
        it_tc_attr_temp[] = it_tc_attr[].
        CASE div.
          WHEN 'AT'.
            matnr = 'A'.
            maktx = div.
          WHEN 'FD'.
            matnr = 'F'.
            maktx = div.
          WHEN 'PY'.
            matnr = 'P'.
            maktx = div.
          WHEN 'SF'.
            matnr = 'C'.    " Or S
            maktx = div.    " Or S
          WHEN 'CB'.
            matnr = 'C'.    " Or S
            maktx = div.    " Or S
          WHEN 'TW'.
            matnr = 'T'.
            maktx = div.
          WHEN 'TX'.
            matnr = 'X'.
            maktx = div.
          WHEN OTHERS.
        ENDCASE.

        IF matnr IS NOT INITIAL AND maktx IS NOT INITIAL.
          matnr_a = matnr.
          matnr_b = matnr.
          matnr_c = matnr.
          matnr_d = matnr.
          matnr_e = matnr.

          maktx_a = maktx.
          maktx_b = maktx.
          maktx_c = maktx.
          maktx_d = maktx.
          maktx_e = maktx.
        ENDIF.

        LOOP AT it_tc_attr INTO wa_tc_attr.
          CLEAR: tabl_name, wa_name.

          CONCATENATE 'IT_' wa_tc_attr-attr INTO tabl_name.
          ASSIGN (tabl_name) TO <table>.
          CONCATENATE 'WA_' wa_tc_attr-attr INTO wa_name.
          ASSIGN (wa_name) TO <wa>.

          CLEAR attrval.
          attrval = wa_tc_attr-value.
          " MATNR Variations
          IF wa_tc_attr-attr = 'GRADE'.
            PERFORM matnr_grade_variations USING : matnr_a  wa_tc_attr-value, " A
                                                   matnr_b  'B',
                                                   matnr_c  'C',
                                                   matnr_d  'D',
                                                   matnr_e  'E'.
          ELSE.
            CONCATENATE matnr_a attrval INTO matnr_a.
            CONCATENATE matnr_b attrval INTO matnr_b.
            CONCATENATE matnr_c attrval INTO matnr_c.
            CONCATENATE matnr_d attrval INTO matnr_d.
            CONCATENATE matnr_e attrval INTO matnr_e.
          ENDIF.

          " MAKTX Variations
          IF wa_tc_attr-attr = 'DENIER'.
            CONCATENATE maktx_a '-' attrval INTO maktx_a.
            CONCATENATE maktx_b '-' attrval INTO maktx_b.
            CONCATENATE maktx_c '-' attrval INTO maktx_c.
            CONCATENATE maktx_d '-' attrval INTO maktx_d.
            CONCATENATE maktx_e '-' attrval INTO maktx_e.
          ENDIF.
          IF wa_tc_attr-attr = 'FILAMENT'.
            READ TABLE <table> ASSIGNING <wa> WITH KEY ('NAME') = wa_tc_attr-value.
            IF sy-subrc = 0 AND <wa> IS ASSIGNED.
              ASSIGN COMPONENT 'DESCR' OF STRUCTURE <wa> TO <fs>.
              CONCATENATE maktx_a '/' <fs> INTO maktx_a.
              CONCATENATE maktx_b '/' <fs> INTO maktx_b.
              CONCATENATE maktx_c '/' <fs> INTO maktx_c.
              CONCATENATE maktx_d '/' <fs> INTO maktx_d.
              CONCATENATE maktx_e '/' <fs> INTO maktx_e.
              UNASSIGN: <wa>, <fs>.
            ENDIF.
          ENDIF.
          IF wa_tc_attr-attr = 'LUSTER'.
            READ TABLE <table> ASSIGNING <wa> WITH KEY ('NAME') = wa_tc_attr-value.
            IF sy-subrc = 0 AND <wa> IS ASSIGNED.
              ASSIGN COMPONENT 'DESCR' OF STRUCTURE <wa> TO <fs>.
              CONCATENATE maktx_a '-' <fs>+0(2) INTO maktx_a.
              CONCATENATE maktx_b '-' <fs>+0(2) INTO maktx_b.
              CONCATENATE maktx_c '-' <fs>+0(2) INTO maktx_c.
              CONCATENATE maktx_d '-' <fs>+0(2) INTO maktx_d.
              CONCATENATE maktx_e '-' <fs>+0(2) INTO maktx_e.
              UNASSIGN: <wa>, <fs>.
            ENDIF.
          ENDIF.
          IF wa_tc_attr-attr = 'CROSS_SECTION'.
            CONCATENATE maktx_a '-' attrval INTO maktx_a.
            CONCATENATE maktx_b '-' attrval INTO maktx_b.
            CONCATENATE maktx_c '-' attrval INTO maktx_c.
            CONCATENATE maktx_d '-' attrval INTO maktx_d.
            CONCATENATE maktx_e '-' attrval INTO maktx_e.
          ENDIF.
          IF wa_tc_attr-attr = 'GRADE'.
            PERFORM maktx_grade_variations USING: maktx_a wa_tc_attr-value, " A
                                                  maktx_b 'B',
                                                  maktx_c 'C',
                                                  maktx_d 'D',
                                                  maktx_e 'E'.
          ENDIF.
          IF wa_tc_attr-attr = 'SHADE'.
            CONCATENATE maktx_a '-' attrval INTO maktx_a.
            CONCATENATE maktx_b '-' attrval INTO maktx_b.
            CONCATENATE maktx_c '-' attrval INTO maktx_c.
            CONCATENATE maktx_d '-' attrval INTO maktx_d.
            CONCATENATE maktx_e '-' attrval INTO maktx_e.
          ENDIF.

          CLEAR wa_tc_attr.
          UNASSIGN: <table>, <wa>, <fs>.
        ENDLOOP.

        IF matnr_a IS NOT INITIAL AND maktx_a IS NOT INITIAL.
          CLEAR: matnr, maktx.
          matnr = matnr_a.
          maktx = maktx_a.
        ENDIF.

        IF matnr IS NOT INITIAL.
          TRANSLATE matnr TO UPPER CASE.
          wa_update-matnr       = matnr.
          wa_update-maktx       = maktx.
          wa_update-spart       = div.
          wa_update-reqby       = sy-uname.
          wa_update-reqdat      = sy-datum.
          wa_update-reqtim      = sy-uzeit.
          wa_update-matl_grp    = t023-matkl.
          wa_update-act_denier  = zsol_mmcreate-act_denier.
          wa_update-denier_desc = zsol_mmcreate-denier_desc.

          SELECT SINGLE *
              FROM mara
              INTO wa_mara
              WHERE matnr = matnr.
          IF sy-subrc <> 0.
            READ TABLE it_mmcreate INTO wa_mmcreate WITH KEY matnr = matnr
                                                             mat_created = ''.
            IF sy-subrc <> 0.
              MODIFY zsol_mmcreate FROM wa_update.
              IF sy-subrc = 0.
                PERFORM db_grade_variations.
                COMMIT WORK.
                IF sy-subrc = 0.
                  CLEAR msg.
                  CONCATENATE 'Request for material' matnr 'and grade variations successfully created.'
                  INTO msg SEPARATED BY space.
                  MESSAGE msg TYPE 'I'.
                ENDIF.
              ENDIF.
            ELSE.
              CLEAR date.
              CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
                EXPORTING
                  date_internal            = wa_mmcreate-reqdat
                IMPORTING
                  date_external            = date
                EXCEPTIONS
                  date_internal_is_invalid = 1
                  OTHERS                   = 2.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.
              CLEAR msg.
              CONCATENATE matnr 'has already been requested by' wa_mmcreate-reqby 'on' date
              'but not yet approved.' INTO msg SEPARATED BY space.
              MESSAGE msg TYPE 'I' DISPLAY LIKE 'E'.
            ENDIF.
          ELSE.
            CLEAR msg.
            CONCATENATE matnr 'has already been created in master. Processing cancelled.'
            INTO msg SEPARATED BY space.
            MESSAGE msg TYPE 'I' DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'CLR'.
      LOOP AT it_tc_attr INTO wa_tc_attr.
        CLEAR wa_tc_attr-value.
        MODIFY it_tc_attr FROM wa_tc_attr TRANSPORTING value.
        CLEAR wa_tc_attr.
      ENDLOOP.
      CLEAR: zsol_mmcreate-act_denier, zsol_mmcreate-denier_desc, t023-matkl.
    WHEN 'E' OR 'ENDE' OR 'ECAN'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module TC_ATTR_CHANGE_FIELD_ATTR OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE tc_attr_change_field_attr OUTPUT.
  LOOP AT SCREEN.
    IF wa_tc_attr IS NOT INITIAL.
      IF screen-name = 'WA_TC_ATTR-VALUE'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TC_ATTR_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_attr_modify INPUT.
  CLEAR: tabl_name, wa_shelp.
  REFRESH it_shelp.

  IF ok_code <> 'CLR'.
    IF wa_tc_attr-attr IS NOT INITIAL.
      IF wa_tc_attr-attr = 'GRADE'.
        IF wa_tc_attr-value NE 'A'.
          CLEAR msg.
          CONCATENATE 'Invalid value for' wa_tc_attr-attr INTO msg SEPARATED BY space.
          MESSAGE msg TYPE 'E'.
        ELSE.
          MODIFY it_tc_attr FROM wa_tc_attr INDEX tc_attr-current_line.
        ENDIF.
      ELSE.
        PERFORM get_values USING wa_tc_attr-attr.

        IF sy-subrc = 0 AND it_shelp IS NOT INITIAL.
          READ TABLE it_shelp INTO wa_shelp WITH KEY name = wa_tc_attr-value.
          IF sy-subrc = 0 OR ( wa_tc_attr-attr EQ 'DENIER' AND strlen( wa_tc_attr-value ) <= 5 ).
            MODIFY it_tc_attr FROM wa_tc_attr INDEX tc_attr-current_line.
          ELSE.
            CLEAR msg.
            CONCATENATE 'Invalid value for' wa_tc_attr-attr INTO msg SEPARATED BY space.
            MESSAGE msg TYPE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form POPULATE_TC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM populate_tc .
  IF zsol_div_attr-spart NE divkey AND divkey IS NOT INITIAL.
    REFRESH it_tc_attr[].
  ENDIF.
  divkey = zsol_div_attr-spart.
  IF zsol_div_attr-spart IS NOT INITIAL AND it_tc_attr IS INITIAL.
    READ TABLE list INTO value WITH KEY key = zsol_div_attr-spart.
    IF sy-subrc = 0.
      div = value-text.
      CLEAR wa_tspat.
      READ TABLE it_tspat INTO wa_tspat WITH KEY spart = div.
      IF sy-subrc = 0.
        tspat-vtext = wa_tspat-vtext.
      ENDIF.
      go_struct ?= cl_abap_typedescr=>describe_by_data( wa_div_attr ).
      gt_comp = go_struct->get_components( ).

      LOOP AT gt_comp INTO gs_comp.
        IF gs_comp-name NE 'MANDT' AND gs_comp-name NE 'SPART'.
          READ TABLE it_div_attr INTO wa_div_attr WITH KEY (gs_comp-name) = 'X'
                                                            spart = div.
          IF sy-subrc = 0.
            wa_tc_attr-attr = gs_comp-name.
            APPEND wa_tc_attr TO it_tc_attr.
          ENDIF.
        ENDIF.
        CLEAR: wa_tc_attr, wa_div_attr, gs_comp.
      ENDLOOP.
      IF it_tc_attr IS NOT INITIAL.
        DESCRIBE TABLE it_tc_attr LINES v_line.
        tc_attr-lines = v_line.
        REFRESH it_tc_attr_temp[].
        it_tc_attr_temp[] = it_tc_attr[].     " For processing f4 even when it_tc_attr gets cleared on 2nd use
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CASE ok_code.
    WHEN 'ECAN'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SHELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE shelp INPUT.
  CLEAR: tabl_name,
         cursor.

  REFRESH: it_shelp[].

  GET CURSOR LINE cursor.
  IF cursor IS NOT INITIAL.
    READ TABLE it_tc_attr_temp INTO wa_tc_attr_temp INDEX cursor.
    IF sy-subrc = 0.
      PERFORM get_values USING wa_tc_attr_temp-attr.
      IF wa_tc_attr_temp-attr = 'GRADE'.
        DELETE it_shelp WHERE name NE 'A'.
      ENDIF.
      IF sy-subrc = 0 AND it_shelp IS NOT INITIAL.
        CLEAR title.
        CONCATENATE 'Pick a value for' wa_tc_attr_temp-attr INTO title SEPARATED BY space.

        REFRESH: it_shret[].
        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            retfield        = 'NAME'
            dynpprog        = sy-repid
            dynpnr          = sy-dynnr
            dynprofield     = 'WA_TC_ATTR-VALUE'
            window_title    = title
            value_org       = 'S'
*           DISPLAY         = ' '
          TABLES
            value_tab       = it_shelp
            return_tab      = it_shret
          EXCEPTIONS
            parameter_error = 1
            no_values_found = 2
            OTHERS          = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      ELSE.
        MESSAGE 'No values found.' TYPE 'S'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_values USING VALUE(p_attr).
  CASE p_attr.
    WHEN 'DENIER'.
      tabl_name = 'ZSOL_DENIER'.
    WHEN 'FILAMENT'.
      tabl_name = 'ZSOL_FILAMENT'.
    WHEN 'LUSTER'.
      tabl_name = 'ZSOL_LUSTER'.
    WHEN 'CROSS_SECTION'.
      tabl_name = 'ZSOL_CROSS_SECT'.
    WHEN 'GRADE'.
      tabl_name = 'ZSOL_GRADE'.
    WHEN 'SHADE'.
      tabl_name = 'ZSOL_SHADE'.
    WHEN 'TWIST'.
      tabl_name = 'ZSOL_TWIST'.
    WHEN 'TPM'.
      tabl_name = 'ZSOL_TPM'.
    WHEN 'PLY'.
      tabl_name = 'ZSOL_PLY'.
    WHEN 'PLY_TYPE'.
      tabl_name = 'ZSOL_PLY_TYPE'.
    WHEN 'TEXT'.
      tabl_name = 'ZSOL_TEXT'.
  ENDCASE.

  CHECK tabl_name IS NOT INITIAL.
  SELECT name
         descr
    FROM (tabl_name)
    INTO CORRESPONDING FIELDS OF TABLE it_shelp.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REQ_GRADE_VARIATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM db_grade_variations.
  PERFORM update USING: matnr_b maktx_b,
                        matnr_c maktx_c,
                        matnr_d maktx_d,
                        matnr_e maktx_e.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MATNR_GRADE_VARIATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_MATNR  text
*      -->P_GRADE  text
*&---------------------------------------------------------------------*
FORM matnr_grade_variations  USING    p_matnr
                                      p_grade.

  CLEAR attrval.
  attrval = p_grade.
  CONCATENATE p_matnr attrval INTO p_matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKTX_GRADE_VARIATIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_MAKTX  text
*      -->P_GRADE  text
*&---------------------------------------------------------------------*
FORM maktx_grade_variations  USING    p_maktx
                                      p_grade.

  READ TABLE <table> ASSIGNING <wa> WITH KEY ('NAME') = p_grade.
  IF sy-subrc = 0 AND <wa> IS ASSIGNED.
    ASSIGN COMPONENT 'DESCR' OF STRUCTURE <wa> TO <fs>.
    CONCATENATE p_maktx '-' <fs> INTO p_maktx.
  ENDIF.
  UNASSIGN: <wa>, <fs>.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_MATNR  text
*      -->P_MAKTX  text
*&---------------------------------------------------------------------*
FORM update  USING    p_matnr
                      p_maktx.

  CLEAR: wa_update-matnr, wa_update-maktx.
  wa_update-matnr = p_matnr.
  wa_update-maktx = p_maktx.
  MODIFY zsol_mmcreate FROM wa_update.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM input_validation .
  LOOP AT it_tc_attr INTO wa_tc_attr.
    IF wa_tc_attr-value IS INITIAL.
      CLEAR msg.
      CONCATENATE 'Fill in all the required fields:' wa_tc_attr-attr INTO msg SEPARATED BY space.
      MESSAGE msg TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE SCREEN.
    ENDIF.
    CLEAR: wa_tc_attr.
  ENDLOOP.
  IF zsol_mmcreate-act_denier IS INITIAL.
    CLEAR msg.
    CONCATENATE msg 'Fill in all the required fields: Actual Denier' INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE SCREEN.
  ENDIF.
  IF zsol_mmcreate-denier_desc IS INITIAL.
    CLEAR msg.
    CONCATENATE msg 'Fill in all the required fields: Denier Desc.' INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE SCREEN.
  ENDIF.
  IF t023-matkl IS INITIAL.
    CLEAR msg.
    CONCATENATE msg 'Fill in all the required fields: Material Group' INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.
