*&---------------------------------------------------------------------*
*&  Include           ZLMEWPF04
*&---------------------------------------------------------------------*

TABLES: tprg.

*----------------------------------------------------------------------*
*   Convert Date-Type from internal to external format                 *
*----------------------------------------------------------------------*
FORM date_category_convert_external USING  dcc_type_ext TYPE any
                                           dcc_type_int TYPE any.

  CLEAR dcc_type_ext.
  SELECT * FROM tprg WHERE spras EQ sy-langu.
    IF tprg-prgrs EQ dcc_type_int.
      dcc_type_ext = tprg-prgbz.
      EXIT.
    ENDIF.
  ENDSELECT.

ENDFORM.                    "date_category_convert_external
