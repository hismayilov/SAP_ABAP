*&---------------------------------------------------------------------*
*& Report  ZTEST_SK_BAPI_PO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZTEST_SK_BAPI_PO.

" DATA DECLARATION
TYPE-POOLS: TRUXS.

CONSTANTS: C_X VALUE 'X'.

" STRUCTURES TO HOLD PO HEADER DATA
TYPES: HEADER  LIKE BAPIMEPOHEADER, " LIKE FOR GLOBAL OBJECT
       HEADERX LIKE BAPIMEPOHEADERX.

" STRUCTURES FOR HOLD PO ITEM DATA
TYPES: ITEM  LIKE BAPIMEPOITEM,
       ITEMX LIKE BAPIMEPOITEMX.

" STRUCTURES TO HOLD PO SCHEDULE DATA
" PLACEHOLDER

" STRUCTURES TO HOLD PO CONDITION DATA
" PLACEHOLDER

" STRUCTURES TO HOLD BAPI RETURN MESSAGES
TYPES: RETURN LIKE BAPIRET2.

" INTERNAL TABLE TO HOLD DATA FROM EXCEL
DATA: IT_TAB TYPE STANDARD TABLE OF ZST_SK_PO_BAPI,
      WA_TAB TYPE ZST_SK_PO_BAPI,

" SEPARATE LINE ITEM FROM HEADER BY COPYING TO ANOTHER INT TAB
      IT_TAB_LITEM TYPE STANDARD TABLE OF ZST_SK_PO_BAPI,
      WA_TAB_LITEM TYPE ZST_SK_PO_BAPI.

" INTERNAL TABLES FOR PO HEADER DATA
DATA: WA_HEADER  TYPE HEADER,
      WA_HEADERX TYPE HEADERX.

" INTERNAL TABLES FOR PO ITEM DATA
DATA: IT_ITEM  TYPE STANDARD TABLE OF ITEM,
      WA_ITEM  TYPE ITEM,
      IT_ITEMX TYPE STANDARD TABLE OF ITEMX,
      WA_ITEMX TYPE ITEMX.

" INTERNAL TABLES FOR PO ITEM DATA
DATA: IT_RETURN TYPE STANDARD TABLE OF RETURN,
      WA_RETURN TYPE RETURN.

" INTERNAL TABLES FOR PO SCHEDULE DATA
" PLACEHOLDER

" INTERNAL TABLES FOR PO CONDITION DATA
" PLACEHOLDER

DATA: IT_RAW TYPE TRUXS_T_TEXT_DATA.

" VAR TO HOLD RETURNED PO NUMBER
DATA: PO_NUM TYPE HEADER-PO_NUMBER.

" DELETION CHECK WITHIN LOOP - ONLY ONCE
DATA: DEL_CHECK TYPE I.

" SYSTEM LANGUAGE
"DATA: LANG LIKE SY-LANGU.

" SYSTEM DATE
"DATA: DATE LIKE SY-DATUM.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TITLE.
PARAMETERS: P_FILE LIKE RLGRAP-FILENAME OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B1.

" BEGIN MAIN LOGIC

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SYST-CPROG
      DYNPRO_NUMBER = SYST-DYNNR
      FIELD_NAME    = 'P_FILE'
    IMPORTING
      FILE_NAME     = P_FILE.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      I_FIELD_SEPERATOR    = C_X
      I_LINE_HEADER        = C_X
      I_TAB_RAW_DATA       = IT_RAW
      I_FILENAME           = P_FILE
    TABLES
      I_TAB_CONVERTED_DATA = IT_TAB
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

START-OF-SELECTION.

  " DATA POPULATION
  "LANG   = SY-LANGU.
  "DATE   = SY-DATUM.

  SORT IT_TAB BY PO_NUMBER.

  IT_TAB_LITEM[] = IT_TAB[].  " CREATE A COPY FOR ITEM DATA

  LOOP AT IT_TAB INTO WA_TAB.

    CLEAR: WA_HEADER, WA_HEADERX, WA_ITEM, WA_ITEMX, IT_ITEM, IT_ITEMX, DEL_CHECK.

    " POPULATE PO HEADER DATA
    WA_HEADER-COMP_CODE   = WA_TAB-COMP_CODE.
    WA_HEADER-DOC_TYPE    = WA_TAB-DOC_TYPE.
    WA_HEADER-CREAT_DATE  = WA_TAB-CREAT_DATE.

    PERFORM CONVERSION USING WA_TAB-ITEM_INTVL CHANGING WA_TAB-ITEM_INTVL.  " CONVERT ITEM_INTVL IN INTERNAL FORMAT
    WA_HEADERX-ITEM_INTVL = WA_TAB-ITEM_INTVL.

    PERFORM CONVERSION USING WA_TAB-VENDOR CHANGING WA_TAB-VENDOR.  " CONVERT VENDOR IN INTERNAL FORMAT
    WA_HEADER-VENDOR      = WA_TAB-VENDOR.
    WA_HEADER-PURCH_ORG   = WA_TAB-PURCH_ORG.
    WA_HEADER-PUR_GROUP   = WA_TAB-PUR_GROUP.

    " POPULATE PO HEADER FLAG DATA
    WA_HEADERX-COMP_CODE  = WA_TAB-COMP_CODEX.
    WA_HEADERX-DOC_TYPE   = WA_TAB-DOC_TYPEX.
    WA_HEADERX-CREAT_DATE = WA_TAB-CREAT_DATEX.
    WA_HEADERX-ITEM_INTVL = WA_TAB-ITEM_INTVLX.
    WA_HEADERX-VENDOR     = WA_TAB-VENDORX.
    WA_HEADERX-PURCH_ORG  = WA_TAB-PURCH_ORGX.
    WA_HEADERX-PUR_GROUP  = WA_TAB-PUR_GROUPX.

    LOOP AT IT_TAB_LITEM INTO WA_TAB_LITEM WHERE PO_NUMBER = WA_TAB-PO_NUMBER.

      " POPULATE PO ITEM DATA
      PERFORM CONVERSION USING WA_TAB_LITEM-PO_ITEM CHANGING WA_TAB_LITEM-PO_ITEM.  " CONVERT PO_ITEM IN INTERNAL FORMAT
      WA_ITEM-PO_ITEM    = WA_TAB_LITEM-PO_ITEM.
      WA_ITEM-SHORT_TEXT = WA_TAB_LITEM-SHORT_TEXT.

      PERFORM CONVERSION USING WA_TAB_LITEM-MATERIAL CHANGING WA_TAB_LITEM-MATERIAL.  " CONVERT MATERIAL IN INTERNAL FORMAT
      WA_ITEM-MATERIAL   = WA_TAB_LITEM-MATERIAL.
      WA_ITEM-PLANT      = WA_TAB_LITEM-PLANT.
      WA_ITEM-MATL_GROUP = WA_TAB_LITEM-MATL_GROUP.
      WA_ITEM-QUANTITY   = WA_TAB_LITEM-QUANTITY.
      WA_ITEM-NET_PRICE  = WA_TAB_LITEM-NET_PRICE.

      APPEND WA_ITEM TO IT_ITEM.

      " POPULATE PO ITEM FLAG DATA
      WA_ITEMX-PO_ITEM    = WA_TAB_LITEM-PO_ITEM.
      WA_ITEMX-PO_ITEMX   = WA_TAB_LITEM-PO_ITEMX.
      WA_ITEMX-SHORT_TEXT = WA_TAB_LITEM-SHORT_TEXTX.
      WA_ITEMX-MATERIAL   = WA_TAB_LITEM-MATERIALX.
      WA_ITEMX-PLANT      = WA_TAB_LITEM-PLANTX.
      WA_ITEMX-STGE_LOC   = WA_TAB_LITEM-STGE_LOCX.
      WA_ITEMX-MATL_GROUP = WA_TAB_LITEM-MATL_GROUPX.
      WA_ITEMX-QUANTITY   = WA_TAB_LITEM-QUANTITYX.
      WA_ITEMX-NET_PRICE  = WA_TAB_LITEM-NET_PRICEX.

      APPEND WA_ITEMX TO IT_ITEMX.

      IF DEL_CHECK <> 1.
        DELETE IT_TAB WHERE PO_NUMBER = WA_TAB-PO_NUMBER. " PREVENTS DUPLICATE/MULTIPLE PO CREATION
        DEL_CHECK = 1.
      ENDIF.

    ENDLOOP.


    " BAPI CALL
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        POHEADER                    = WA_HEADER
        POHEADERX                   = WA_HEADERX
*   POADDRVENDOR                 =
*   TESTRUN                      =
*   MEMORY_UNCOMPLETE            =
*   MEMORY_COMPLETE              =
*   POEXPIMPHEADER               =
*   POEXPIMPHEADERX              =
*   VERSIONS                     =
*   NO_MESSAGING                 =
*   NO_MESSAGE_REQ               =
*   NO_AUTHORITY                 =
*   NO_PRICE_FROM_PO             =
      IMPORTING
        EXPPURCHASEORDER            = PO_NUM
*   EXPHEADER                    =
*   EXPPOEXPIMPHEADER            =
      TABLES
        RETURN                      = IT_RETURN
        POITEM                      = IT_ITEM
        POITEMX                     = IT_ITEMX
*   POADDRDELIVERY               =
*   POSCHEDULE                   =
*   POSCHEDULEX                  =
*   POACCOUNT                    =
*   POACCOUNTPROFITSEGMENT       =
*   POACCOUNTX                   =
*   POCONDHEADER                 =
*   POCONDHEADERX                =
*   POCOND                       =
*   POCONDX                      =
*   POLIMITS                     =
*   POCONTRACTLIMITS             =
*   POSERVICES                   =
*   POSRVACCESSVALUES            =
*   POSERVICESTEXT               =
*   EXTENSIONIN                  =
*   EXTENSIONOUT                 =
*   POEXPIMPITEM                 =
*   POEXPIMPITEMX                =
*   POTEXTHEADER                 =
*   POTEXTITEM                   =
*   ALLVERSIONS                  =
*   POPARTNER                    =
*   POCOMPONENTS                 =
*   POCOMPONENTSX                =
*   POSHIPPING                   =
*   POSHIPPINGX                  =
*   POSHIPPINGEXP                =
                .

    " COMMIT DOCUMENT USING ANOTHER BAPI
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT          = C_X
* IMPORTING
*   RETURN        =
                .

    WRITE: / 'CREATED PO WITH NUMBER: ', PO_NUM.

  ENDLOOP.

  " WRITE O/P FROM BAPI CALL

  LOOP AT IT_RETURN INTO WA_RETURN.
    ULINE.
    WRITE: / WA_RETURN-MESSAGE.
  ENDLOOP.

*&---------------------------------------------------------------------*
*&      Form  CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_TAB_ITEM_INTVL  text
*      <--P_WA_TAB_ITEM_INTVL  text
*----------------------------------------------------------------------*
FORM CONVERSION  USING    P_WA-FIELD
                 CHANGING P_WA_FIELD.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' " CONVERT FIELD IN INTERNAL FORMAT
        EXPORTING
          INPUT         = P_WA-FIELD
        IMPORTING
          OUTPUT        = P_WA-FIELD
            .

ENDFORM.                    " CONVERSION

*================================================Correct Case===============================================*

*&---------------------------------------------------------------------*
*& Report  ZTEST_SK_BAPI_PO
*&
*&---------------------------------------------------------------------*
*& Created by Saurabh Khare, SolSynch Technologies
*& Program to create PO using BAPI for multi-line items (from xcel sheet)
*&---------------------------------------------------------------------*

REPORT  ztest_sk_bapi_po.

" DATA DECLARATION
TYPE-POOLS: truxs.

CONSTANTS: c_x VALUE 'X'.

" STRUCTURES TO HOLD PO HEADER DATA
TYPES: header  LIKE bapimepoheader, " LIKE FOR GLOBAL OBJECT
       headerx LIKE bapimepoheaderx.

" STRUCTURES FOR HOLD PO ITEM DATA
TYPES: item  LIKE bapimepoitem,
       itemx LIKE bapimepoitemx.

" STRUCTURES TO HOLD PO SCHEDULE DATA
" PLACEHOLDER

" STRUCTURES TO HOLD PO CONDITION DATA
" PLACEHOLDER

" STRUCTURES TO HOLD BAPI RETURN MESSAGES
TYPES: return LIKE bapiret2,
       ret_all LIKE bapiret2.

" STRUCTURES FOR OUT TABLE/ OUT TABLE HEADER
TYPES: BEGIN OF ty_out_head,
         f1 TYPE string,
         f2 TYPE string,
       END OF ty_out_head,

       BEGIN OF ty_out,
         file_po   LIKE bapimepoheader-po_number,
         po_number LIKE bapimepoheader-po_number,
       END OF ty_out.

" INTERNAL TABLE TO HOLD DATA FROM EXCEL
DATA: it_tab TYPE STANDARD TABLE OF zst_sk_po_bapi,
      wa_tab TYPE zst_sk_po_bapi,

" SEPARATE LINE ITEM FROM HEADER BY COPYING TO ANOTHER INT TAB
      it_tab_litem TYPE STANDARD TABLE OF zst_sk_po_bapi,
      wa_tab_litem TYPE zst_sk_po_bapi.

" INTERNAL TABLES FOR PO HEADER DATA
DATA: wa_header  TYPE header,
      wa_headerx TYPE headerx.

" INTERNAL TABLES FOR PO ITEM DATA
DATA: it_item  TYPE STANDARD TABLE OF item,
      wa_item  TYPE item,
      it_itemx TYPE STANDARD TABLE OF itemx,
      wa_itemx TYPE itemx.

" INTERNAL TABLES FOR PO ITEM DATA
DATA: it_return TYPE STANDARD TABLE OF return WITH HEADER LINE,
      "wa_return TYPE return,

      it_ret_all TYPE STANDARD TABLE OF ret_all WITH HEADER LINE.
"wa_ret_all TYPE ret_all.

" INTERNAL TABLES TO HOLD OUTPUT PO
DATA: it_out TYPE STANDARD TABLE OF ty_out,
      wa_out TYPE ty_out.

" INTERNAL TABLES FOR PO SCHEDULE DATA
" PLACEHOLDER

" INTERNAL TABLES FOR PO CONDITION DATA
" PLACEHOLDER

DATA: it_raw TYPE truxs_t_text_data.

" VAR TO HOLD RETURNED PO NUMBER
DATA: po_num TYPE header-po_number.

" DELETION CHECK WITHIN LOOP - ONLY ONCE
DATA: del_check TYPE i.

" DIR PATH
DATA: dir_path TYPE string,
      out_path_def TYPE string.

" DEF FILE NAME
DATA: file_out TYPE rlgrap-filename VALUE 'OUT.xls'.

" SYSTEM LANGUAGE
"DATA: LANG LIKE SY-LANGU.

" SYSTEM DATE
"DATA: DATE LIKE SY-DATUM.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE title.
PARAMETERS: p_file LIKE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

" BEGIN MAIN LOGIC

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'p_file'
    IMPORTING
      file_name     = p_file.

  IF p_file IS NOT INITIAL.

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = c_x
        i_line_header        = c_x
        i_tab_raw_data       = it_raw
        i_filename           = p_file
      TABLES
        i_tab_converted_data = it_tab
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

START-OF-SELECTION.

  "POPULATE OUT TABLE HEADER
  wa_out-file_po = 'FILE INDEX'.
  wa_out-po_number = 'PO NUMBER'.
  APPEND wa_out TO it_out.

  " DATA POPULATION
  "LANG   = SY-LANGU.
  "DATE   = SY-DATUM.

  SORT it_tab BY po_number.

  it_tab_litem[] = it_tab[].  " CREATE A COPY FOR ITEM DATA

  LOOP AT it_tab INTO wa_tab.

    CLEAR: wa_header, wa_headerx, wa_item, wa_itemx, it_item, it_itemx, del_check.

    " POPULATE PO HEADER DATA
    wa_header-comp_code   = wa_tab-comp_code.
    wa_header-doc_type    = wa_tab-doc_type.
    wa_header-creat_date  = wa_tab-creat_date.

    PERFORM conversion USING wa_tab-item_intvl CHANGING wa_tab-item_intvl.  " CONVERT ITEM_INTVL IN INTERNAL FORMAT
    wa_headerx-item_intvl = wa_tab-item_intvl.

    PERFORM conversion USING wa_tab-vendor CHANGING wa_tab-vendor.  " CONVERT VENDOR IN INTERNAL FORMAT
    wa_header-vendor      = wa_tab-vendor.
    wa_header-purch_org   = wa_tab-purch_org.
    wa_header-pur_group   = wa_tab-pur_group.

    " POPULATE PO HEADER FLAG DATA
    wa_headerx-comp_code  = wa_tab-comp_codex.
    wa_headerx-doc_type   = wa_tab-doc_typex.
    wa_headerx-creat_date = wa_tab-creat_datex.
    wa_headerx-item_intvl = wa_tab-item_intvlx.
    wa_headerx-vendor     = wa_tab-vendorx.
    wa_headerx-purch_org  = wa_tab-purch_orgx.
    wa_headerx-pur_group  = wa_tab-pur_groupx.

    LOOP AT it_tab_litem INTO wa_tab_litem WHERE po_number = wa_tab-po_number.

      " POPULATE PO ITEM DATA
      PERFORM conversion USING wa_tab_litem-po_item CHANGING wa_tab_litem-po_item.  " CONVERT PO_ITEM IN INTERNAL FORMAT
      wa_item-po_item    = wa_tab_litem-po_item.
      wa_item-short_text = wa_tab_litem-short_text.

      PERFORM conversion USING wa_tab_litem-material CHANGING wa_tab_litem-material.  " CONVERT MATERIAL IN INTERNAL FORMAT
      wa_item-material   = wa_tab_litem-material.
      wa_item-plant      = wa_tab_litem-plant.
      wa_item-matl_group = wa_tab_litem-matl_group.
      wa_item-quantity   = wa_tab_litem-quantity.
      wa_item-net_price  = wa_tab_litem-net_price.

      APPEND wa_item TO it_item.

      " POPULATE PO ITEM FLAG DATA
      wa_itemx-po_item    = wa_tab_litem-po_item.
      wa_itemx-po_itemx   = wa_tab_litem-po_itemx.
      wa_itemx-short_text = wa_tab_litem-short_textx.
      wa_itemx-material   = wa_tab_litem-materialx.
      wa_itemx-plant      = wa_tab_litem-plantx.
      wa_itemx-stge_loc   = wa_tab_litem-stge_locx.
      wa_itemx-matl_group = wa_tab_litem-matl_groupx.
      wa_itemx-quantity   = wa_tab_litem-quantityx.
      wa_itemx-net_price  = wa_tab_litem-net_pricex.

      APPEND wa_itemx TO it_itemx.

      IF del_check <> 1.
        DELETE it_tab WHERE po_number = wa_tab-po_number. " PREVENTS DUPLICATE/MULTIPLE PO CREATION
        del_check = 1.
      ENDIF.

    ENDLOOP.


    " BAPI CALL
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader                    = wa_header
        poheaderx                   = wa_headerx
*   POADDRVENDOR                 =
*   TESTRUN                      =
*   MEMORY_UNCOMPLETE            =
*   MEMORY_COMPLETE              =
*   POEXPIMPHEADER               =
*   POEXPIMPHEADERX              =
*   VERSIONS                     =
*   NO_MESSAGING                 =
*   NO_MESSAGE_REQ               =
*   NO_AUTHORITY                 =
*   NO_PRICE_FROM_PO             =
      IMPORTING
        exppurchaseorder            = po_num
*   EXPHEADER                    =
*   EXPPOEXPIMPHEADER            =
      TABLES
        return                      = it_return
        poitem                      = it_item
        poitemx                     = it_itemx
*   POADDRDELIVERY               =
*   POSCHEDULE                   =
*   POSCHEDULEX                  =
*   POACCOUNT                    =
*   POACCOUNTPROFITSEGMENT       =
*   POACCOUNTX                   =
*   POCONDHEADER                 =
*   POCONDHEADERX                =
*   POCOND                       =
*   POCONDX                      =
*   POLIMITS                     =
*   POCONTRACTLIMITS             =
*   POSERVICES                   =
*   POSRVACCESSVALUES            =
*   POSERVICESTEXT               =
*   EXTENSIONIN                  =
*   EXTENSIONOUT                 =
*   POEXPIMPITEM                 =
*   POEXPIMPITEMX                =
*   POTEXTHEADER                 =
*   POTEXTITEM                   =
*   ALLVERSIONS                  =
*   POPARTNER                    =
*   POCOMPONENTS                 =
*   POCOMPONENTSX                =
*   POSHIPPING                   =
*   POSHIPPINGX                  =
*   POSHIPPINGEXP                =
                .

    " COMMIT DOCUMENT USING ANOTHER BAPI
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait          = c_x
* IMPORTING
*   RETURN        =
                .

    LOOP AT it_return.  " GENERATE RETURN TABLE FOR ALL PO'S
      MOVE-CORRESPONDING it_return TO it_ret_all.
      APPEND it_ret_all.
    ENDLOOP.

    WRITE: / 'CREATED PO WITH NUMBER: ', po_num.
    wa_out-file_po = wa_tab-po_number.
    wa_out-po_number = po_num.
    APPEND wa_out TO it_out.

  ENDLOOP.

  " WRITE O/P FROM BAPI CALL

  LOOP AT it_ret_all.
    ULINE.
    WRITE: / it_ret_all-message.
  ENDLOOP.

  " GET DEFAULT PATH FROM INPUT FILE
  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name           = p_file
    IMPORTING
*      STRIPPED_NAME       =
      file_path           = out_path_def
    EXCEPTIONS
      x_error             = 1
      OTHERS              = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Select Directory for Output File'
      initial_folder       = out_path_def
    CHANGING
      selected_folder      = dir_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CONCATENATE dir_path file_out INTO file_out.

  IF file_out IS NOT INITIAL AND it_out IS NOT INITIAL.

    CALL FUNCTION 'SAP_CONVERT_TO_XLS_FORMAT'
      EXPORTING
*        i_field_seperator          = c_x
*        i_line_header              = c_x
        i_filename                 = file_out
*     I_APPL_KEEP                = ' '
      TABLES
        i_tab_sap_data             = it_out
*   CHANGING
*     I_TAB_CONVERTED_DATA       =
      EXCEPTIONS
        conversion_failed          = 1
      OTHERS                       = 2
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_TAB_ITEM_INTVL  text
*      <--P_WA_TAB_ITEM_INTVL  text
*----------------------------------------------------------------------*
FORM conversion  USING    p_wa-field
                 CHANGING p_wa_field.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' " CONVERT FIELD IN INTERNAL FORMAT
        EXPORTING
          input         = p_wa-field
        IMPORTING
          output        = p_wa-field
            .

ENDFORM.                    " CONVERSION
