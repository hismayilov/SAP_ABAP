*&---------------------------------------------------------------------*
*& Report ZSOL_CREATE_MAT_PROD_VERS
*&---------------------------------------------------------------------*
*& Author: Saurabh Khare
*& Creation Date: 31.03.17 11:23 PM
*& Description: Create material master product version(with routing assignment)
*&---------------------------------------------------------------------*
REPORT zsol_create_mat_prod_vers.

* Data Declaration *

* Tables *
TABLES: mapl, mkal, mast.

* Internal Tables *
DATA: it_mapl   TYPE TABLE OF mapl, " material - routing groups
      wa_mapl   TYPE mapl,

      it_mast   TYPE TABLE OF mast, " material - BOM
      wa_mast   TYPE mast,

      it_mkal_i TYPE TABLE OF mkal, " insert
      wa_mkal_i TYPE mkal,

      it_mkal   TYPE TABLE OF mkal, " material - prod. vers
      wa_mkal   TYPE mkal,

      it_mkal_u TYPE TABLE OF mkal, " update
      wa_mkal_u TYPE mkal.

* Variables *
DATA: v_verid   TYPE mkal-verid VALUE '0001',    " Product version
      v_text1   TYPE mkal-text1 VALUE 'BOM1',    " Prod vers description
      inc(2)    TYPE c,
      prev_mat  TYPE mapl-matnr,
      prev_plnt TYPE mapl-werks.

* Start of Selection *
START-OF-SELECTION.
  PERFORM get_data.     " Data retrieval
  PERFORM process_data. " Create/Update product versions for fetched materials

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  " If Routing is assigned to the material
  SELECT *
    FROM mapl
    INTO TABLE it_mapl
    WHERE plnty EQ 'N'    " Task type N = Routing
    AND   plnnr NE ''.    " Routing Group

  IF sy-subrc = 0.
    " Alternative BOM for material
    SELECT *
      FROM mast
      INTO TABLE it_mast
      FOR ALL ENTRIES IN it_mapl
      WHERE matnr = it_mapl-matnr
      AND   werks = it_mapl-werks.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .
  IF it_mapl[] IS NOT INITIAL.
    SORT it_mapl[] BY matnr werks plnnr.
    SORT it_mast[] BY matnr werks stlal.
    DELETE ADJACENT DUPLICATES FROM it_mast[] COMPARING matnr werks.

    LOOP AT it_mapl INTO wa_mapl.
      " For materials with multiple routing groups assigned
      " 1 routing group <-> 1 prod. version
      IF  wa_mapl-matnr EQ prev_mat
      AND wa_mapl-werks EQ prev_plnt.           " Check if same matnr, plant as previous loop pass
        CLEAR inc.
        inc = v_verid+3(1) + 1.
        v_verid = v_verid+0(3).
        CONCATENATE v_verid inc INTO v_verid. " 0001, 0002, 0003...

        CLEAR inc.
        inc = v_text1+3(1) + 1.
        v_text1 = v_text1+0(3).
        CONCATENATE v_text1 inc INTO v_text1. " BOM1, BOM2, BOM3...
      ELSE.
        v_verid = '0001'.
        v_text1 = 'BOM1'.
      ENDIF.
      wa_mkal_i-verid = v_verid.          " Product version
      wa_mkal_i-text1 = v_text1.          " Description
      wa_mkal_i-mandt = sy-mandt.         " Client
      wa_mkal_i-matnr = wa_mapl-matnr.    " Material
      wa_mkal_i-werks = wa_mapl-werks.    " Plant
      wa_mkal_i-bdatu = '99991231'.       " Valid-to
      wa_mkal_i-adatu = sy-datum.         " Valid-from
      READ TABLE it_mast INTO wa_mast WITH KEY matnr = wa_mapl-matnr
                                               werks = wa_mapl-werks.
      IF sy-subrc = 0.
        wa_mkal_i-stlal = wa_mast-stlal.  " Alternative BOM
        wa_mkal_i-stlan = wa_mast-stlan.  " BOM Usage
      ENDIF.
      wa_mkal_i-plnty  = wa_mapl-plnty.    " Task list type -> N
      wa_mkal_i-plnnr  = wa_mapl-plnnr.    " Routing Group
      wa_mkal_i-alnal  = wa_mapl-plnal.    " Group Counter
      wa_mkal_i-prfg_f = '1'.              " Check status

      APPEND wa_mkal_i TO it_mkal_i.
      prev_mat  = wa_mapl-matnr.           " Store current matnr, plant for comparison in next loop pass
      prev_plnt = wa_mapl-werks.
      CLEAR: wa_mapl, wa_mast.
    ENDLOOP.

    IF it_mkal_i[] IS NOT INITIAL.
      " Check if already product version is created for material
      SELECT *
        FROM mkal
        INTO TABLE it_mkal
        FOR ALL ENTRIES IN it_mkal_i
        WHERE matnr = it_mkal_i-matnr
        AND   werks = it_mkal_i-werks
        AND   verid = it_mkal_i-verid.

      " Update the product version for the material if already created
      IF sy-subrc = 0.
        LOOP AT it_mkal_i INTO wa_mkal_i.
          READ TABLE it_mkal INTO wa_mkal WITH KEY matnr = wa_mkal_i-matnr
                                                   werks = wa_mkal_i-werks
                                                   verid = wa_mkal_i-verid.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING wa_mkal_i TO wa_mkal_u.
            DELETE it_mkal_i.
            APPEND wa_mkal_u TO it_mkal_u.
          ENDIF.
          CLEAR: wa_mkal_i, wa_mkal, wa_mkal_u.
        ENDLOOP.
      ENDIF.

      " Function module is an update FM (Do not change).
      CALL FUNCTION 'CM_FV_PROD_VERS_DB_UPDATE' IN UPDATE TASK
        TABLES
          it_mkal_i = it_mkal_i
          it_mkal_u = it_mkal_u.

      IF sy-subrc = 0.
        COMMIT WORK.  " Triggers the update FM(Do not remove)
        MESSAGE 'Product version created/updated in material master successfully.' TYPE 'I'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
