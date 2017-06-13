" SAPMF2K  - User Exit
" ZXF05U01 - Include

*&---------------------------------------------------------------------*
*&  Include           ZXF05U01
*&---------------------------------------------------------------------*

" ...
* ---- Addition by SaurabhK on 13.06.17 02:21 PM to make GST IN Code mandatory for registered vendors ---- *
FIELD-SYMBOLS: <venclass> TYPE j_1imovend-ven_class.
DATA: venclass TYPE j_1imovend-ven_class.

ASSIGN ('(SAPLJ1I_MASTER)J_1IMOVEND-VEN_CLASS') TO <venclass> .

IF <venclass> IS ASSIGNED.
  venclass = <venclass>.
  IF venclass IS INITIAL.
    IF i_lfa1-stcd3 IS INITIAL.
      MESSAGE 'GST IN code is mandatory for registered vendors' TYPE 'E'.
    ENDIF.
  ENDIF.
ELSE.
  MESSAGE 'Vendor class is not maintained' TYPE 'E'.
ENDIF.
* ---- End of Addition ---- *
... "
