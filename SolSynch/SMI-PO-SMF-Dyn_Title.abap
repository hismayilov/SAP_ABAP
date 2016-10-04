" Change title based on doc type
" NACE -> Output Control -> Select EF -> Click Output Types -> Select ZDOM -> Double Click Processing Routines -> Select Smartform
from print output line 

" Global Data -> Initialisation
*  begin of addition by ashwin m. 3.10.2016
IF ls_ekko-bsart EQ 'ZDPO'.
  lv_title = 'DOMESTIC PURCHASE ORDER'.
ELSEIF ls_ekko-bsart EQ 'ZSPO' .
  lv_title = 'SERVICE PURCHASE ORDER'.
ENDIF.
* END OF ADDITION.
