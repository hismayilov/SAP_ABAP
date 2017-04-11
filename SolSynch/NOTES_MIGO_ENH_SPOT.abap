Field enhancements in MIGO
Program : SAPLMIGO
Include : LMIGOSMC
Sample Enhancement Implementation in that include: 
ENHANCEMENT 237  ZES_SAPLMIGO_LMIGOSMC_01.    "active version

***Begin of ENH1
***This Enhancement is used make Delivery Note Field Mandatory for Movement type 101

DATA: doctype TYPE ekko-bsart.

  IF godynpro-action EQ 'A01' AND
     godynpro-refdoc EQ 'R01' AND
     godefault_tv-bwart EQ '101'.
    IF goitem IS NOT INITIAL AND
       gohead-lfsnr IS INITIAL.
      IF screen-name EQ 'GOHEAD-LFSNR'.
        screen-required = c_mod_on.
      ENDIF.
    ENDIF.
*** Added by SaurabhK to grey out storage location field in MIGO for TRADEX
    IF goitem IS NOT INITIAL.
      IF goitem-ebeln IS NOT INITIAL.
*      AND GOITEM-LGOBE IS NOT INITIAL
*      AND GOITEM-LGORT IS NOT INITIAL.
        SELECT SINGLE bsart
          FROM ekko
          INTO doctype
          WHERE ebeln = goitem-ebeln.
        IF doctype = 'ZTRD' AND goitem-mat_kdauf IS NOT INITIAL.
          IF screen-name EQ 'GOITEM-LGOBE'
            OR screen-name EQ 'GOITEM-LGORT'
            OR screen-name EQ 'GOITEM-CHARG'.
            screen-input = c_mod_off.
          ENDIF.
*          IF goitem-lgort is INITIAL and sy-dynnr = '0325'.
*            MESSAGE 'Please update storage location in SOW first.' TYPE 'S'.
*          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*** Till here ***
  ELSEIF godefault_tv-bwart NE '101'.
    IF screen-name EQ 'GOHEAD-LFSNR'.
      screen-required = c_mod_off.
    ENDIF.
  ENDIF.
***ENd of ENH1
