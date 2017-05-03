*&---------------------------------------------------------------------*
*& Report ZSOL_MATERIAL_CREATE
*&---------------------------------------------------------------------*
*& Author: Saurabh Khare
*& Creation Date: 08.03.2017
*& Description: Create approved materials(all users)
*& TCODE: ZMAT_CREATE
*&---------------------------------------------------------------------*
REPORT zsol_material_create.

* ---- Data declaration ---- *

* ---- Type-Pools ---- *
TYPE-POOLS: slis.

* ---- Tables ---- *
TABLES: zsol_mmcreate.

* ---- Constants ---- *
*CONSTANTS: .

* ---- Types ---- *
TYPES: BEGIN OF ty_final,
         sel.
    INCLUDE STRUCTURE zsol_mmcreate.
TYPES: END OF ty_final.

* ---- Internal Tables ---- *
DATA: it_mmcreate TYPE TABLE OF zsol_mmcreate,
      wa_mmcreate TYPE zsol_mmcreate,

      it_mmdef    TYPE TABLE OF zsol_mmdef,
      wa_mmdef    TYPE zsol_mmdef,

      it_luster   TYPE TABLE OF zsol_luster,
      wa_luster   TYPE zsol_luster,

      it_shade    TYPE TABLE OF zsol_shade,
      wa_shade    TYPE zsol_shade,

      it_grade    TYPE TABLE OF zsol_grade,
      wa_grade    TYPE zsol_grade,

      it_final    TYPE TABLE OF ty_final,
      wa_final    TYPE ty_final,

      it_t023     TYPE TABLE OF t023,
      wa_t023     TYPE t023.

* ---- Variables ---- *
DATA: msg      TYPE string,              " Error handling messages
      txt      TYPE string,              " Message
      lv_items TYPE n LENGTH 3,          " Table lines
      lv_spart TYPE spart.               " Division

* ---- ALV Related ---- *
DATA: it_fieldcat TYPE lvc_t_fcat,
      wa_fieldcat TYPE lvc_s_fcat,
      wa_layout   TYPE lvc_s_layo,
      g_variant   TYPE disvariant,
      gx_variant  TYPE disvariant.

* ---- Material Creation ---- *
DATA: headdata             TYPE zsol_tt_headdata             WITH HEADER LINE,
      clientdata           TYPE zsol_tt_clientdata           WITH HEADER LINE,
      clientdatax          TYPE zsol_tt_clientdatax          WITH HEADER LINE,
      plantdata            TYPE zsol_tt_plantdata            WITH HEADER LINE,
      plantdatax           TYPE zsol_tt_plantdatax           WITH HEADER LINE,
      storagelocationdata  TYPE zsol_tt_storagelocationdata  WITH HEADER LINE,
      storagelocationdatax TYPE zsol_tt_storagelocationdatax WITH HEADER LINE,
      valuationdata        TYPE zsol_tt_valuationdata        WITH HEADER LINE,
      valuationdatax       TYPE zsol_tt_valuationdatax       WITH HEADER LINE,
      salesdata            TYPE zsol_tt_salesdata            WITH HEADER LINE,
      salesdatax           TYPE zsol_tt_salesdatax           WITH HEADER LINE.

DATA: materialdescriptions TYPE zsol_tt_materialdescriptions WITH HEADER LINE,
      taxclassifications   TYPE zsol_tt_taxclassifications   WITH HEADER LINE.

DATA: steuertab TYPE TABLE OF mg03steuer WITH HEADER LINE.

DATA: num TYPE i.

* ---- Selection Screen ---- *
PARAMETERS: variant LIKE disvariant-variant NO-DISPLAY.

INITIALIZATION.
* ---- Get default variant ---- *
  IF variant IS INITIAL.
    gx_variant-report = sy-repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
      EXPORTING
        i_save     = 'X'
      CHANGING
        cs_variant = gx_variant
      EXCEPTIONS
        not_found  = 2.
    IF sy-subrc = 0.
      variant = gx_variant-variant.
      g_variant-variant = variant.
    ENDIF.
  ENDIF.

* ---- Selection Screen Events ---- *

* ---- Begin Main Program ---- *
START-OF-SELECTION.
* ---- Get Data from database ---- *
  PERFORM get_data.
* ---- Construct final table ---- *
  PERFORM process_data.

* ---- Build FCAT and display ALV ---- *
  IF it_final[] IS NOT INITIAL.
    PERFORM build_layout.
    PERFORM fcat.
    PERFORM alv_display.
  ELSE.
    MESSAGE 'No data found' TYPE 'I' DISPLAY LIKE 'E'.
    MESSAGE 'No approved materials pending for creation' TYPE 'S'.
    EXIT.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
* ---- Get requested material details ---- *
*  SELECT *
*   FROM zsol_mmcreate
*   INTO CORRESPONDING FIELDS OF TABLE it_mmcreate
*   WHERE appby  NE ''
*   AND   appdat IS NOT NULL
*   AND   apptim IS NOT NULL
*   AND   mat_created NE 'X'.

     SELECT *
   FROM zsol_mmcreate
   INTO CORRESPONDING FIELDS OF TABLE it_mmcreate
   WHERE mat_created NE 'X'.
ENDFORM.                    "get_data
*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data .
* ---- Process data / Construct final ALV table ---- *
  IF it_mmcreate[] IS NOT INITIAL.
    LOOP AT it_mmcreate INTO wa_mmcreate.
      MOVE-CORRESPONDING wa_mmcreate TO wa_final.
      IF wa_final-mat_created = 'X'.
        wa_final-mat_created = 'Y'.
      ELSE.
        wa_final-mat_created = 'N'.
      ENDIF.
      APPEND wa_final TO it_final.
      CLEAR: wa_final, wa_mmcreate.
    ENDLOOP.
  ENDIF.

  IF it_mmcreate[] IS NOT INITIAL.
    DESCRIBE TABLE it_mmcreate LINES lv_items.
    SHIFT lv_items LEFT DELETING LEADING '0'.
    CLEAR msg.
    CONCATENATE lv_items 'approved materials selected.' INTO msg SEPARATED BY space.
    MESSAGE msg TYPE 'I'.
  ENDIF.
ENDFORM.                    "process_data
*&---------------------------------------------------------------------*
*&      Form  FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fcat .
  PERFORM fill_fcat USING:
  'MATNR'       'IT_FINAL'  'Material'          'X'   'X'   space space space,
  'MAKTX'       'IT_FINAL'  'Material Descr.'   'X'   'X'   space space space,
  'SPART'       'IT_FINAL'  'Division'          'X'   'X'   space space space,
  'REQBY'       'IT_FINAL'  'Requested By'      'X'   'X'   space space space,
  'REQDAT'      'IT_FINAL'  'Request Date'      'X'   'X'   space space space,
  'REQTIM'      'IT_FINAL'  'Request Time'      'X'   'X'   space space space,
  'APPBY'       'IT_FINAL'  'Approved By'       'X'   'X'   space space space,
  'APPDAT'      'IT_FINAL'  'Approved Date'     'X'   'X'   space space space,
  'APPTIM'      'IT_FINAL'  'Approved Time'     'X'   'X'   space space space,
  'STD_PR_VAL'  'IT_FINAL'  'Standard Price'    'X'   space space space 'X',
  'MATL_GRP'    'IT_FINAL'  'Material Group'    'X'   space space space space,
  'ACT_DENIER'  'IT_FINAL'  'Actual Denier'     'X'   space space space space,
  'DENIER_DESC' 'IT_FINAL'  'Denier Descr.'     space space '20'  space space,
  'MAT_CREATED' 'IT_FINAL'  'Material Created?' 'X'   'X'   space space space,
  'LOG'         'IT_FINAL'  'Creation Log'      'X'   'X'   space space space.

* ---- Make PO Number as key field in ALV, remains fixed while scrolling ---- *
  IF it_fieldcat[] IS NOT INITIAL.
    LOOP AT it_fieldcat INTO wa_fieldcat WHERE fieldname = 'MATNR'.
      wa_fieldcat-key = 'X'.    " Key field
      MODIFY it_fieldcat FROM wa_fieldcat.
      CLEAR: wa_fieldcat.
    ENDLOOP.
    LOOP AT it_fieldcat INTO wa_fieldcat WHERE fieldname = 'MATL_GRP'.
      wa_fieldcat-f4availabl = 'X'.     " f4 search help
      wa_fieldcat-ref_table  = 'T023'.  " Ref table
      wa_fieldcat-ref_field  = 'MATKL'. " Ref field
      MODIFY it_fieldcat FROM wa_fieldcat.
      CLEAR: wa_fieldcat.
    ENDLOOP.
    LOOP AT it_fieldcat INTO wa_fieldcat WHERE fieldname = 'SPART'.
      wa_fieldcat-currency   = 'INR'.
      wa_fieldcat-cfieldname = 'CURR'.
      MODIFY it_fieldcat FROM wa_fieldcat.
      CLEAR: wa_fieldcat.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "fcat
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_display .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP-OF-PAGE'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = it_fieldcat[]
*     IT_SORT_LVC              =
*     I_DEFAULT                = 'X'
      i_save                   = 'X'
      is_variant               = g_variant
*     IT_EVENTS                =
    TABLES
      t_outtab                 = it_final[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    "alv_display
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_layout.
* ---- For Select field in alv ---- *
  wa_layout-box_fname     = 'SEL'.
  wa_layout-zebra         = 'X'.
ENDFORM.                    "build_layout
*&---------------------------------------------------------------------*
*&      Form  FILL_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM fill_fcat  USING    VALUE(p_fname)
                         VALUE(p_tname)
                         VALUE(p_stext)
                         VALUE(p_clopt)
                         VALUE(p_blank)
                         VALUE(p_outln)
                         VALUE(p_emphs)
                         VALUE(p_edit).

  wa_fieldcat-fieldname   = p_fname.
  wa_fieldcat-tabname     = p_tname.
  wa_fieldcat-scrtext_m   = p_stext.
  wa_fieldcat-col_opt     = p_clopt.
  wa_fieldcat-no_zero     = p_blank.    " Replace '0' value by blank
  wa_fieldcat-outputlen   = p_outln.    " Output length
  wa_fieldcat-emphasize   = p_emphs.    " Color columns
  wa_fieldcat-edit        = p_edit.     " Editable field

  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
ENDFORM.                    "fill_fcat
*&---------------------------------------------------------------------*
*&      Form  top-of-page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top-of-page.
* ---- ALV Header declarations ---- *
  DATA: gt_header     TYPE slis_t_listheader,
        gs_header     TYPE slis_listheader,
        ld_lines      TYPE i,
        ld_linesc(10) TYPE c,
        textn         TYPE slis_listheader-info.

* ---- Title ---- *
  gs_header-typ = 'H'.
  gs_header-info = 'Create requested materials' .
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- User ---- *
  gs_header-typ  = 'S'.
  gs_header-key = 'User :- '.
  CONCATENATE  sy-uname ' ' INTO gs_header-info.   "Logged in user
  APPEND gs_header TO gt_header.
  CLEAR: gs_header.

* ---- Total No. of Records Selected ---- *
  DESCRIBE TABLE  it_final LINES ld_lines.
  ld_linesc = ld_lines.
  gs_header-typ  = 'A'.
  CONCATENATE 'Approved materials pending for creation:' ld_linesc INTO textn SEPARATED BY space.
  gs_header-info = textn.
  APPEND gs_header TO gt_header.
  CLEAR: gs_header, textn.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header.

ENDFORM.                    "top-of-page
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.        "#EC CALLED
  SET PF-STATUS 'ZSTAT_MMCREATE'.
ENDFORM.                    "zstat_ins
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
  DATA: ref1     TYPE REF TO cl_gui_alv_grid,
        gv_valid TYPE char01.

  CLEAR gv_valid.
* ---- Get modified ALV data ---- *
  IF r_ucomm EQ '&DATA_SAVE' OR r_ucomm EQ '&CREATE'.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref1.
* ---- Check correctness of changed data ---- *
    CALL METHOD ref1->check_changed_data
      IMPORTING
        e_valid = gv_valid.
* ---- Create material -- only if entered data is valid ---- *
    IF gv_valid IS NOT INITIAL.
      IF it_final[] IS NOT INITIAL.
        PERFORM create_mat.
      ENDIF.
      rs_selfield-refresh = 'X'.
    ELSE.
      CLEAR txt.
      txt = 'Please rectify the above errors in your input.'.
      CLEAR msg.
      CONCATENATE txt msg INTO msg.
      MESSAGE msg TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_mat .
* ---- Check if any line is selected ---- *
  READ TABLE it_final INTO wa_final WITH KEY sel = 'X'.
  IF sy-subrc = 0.
* ---- Perform validation checks on user input ---- *
    PERFORM validation.

    SELECT *
      FROM zsol_mmdef
      INTO TABLE it_mmdef.

    SELECT *
      FROM zsol_luster
      INTO TABLE it_luster.

    SELECT *
      FROM zsol_shade
      INTO TABLE it_shade.

    SELECT *
      FROM zsol_grade
      INTO TABLE it_grade.

    CLEAR: wa_final, lv_items.
    IF it_mmdef[] IS NOT INITIAL.
      LOOP AT it_final INTO wa_final WHERE sel EQ 'X' AND mat_created NE 'X'.
        num = num + 1.
* ---- Add material creation logic here ---- *
        lv_spart = wa_final-spart.
        READ TABLE it_mmdef INTO wa_mmdef WITH KEY spart = lv_spart.
        IF sy-subrc = 0.
* ---- Build headdata ---- *
          headdata-num              = num.
          headdata-material_long    = wa_final-matnr.
          headdata-ind_sector       = 'T'.             " hard-coded for now  - mandatory
          headdata-matl_type        = 'ZERT'.          " hard-coded for now  - mandatory
          headdata-basic_view       = 'X'.
          headdata-sales_view       = 'X'.
          headdata-mrp_view         = 'X'.
          headdata-account_view     = 'X'.
          headdata-WORK_SCHED_VIEW  = 'X'.
          APPEND headdata.

* ---- Build clientdata/x ---- *
          clientdata-num            = num.
          READ TABLE it_shade INTO wa_shade WITH KEY name = wa_final-matnr+11(6).
          IF sy-subrc = 0.
            clientdata-old_mat_no   = wa_shade-mat_shade.
          ENDIF.
          clientdata-matl_group     = wa_final-matl_grp.
          clientdata-DOCUMENT       = wa_final-old_mat.
          clientdata-extmatlgrp     = wa_final-act_denier.
          clientdata-base_uom       = wa_mmdef-meins.
          clientdata-division       = lv_spart.
          READ TABLE it_luster INTO wa_luster WITH KEY name = wa_final-matnr+8(1).
          IF sy-subrc = 0.
            clientdata-dsn_office   = wa_luster-descr+0(2).
            IF  clientdata-dsn_office = 'MI'.
                clientdata-dsn_office = 'MX'.
            ENDIF.
          ENDIF.
          clientdata-prod_memo      = wa_final-denier_desc.
          READ TABLE it_grade INTO wa_grade WITH KEY name = wa_final-matnr+10(1).
          IF sy-subrc = 0.
            clientdata-std_descr    = wa_grade-descr.
          ENDIF.
          clientdata-trans_grp      = wa_mmdef-tragr.
          clientdata-mat_grp_sm     = 'ZRCS'.               " Hard-coded as per client req
          clientdata-PL_REF_MAT     = 'REFPACK'.
          if wa_grade-descr+0(1) ne 'W'.
          clientdata-batch_mgmt     = 'X'.
          endif.
          APPEND clientdata.

          clientdatax-num           = num.
          clientdatax-old_mat_no    = 'X'.
          clientdatax-matl_group    = 'X'.
          clientdatax-extmatlgrp    = 'X'.
          clientdatax-base_uom      = 'X'.
          clientdatax-division      = 'X'.
          clientdatax-dsn_office    = 'X'.
          clientdatax-prod_memo     = 'X'.
          clientdatax-std_descr     = 'X'.
          clientdatax-trans_grp     = 'X'.
          clientdatax-mat_grp_sm    = 'X'.
          clientdatax-PL_REF_MAT    = 'X'.
          clientdatax-batch_mgmt    = 'X'.
          clientdatax-DOCUMENT      = 'X'.
          APPEND clientdatax.

* ---- Build plantdata/x ---- *
          plantdata-num             = num.
          plantdata-plant           = '1110'.          " hard-coded for now  - mandatory
          plantdata-mrp_type        = wa_mmdef-dismm.
          plantdata-mrp_ctrler      = wa_mmdef-dispo.
          plantdata-availcheck      = wa_mmdef-mtvfp.
          plantdata-lotsizekey      = wa_mmdef-disls.
          plantdata-loadinggrp      = wa_mmdef-ladgr.
          plantdata-profit_ctr      = wa_mmdef-prctr.
          if wa_grade-descr+0(1) ne 'W'.
          plantdata-batch_mgmt      = 'X'.
          endif.
          plantdata-iss_st_loc      = wa_mmdef-lgort.
          APPEND plantdata.

          plantdatax-num            = num.
          plantdatax-plant          = '1110'.          " hard-coded for now  - mandatory
          plantdatax-mrp_type       = 'X'.
          plantdatax-mrp_ctrler     = 'X'.
          plantdatax-availcheck     = 'X'.
          plantdatax-lotsizekey     = 'X'.
          plantdatax-loadinggrp     = 'X'.
          plantdatax-profit_ctr     = 'X'.
          plantdatax-batch_mgmt     = 'X'.
          plantdatax-iss_st_loc     = 'X'.
          APPEND plantdatax.

* Can be used if required later
** ---- Build storagelocationdata/x ---- *
          storagelocationdata-num      = num.
          storagelocationdata-plant    = '1110'.
          storagelocationdata-stge_loc = wa_mmdef-lgort_s.
          APPEND storagelocationdata.

          storagelocationdatax-num      = num.
          storagelocationdatax-plant    = '1110'.
          storagelocationdatax-stge_loc = wa_mmdef-lgort_s.
          APPEND storagelocationdatax.

* ---- Build valuationdata/x ---- *
          valuationdata-num         = num.
          valuationdata-val_area    = plantdata-plant.  " hard-coded for now - mandatory
          if wa_grade-descr+0(1) = 'W'.
          valuationdata-val_class   = wa_mmdef-bklas_w.
          else.
          valuationdata-val_class   = wa_mmdef-bklas.
          endif.
          if wa_grade-descr+0(1) = 'W'.
          valuationdata-PRICE_CTRL = 'V'.
          valuationdata-std_price   = wa_final-std_pr_val.
          ELSE.
           valuationdata-std_price   = wa_final-std_pr_val.
           endif.
          APPEND valuationdata.

          valuationdatax-num        = num.
          valuationdatax-val_area   = plantdata-plant.  " hard-coded for now - mandatory
          valuationdatax-val_class  = 'X'.
          valuationdatax-std_price  = 'X'.
          if wa_grade-descr+0(1) = 'W'.
           valuationdatax-PRICE_CTRL = 'X'.
           endif.
          APPEND valuationdatax.

* ---- Build salesdata/x ---- *
          salesdata-num             = num.
          salesdata-distr_chan      = '10'.             " hard-coded for now
          salesdata-sales_org       = '1100'.           " hard-coded for now
          salesdata-acct_assgt      = wa_mmdef-ktgrm.
          APPEND salesdata.

          salesdatax-num            = num.
          salesdatax-distr_chan     = '10'.             " hard-coded for now
          salesdatax-sales_org      = '1100'.           " hard-coded for now
          salesdatax-acct_assgt     = 'X'.
          APPEND salesdatax.

* ---- Build materialdescription table ---- *
          materialdescriptions-num       = num.
          materialdescriptions-langu     = 'EN'.               " hard-coded for now - mandatory
          materialdescriptions-matl_desc = wa_final-maktx.
          APPEND materialdescriptions.

          CALL FUNCTION 'STEUERTAB_IDENTIFY'
            EXPORTING
*             KZRFB                 = ' '
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
* Implement suitable error handling here
          ELSE.
            READ TABLE steuertab INDEX 1.
            IF sy-subrc = 0.
              taxclassifications-num = num.
              MOVE steuertab-aland TO taxclassifications-depcountry.
              MOVE steuertab-tatyp TO taxclassifications-tax_type_1.
              MOVE wa_mmdef-taxkm  TO taxclassifications-taxclass_1.
              APPEND taxclassifications.
              CLEAR steuertab.
            ENDIF.
          ENDIF.

          DELETE it_final WHERE matnr = wa_final-matnr.
        ENDIF.
        CLEAR: headdata, clientdata, clientdatax, plantdata, plantdatax, valuationdata, valuationdatax, taxclassifications ,
        salesdata, salesdatax, materialdescriptions, wa_final, wa_shade, wa_grade , storagelocationdata , storagelocationdatax , wa_mmdef.
      ENDLOOP.

      " Create material in background
      IF headdata[] IS NOT INITIAL.
        CALL FUNCTION 'ZSOL_MATERIAL_CREATE'  IN BACKGROUND TASK
          TABLES
            t_headdata             = headdata
            t_clientdata           = clientdata
            t_clientdatax          = clientdatax
            t_plantdata            = plantdata
            t_plantdatax           = plantdatax
            T_STORAGELOCATIONDATA  = STORAGELOCATIONDATA
            T_STORAGELOCATIONDATAX = STORAGELOCATIONDATAX
            t_valuationdata        = valuationdata
            t_valuationdatax       = valuationdatax
            t_salesdata            = salesdata
            t_salesdatax           = salesdatax
            t_materialdescriptions = materialdescriptions
            t_taxclassifications   = taxclassifications.

        MESSAGE 'Material creation scheduled successfully. Plant - 1100, Sales Org. - 1100, Dist. Channel - 10. Please use transaction AL11 -> DIR_PERF to check the logs.'
        TYPE 'I'.
        COMMIT WORK.
        IF it_final[] IS INITIAL.
          LEAVE PROGRAM.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'No rows selected for processing.' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
  SORT it_final[] BY matnr.
ENDFORM.                    " CREATE_MAT
*&---------------------------------------------------------------------*
*& Form VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validation .
* ---- Process only selected items ---- *
* ---- Validation Process ---- *
*  LOOP AT it_final INTO wa_final WHERE sel EQ 'X'.
*    IF wa_final-std_pr_val IS INITIAL.
*      CLEAR msg.
*      CONCATENATE wa_final-matnr ': Standard price is mandatory.' INTO msg
*      SEPARATED BY space.
*      MESSAGE msg TYPE 'E'.
*    ENDIF.
*    CLEAR: wa_final.
*  ENDLOOP.
ENDFORM.
