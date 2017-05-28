*&---------------------------------------------------------------------*
*&  Include           ZLMEWPF10
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   convert internal values to external format                         *
*----------------------------------------------------------------------*
FORM value_to_external USING vte_value    TYPE any
                             vte_currency TYPE any
                             vte_extval   TYPE any.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      currency        = vte_currency
      amount_internal = vte_value
    IMPORTING
      amount_external = vte_extval
    EXCEPTIONS
      OTHERS          = 0.

ENDFORM.                    "value_to_external
