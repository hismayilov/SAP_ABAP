*&---------------------------------------------------------------------*
*& Report  ZPRG_PO_CREATE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zprg_po_create.

INCLUDE zprg_po_create_dd.     " Data Declarations

INCLUDE zprg_po_create_ss.     " Selection Screen

INCLUDE zprg_po_create_fr.     " Form Routines

*-----------------------------------------------------------------------
*   Initialization
*-----------------------------------------------------------------------

INITIALIZATION.
  PERFORM initialize_variant.
  
*** Added for stp-listbox by SaurabhK  
  PERFORM listbox_init.
  p_kunag = 'PK00001'.  " Default value for ship-to-party, listbox value in pos 1
*** Till Here  
*-----------------------------------------------------------------------
*   At Selection-screen Output.
*-----------------------------------------------------------------------

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'P_VKORG'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'TEXT'   OR
       screen-name = 'TEXTN'  OR
       screen-name = 'TEXTJ'.
      screen-intensified = 1.
      screen-display_3d = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
  
*** Added for stp-listbox by SaurabhK
  " Populate comments for Sales Org and Ship-To-Party
  IF p_vkorg IS NOT INITIAL.
    SELECT SINGLE vtext FROM tvkot INTO text  WHERE vkorg EQ p_vkorg.
  ENDIF.
  IF p_kunag IS NOT INITIAL.
    SELECT SINGLE name1 FROM kna1  INTO textn WHERE kunnr EQ p_kunag.
  ENDIF.
*  SELECT SINGLE name1 FROM kna1  INTO textj WHERE kunnr EQ p_kunagj.
*** Till here
*-----------------------------------------------------------------------
*   At Selection Screen for Variant Selection
*-----------------------------------------------------------------------

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.
*-----------------------------------------------------------------------
*   At Selection Screen
*----------------------------------------------------------------------

AT SELECTION-SCREEN.
  PERFORM pai_of_selection_screen.
*** Added for stp-listbox by SaurabhK
  PERFORM pai_listbox.
*** till here
 
"".........
