" BADI NAME: Z_WORKORDER_GOODSMVT
" Client Shree Mahavir
" Badi to allow changes to Goods MVT type in CO11N from default only to certain users

" Method: COMPLETE_GOODSMOVEMENT
  METHOD if_ex_workorder_goodsmvt~complete_goodsmovement.

*EXPORT is_cowb_comp_old-bwart FROM is_cowb_comp_old-bwart to MEMORY ID 'SAP'.

  ENDMETHOD.

" Method: GM_SCREEN_LINE_CHECK
METHOD if_ex_workorder_goodsmvt~gm_screen_line_check.

*    DATA : v_old TYPE mseg-bwart.
*
*    IMPORT is_cowb_comp_old-bwart TO v_old FROM MEMORY ID 'SAP'.
*
*    IF sy-uname <> 'VIMALNA' AND sy-uname <> 'RPN' AND sy-uname <> 'RISHIKO'.
*      IF v_old NE i_cowb_comp-bwart.
*        MESSAGE 'YOU ARE NOT AUTHORIZED TO CHANGE MOVEMENT TYPE.' TYPE 'E'.
*      ENDIF.
*    ENDIF.

  ENDMETHOD.
