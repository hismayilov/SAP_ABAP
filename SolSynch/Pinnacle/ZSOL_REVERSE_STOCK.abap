*********************************************************************
*                     PINNACLE                                      *
*********************************************************************
*                  I N F O R M A T I O N                            *
*********************************************************************
* Module             : MM
* Developer          : Saurabh Khare, Solsynch
* Date Of Creation   : 30/03/2017
* Transport Request# : DEVK910185
* Program Name       : ZSOL_REVERSE_STOCK
* Transaction Code   : ZREV_STOCK
* Development Pkg    : ZMM
* Description        : Stock reversal for Z11, Z12 Mvt. Types after MRP
**********************************************************************
*                       Change History
**********************************************************************
* Functional         :
* Developer          :
* Functional Spec#   :
* Date Of Change     :
* Transport Request# :
* Change Description :
**********************************************************************
* Modification history:
* ----------------------------------------------------------------------------------------------------------
* DATE     |Tech. Con.|Func. Con.|TS Ver | Trp. Request | Description
*
* ----------------------------------------------------------------------------------------------------------
REPORT zsol_reverse_stock.

* ---- Data Declaration ---- *

* ---- Tables ---- *
TABLES: mkpf.

* ---- Types ---- *
TYPES: BEGIN OF ty_log,
        log TYPE char255,
       END OF ty_log.

* ---- Internal Tables ---- *
DATA: it_view TYPE TABLE OF wb2_v_mkpf_mseg2,
      wa_view TYPE wb2_v_mkpf_mseg2,

      it_temp TYPE TABLE OF wb2_v_mkpf_mseg2,
      wa_temp TYPE wb2_v_mkpf_mseg2,

      headret TYPE bapi2017_gm_head_ret,
      return  TYPE TABLE OF bapiret2 WITH HEADER LINE,

      it_log  TYPE TABLE OF ty_log,
      wa_log TYPE ty_log.


* ---- Variables ---- *
DATA: v_lines TYPE i,
      cnt(5)  TYPE c,
      msg     TYPE string.

* ---- Selection-Screen ---- *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_date FOR mkpf-budat OBLIGATORY.
parameters: s_pstdt  like mkpf-budat obligatory.
SELECTION-SCREEN END OF BLOCK b1.

* ---- Initialisation ---- *
INITIALIZATION.
  cnt = 0.

* ---- Start of selection ---- *
START-OF-SELECTION.
  SELECT *
    FROM wb2_v_mkpf_mseg2
    INTO TABLE it_view
    WHERE budat IN s_date
    AND   ( bwart_i EQ 'Z11'    " Movement Types
    OR    bwart_i EQ 'Z12' ).

  IF sy-subrc = 0.
* Get reversal documents if any out of the range of selection date *
    SELECT *
    FROM wb2_v_mkpf_mseg2
    APPENDING TABLE it_view
    FOR ALL ENTRIES IN it_view
    WHERE smbln_i = it_view-mblnr.

    IF it_view[] IS NOT INITIAL.
* Remove multiple line items *
      DELETE ADJACENT DUPLICATES FROM it_view COMPARING mblnr mjahr.
    ENDIF.

    IF it_view[] IS NOT INITIAL.
      it_temp[] = it_view[].
* Delete already reversed documents *
      LOOP AT it_view INTO wa_view.
        READ TABLE it_temp INTO wa_temp WITH KEY smbln_i = wa_view-mblnr_i.
        IF sy-subrc = 0.
          DELETE it_view.
          CLEAR wa_temp.
        ENDIF.
        CLEAR wa_view.
      ENDLOOP.

* Delete reversal documents *
      IF it_view[] IS NOT INITIAL.
        DELETE it_view WHERE smbln_i IS NOT INITIAL.
        SORT it_view[] BY mblnr.
      ENDIF.
    ENDIF.

    IF it_view[] IS NOT INITIAL.
      SORT it_view[] BY mblnr.
      DESCRIBE TABLE it_view LINES v_lines.
      LOOP AT it_view INTO wa_view.
        " Reverse Stock
        CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
          EXPORTING
            materialdocument = wa_view-mblnr
            matdocumentyear  = wa_view-mjahr
            goodsmvt_pstng_date =  s_pstdt
          IMPORTING
            goodsmvt_headret = headret
          TABLES
            return           = return.
        READ TABLE return WITH KEY type = 'E'.
        IF sy-subrc <> 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*         EXPORTING
*           WAIT          =
*         IMPORTING
*           RETURN        =
            .
          " Create output log
          IF sy-subrc = 0.
            ADD 1 TO cnt.
            CONCATENATE 'material document' wa_view-mblnr 'reversed with document'
            headret-mat_doc 'in year' headret-doc_year INTO wa_log-log SEPARATED BY space.
          ENDIF.
        ELSE.
          CONCATENATE wa_view-mblnr ':' return-message INTO wa_log-log SEPARATED BY space.
        ENDIF.
        APPEND wa_log TO it_log.
        CLEAR: wa_view, wa_log.
        REFRESH: return[].
      ENDLOOP.

* ---- Display Error Log ---- *
      IF it_log IS NOT INITIAL.
        CLEAR: msg.
        MOVE v_lines TO msg.
        CONCATENATE msg 'documents selected for reversal.' INTO msg SEPARATED BY space.
        CONCATENATE msg cnt 'documents reversed successfully.' INTO msg SEPARATED BY space.
        MESSAGE msg TYPE 'I'.
        LOOP AT it_log INTO wa_log.
          WRITE: wa_log-log.
          CLEAR: wa_log.
        ENDLOOP.
      ENDIF.
    ELSE.
      MESSAGE 'No data found.' TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE 'No data found.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
