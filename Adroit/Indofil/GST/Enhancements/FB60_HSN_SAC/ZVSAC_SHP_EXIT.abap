FUNCTION ZVSAC_SHP_EXIT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------
*{   INSERT         IRDK928385                                        1

* EXIT immediately, if you do not want to handle this step
  IF CALLCONTROL-STEP <> 'SELONE' AND
     CALLCONTROL-STEP <> 'SELECT' AND
     " AND SO ON
     CALLCONTROL-STEP <> 'DISP'.
     EXIT.
  ENDIF.

*}   INSERT
*"----------------------------------------------------------------------
*{   INSERT         IRDK928385                                        2
* STEP SELONE  (Select one of the elementary searchhelps)
*}   INSERT
*"----------------------------------------------------------------------
*{   INSERT         IRDK928385                                        3
* This step is only called for collective searchhelps. It may be used
* to reduce the amount of elementary searchhelps given in SHLP_TAB.
* The compound searchhelp is given in SHLP.
* If you do not change CALLCONTROL-STEP, the next step is the
* dialog, to select one of the elementary searchhelps.
* If you want to skip this dialog, you have to return the selected
* elementary searchhelp in SHLP and to change CALLCONTROL-STEP to
* either to 'PRESEL' or to 'SELECT'.
  IF CALLCONTROL-STEP = 'SELONE'.
*   PERFORM SELONE .........
    EXIT.
  ENDIF.

*}   INSERT
*"----------------------------------------------------------------------
*{   INSERT         IRDK928385                                        4
* STEP PRESEL  (Enter selection conditions)
*}   INSERT
*"----------------------------------------------------------------------
*{   INSERT         IRDK928385                                        5
* This step allows you, to influence the selection conditions either
* before they are displayed or in order to skip the dialog completely.
* If you want to skip the dialog, you should change CALLCONTROL-STEP
* to 'SELECT'.
* Normaly only SHLP-SELOPT should be changed in this step.
  IF CALLCONTROL-STEP = 'PRESEL'.
*   PERFORM PRESEL ..........
    EXIT.
  ENDIF.
*}   INSERT
*"----------------------------------------------------------------------
*{   INSERT         IRDK928385                                        6
* STEP SELECT    (Select values)
*}   INSERT
*"----------------------------------------------------------------------
*{   INSERT         IRDK928385                                        7
* This step may be used to overtake the data selection completely.
* To skip the standard seletion, you should return 'DISP' as following
* step in CALLCONTROL-STEP.
* Normally RECORD_TAB should be filled after this step.
* Standard function module F4UT_RESULTS_MAP may be very helpfull in this
* step.
  IF CALLCONTROL-STEP = 'SELECT'.
*   PERFORM STEP_SELECT TABLES RECORD_TAB SHLP_TAB
*                       CHANGING SHLP CALLCONTROL RC.
    TYPES: BEGIN OF ty_shp,
             j_1ichid TYPE j_1ichidtx-j_1ichid,
             j_1icht1 TYPE j_1ichidtx-j_1icht1,
           END OF ty_shp.

    DATA: it_shp TYPE TABLE OF ty_shp,
          wa_shp TYPE ty_shp.

    SELECT j_1ichid j_1icht1
      FROM j_1ichidtx
      INTO TABLE it_shp
      WHERE j_1ichid LIKE '99____'  " Begin with 99 and length 6 chars
      AND   langu EQ sy-langu.

    CALL FUNCTION 'F4UT_RESULTS_MAP'
*     EXPORTING
*       SOURCE_STRUCTURE         =
*       APPLY_RESTRICTIONS       = ' '
      TABLES
        shlp_tab          = shlp_tab
        record_tab        = record_tab
        source_tab        = it_shp
      CHANGING
        shlp              = shlp
        callcontrol       = callcontrol
      EXCEPTIONS
        illegal_structure = 1
        OTHERS            = 2.
    IF sy-subrc = 0.
      callcontrol-step = 'DISP'.
    ELSE.
      callcontrol-step = 'EXIT'.
    ENDIF.
    EXIT. "Don't process STEP DISP additionally in this call.
  ENDIF.
*}   INSERT
*"----------------------------------------------------------------------
*{   INSERT         IRDK928385                                        8
* STEP DISP     (Display values)
*}   INSERT
*"----------------------------------------------------------------------
*{   INSERT         IRDK928385                                        9
* This step is called, before the selected data is displayed.
* You can e.g. modify or reduce the data in RECORD_TAB
* according to the users authority.
* If you want to get the standard display dialog afterwards, you
* should not change CALLCONTROL-STEP.
* If you want to overtake the dialog on you own, you must return
* the following values in CALLCONTROL-STEP:
* - "RETURN" if one line was selected. The selected line must be
*   the only record left in RECORD_TAB. The corresponding fields of
*   this line are entered into the screen.
* - "EXIT" if the values request should be aborted
* - "PRESEL" if you want to return to the selection dialog
* Standard function modules F4UT_PARAMETER_VALUE_GET and
* F4UT_PARAMETER_RESULTS_PUT may be very helpfull in this step.
  IF CALLCONTROL-STEP = 'DISP'.
*   PERFORM AUTHORITY_CHECK TABLES RECORD_TAB SHLP_TAB
*                           CHANGING SHLP CALLCONTROL.
    EXIT.
  ENDIF.
*}   INSERT
ENDFUNCTION.
