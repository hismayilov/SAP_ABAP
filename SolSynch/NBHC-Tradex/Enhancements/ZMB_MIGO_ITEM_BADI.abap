METHOD if_ex_mb_migo_item_badi~item_modify.
  DATA g_ebeln TYPE ekko-ebeln.
  DATA g_bedat TYPE ekko-bedat.
  FREE MEMORY ID 'ZMESS'.
  IF is_goitem-ebeln IS NOT INITIAL.
    CLEAR g_bedat.
    IF g_ebeln IS INITIAL.
      SELECT SINGLE bedat FROM ekko
                    INTO g_bedat
                    WHERE ebeln EQ is_goitem-ebeln
                      AND bsart IN ('FF','IF','FM','IM','FC','IC',
                                    'FA','IA','FR','IR','FT','IT',
                                    'FK','IK','FN','IN','FI','II',
                                    'FD','ID','FU','IU').
      IF sy-subrc EQ 0.
        SET PARAMETER ID 'ZMESS' FIELD g_bedat.
      ENDIF.
    ENDIF.

  ENDIF.

****  For Tradex **** || **** Get Stor loc by default from sow ***
  DATA: doctype TYPE ekko-bsart,
        ebeln   TYPE goitem-ebeln.

  ebeln = is_goitem-ebeln.

  IF ebeln IS NOT INITIAL.
    SELECT SINGLE bsart
      FROM ekko
      INTO doctype
      WHERE ebeln = ebeln.
  ENDIF.

  IF sy-subrc = 0.
    IF doctype = 'ZTRD' AND is_goitem-mat_kdauf IS NOT INITIAL. "AND gv_mode = 'A01'.
      SELECT SINGLE lgort
        FROM vbap
        INTO e_stge_loc
        WHERE vbeln = is_goitem-mat_kdauf
        AND posnr = is_goitem-mat_kdpos.
    ENDIF.
  ENDIF.
ENDMETHOD.
