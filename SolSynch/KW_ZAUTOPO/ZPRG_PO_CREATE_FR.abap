".......
*&---------------------------------------------------------------------*
*&      Form  listbox_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM listbox_init.
*** For listbox ***
  wa_list-key = '1'.
  wa_list-text = 'PK00001'.
  APPEND wa_list TO it_list.
  CLEAR wa_list.

  wa_list-key = '2'.
  wa_list-text = 'PA00030'.
  APPEND wa_list TO it_list.
  CLEAR wa_list.

  l_name = 'LS_KUNAG'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = l_name
      values          = it_list
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    "listbox_init
".........
*&---------------------------------------------------------------------*
*&      Form  pai_listbox
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pai_listbox.
*** For listbox ***
  CLEAR: it_listval, wa_listval.
  REFRESH it_listval.
  wa_listval-fieldname = 'LS_KUNAG'.
  APPEND wa_listval TO it_listval.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = it_listval.

  READ TABLE it_listval INDEX 1 INTO wa_listval.
  IF sy-subrc = 0 AND wa_listval-fieldvalue IS NOT INITIAL.
    READ TABLE it_list INTO wa_list
                      WITH KEY key = wa_listval-fieldvalue.
    IF sy-subrc = 0.
      p_kunag = wa_list-text.
    ENDIF.
  ENDIF.
ENDFORM.                    "pai_listbox
".........
