**** Added TBC on screen via wizard and added code in include ZSOL_INCL_ADDB_SOW

PROCESS BEFORE OUTPUT.

  MODULE set_data.
  MODULE get_data.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TBC_8459'
  MODULE tbc_8459_change_tc_attr.
*&SPWIZARD: MODULE TBC_8459_CHANGE_COL_ATTR.
  LOOP AT   it_chardata INTO wa_chardata WITH CONTROL tbc_8459
       CURSOR tbc_8459-current_line.
    MODULE tbc_8459_get_lines.
*&SPWIZARD:   MODULE TBC_8459_CHANGE_FIELD_ATTR
  ENDLOOP.
*                            Verarbeitung vor der Ausgabe
PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TBC_8459'
  LOOP AT it_chardata.
    CHAIN.
      FIELD wa_chardata-atbez.
      FIELD wa_chardata-meins.
      FIELD wa_chardata-specs.
      FIELD wa_chardata-low_lim.
      FIELD wa_chardata-up_lim.
      FIELD wa_chardata-dect.
      MODULE tbc_8459_modify ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.

  MODULE tbc_8459_user_command.
  MODULE store_data.
*&SPWIZARD: MODULE TBC_8459_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TBC_8459_CHANGE_COL_ATTR.

*                            Verarbeitung nach der Eingabe
