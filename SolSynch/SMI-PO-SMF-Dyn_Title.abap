*  begin of addition by ashwin m. 3.10.2016
IF ls_ekko-bsart EQ 'ZDPO'.
  lv_title = 'DOMESTIC PURCHASE ORDER'.
ELSEIF ls_ekko-bsart EQ 'ZSPO' .
  lv_title = 'SERVICE PURCHASE ORDER'.
ENDIF.
* END OF ADDITION.
