ENHANCEMENT 1  ZSCREEN_500.    "active version

DATA: t_aufnr TYPE aufnr,
      t_auart TYPE aufart.

SELECT SINGLE aufnr auart into ( t_aufnr, t_auart ) from aufk where aufnr = cowb_comp-aufnr.

IF screen-name = 'COWB_COMP-LGORT'.

  IF sy-uname EQ 'VIMALNA' OR sy-uname EQ 'PANKAJTA' OR sy-uname EQ 'RISHIKO'.
    " Implementation missing
  ELSEIF cowb_comp-bwart = '261' AND t_auart = 'ZF01'.

    screen-input = 0.
    MODIFY SCREEN.
  ENDIF.
ENDIF.

*---------Disable adding new items/editng existing items in CO11N except for specific users----------
*---------Implemented in conjuction with BADI Z_WORKORDER_GOODSMVT/ Do not permit changes to BWART--------"
" Added by saurabhk on 09.01.2017.
*IF sy-tcode EQ 'CO11N'.
*  IF sy-uname <> 'VIMALNA' AND sy-uname <> 'RPN' AND sy-uname <> 'RISHIKO' AND sy-uname <> 'SUVIDHME'.
*    IF t_auart = 'ZF01'.
*      IF <tctrl>-current_line GE lv_lines.
*        <tctrl>-lines = lv_lines.
*        screen-input = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*ENDIF.
" Till here

ENDENHANCEMENT.
