FUNCTION zsol_bapi_update_qlty_param.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SALES_CONTRACT) TYPE  VBELN
*"     VALUE(MATERIAL) TYPE  MATNR
*"     VALUE(BATCH) TYPE  CHARG_D
*"     VALUE(LORRY_NO) TYPE  ZTB_TRD_SPECS-LORRY_NO
*"     VALUE(ALLOCVALUESNUM) TYPE  ZSOL_TTY_ALLOCVALUESNUM
*"     VALUE(ALLOCVALUESCHAR) TYPE  ZSOL_TTY_ALLOCVALUESCHAR
*"     VALUE(ALLOCVALUESCURR) TYPE  ZSOL_TTY_ALLOCVALUESCURR
*"     VALUE(ULEVEL) TYPE  ZULEVEL
*"     VALUE(ACTION) TYPE  SY-UCOMM
*"  EXPORTING
*"     VALUE(RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  PERFORM input_check TABLES    return
                      CHANGING  sales_contract
                                material
                                batch
                                lorry_no
                                ulevel
                                action.

  IF v_check IS INITIAL.
    PERFORM initial_data_retrieval TABLES return
                                   USING  sales_contract
                                          material
                                          batch
                                          lorry_no.
    IF v_check IS INITIAL.
      CASE action.
        WHEN 'HOLD'.
          PERFORM hold TABLES   allocvaluesnum
                                allocvalueschar
                                allocvaluescurr
                                return
                       USING    material
                                batch.

        WHEN 'SAVE'.
          PERFORM hold TABLES   allocvaluesnum
                                allocvalueschar
                                allocvaluescurr
                                return
                       USING    material
                                batch.
          IF v_status = '1'.
            PERFORM save TABLES return
                         USING ulevel.
          ELSE.
            RETURN.
          ENDIF.
        WHEN OTHERS.
          CLEAR wa_return.

          wa_return-type        = 'E'.
          wa_return-id          = '00'.
          wa_return-number      = '001'.
*          wa_return-message     = 'Invalid action specified'.
          wa_return-message_v1  = 'Invalid action specified'.
          wa_return-message_v2  = ''.
          wa_return-message_v3  = ''.
          wa_return-message_v4  = ''.

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

          IF wa_return IS NOT INITIAL.
            APPEND wa_return TO return.
          ENDIF.
          EXIT.
      ENDCASE.
    ELSE.
      RETURN.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.
ENDFUNCTION.
