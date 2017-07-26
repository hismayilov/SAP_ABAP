*&---------------------------------------------------------------------*
*& Report  ZMM_MATERIAL_MASTER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zmm_material_master.

* Data Declaration *
* Type-Pools *
TYPE-POOLS: truxs, abap.

* Tables *
TABLES: makt, mara, marc, mard, marm, mbew, mlan, mvke.

* Types *
TYPES: excelcell TYPE char256,

       BEGIN OF ty_file,  " Data from uploaded file
         matnr      TYPE excelcell,  " Headdata/Mara
         mbrsh      TYPE excelcell,  " Default Value
         mtart      TYPE excelcell,
         meins      TYPE excelcell,  " Mara/Clientdata
         matkl      TYPE excelcell,
         bismt      TYPE excelcell,
         spart      TYPE excelcell,
         mtpos_mara TYPE excelcell, " Default Value
         ntgew      TYPE excelcell,
         gewei      TYPE excelcell,
         tragr      TYPE excelcell,  " Default Value
         bstme      TYPE excelcell,
         vabme      TYPE excelcell,
         ekwsl      TYPE excelcell,
         mhdrz      TYPE excelcell,
         mhdhb      TYPE excelcell,
         werks      TYPE excelcell,  " Marc/Plantdata
         ladgr      TYPE excelcell,  " Default Value
         herkl      TYPE excelcell,  " Default Value
         herkr      TYPE excelcell,
         steuc      TYPE excelcell,
         ekgrp      TYPE excelcell,
         kordb      TYPE excelcell,
         dismm      TYPE excelcell,
         dispo      TYPE excelcell,
         minbe      TYPE excelcell,
         disls      TYPE excelcell,
         bstmi      TYPE excelcell,
         bstma      TYPE excelcell,
         bstfe      TYPE excelcell,
         eisbe      TYPE excelcell,
         ausss      TYPE excelcell,
         beskz      TYPE excelcell,
         sobsl      TYPE excelcell,
         kzech      TYPE excelcell,  " Default Value
         lgpro      TYPE excelcell,
         lgfsb      TYPE excelcell,
         rgekz      TYPE excelcell,  " Default Value
         dzeit      TYPE excelcell,  " Default Value
         plifz      TYPE excelcell,
         webaz      TYPE excelcell,
         fhori      TYPE excelcell,
         rwpro      TYPE excelcell,
         strgr      TYPE excelcell,
         mtvfp      TYPE excelcell,
         sbdkz      TYPE excelcell,
         fevor      TYPE excelcell,  " Default Value
         sfcpf      TYPE excelcell,  " Default Value
         uneto      TYPE excelcell,
         ueeto      TYPE excelcell,
         xchpf      TYPE excelcell,  " Default Value
         prctr      TYPE excelcell,
         prfrq      TYPE excelcell,
         ncost      TYPE excelcell,
         awsls      TYPE excelcell,
         sobsk      TYPE excelcell,
         losgr      TYPE excelcell,  " Default Value
         lgort      TYPE excelcell,  " Mard/Storagelocationdata
         bklas      TYPE excelcell,  " Mbew/Valuationdata
         vprsv      TYPE excelcell,
         peinh      TYPE excelcell,
         verpr      TYPE excelcell,
         stprs      TYPE excelcell,
         ekalr      TYPE excelcell,  " Default Value
         hkmat      TYPE excelcell,  " Default Value
         hrkft      TYPE excelcell,
         kosgr      TYPE excelcell,
         zplp1      TYPE excelcell,   " Marked for Removal
         zpld1      TYPE excelcell,   " Marked for Removal
         zplp2      TYPE excelcell,   " Marked for Removal
         zpld2      TYPE excelcell,   " Marked for Removal
         zplp3      TYPE excelcell,   " Marked for Removal
         zpld3      TYPE excelcell,   " Marked for Removal
         vkorg      TYPE excelcell,   " Mvke/Salesdata
         vtweg      TYPE excelcell,
         vrkme      TYPE excelcell,
         dwerk      TYPE excelcell,
         sktof      TYPE excelcell,
         versg      TYPE excelcell,
         bonus      TYPE excelcell,
         kondm      TYPE excelcell,
         ktgrm      TYPE excelcell,
         mtpos      TYPE excelcell,  " Default Value
         prodh      TYPE excelcell,
         mvgr1      TYPE excelcell,
         mvgr2      TYPE excelcell,
         mvgr3      TYPE excelcell,
         mvgr4      TYPE excelcell,
         mvgr5      TYPE excelcell,
         aumng      TYPE excelcell,
         maktx      TYPE excelcell,  " Makt/MaterialDescription
         brgew      TYPE excelcell,  " Marm/UnitsOfMeasure
         " Tax Classification
       END OF ty_file,

       BEGIN OF ty_data,
         index      TYPE i,
         sel        TYPE flag,
         matnr      TYPE mara-matnr,
         mbrsh      TYPE mara-mbrsh,
         mtart      TYPE mara-mtart,
         meins      TYPE mara-meins,
         matkl      TYPE mara-matkl,
         bismt      TYPE mara-bismt,
         spart      TYPE mara-spart,
         mtpos_mara TYPE mara-mtpos_mara,
         ntgew      TYPE mara-ntgew,
         gewei      TYPE mara-gewei,
         tragr      TYPE mara-tragr,
         bstme      TYPE mara-bstme,
         vabme      TYPE mara-vabme,
         ekwsl      TYPE mara-ekwsl,
         mhdrz      TYPE mara-mhdrz,
         mhdhb      TYPE mara-mhdhb,
         werks      TYPE marc-werks,
         ladgr      TYPE marc-ladgr,
         herkl      TYPE marc-herkl,
         herkr      TYPE marc-herkr,
         steuc      TYPE marc-steuc,
         ekgrp      TYPE marc-ekgrp,
         kordb      TYPE marc-kordb,
         dismm      TYPE marc-dismm,
         dispo      TYPE marc-dispo,
         minbe      TYPE marc-minbe,
         disls      TYPE marc-disls,
         bstmi      TYPE marc-bstmi,
         bstma      TYPE marc-bstma,
         bstfe      TYPE marc-bstfe,
         eisbe      TYPE marc-eisbe,
         ausss      TYPE marc-ausss,
         beskz      TYPE marc-beskz,
         sobsl      TYPE marc-sobsl,
         kzech      TYPE marc-kzech,
         lgpro      TYPE marc-lgpro,
         lgfsb      TYPE marc-lgfsb,
         rgekz      TYPE marc-rgekz,
         dzeit      TYPE marc-dzeit,
         plifz      TYPE marc-plifz,
         webaz      TYPE marc-webaz,
         fhori      TYPE marc-fhori,
         rwpro      TYPE marc-rwpro,
         strgr      TYPE marc-strgr,
         mtvfp      TYPE marc-mtvfp,
         sbdkz      TYPE marc-sbdkz,
         fevor      TYPE marc-fevor,
         sfcpf      TYPE marc-sfcpf,
         uneto      TYPE marc-uneto,
         ueeto      TYPE marc-ueeto,
         xchpf      TYPE marc-xchpf,
         prctr      TYPE marc-prctr,
         prfrq      TYPE marc-prfrq,
         ncost      TYPE marc-ncost,
         awsls      TYPE marc-awsls,
         sobsk      TYPE marc-sobsk,
         losgr      TYPE marc-losgr,
         lgort      TYPE mard-lgort,
         bklas      TYPE mbew-bklas,
         vprsv      TYPE mbew-vprsv,
         peinh      TYPE mbew-peinh,
         verpr      TYPE mbew-verpr,
         stprs      TYPE mbew-stprs,
         ekalr      TYPE mbew-ekalr,
         hkmat      TYPE mbew-hkmat,
         hrkft      TYPE mbew-hrkft,
         kosgr      TYPE mbew-kosgr,
         zplp1      TYPE mbew-zplp1,
         zpld1      TYPE mbew-zpld1,
         zplp2      TYPE mbew-zplp2,
         zpld2      TYPE mbew-zpld2,
         zplp3      TYPE mbew-zplp3,
         zpld3      TYPE mbew-zpld3,
         vkorg      TYPE mvke-vkorg,
         vtweg      TYPE mvke-vtweg,
         vrkme      TYPE mvke-vrkme,
         dwerk      TYPE mvke-dwerk,
         sktof      TYPE mvke-sktof,
         versg      TYPE mvke-versg,
         bonus      TYPE mvke-bonus,
         kondm      TYPE mvke-kondm,
         ktgrm      TYPE mvke-ktgrm,
         mtpos      TYPE mvke-mtpos,
         prodh      TYPE mvke-prodh,
         mvgr1      TYPE mvke-mvgr1,
         mvgr2      TYPE mvke-mvgr2,
         mvgr3      TYPE mvke-mvgr3,
         mvgr4      TYPE mvke-mvgr4,
         mvgr5      TYPE mvke-mvgr5,
         aumng      TYPE mvke-aumng,
         maktx      TYPE makt-maktx,
         brgew      TYPE marm-brgew,
         " Tax Classification
       END OF ty_data,

       BEGIN OF ty_log,
         index TYPE excelcell.
        INCLUDE TYPE ty_file.
TYPES:   log TYPE excelcell,
         END OF ty_log.

* Internal Tables *
DATA: it_makt TYPE TABLE OF makt,     " Material Description
      wa_makt TYPE makt,

      it_file TYPE TABLE OF ty_file,  " File upload data
      wa_file TYPE ty_file,

      it_data TYPE TABLE OF ty_data,  " Converted data in DE Format
      wa_data TYPE ty_data,

      it_log  TYPE TABLE OF ty_log,    " Log file
      wa_log  TYPE ty_log.

* Variables *
DATA: index    TYPE i,
      material TYPE matnr,      " Material Number
      lines(5) TYPE c,          " Table line count
      msg      TYPE string,     " Message
      answer   TYPE c.          " Answer from confirmation pop-up

* Field Symbols *
FIELD-SYMBOLS: <fs>     TYPE any,
               <fs_wa>  TYPE any,
               <fs_tab> TYPE STANDARD TABLE.

* FM Related *
* TEXT_CONVERT_XLS_TO_SAP *
DATA: it_raw TYPE truxs_t_text_data.  " For internal processing

* BAPI_MATERIAL_SAVEDATA *
DATA: headdata             TYPE bapimathead, " View Selection
      clientdata           TYPE bapi_mara,   " MARA
      clientdatax          TYPE bapi_marax,  " Checkbox
      plantdata            TYPE bapi_marc,   " MARC
      plantdatax           TYPE bapi_marcx,  " Checkbox
      storagelocationdata  TYPE bapi_mard,   " MARD
      storagelocationdatax TYPE bapi_mardx,  " Checkbox
      valuationdata        TYPE bapi_mbew,   " MBEW
      valuationdatax       TYPE bapi_mbewx,  " Checkbox
      salesdata            TYPE bapi_mvke,   " MVKE
      salesdatax           TYPE bapi_mvkex,  " Checkbox
      return               TYPE bapiret2.    " return structure

DATA: materialdescription TYPE TABLE OF bapi_makt         WITH HEADER LINE,  " MAKT
      unitsofmeasure      TYPE TABLE OF bapi_marm         WITH HEADER LINE,  " MARM
      unitsofmeasurex     TYPE TABLE OF bapi_marmx        WITH HEADER LINE,  " Checkbox
      taxclassifications  TYPE TABLE OF bapi_mlan         WITH HEADER LINE,  " MLAN
      returnmessages      TYPE TABLE OF bapi_matreturn2   WITH HEADER LINE.  " Return messages from BAPI

* STEUERTAB_IDENTIFY *
DATA: steuertab TYPE TABLE OF mg03steuer WITH HEADER LINE.  " Tax types for sal. org. / distr. channel

* File output related *
* cl_gui_frontend_services=>file_save_dialog *
* cl_gui_frontend_services=>gui_download *
DATA: it_errfname TYPE TABLE OF fieldnames,
      wa_errfname TYPE fieldnames,
      it_logfname TYPE TABLE OF fieldnames,
      wa_logfname TYPE fieldnames.

DATA: file       TYPE string,
      path       TYPE string,
      file_path  TYPE string,
      title      TYPE string,
      defname    TYPE string,
      defext     TYPE string,
      useraction TYPE i.

* Selection Screen *
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:     p_rad1 RADIOBUTTON GROUP rad USER-COMMAND abc DEFAULT 'X',
                p_rad2 RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE text-003,
                  BEGIN OF LINE,
                  PUSHBUTTON 2(10) text-004 USER-COMMAND dwn,
                  END OF LINE,
                  END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(79) text-005.
SELECTION-SCREEN END OF LINE.
PARAMETERS:     p_file TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b2.

* Selection screen events
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name EQ 'P_FILE'.
      IF p_rad1 EQ 'X'.
        screen-input = 1.
      ELSEIF p_rad2 EQ 'X'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
      EXIT.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN.
  IF p_rad1 EQ 'X' AND sy-ucomm EQ 'ONLI' AND p_file IS INITIAL.
    MESSAGE 'Material Data File is mandatory' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
  IF p_rad2 EQ 'X' AND sy-ucomm EQ 'ONLI'.
    MESSAGE 'Not yet implemented' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM select_file.

* Macro *
  DEFINE alpha_input.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = &1
        IMPORTING
          output = &2.
  END-OF-DEFINITION.

* Start of Main *
START-OF-SELECTION.

  PERFORM file_to_tab.          " Convert Excel to Internal Table
  PERFORM check_if_tab_empty.
  PERFORM file_format_adjust.   " Remove leading spaces if any from excel cells
  PERFORM convert_data_to_bapi_format.
  PERFORM material_validation.  " Based on description
  PERFORM material_creation.
  PERFORM log_output.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  SELECT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_file .
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_FILE'
    IMPORTING
      file_name     = p_file.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILE_TO_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM file_to_tab .
  IF p_file IS NOT INITIAL.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = 'X'
*       i_line_header        = 'X'
        i_tab_raw_data       = it_raw
        i_filename           = p_file
      TABLES
        i_tab_converted_data = it_file
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    MESSAGE 'Invalid File Selected' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM material_validation .
  IF it_data IS NOT INITIAL.
    LOOP AT it_data INTO wa_data.
*      alpha_input wa_data-maktx wa_makt-maktx.
      MOVE wa_data-maktx TO wa_makt-maktx.
      APPEND wa_makt TO it_makt.
      CLEAR: wa_data, wa_makt.
    ENDLOOP.

    IF it_makt IS NOT INITIAL.
      SELECT *
      FROM makt
      INTO TABLE it_makt
      FOR ALL ENTRIES IN it_makt
      WHERE maktx EQ it_makt-maktx
      AND spras EQ sy-langu.

      IF it_makt IS NOT INITIAL.
        LOOP AT it_data INTO wa_data.
          READ TABLE it_makt INTO wa_makt WITH KEY maktx = wa_data-maktx.
          IF sy-subrc = 0.
            CLEAR wa_data-sel.
            MOVE-CORRESPONDING wa_data TO wa_log.
            CONCATENATE 'Material' wa_makt-matnr 'already exists with description' wa_makt-maktx
            INTO wa_log-log SEPARATED BY space.
            APPEND wa_log TO it_log.
            MODIFY it_data FROM wa_data TRANSPORTING sel.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_IF_TAB_EMPTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_if_tab_empty .
  DATA: lv_tabix TYPE sy-tabix.
  IF it_file IS NOT INITIAL.
    LOOP AT it_file INTO wa_file.
      ADD 1 TO lv_tabix.
      IF lv_tabix EQ 1 OR lv_tabix EQ 2.
        DELETE it_file.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF it_file IS INITIAL.
      MESSAGE 'No data could be processed from file' TYPE 'S' DISPLAY LIKE 'E'.
      STOP.
    ENDIF.
  ELSE.
    MESSAGE 'No data could be processed from file' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATA_TO_BAPI_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM convert_data_to_bapi_format .
  DATA: lo_descr TYPE REF TO cl_abap_typedescr.
  DATA: lv_relative_name TYPE string.
  DATA: lv_data_element TYPE rollname.
  DATA: lv_function TYPE funcname.
  DATA: wa_dd04l TYPE dd04l.
  DATA: lv_index.

  IF it_file IS NOT INITIAL.
    LOOP AT it_file INTO wa_file.
      ADD 1 TO lv_index.
      MOVE lv_index TO wa_data-index.
      MOVE 'X' TO wa_data-sel.
      MOVE-CORRESPONDING wa_file TO wa_data.
      APPEND wa_data TO it_data.
      CLEAR: wa_file, wa_data.
    ENDLOOP.
  ENDIF.

  IF it_data IS NOT INITIAL.
    UNASSIGN: <fs_tab>, <fs_wa>, <fs>.
    ASSIGN it_data TO <fs_tab>.
    LOOP AT <fs_tab> ASSIGNING <fs_wa>.
      sy-subrc = 0.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <fs_wa> TO <fs>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        IF <fs> IS ASSIGNED AND <fs> IS NOT INITIAL.
          lo_descr = cl_abap_typedescr=>describe_by_data( p_data = <fs> ).

          IF lo_descr IS BOUND.
            lv_relative_name = lo_descr->get_relative_name( ).

            IF lv_relative_name IS NOT INITIAL.
              MOVE lv_relative_name TO lv_data_element.

              SELECT SINGLE *
              FROM dd04l
              INTO wa_dd04l
              WHERE rollname = lv_data_element.

              IF wa_dd04l-convexit IS NOT INITIAL.
                CONCATENATE 'CONVERSION_EXIT_' wa_dd04l-convexit '_INPUT' INTO lv_function.

                CALL FUNCTION lv_function
                  EXPORTING
                    input  = <fs>
                  IMPORTING
                    output = <fs>.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDDO.
      MODIFY <fs_tab> FROM <fs_wa>.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LOG_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM log_output .
  IF it_log IS NOT INITIAL.
    UNASSIGN: <fs_tab>, <fs_wa>, <fs>.
    ASSIGN it_log TO <fs_tab>.
    LOOP AT <fs_tab> ASSIGNING <fs_wa>.
      sy-subrc = 0.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <fs_wa> TO <fs>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        IF <fs> IS ASSIGNED.
          SHIFT <fs> LEFT DELETING LEADING space.
        ENDIF.
      ENDDO.
      MODIFY <fs_tab> FROM <fs_wa>.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MATERIAL_CREATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM material_creation .
  DATA: material_number TYPE TABLE OF bapimatinr WITH HEADER LINE,
        mat_no_return   TYPE bapireturn1.
  IF it_data IS NOT INITIAL.
    LOOP AT it_data INTO wa_data WHERE sel EQ 'X'.
      CLEAR return.
      CALL FUNCTION 'BAPI_MATERIAL_GETINTNUMBER'
        EXPORTING
          material_type    = wa_data-mtart
          industry_sector  = 'C'
          required_numbers = 1
        IMPORTING
          return           = mat_no_return
        TABLES
          material_number  = material_number.

      CLEAR headdata.
      READ TABLE material_number INDEX 1.
      IF sy-subrc = 0 AND mat_no_return-type EQ 'S'.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input  = material_number-material
          IMPORTING
            output = headdata-material.
      ENDIF.
      MOVE 'C'            TO headdata-ind_sector.    " MBRSH
      MOVE wa_data-mtart  TO headdata-matl_type.
      MOVE abap_true      TO headdata-basic_view.
      MOVE abap_true      TO headdata-sales_view.
      MOVE abap_true      TO headdata-purchase_view.
      MOVE abap_true      TO headdata-mrp_view.
      MOVE abap_true      TO headdata-prt_view.
      MOVE abap_true      TO headdata-storage_view.
      MOVE abap_true      TO headdata-quality_view.
      MOVE abap_true      TO headdata-account_view.
      MOVE abap_true      TO headdata-cost_view.
      MOVE 'I'            TO headdata-inp_fld_check.

      CLEAR clientdata.
      MOVE wa_data-meins TO clientdata-base_uom.
      MOVE wa_data-matkl TO clientdata-matl_group.
      MOVE wa_data-bismt TO clientdata-old_mat_no.
      MOVE wa_data-spart TO clientdata-division.
      MOVE 'NORM'        TO clientdata-item_cat.    " MTPOS_MARA
      MOVE wa_data-ntgew TO clientdata-net_weight.
      MOVE wa_data-gewei TO clientdata-unit_of_wt.
      MOVE '0001'        TO clientdata-trans_grp.   " TRAGR
      MOVE wa_data-bstme TO clientdata-po_unit.
      MOVE wa_data-vabme TO clientdata-var_ord_un.
      MOVE wa_data-ekwsl TO clientdata-pur_valkey.
      MOVE wa_data-mhdrz TO clientdata-minremlife.
      MOVE wa_data-mhdhb TO clientdata-shelf_life.
      MOVE wa_data-prodh TO clientdata-prod_hier.   " PRODH_H
      MOVE abap_true     TO clientdata-batch_mgmt.  " XCHPF

      CLEAR clientdatax.
      MOVE abap_true TO clientdatax-base_uom.
      MOVE abap_true TO clientdatax-matl_group.
      MOVE abap_true TO clientdatax-old_mat_no.
      MOVE abap_true TO clientdatax-division.
      MOVE abap_true TO clientdatax-item_cat.
      MOVE abap_true TO clientdatax-net_weight.
      MOVE abap_true TO clientdatax-unit_of_wt.
      MOVE abap_true TO clientdatax-trans_grp.
      MOVE abap_true TO clientdatax-po_unit.
      MOVE abap_true TO clientdatax-var_ord_un.
      MOVE abap_true TO clientdatax-pur_valkey.
      MOVE abap_true TO clientdatax-minremlife.
      MOVE abap_true TO clientdatax-shelf_life.
      MOVE abap_true TO clientdatax-prod_hier.
      MOVE abap_true TO clientdatax-batch_mgmt.  " XCHPF

      CLEAR plantdata.
      MOVE wa_data-werks TO plantdata-plant.
      MOVE 'Z001'        TO plantdata-loadinggrp.   " LADGR
      MOVE 'IN'          TO plantdata-countryori.   " HERKL
      MOVE wa_data-herkr TO plantdata-regionorig.
      MOVE wa_data-steuc TO plantdata-ctrl_code.
      MOVE wa_data-ekgrp TO plantdata-pur_group.
      MOVE wa_data-kordb TO plantdata-sourcelist.
      MOVE wa_data-dismm TO plantdata-mrp_type.
      MOVE wa_data-dispo TO plantdata-mrp_ctrler.
      MOVE wa_data-minbe TO plantdata-reorder_pt.
      MOVE wa_data-disls TO plantdata-lotsizekey.
      MOVE wa_data-bstmi TO plantdata-minlotsize.
      MOVE wa_data-bstma TO plantdata-maxlotsize.
      MOVE wa_data-bstfe TO plantdata-fixed_lot.
      MOVE wa_data-eisbe TO plantdata-safety_stk.
      MOVE wa_data-ausss TO plantdata-assy_scrap.
      MOVE wa_data-beskz TO plantdata-proc_type.
      MOVE wa_data-sobsl TO plantdata-spproctype.
      MOVE '3'           TO plantdata-batchentry.   " KZECH
      MOVE wa_data-lgpro TO plantdata-iss_st_loc.
      MOVE wa_data-lgfsb TO plantdata-sloc_exprc.
      MOVE '1'           TO plantdata-backflush.    " MARC-RGEKZ, PLANTDATA-BACKFLUSH with DType RGEKM
      MOVE '1'           TO plantdata-inhseprodt.   " DZEIT
      MOVE wa_data-plifz TO plantdata-plnd_delry.
      MOVE wa_data-webaz TO plantdata-gr_pr_time.
      MOVE wa_data-fhori TO plantdata-sm_key.
      MOVE wa_data-rwpro TO plantdata-covprofile.
      MOVE wa_data-strgr TO plantdata-plan_strgp.
      MOVE wa_data-mtvfp TO plantdata-availcheck.
      MOVE wa_data-sbdkz TO plantdata-dep_req_id.
      IF clientdata-division EQ '10' OR clientdata-division EQ '15'.
        MOVE 'AGR'       TO plantdata-production_scheduler.   " FEVOR
        MOVE 'AGRO'      TO plantdata-prodprof.               " MARC-SFCPF, PLANTDATA-PRODPROF with Dtype CO_PRODPRF
      ELSEIF clientdata-division EQ '20'.
        MOVE 'SPC'       TO plantdata-production_scheduler.   " FEVOR
        MOVE 'SPCD'      TO plantdata-prodprof.               " MARC-SFCPF, PLANTDATA-PRODPROF with Dtype CO_PRODPRF
      ENDIF.
      MOVE wa_data-uneto TO plantdata-under_tol.
      MOVE wa_data-ueeto TO plantdata-over_tol.
      MOVE wa_data-prctr TO plantdata-profit_ctr.
      MOVE wa_data-prfrq TO plantdata-insp_int.
      MOVE wa_data-ncost TO plantdata-no_costing.     " MARC-NCOST, PLANTDATA-NO_COSTING with Dtype CK_NO_COSTING
      MOVE wa_data-awsls TO plantdata-variance_key.
      MOVE wa_data-sobsk TO plantdata-specprocty.     " MARC-SOBSK, PLANTDATA-SPECPROCTY with Dtype CK_SOBSL
      MOVE '1000'        TO plantdata-lot_size.       " LOSGR

      CLEAR plantdatax.
      MOVE wa_data-werks  TO plantdatax-plant.
      MOVE abap_true      TO plantdatax-loadinggrp.
      MOVE abap_true      TO plantdatax-countryori.
      MOVE abap_true      TO plantdatax-regionorig.
      MOVE abap_true      TO plantdatax-ctrl_code.
      MOVE abap_true      TO plantdatax-pur_group.
      MOVE abap_true      TO plantdatax-sourcelist.
      MOVE abap_true      TO plantdatax-mrp_type.
      MOVE abap_true      TO plantdatax-mrp_ctrler.
      MOVE abap_true      TO plantdatax-reorder_pt.
      MOVE abap_true      TO plantdatax-lotsizekey.
      MOVE abap_true      TO plantdatax-minlotsize.
      MOVE abap_true      TO plantdatax-maxlotsize.
      MOVE abap_true      TO plantdatax-fixed_lot.
      MOVE abap_true      TO plantdatax-safety_stk.
      MOVE abap_true      TO plantdatax-assy_scrap.
      MOVE abap_true      TO plantdatax-proc_type.
      MOVE abap_true      TO plantdatax-spproctype.
      MOVE abap_true      TO plantdatax-batchentry.
      MOVE abap_true      TO plantdatax-iss_st_loc.
      MOVE abap_true      TO plantdatax-sloc_exprc.
      MOVE abap_true      TO plantdatax-backflush.
      MOVE abap_true      TO plantdatax-inhseprodt.
      MOVE abap_true      TO plantdatax-plnd_delry.
      MOVE abap_true      TO plantdatax-gr_pr_time.
      MOVE abap_true      TO plantdatax-sm_key.
      MOVE abap_true      TO plantdatax-covprofile.
      MOVE abap_true      TO plantdatax-plan_strgp.
      MOVE abap_true      TO plantdatax-availcheck.
      MOVE abap_true      TO plantdatax-dep_req_id.
      MOVE abap_true      TO plantdatax-production_scheduler.
      MOVE abap_true      TO plantdatax-prodprof.
      MOVE abap_true      TO plantdatax-under_tol.
      MOVE abap_true      TO plantdatax-over_tol.
      MOVE abap_true      TO plantdatax-profit_ctr.
      MOVE abap_true      TO plantdatax-insp_int.
      MOVE abap_true      TO plantdatax-no_costing.
      MOVE abap_true      TO plantdatax-variance_key.
      MOVE abap_true      TO plantdatax-specprocty.
      MOVE abap_true      TO plantdatax-lot_size.

      CLEAR storagelocationdata.
      MOVE plantdata-plant TO storagelocationdata-plant.
      MOVE wa_data-lgort   TO storagelocationdata-stge_loc.

      CLEAR storagelocationdatax.
      MOVE plantdata-plant TO storagelocationdatax-plant.
      MOVE wa_data-lgort   TO storagelocationdatax-stge_loc.

      CLEAR valuationdata.
      MOVE plantdata-plant  TO valuationdata-val_area.  " ? include as it is mandatory
      MOVE wa_data-bklas    TO valuationdata-val_class.
      MOVE wa_data-vprsv    TO valuationdata-price_ctrl.
      MOVE wa_data-peinh    TO valuationdata-price_unit.
      MOVE wa_data-verpr    TO valuationdata-moving_pr.
      MOVE wa_data-stprs    TO valuationdata-std_price.
      MOVE abap_true        TO valuationdata-qty_struct.     " MBEW-EKALR, VALUATIONDATA-QTY_STRUCT with Dtype CK_EKALREL
      MOVE abap_true        TO valuationdata-orig_mat.       " HKMAT
      MOVE wa_data-hrkft    TO valuationdata-orig_group.
      MOVE wa_data-kosgr    TO valuationdata-overhead_grp.

      CLEAR valuationdatax.
      MOVE plantdata-plant  TO valuationdatax-val_area.  " ? include as it is mandatory
      MOVE abap_true        TO valuationdatax-val_class.
      MOVE abap_true        TO valuationdatax-price_ctrl.
      MOVE abap_true        TO valuationdatax-price_unit.
      MOVE abap_true        TO valuationdatax-moving_pr.
      MOVE abap_true        TO valuationdatax-std_price.
      MOVE abap_true        TO valuationdatax-qty_struct.
      MOVE abap_true        TO valuationdatax-orig_mat.
      MOVE abap_true        TO valuationdatax-orig_group.
      MOVE abap_true        TO valuationdatax-overhead_grp.

      CLEAR salesdata.
      MOVE wa_data-vkorg TO salesdata-sales_org.
      MOVE wa_data-vtweg TO salesdata-distr_chan.
      MOVE wa_data-vrkme TO salesdata-sales_unit.
      MOVE wa_data-dwerk TO salesdata-delyg_plnt.
      MOVE wa_data-sktof TO salesdata-cash_disc.
      MOVE wa_data-versg TO salesdata-matl_stats.   " MVKE-VERSG, SALESDATA-MATL_STATS with Dtype STGMA
      MOVE wa_data-bonus TO salesdata-rebate_grp.
      MOVE wa_data-kondm TO salesdata-mat_pr_grp.
      MOVE wa_data-ktgrm TO salesdata-acct_assgt.
      MOVE 'NORM'        TO salesdata-item_cat.     " MTPOS
*      MOVE wa_data-prodh TO salesdata-prod_hier.
      MOVE wa_data-mvgr1 TO salesdata-matl_grp_1.
      MOVE wa_data-mvgr2 TO salesdata-matl_grp_2.
      MOVE wa_data-mvgr3 TO salesdata-matl_grp_3.
      MOVE wa_data-mvgr4 TO salesdata-matl_grp_4.
      MOVE wa_data-mvgr5 TO salesdata-matl_grp_5.
      MOVE wa_data-aumng TO salesdata-min_order.    " MVKE-AUMNG, SALESDATA-MIN_ORDER with Dtype MINAU

      CLEAR salesdatax.
      MOVE wa_data-vkorg  TO salesdatax-sales_org.
      MOVE wa_data-vtweg  TO salesdatax-distr_chan.
      MOVE abap_true      TO salesdatax-sales_unit.
      MOVE abap_true      TO salesdatax-delyg_plnt.
      MOVE abap_true      TO salesdatax-cash_disc.
      MOVE abap_true      TO salesdatax-matl_stats.
      MOVE abap_true      TO salesdatax-rebate_grp.
      MOVE abap_true      TO salesdatax-mat_pr_grp.
      MOVE abap_true      TO salesdatax-acct_assgt.
      MOVE abap_true      TO salesdatax-item_cat.
*      MOVE abap_true      TO salesdatax-prod_hier.
      MOVE abap_true      TO salesdatax-matl_grp_1.
      MOVE abap_true      TO salesdatax-matl_grp_2.
      MOVE abap_true      TO salesdatax-matl_grp_3.
      MOVE abap_true      TO salesdatax-matl_grp_4.
      MOVE abap_true      TO salesdatax-matl_grp_5.
      MOVE abap_true      TO salesdatax-min_order.

      REFRESH materialdescription.
      CLEAR materialdescription.
      materialdescription-langu     = 'EN'.               " hard-coded for now - mandatory
      materialdescription-matl_desc = wa_data-maktx.
      APPEND materialdescription.

      REFRESH unitsofmeasure.
      CLEAR unitsofmeasure.
      MOVE clientdata-base_uom    TO unitsofmeasure-alt_unit.
      MOVE wa_data-brgew          TO unitsofmeasure-gross_wt.
      APPEND unitsofmeasure.

      REFRESH unitsofmeasurex.
      CLEAR unitsofmeasurex.
      MOVE clientdata-base_uom  TO unitsofmeasurex-alt_unit.
      MOVE abap_true            TO unitsofmeasurex-gross_wt.
      APPEND unitsofmeasurex.

      REFRESH: taxclassifications, steuertab.
      CLEAR: taxclassifications, steuertab.
      " Get tax classification data for sal. org/distr. channel combination
      CALL FUNCTION 'STEUERTAB_IDENTIFY'
        EXPORTING
*         KZRFB                 = ' '
          vkorg                 = salesdata-sales_org
          bukrs_vkorg           = salesdata-sales_org
          vtweg                 = salesdata-distr_chan
        TABLES
          steuertab             = steuertab
        EXCEPTIONS
          wrong_call            = 1
          vkorg_bukrs_not_found = 2
          steuertab_empty       = 3
          OTHERS                = 4.
      IF sy-subrc <> 0.
*Implement suitable error handling here
      ELSE.
        LOOP AT steuertab.
          taxclassifications-depcountry = steuertab-aland.
          taxclassifications-tax_type_1 = steuertab-tatyp.
          taxclassifications-taxclass_1 = '0'.
          APPEND taxclassifications.
          CLEAR: steuertab, taxclassifications.
        ENDLOOP.
      ENDIF.

      CLEAR: return, returnmessages.
      REFRESH: returnmessages.
      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          headdata             = headdata
          clientdata           = clientdata
          clientdatax          = clientdatax
          plantdata            = plantdata
          plantdatax           = plantdatax
          storagelocationdata  = storagelocationdata
          storagelocationdatax = storagelocationdatax
          valuationdata        = valuationdata
          valuationdatax       = valuationdatax
          salesdata            = salesdata
          salesdatax           = salesdatax
        IMPORTING
          return               = return
        TABLES
          materialdescription  = materialdescription
          unitsofmeasure       = unitsofmeasure
          unitsofmeasurex      = unitsofmeasurex
          taxclassifications   = taxclassifications
          returnmessages       = returnmessages.

      MOVE-CORRESPONDING wa_data TO wa_log.

      READ TABLE returnmessages WITH KEY type = 'E' TRANSPORTING message.
      IF sy-subrc = 0.  " Error exists, log it in error log
        wa_log-log = returnmessages-message.
        APPEND wa_log TO it_log.
        CLEAR: wa_log, returnmessages.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE. " No error
        IF return-number = '356' AND return-type = 'S'. " Check if extension succeeded (MSG 356) and log it in status log
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          wa_log-log = return-message.
          APPEND wa_log TO it_log.
          CLEAR: wa_log.
        ENDIF.  " IF return-number = '356'
      ENDIF.
      " End read returnmessages
      CLEAR wa_data.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILE_FORMAT_ADJUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM file_format_adjust .
  IF it_file IS NOT INITIAL.
    UNASSIGN: <fs_tab>, <fs_wa>, <fs>.
    ASSIGN it_file TO <fs_tab>.
    LOOP AT <fs_tab> ASSIGNING <fs_wa>.
      sy-subrc = 0.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <fs_wa> TO <fs>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        IF <fs> IS ASSIGNED.
          SHIFT <fs> LEFT DELETING LEADING space.
        ENDIF.
      ENDDO.
      MODIFY <fs_tab> FROM <fs_wa>.
    ENDLOOP.
  ENDIF.
ENDFORM.
