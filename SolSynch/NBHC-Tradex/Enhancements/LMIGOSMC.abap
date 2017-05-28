*----------------------------------------------------------------------*
*   INCLUDE LMIGOSMC                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Modify fieldselection
************************************************************************
METHOD set.
  DATA: ls_fs     TYPE ty_s_fs,
        ls_fields TYPE migo_fieldname,
        lt_fields TYPE ty_t_fieldname.
  FIELD-SYMBOLS: <t_fieldselection> TYPE ty_s_fst,
                 <s_fs>             TYPE ty_s_fs.
* Access the fieldselection table and modify the contents
  READ TABLE t_fieldselection ASSIGNING <t_fieldselection>
       WITH TABLE KEY glc = i_global_counter.
* Create internal table with the fields to be processed
  SPLIT i_fields AT ' ' INTO TABLE lt_fields.
  DELETE lt_fields WHERE table_line IS initial.
  APPEND LINES OF it_fields TO lt_fields.
  CASE i_inversion.
    WHEN abap_false.
*     Set the status for the specified fields
      LOOP AT lt_fields INTO ls_fields.
        READ TABLE <t_fieldselection>-table ASSIGNING <s_fs>
             WITH TABLE KEY name = ls_fields.
*       Error in fieldselection list. For the template, this is
*       allowed as the list for GLC 0 has to be copied and contains
*       more entries.
        IF sy-subrc <> 0.
          IF i_global_counter <> c_item_template.
            MESSAGE e899 WITH 'FIELDSELECTION'
                              ls_fields
                              space
                              space.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.
*       Modify MODE fieldselection (Only a lower status is allowed)
        CASE i_mode.
          WHEN abap_false.
            CHECK i_one_way = abap_false OR i_status < <s_fs>-work.
            IF i_status <= <s_fs>-mode.
              <s_fs>-work = i_status.
            ELSE.
              <s_fs>-work = <s_fs>-mode.
            ENDIF.
          WHEN abap_true.
            CHECK i_one_way = abap_false OR i_status < <s_fs>-mode.
            IF i_status <= <s_fs>-sfac.
              <s_fs>-mode = i_status.
              <s_fs>-work = i_status.
            ELSE.
              <s_fs>-mode = <s_fs>-sfac.
              <s_fs>-work = <s_fs>-sfac.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    WHEN abap_true.
*     Process all fields except the ones given in the list
      SORT lt_fields BY table_line.
      LOOP AT <t_fieldselection>-table ASSIGNING <s_fs>.
        READ TABLE lt_fields WITH KEY table_line = <s_fs>-name
                             TRANSPORTING NO FIELDS.
        CHECK sy-subrc <> 0.
        CASE i_mode.
          WHEN abap_false.
            CHECK i_one_way = abap_false OR i_status < <s_fs>-work.
            IF i_status <= <s_fs>-mode.
              <s_fs>-work = i_status.
            ELSE.
              <s_fs>-work = <s_fs>-mode.
            ENDIF.
          WHEN abap_true.
            CHECK i_one_way = abap_false OR i_status < <s_fs>-mode.
            IF i_status <= <s_fs>-sfac.
              <s_fs>-mode = i_status.
              <s_fs>-work = i_status.
            ELSE.
              <s_fs>-mode = <s_fs>-sfac.
              <s_fs>-work = <s_fs>-sfac.
            ENDIF.
        ENDCASE.
      ENDLOOP.
  ENDCASE.
ENDMETHOD.
************************************************************************
* Get the current status of the WORK area
************************************************************************
METHOD get.
  FIELD-SYMBOLS: <ls_fst> TYPE ty_s_fst,
                 <ls_fs>  TYPE ty_s_fs.
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
             WITH TABLE KEY glc = i_global_counter.
  IF sy-subrc <> 0.
    MESSAGE e899 WITH 'FIELDSELECTION=>GET'
                      'GLOBAL_COUNTER'
                      i_global_counter
                      space.
  ENDIF.
  READ TABLE <ls_fst>-table ASSIGNING <ls_fs>
             WITH TABLE KEY name = i_field.
  IF sy-subrc <> 0.
*   BAdI: No error message, if the field is not used on any screen in
*         transaction MIGO. Set r_status=8 (=not valid).
    IF i_badi = x.
      r_status = 8.
      EXIT.
    ENDIF.
    MESSAGE e899 WITH 'FIELDSELECTION=>GET FIELD'
                      i_global_counter
                      i_field
                      space.
  ENDIF.
  r_status = <ls_fs>-work.
ENDMETHOD.
************************************************************************
* Check whether a given field is required
************************************************************************
METHOD get_required.
  FIELD-SYMBOLS: <ls_fst> TYPE ty_s_fst,
                 <ls_fs>  TYPE ty_s_fs.
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
             WITH TABLE KEY glc = i_global_counter.
  CHECK sy-subrc = 0.
  READ TABLE <ls_fst>-table ASSIGNING <ls_fs>
             WITH TABLE KEY name = i_field.
  CHECK sy-subrc = 0.
  r_required = <ls_fs>-work_required.
ENDMETHOD.
************************************************************************
* Main fieldselection routine. Called from SCREENOBJECT in every
* screen and for each line of the TC. This method can handle
* normal fields, tabstrips, table control buttons, and local
* specialties...
************************************************************************
METHOD main.
  FIELD-SYMBOLS:
    <ls_fst>           TYPE lcl_migo_screenmodification=>ty_s_fst,
    <l_required_field> TYPE ANY.
  DATA:
    ls_column TYPE lcl_migo_screenmodification=>ty_s_column,
    ls_fs     TYPE lcl_migo_screenmodification=>ty_s_fs.
ENHANCEMENT-POINT LMIGOSMC_04 SPOTS ES_SAPLMIGO STATIC .
* Access the fieldselection data
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
             WITH TABLE KEY glc = i_global_counter.
  CHECK sy-subrc = 0.
* Execute the screenmodification.
  LOOP AT SCREEN.
    READ TABLE <ls_fst>-table INTO ls_fs
               WITH TABLE KEY name = screen-name.
    CHECK sy-subrc = 0.
*   Columns in the table control: Special handling (as usual...).
*   - 0200 = Table Control-Screen
*   - 1000 = Split quantity popup
*   - GLC initial: If we are in the LOOP AT CONTROL, no column manip.
*   - TYPE = C: Superset for columns in TC.
ENHANCEMENT-SECTION     LMIGOSMC_02 SPOTS ES_SAPLMIGO.
    IF ls_fs-type = 'C' AND
       ( sy-dynnr = '0200' OR sy-dynnr = '1000' ).
*     Read the COLS table of the table control to check
*     whether this element is a column or not (remember: there
*     are buttons in screen 0200, too).
      CASE sy-dynnr.
        WHEN '0200'.
          READ TABLE tv_goitem-cols INTO ls_column
                       WITH KEY screen-name = screen-name
                       TRANSPORTING invisible
                                    index.
        WHEN '1000'.
          READ TABLE tv_gosplit-cols INTO ls_column
                       WITH KEY screen-name = screen-name
                       TRANSPORTING invisible
                                    index.
      ENDCASE.
*     GLC = 0 : Disabling columns
      IF i_global_counter IS INITIAL.
*       Check for SY-SUBRC is necessary as there are data in field-
*       selections which are possibly columns in the TC, but not
*       currently implemented (accounting fields). For these, the
*       MIGO fieldselection is used as a transporter for FS-information.
        IF sy-subrc = 0.
*        Columns disabled by administrator: INVISIBLE = X. Do not touch!
*         Columns disabled by us:            INVISIBLE = 1. Jupedidu!
          CHECK ls_column-invisible <> x.
          ls_column-invisible = c_mod_off.
          IF ls_fs-work = c_invisible.
            ls_column-invisible = c_mod_on.
          ENDIF.
          CASE sy-dynnr.
            WHEN '0200'.
              MODIFY tv_goitem-cols FROM ls_column
                                    INDEX sy-tabix
                                    TRANSPORTING invisible.
            WHEN '1000'.
              MODIFY tv_gosplit-cols FROM ls_column
                                     INDEX sy-tabix
                                     TRANSPORTING invisible.
          ENDCASE.
*         Do not execute normal screen modification!!!
          CONTINUE.
        ENDIF.
      ELSE.
*       GLC > 0: Item modification in TV. Check that column
*       is visible. Necessary to prevent the field itself to
*       be set INVISIBLE (No fields transport. Deadly!)
        CHECK ls_column-invisible = c_mod_off.
      ENDIF.
    ENDIF.
END-ENHANCEMENT-SECTION.
*$*$-Start: LMIGOSMC_02-------------------------------------------------------------------------$*$*
ENHANCEMENT 50  /CWM/APPL_MM_SAPLMIGO.    "active version
    IF ls_fs-type = 'C' AND
       ( sy-dynnr = g_tablev_current_dyn OR sy-dynnr = '1000' ).
*     Read the COLS table of the table control to check
*     whether this element is a column or not (remember: there
*     are buttons in screen 0200, too).
      CASE sy-dynnr.
        WHEN g_tablev_current_dyn.
          READ TABLE <tv_goitem_cols> INTO ls_column
                       WITH KEY screen-name = screen-name
                       TRANSPORTING invisible
                                    index.
        WHEN '1000'.
          READ TABLE tv_gosplit-cols INTO ls_column
                       WITH KEY screen-name = screen-name
                       TRANSPORTING invisible
                                    index.
      ENDCASE.
*     GLC = 0 : Disabling columns
      IF i_global_counter IS INITIAL.
*       Check for SY-SUBRC is necessary as there are data in field-
*       selections which are possibly columns in the TC, but not
*       currently implemented (accounting fields). For these, the
*       MIGO fieldselection is used as a transporter for FS-information.
        IF sy-subrc = 0.
*        Columns disabled by administrator: INVISIBLE = X. Do not touch!
*         Columns disabled by us:            INVISIBLE = 1. Jupedidu!
          CHECK ls_column-invisible <> x.
          ls_column-invisible = c_mod_off.
          IF ls_fs-work = c_invisible.
            ls_column-invisible = c_mod_on.
          ENDIF.
          INCLUDE /CWM/MOD_LMIGOSMC_1 IF FOUND.       "CWM CWEK001982 TB
          CASE sy-dynnr.
            WHEN g_tablev_current_dyn.
              MODIFY <tv_goitem_cols> FROM ls_column
                                      INDEX sy-tabix
                                      TRANSPORTING invisible.
            WHEN '1000'.
              MODIFY tv_gosplit-cols FROM ls_column
                                     INDEX sy-tabix
                                     TRANSPORTING invisible.
          ENDCASE.
*         Do not execute normal screen modification!!!
          CONTINUE.
        ENDIF.
      ELSE.
*       GLC > 0: Item modification in TV. Check that column
*       is visible. Necessary to prevent the field itself to
*       be set INVISIBLE (No fields transport. Deadly!)
        CHECK ls_column-invisible = c_mod_off.
      ENDIF.
    ENDIF.
ENDENHANCEMENT.
*$*$-End:   LMIGOSMC_02-------------------------------------------------------------------------$*$*
ENHANCEMENT-POINT FIELDSELECTION_01 SPOTS ES_SAPLMIGO.
*$*$-Start: FIELDSELECTION_01-------------------------------------------------------------------$*$*
ENHANCEMENT 210  OI0_SAPLMIGO.    "active version
* SHOW TEXT VALAUTION ON LEFT SIDE, EVEN WHEN ONLY RIGHT SIDE IS WITH VAL
    if screen-name = 'GODYNPRO-BWTAR'.
       if goitem-bwtty is initial and not
          goitem-umbwtty is initial.
          ls_fs-work = c_visible.
       endif.
    endif.
*   Disable field 'Qty in PO Price Unit' for HPM and TDP materials
    CLASS CL_OI0_MIGO DEFINITION LOAD.

    if screen-name = 'GOITEM-BPMNG'.
      DATA: l_cmeth type OIB_CMETH.

      l_cmeth =
         cl_im_oib_migo_badi_qci=>get_cmeth_of_item( i_global_counter ).

      if l_cmeth = cl_oi0_migo=>c_cmeth_hpm or
         l_cmeth = cl_oi0_migo=>c_cmeth_tdp.
        if ls_fs-work >= c_input.
          ls_fs-work = c_visible.
        endif.
      endif.
    endif.
ENDENHANCEMENT.
*$*$-End:   FIELDSELECTION_01-------------------------------------------------------------------$*$*
*   Normal fields (no columns of the table control)
    IF ls_fs-work >= c_input.
      screen-invisible = c_mod_off.
      screen-input     = c_mod_on.
    ELSEIF ls_fs-work >= c_visible.
      screen-invisible = c_mod_off.
      screen-input     = c_mod_off.
    ELSE.
      screen-invisible = c_mod_on.
      screen-input     = c_mod_off.
    ENDIF.
*   Tabstrips must be INPUT = 1, even if invisible.
*   Consistency is a nice thing to have, but a hard thing to achieve...
    IF ls_fs-type = 'T'.
      screen-input = c_mod_on.
    ENDIF.
*   Mark required fields for the user. This cannot be done using
*   the REQUIRED attribute, because this would block the transaction.
*   We use INTENSIFIED instead. There is a twin of this code in
*   LMIGODA2 for the fields on the foreign accounting screen.
    IF ls_fs-work_required = abap_true.
*     Check whether the field is empty.
      ASSIGN (screen-name) TO <l_required_field>.
      IF sy-subrc = 0 AND <l_required_field> IS INITIAL.
        screen-intensified = c_mod_on.
      ENDIF.
    ENDIF.
ENHANCEMENT-POINT LMIGOSMC_01 SPOTS ES_SAPLMIGO.
*$*$-Start: LMIGOSMC_01-------------------------------------------------------------------------$*$*
ENHANCEMENT 145  /SAPMP/SEGM_ORDER_PP_SAPLMIGO.    "active version
* mill jw
    if screen-name = 'OK_PARTITIONING'.
      CALL FUNCTION 'MILL_UA1_CHECK_ACTIVE_UA'
        EXCEPTIONS
          ACTIVE        = 1
          OTHERS        = 2.
* no partitioning order button
      IF SY-SUBRC <> 1.
        screen-invisible = c_mod_off.
        screen-input     = c_mod_off.
      ENDIF.
    endif.
ENDENHANCEMENT.
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
            OR screen-name EQ 'GOITEM-LGORT'.
*            OR screen-name EQ 'GOITEM-CHARG'.
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

***Begin of ENH2
***This ENchanment is used to make Document Date & Posting same as PO's DOcument Date
*** BADI Implementation Name  is  'ZMB_MIGO_ITEM_BADI' to set date in Memory
***For Movement type 105 & for Only PO's Doc type will be investment.

if gohead-bldat eq '20000101' or
   gohead-budat eq '20000101'.

***Badi Implementation name

if GODYNPRO-REFDOC eq 'R01' and
   GOITEM is not INITIAL .
*break ftabap.

DATA G_BEDAT TYPE EKKO-BEDAT.
get PARAMETER ID 'ZMESS' FIELD g_bedat.

if g_bedat is not INITIAL.
  gohead-bldat = g_bedat.
  gohead-budat = g_bedat.
FREE MEMORY ID 'ZMESS'.
endif.

ENDIF.
endif.


ENDENHANCEMENT.
*$*$-End:   LMIGOSMC_01-------------------------------------------------------------------------$*$*
    MODIFY SCREEN.
  ENDLOOP.
ENDMETHOD.
************************************************************************
* Copy the current template data to a new line in T_FIELDSELECTION
************************************************************************
METHOD template_copy.
  DATA: ls_fst TYPE ty_s_fst.
  READ TABLE t_fieldselection INTO ls_fst
       WITH TABLE KEY glc = c_item_template.
  ls_fst-glc = i_global_counter.
  INSERT ls_fst INTO TABLE t_fieldselection.
ENDMETHOD.
************************************************************************
* Delete an entry in the fieldselection table
************************************************************************
METHOD delete_item.
  DELETE t_fieldselection WHERE glc = i_global_counter.
ENDMETHOD.
************************************************************************
* Delete all items. Used in Kernel->RESET.
************************************************************************
METHOD delete_all.
  DELETE t_fieldselection WHERE NOT glc IS initial
                            AND NOT glc = c_item_template.
ENDMETHOD.
************************************************************************
* Restore the fieldselection table.
* If called with I_MODE = TRUE --> Copy SFAC into MODE and WORK.
* otherwise operate on MODE -> WORK only.
* Only one GLC at a time.
************************************************************************
METHOD restore.
  FIELD-SYMBOLS: <ls_fst> TYPE ty_s_fst,
                 <ls_fs>  TYPE ty_s_fs.
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
       WITH TABLE KEY glc = i_global_counter.
  LOOP AT <ls_fst>-table ASSIGNING <ls_fs>.
    IF i_mode = abap_true.
      <ls_fs>-mode          = <ls_fs>-sfac.
      <ls_fs>-mode_required = <ls_fs>-sfac_required.
    ENDIF.
    <ls_fs>-work          = <ls_fs>-mode.
    <ls_fs>-work_required = <ls_fs>-mode_required.
  ENDLOOP.
ENDMETHOD.
************************************************************************
* For a given list of fieldnames, look through all global_counter
* lines and return the highest status the field has.
* Used for dynamic disabling of table control columns.
************************************************************************
METHOD dynamic_columns.
  DATA: ls_fs      TYPE ty_s_fs,
        ls_dynamic TYPE ty_s_dynamic.
  FIELD-SYMBOLS: <ls_fst>     TYPE ty_s_fst,
                 <ls_dynamic> TYPE ty_s_dynamic.
* Reset the result field to initial value for all incoming lines
  MODIFY ct_dynamic FROM ls_dynamic TRANSPORTING status
                    WHERE NOT name IS INITIAL.
* Check all lines in the model (GLC = 99999: template)
  LOOP AT t_fieldselection ASSIGNING <ls_fst>
                           WHERE glc <> 0.
*   Fields to be processed
    LOOP AT ct_dynamic ASSIGNING <ls_dynamic>.
*     Get the field status in this line
      READ TABLE <ls_fst>-table INTO ls_fs
           WITH TABLE KEY name = <ls_dynamic>-name.
*     Remember the maximum
      IF ls_fs-work > <ls_dynamic>-status.
        <ls_dynamic>-status = ls_fs-work.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDMETHOD.
************************************************************************
* Set the REQUIRED-attribute for a given field
* This method is not as sophisticated as SET as it is only
* used to set the attribute for movement type depending fields
************************************************************************
METHOD set_required.
  FIELD-SYMBOLS: <ls_fst> TYPE ty_s_fst,
                 <ls_fs>  TYPE ty_s_fs.
  READ TABLE t_fieldselection ASSIGNING <ls_fst>
             WITH TABLE KEY glc = i_global_counter.
  READ TABLE <ls_fst>-table ASSIGNING <ls_fs>
             WITH TABLE KEY name = i_field.
  IF i_mode = abap_true.
    <ls_fs>-mode_required = abap_true.
  ENDIF.
  <ls_fs>-work_required = abap_true.
ENDMETHOD.
************************************************************************
* Locate a field on the dynpros. Return a table of dynpros
* where the specified field is ready for input.
************************************************************************
METHOD field_locate.
  DATA: ls_generated TYPE ty_s_generated,
        l_status     TYPE migo_fs_status.
* Start with a clean result table
  CLEAR et_dynnr.
* Check that the field  is ready for input for the specified GLC
  CALL METHOD get
    EXPORTING
      i_field          = i_field
      i_global_counter = i_global_counter
    RECEIVING
      r_status         = l_status.
  CHECK l_status >= c_input.
* Access the fielddata from the generated include
  READ TABLE t_generated INTO ls_generated
             WITH TABLE KEY name = i_field.
  CHECK sy-subrc = 0.
* Fill the export table from the two available dynpro data
  IF NOT ls_generated-dynnr1 IS INITIAL.
    INSERT ls_generated-dynnr1 INTO TABLE et_dynnr.
  ENDIF.
  IF NOT ls_generated-dynnr2 IS INITIAL.
    INSERT ls_generated-dynnr2 INTO TABLE et_dynnr.
  ENDIF.
ENDMETHOD.
