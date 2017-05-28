*----------------------------------------------------------------------*
***INCLUDE LZSOL_TRADEXF01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  HOLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ALLOCVALUESNUM  text
*      -->ALLOCVALUESCHAR  text
*      -->ALLOCVALUESCURR  text
*      -->MATERIAL  text
*      -->BATCH  text
*      -->RETURN  text
*----------------------------------------------------------------------*
FORM hold  TABLES   allocvaluesnum  STRUCTURE bapi1003_alloc_values_num
                    allocvalueschar STRUCTURE bapi1003_alloc_values_char
                    allocvaluescurr STRUCTURE bapi1003_alloc_values_curr
                    return          STRUCTURE bapiret2
           USING    material
                    batch.

  CLEAR: v_obj, wa_inob, wa_kssk, wa_klah, v_clnum, v_cltype, v_objtab.
  REFRESH: oldvaluesnum[],
           oldvalueschar[],
           oldvaluescurr[],
           return_tab[].

  TRANSLATE material TO UPPER CASE.
  TRANSLATE batch TO UPPER CASE.

  CONCATENATE material batch INTO v_obj RESPECTING BLANKS.

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
    v_clnum  = wa_klah-class.
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
        allocvaluesnum   = oldvaluesnum
        allocvalueschar  = oldvalueschar
        allocvaluescurr  = oldvaluescurr
        return           = return_tab.

    APPEND LINES OF return_tab TO return.

    REFRESH return_tab[].

    IF allocvaluesnum[] IS NOT INITIAL.
      LOOP AT allocvaluesnum INTO wa_valuesnum.
        READ TABLE oldvaluesnum WITH KEY charact = wa_valuesnum-charact.
        IF sy-subrc = 0.
          IF wa_valuesnum-value_from IS INITIAL.
            MOVE oldvaluesnum-value_from TO wa_valuesnum-value_from.
            MODIFY allocvaluesnum FROM wa_valuesnum.
          ENDIF.
          LOOP AT it_specs INTO wa_specs WHERE atnam = wa_valuesnum-charact.
            MOVE wa_valuesnum-value_from TO wa_specs-act_val.
            MODIFY it_specs FROM wa_specs.
            CLEAR wa_specs.
          ENDLOOP.
        ELSE.
          CLEAR: msg, type.
          CONCATENATE 'Characteristic missing or invalid:' wa_valuesnum-charact
            INTO msg SEPARATED BY space.
          type = 'E'.
          PERFORM update_return TABLES return
                                USING  type
                                       msg.
          REFRESH allocvaluesnum[].
          EXIT.
        ENDIF.
        CLEAR: wa_valuesnum, oldvaluesnum.
      ENDLOOP.
    ENDIF.

    IF allocvalueschar[] IS NOT INITIAL.
      LOOP AT allocvalueschar INTO wa_valueschar.
        READ TABLE oldvalueschar WITH KEY charact = wa_valueschar-charact.
        IF sy-subrc = 0.
          IF wa_valueschar-value_char IS INITIAL.
            MOVE oldvalueschar-value_char TO wa_valueschar-value_char.
            MODIFY allocvalueschar FROM wa_valueschar.
          ENDIF.
          LOOP AT it_specs INTO wa_specs WHERE atnam = wa_valueschar-charact.
            MOVE wa_valueschar-value_char TO wa_specs-act_val.
            MODIFY it_specs FROM wa_specs.
            CLEAR wa_specs.
          ENDLOOP.
        ELSE.
          CLEAR: msg, type.
          CONCATENATE 'Characteristic missing or invalid:' wa_valueschar-charact
            INTO msg SEPARATED BY space.
          type = 'E'.
          PERFORM update_return TABLES return
                                USING  type
                                       msg.
          REFRESH allocvalueschar[].
          EXIT.
        ENDIF.
        CLEAR: wa_valueschar, oldvalueschar.
      ENDLOOP.
    ENDIF.

    IF allocvaluescurr[] IS NOT INITIAL.
      LOOP AT allocvaluescurr INTO wa_valuescurr.
        READ TABLE oldvaluescurr WITH KEY charact = wa_valuescurr-charact.
        IF sy-subrc = 0.
          IF wa_valuescurr-value_from IS INITIAL.
            MOVE oldvaluescurr-value_from TO wa_valuescurr-value_from.
            MODIFY allocvaluescurr FROM wa_valuescurr.
          ENDIF.
          LOOP AT it_specs INTO wa_specs WHERE atnam = wa_valuescurr-charact.
            MOVE wa_valuescurr-value_from TO wa_specs-act_val.
            MODIFY it_specs FROM wa_specs.
            CLEAR wa_specs.
          ENDLOOP.
        ELSE.
          CLEAR: msg, type.
          CONCATENATE 'Characteristic missing or invalid:' wa_valuescurr-charact
            INTO msg SEPARATED BY space.
          type = 'E'.
          PERFORM update_return TABLES return
                                USING  type
                                       msg.
          REFRESH allocvaluescurr[].
          EXIT.
        ENDIF.
        CLEAR: wa_valuescurr, oldvaluescurr.
      ENDLOOP.
    ENDIF.

    IF allocvaluesnum[]  IS NOT INITIAL
    OR allocvalueschar[] IS NOT INITIAL
    OR allocvaluescurr[] IS NOT INITIAL.

      CALL FUNCTION 'BAPI_OBJCL_CHANGE'
        EXPORTING
          objectkey          = v_obj
          objecttable        = v_objtab
          classnum           = v_clnum
          classtype          = v_cltype
          status             = '1'
          keydate            = sy-datum
        IMPORTING
          classif_status     = v_status
        TABLES
          allocvaluesnumnew  = allocvaluesnum
          allocvaluescharnew = allocvalueschar
          allocvaluescurrnew = allocvaluescurr
          return             = return_tab.
    ELSE.
      CLEAR: v_status, msg, type.
      msg = 'Update unsuccessful. Please check your input!'.
      type = 'E'.
      PERFORM update_return TABLES return
                            USING  type
                                   msg.
    ENDIF.

    IF v_status = '1'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      CLEAR: msg, type.
      msg = 'Characteristics updated successfully!'.
      type = 'S'.
      PERFORM update_return TABLES return
                            USING  type
                                   msg.
    ELSEIF return_tab[] IS NOT INITIAL.
      APPEND LINES OF return_tab TO return.
    ENDIF.
  ENDIF.

ENDFORM.                    " HOLD
*&---------------------------------------------------------------------*
*&      Form  GET_QLTY_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ALLOCVALUESNUM   text
*      -->ALLOCVALUESCHAR  text
*      -->ALLOCVALUESCURR  text
*      -->RETURN    text
*      -->MATERIAL  text
*      -->BATCH     text
*----------------------------------------------------------------------*
FORM get_qlty_char  TABLES   allocvaluesnum  STRUCTURE bapi1003_alloc_values_num
                             allocvalueschar STRUCTURE bapi1003_alloc_values_char
                             allocvaluescurr STRUCTURE bapi1003_alloc_values_curr
                             return          STRUCTURE bapiret2
                    USING    material
                             batch.

  CLEAR: v_obj, wa_inob, wa_kssk, wa_klah, v_clnum, v_cltype, v_objtab.

  TRANSLATE material TO UPPER CASE.
  TRANSLATE batch TO UPPER CASE.

  CONCATENATE material batch INTO v_obj RESPECTING BLANKS.

  IF v_obj IS NOT INITIAL.
    SELECT SINGLE *
      FROM inob
      INTO CORRESPONDING FIELDS OF wa_inob
      WHERE objek EQ v_obj.

    IF sy-subrc = 0.
      SELECT SINGLE *
        FROM kssk
        INTO CORRESPONDING FIELDS OF wa_kssk
        WHERE objek EQ wa_inob-cuobj.

      IF sy-subrc = 0.
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
              allocvaluesnum   = allocvaluesnum
              allocvalueschar  = allocvalueschar
              allocvaluescurr  = allocvaluescurr
              return           = return_tab.

          APPEND LINES OF return_tab TO return.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR: msg, type.
    msg = 'Both material and batch are mandatory'.
    type = 'E'.
    PERFORM update_return TABLES return
                          USING type
                                msg.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_QLTY_CHAR
*&---------------------------------------------------------------------*
*&      Form  UPDATE_RETURN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RETURN  text
*      -->MSG  text
*      -->TYPE text
*----------------------------------------------------------------------*
FORM update_return  TABLES  return STRUCTURE bapiret2
                    USING type
                          msg.
  CLEAR wa_return.

  wa_return-type        = type.
  wa_return-id          = '00'.
  wa_return-number      = '001'.
  wa_return-message     = msg.

  IF wa_return IS NOT INITIAL.
    APPEND wa_return TO return.
  ENDIF.
ENDFORM.                    " UPDATE_RETURN
*&---------------------------------------------------------------------*
*&      Form  INPUT_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RETURN  text
*      -->SALES_CONTRACT  text-->
*      -->MATERIAL  text      -->
*      -->BATCH  text         -->
*      -->LORRY_NO  text      -->
*      -->ULEVEL  text        -->
*      -->ACTION  text        -->
*----------------------------------------------------------------------*
FORM input_check  TABLES   return STRUCTURE bapiret2
                  CHANGING sales_contract
                           material
                           batch
                           lorry_no
                           ulevel
                           action.

  CLEAR: msg, type, v_check.

  IF sales_contract IS INITIAL.
    msg = 'Sales Contract'.
    v_check = 'X'.
  ELSE.
    TRANSLATE sales_contract TO UPPER CASE.
  ENDIF.

  IF material IS INITIAL.
    CONCATENATE msg 'Material' INTO msg SEPARATED BY ','.
    v_check = 'X'.
  ELSE.
    TRANSLATE material TO UPPER CASE.
  ENDIF.

  IF batch IS INITIAL.
    CONCATENATE msg 'Batch' INTO msg SEPARATED BY ','.
    v_check = 'X'.
  ELSE.
    TRANSLATE batch TO UPPER CASE.
  ENDIF.

  IF lorry_no IS INITIAL.
    CONCATENATE msg 'Lorry No' INTO msg SEPARATED BY ','.
    v_check = 'X'.
  ELSE.
    TRANSLATE lorry_no TO UPPER CASE.
  ENDIF.

  IF ulevel IS INITIAL.
    CONCATENATE msg 'User Level' INTO msg SEPARATED BY ','.
    v_check = 'X'.
  ELSE.
    TRANSLATE ulevel TO UPPER CASE.
  ENDIF.

  IF action IS INITIAL.
    CONCATENATE msg 'Action' INTO msg SEPARATED BY ','.
    v_check = 'X'.
  ELSE.
    TRANSLATE action TO UPPER CASE.
  ENDIF.

  IF v_check EQ 'X'.
    CONCATENATE 'Mandatory input missing:' msg INTO msg SEPARATED BY space.
    type = 'E'.
    PERFORM update_return TABLES return
                          USING type
                                msg.
    RETURN.
  ENDIF.
ENDFORM.                    " INPUT_CHECK
*&---------------------------------------------------------------------*
*&      Form  INITIAL_DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RETURN  text
*      -->SALES_CONTRACT  text
*      -->MATERIAL  text
*      -->BATCH  text
*      -->LORRY_NO  text
*----------------------------------------------------------------------*
FORM initial_data_retrieval  TABLES   return STRUCTURE bapiret2
                             USING    sales_contract
                                      material
                                      batch
                                      lorry_no.

  CLEAR v_check.
  REFRESH: it_mska[], it_specs[].

  SELECT *
        FROM mska
        INTO CORRESPONDING FIELDS OF TABLE it_mska
        WHERE matnr EQ material
        AND   charg EQ batch
        AND   vbeln EQ sales_contract
        AND   kains GT 0.

  IF sy-subrc = 0.
    SELECT *
     FROM ztb_trd_specs
     INTO CORRESPONDING FIELDS OF TABLE it_specs
     FOR ALL ENTRIES IN it_mska
     WHERE vbeln EQ it_mska-vbeln
     AND   posnr EQ it_mska-posnr
     AND   matnr EQ it_mska-matnr
     AND   lorry_no EQ lorry_no.

    IF sy-subrc <> 0.
      CLEAR: msg, type.
      msg = 'No qlty specs maintained in SOW for given criteria'.
      type = 'E'.
      PERFORM update_return TABLES return
                          USING type
                                msg.
      v_check = 'X'.
      RETURN.
    ENDIF.
  ELSE.
    CLEAR: msg, type.
    msg = 'No stock found in quality for given criteria'.
    type = 'E'.
    PERFORM update_return TABLES return
                          USING type
                                msg.
    v_check = 'X'.
    RETURN.
  ENDIF.
ENDFORM.                    " INITIAL_DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*&      Form  SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RETURN  text
*      -->ULEVEL  text
*----------------------------------------------------------------------*
FORM save TABLES   return STRUCTURE bapiret2
          USING    ulevel.

  LOOP AT it_specs INTO wa_specs. "WHERE act_val IS NOT INITIAL.
**********
*** CHECK ACT_VAL TYPE
*** ADD FOR CHAR TYPE
    IF ulevel IS INITIAL.
      ulevel = '0'.
    ENDIF.

    IF ( ulevel EQ '0' ).
      IF ( wa_specs-low_lim IS INITIAL AND wa_specs-up_lim IS NOT INITIAL ).
        IF ( wa_specs-act_val GE wa_specs-specs AND wa_specs-act_val LE wa_specs-up_lim ).
          wa_specs-act_dect = ABS( wa_specs-act_val - wa_specs-specs ) * wa_specs-dect.
          v_accept = 'X'.

          PERFORM db_update.
        ELSEIF wa_specs-act_val GT wa_specs-up_lim.
          CLEAR: msg, type, v_accept.
          msg = 'Deduction out of bounds: You are not authorised to accept.'.
          type = 'E'.
          PERFORM update_return TABLES return
                          USING type
                                msg.
          RETURN.
        ELSE.
          v_accept = 'X'.
        ENDIF.
      ELSEIF ( wa_specs-low_lim IS NOT INITIAL AND wa_specs-up_lim IS INITIAL ).
        IF ( wa_specs-act_val LE wa_specs-specs  AND wa_specs-act_val GE wa_specs-low_lim ).
          wa_specs-act_dect = ABS( wa_specs-act_val - wa_specs-specs ) * wa_specs-dect.
          v_accept = 'X'.

          PERFORM db_update.
        ELSEIF wa_specs-act_val LT wa_specs-low_lim.
          CLEAR: msg, type, v_accept.
          msg = 'Deduction out of bounds: You are not authorised to accept.'.
          type = 'E'.
          PERFORM update_return TABLES return
                          USING type
                                msg.
          RETURN.
        ELSE.
          v_accept = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ulevel = '1'.
      IF ( wa_specs-low_lim IS INITIAL AND wa_specs-up_lim IS NOT INITIAL ).
        IF wa_specs-act_val GT wa_specs-up_lim.
          wa_specs-act_dect = ABS( wa_specs-act_val - wa_specs-specs ) * wa_specs-dect. "update ztab with act_dect
          v_accept = 'X'.

          PERFORM db_update.
        ENDIF.
      ELSEIF ( wa_specs-low_lim IS NOT INITIAL AND wa_specs-up_lim IS INITIAL ).
        IF wa_specs-act_val LT wa_specs-low_lim.
          wa_specs-act_dect = ABS( wa_specs-act_val - wa_specs-specs ) * wa_specs-dect. "update ztab with act_dect
          v_accept = 'X'.

          PERFORM db_update.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ulevel = '2'.
      v_accept = 'X'. " No deduction calc or DB Update
    ENDIF.

    MODIFY it_specs FROM wa_specs.
    CLEAR wa_specs.
  ENDLOOP.

  IF it_specs[] IS NOT INITIAL.
    DELETE ADJACENT DUPLICATES FROM it_specs COMPARING vbeln posnr.
    IF it_specs[] IS NOT INITIAL.
      REFRESH: it_vbap[].

      SELECT *
         FROM vbap
         INTO CORRESPONDING FIELDS OF TABLE it_vbap
         FOR ALL ENTRIES IN it_specs
         WHERE vbeln EQ it_specs-vbeln
         AND posnr EQ it_specs-posnr.

      IF sy-subrc <> 0.
        CLEAR: msg, type.
        msg = 'No SOW details found for given criteria'.
        type = 'E'.
        PERFORM update_return TABLES return
                         USING type
                               msg.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  IF v_accept = 'X'.
* ---- Header ---- *
    wa_head-pstng_date  = sy-datum.
    wa_head-doc_date    = sy-datum.

    gm_code = '04'.

* ---- Line items ---- *
* ---- Could be modified later if not all line items need to be processed ---- *
    LOOP AT it_specs INTO wa_specs.
      READ TABLE it_mska INTO wa_mska WITH KEY vbeln = wa_specs-vbeln
                                               posnr = wa_specs-posnr
                                               matnr = wa_specs-matnr.
      IF sy-subrc = 0.
        READ TABLE it_vbap INTO wa_vbap WITH KEY vbeln = wa_specs-vbeln
                                                 posnr = wa_specs-posnr.

        IF sy-subrc = 0.
          wa_item-material        = wa_specs-matnr.
          wa_item-plant           = wa_mska-werks.
          wa_item-stge_loc        = wa_mska-lgort.
          wa_item-batch           = wa_specs-charg.
          wa_item-move_type       = '321'.
          wa_item-spec_stock      = 'E'.
          wa_item-entry_qnt       = wa_mska-kains.
          wa_item-entry_uom       = wa_vbap-vrkme.
          wa_item-move_stloc      = wa_mska-lgort.
          wa_item-val_sales_ord   = wa_specs-vbeln.
          wa_item-val_s_ord_item  = wa_specs-posnr.

          APPEND wa_item TO it_item.
          CLEAR: wa_item.
          REFRESH return_tab[].
        ENDIF.
      ENDIF.
      CLEAR: wa_specs, wa_mska, wa_vbap.
    ENDLOOP.
  ENDIF.

  IF wa_head IS NOT INITIAL AND it_item[] IS NOT INITIAL.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = wa_head
        goodsmvt_code    = gm_code
      IMPORTING
        materialdocument = mat_doc
        matdocumentyear  = doc_year
      TABLES
        goodsmvt_item    = it_item
        return           = return_tab.

    IF mat_doc IS NOT INITIAL AND sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      CLEAR: msg, type.
      CONCATENATE 'Doc.' mat_doc 'with' doc_year 'has been created!' INTO msg SEPARATED BY space.
      type = 'S'.
      PERFORM update_return TABLES return
                            USING type
                                  msg.
    ELSE.
      APPEND LINES OF return_tab TO return.
      RETURN.
    ENDIF.
  ELSE.
    CLEAR: msg, type.
    msg = 'No details supplied for goods movement'.
    type = 'E'.
    PERFORM update_return TABLES return
                          USING type
                                msg.
  ENDIF.

ENDFORM.                    " SAVE
*&---------------------------------------------------------------------*
*&      Form  DB_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM db_update .
  UPDATE ztb_trd_specs SET act_dect = wa_specs-act_dect
                WHERE vbeln = wa_specs-vbeln
                AND   atnam = wa_specs-atnam
                AND   matnr = wa_specs-matnr
                AND   lorry_no = wa_specs-lorry_no.
  COMMIT WORK.
ENDFORM.                    " DB_UPDATE
