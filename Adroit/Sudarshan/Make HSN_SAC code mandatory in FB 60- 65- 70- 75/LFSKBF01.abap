*&---------------------------------------------------------------------*
*&      Form  TRANSPORT_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transport_fields.

* save acgl_item
   *acgl_item = acgl_item.
* rette alte Werte aus tab_fskb (non  screen fields, LZBKZ for instance)
* die auf detailsecreen eingegeben wurden
  MOVE-CORRESPONDING tab_fskb TO acgl_item.
  PERFORM move_fkber_from_bseg                              "Note428165
              USING                                         "Note428165
                  tab_fskb-fkber                            "Note428165
                  tab_fskb-fkber_long                       "Note428165
              CHANGING                                      "Note428165
                  acgl_item-fkber.                          "Note428165

* überschreibe acgl_item mit den aktuellen Inhalten der screen Felder
  PERFORM move_acgl_item.
* berücksichtige abgeleitete Werte
*  acgl_item-shkzg = *acgl_item-shkzg.
*  acgl_item-wrbtr = *acgl_item-wrbtr.
*  acgl_item-bschl = *acgl_item-bschl.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Form TRANSPORT_FIELDS, End                                                                                                                        A
*$*$-Start: (1)---------------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZHSN_CODE_MANDATE_FB60.    "active version
IF sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65' OR sy-tcode EQ 'FB70' OR sy-tcode EQ 'FB75'.
  IF sy-ucomm EQ 'BS' OR sy-ucomm EQ 'BU' OR sy-ucomm EQ 'BP'.
    IF acgl_item-hkont IS NOT INITIAL AND acgl_item-bschl IS NOT INITIAL AND acgl_item-koart IS NOT INITIAL.
      IF acgl_item-hsn_sac IS INITIAL.
        SET CURSOR FIELD 'ACGL_ITEM-HSN_SAC' LINE sy-stepl.
        MESSAGE 'HSN/SAC code is mandatory' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
ENDENHANCEMENT.
*$*$-End:   (1)---------------------------------------------------------------------------------$*$*
ENDFORM.
