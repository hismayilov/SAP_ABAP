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
*"     VALUE(RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  REFRESH: allocvaluesnum[], allocvalueschar[], allocvaluescurr[], return[].

  PERFORM get_qlty_char TABLES allocvaluesnum
                               allocvalueschar
                               allocvaluescurr
                               return
                        USING  material
                               batch.

ENDFUNCTION.
