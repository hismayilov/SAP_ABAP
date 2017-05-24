FUNCTION zsol_bapi_get_qlty_param.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(MATERIAL) TYPE  MATNR
*"     VALUE(BATCH) TYPE  CHARG_D
*"  EXPORTING
*"     VALUE(ALLOCVALUESNUM) TYPE  ZSOL_TTY_ALLOCVALUESNUM
*"     VALUE(ALLOCVALUESCHAR) TYPE  ZSOL_TTY_ALLOCVALUESCHAR
*"     VALUE(ALLOCVALUESCURR) TYPE  ZSOL_TTY_ALLOCVALUESCURR
*"     VALUE(RETURN) TYPE  ZTT_BAPIRETURN
*"----------------------------------------------------------------------

  DATA: v_obj    TYPE inob-objek,
        wa_inob  TYPE inob,
        wa_klah  TYPE klah,
        wa_kssk  TYPE kssk,
        v_clnum  TYPE bapi1003_key-classnum,
        v_cltype TYPE bapi1003_key-classtype,
        v_objtab TYPE bapi1003_key-objecttable,
        w_return LIKE LINE OF return.

  REFRESH: allocvaluesnum[], allocvalueschar[], allocvaluescurr[], return[].

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
              return           = return.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR w_return.

    w_return-type        = 'E'.
    w_return-id          = '00'.
    w_return-number      = '001'.
    w_return-message_v1  = 'Both material and batch are mandatory'.
    w_return-message_v2  = ''.
    w_return-message_v3  = ''.
    w_return-message_v4  = ''.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = w_return-type
        cl     = w_return-id
        number = w_return-number
        par1   = w_return-message_v1
        par2   = w_return-message_v2
        par3   = w_return-message_v3
        par4   = w_return-message_v4
      IMPORTING
        return = w_return.

    IF w_return IS NOT INITIAL.
      APPEND w_return TO return.
    ENDIF.

    EXIT.
  ENDIF.
ENDFUNCTION.
