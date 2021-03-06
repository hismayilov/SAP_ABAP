* Screen 100 PBO/PAI Flow Logic *
PROCESS BEFORE OUTPUT.
  MODULE status_0100.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TC_ATTR'
  MODULE tc_attr_change_tc_attr.
*&SPWIZARD: MODULE TC_ATTR_CHANGE_COL_ATTR.
  LOOP AT   it_tc_attr
       INTO wa_tc_attr
       WITH CONTROL tc_attr
       CURSOR tc_attr-current_line.
*&SPWIZARD:   MODULE TC_ATTR_CHANGE_FIELD_ATTR
    MODULE tc_attr_change_field_attr.
  ENDLOOP.

PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TC_ATTR'
  LOOP AT it_tc_attr.
    CHAIN.
      FIELD wa_tc_attr-attr.
      FIELD wa_tc_attr-value.
      MODULE tc_attr_modify ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command_0100.
  MODULE exit AT EXIT-COMMAND.

PROCESS ON VALUE-REQUEST.
  FIELD wa_tc_attr-value MODULE shelp.
*&SPWIZARD: MODULE TC_ATTR_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC_ATTR_CHANGE_COL_ATTR.
