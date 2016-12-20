ORM userexit_save_document.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1 ) Form USEREXIT_SAVE_DOCUMENT, Start                                                                                                           D
*$*$-Start: (1 )--------------------------------------------------------------------------------$*$*
ENHANCEMENT 315  ZCHARDATA_SAVE.    "active version

data: wa_update TYPE ztb_trd_specs,
      wa_final  TYPE ztb_trd_specs,
      it_final  TYPE STANDARD TABLE OF ztb_trd_specs,
      wa_head   TYPE ztb_specs_head.

import it_final FROM MEMORY ID 'FINAL'.
import wa_head FROM MEMORY ID 'HEAD'.

IF sy-tcode = 'VA41'.
  IF it_final is not initial.
  LOOP AT it_final INTO wa_final.
    MOVE-CORRESPONDING wa_final to wa_update.
    wa_update-vbeln = vbak-vbeln.
    insert INTO ztb_trd_specs VALUES wa_update.
  ENDLOOP.
  ENDIF.

  if wa_head is not INITIAL.
    wa_head-vbeln = vbak-vbeln.
    INSERT INTO ztb_specs_head VALUES wa_head.
  endif.
ENDIF.

IF sy-tcode = 'VA42'.
  IF it_final is not initial.
  LOOP AT it_final INTO wa_final.
    MOVE-CORRESPONDING wa_final to wa_update.
    wa_update-vbeln = vbak-vbeln.
    update ztb_trd_specs FROM wa_update.
  ENDLOOP.
  ENDIF.

  if wa_head is not INITIAL.
    wa_head-vbeln = vbak-vbeln.
    UPDATE ztb_specs_head from wa_head.
  endif.
ENDIF.

ENDENHANCEMENT.
*$*$-End:   (1 )--------------------------------------------------------------------------------$*$*

* Example:
* CALL FUNCTION 'ZZ_EXAMPLE'
*      IN UPDATE TASK
*      EXPORTING
*           ZZTAB = ZZTAB.

ENDFORM.                    "USEREXIT_SAVE_DOCUMENT
