" SAPMF02D - User Exit
" ZXF04U01 - Include

" ...
* ---- Addition by SaurabhK on 13.06.17 04:22 PM to make GST IN Code mandatory for registered customers ---- *
DATA: w_knvi LIKE LINE OF t_knvi.

IF t_knvi[] IS NOT INITIAL.
  READ TABLE t_knvi INTO w_knvi WITH KEY tatyp = 'JOIG'.
  IF sy-subrc = 0 AND w_knvi-taxkd = '0'.
    IF i_kna1-stcd3 IS INITIAL.
      MESSAGE 'GST IN code is mandatory for registered customers' TYPE 'I'.
    ENDIF.
  ENDIF.
ENDIF.
* ---- End of addition ---- *
" ....
