*&---------------------------------------------------------------------*
*&  Include           ZSOL_VLMOVE_BAPI_DD
*&---------------------------------------------------------------------*

*-----------------------------------------------------------------------
*   Type-Pools
*-----------------------------------------------------------------------
TYPE-POOLS: truxs.

*-----------------------------------------------------------------------
*   Types
*-----------------------------------------------------------------------
TYPES: BEGIN OF ty_tab,
         plant TYPE werks_d,          " it_mov
         stgloc TYPE lgort_d,         " it_mov
         handunit TYPE exidv,         " it_ext
       END OF ty_tab,

       BEGIN OF ty_data,
         plant TYPE werks_d,          " it_mov
         stgloc TYPE lgort_d,         " it_mov
         handunit TYPE exidv,         " it_ext
         venum TYPE venum,            " it_hu_itm
         vepos TYPE vepos,            " it_hu_itm
         tabix TYPE stabix,           " it_hu_itm
       END OF ty_data,

       BEGIN OF ty_vekp,
         venum TYPE venum,   " int hand unit no
         exidv TYPE exidv,   " hand unit no
       END OF ty_vekp.

*-----------------------------------------------------------------------
*   Internal Tables and Corresponding Work Areas
*-----------------------------------------------------------------------
" int. hand unit no
DATA: it_vekp TYPE TABLE OF ty_vekp,
      wa_vekp TYPE ty_vekp.

" int hand. unit details
DATA: it_vepo TYPE TABLE OF vepo,
      wa_vepo TYPE vepo.

" Plant/Stgloc and mvt type
DATA: it_mv_to TYPE hum_data_move_to_t,
      wa_mv_to LIKE LINE OF it_mv_to.

" hu_item append to move_to
DATA: it_hu_itm TYPE hum_humseg_t,
      wa_hu_im LIKE LINE OF it_hu_itm.

" handling unit
DATA: it_ex_id TYPE hum_exidv_t,
      wa_ex_id LIKE LINE OF it_ex_id.

" output from bapi
DATA: wa_msg TYPE huitem_messages,
      it_msg TYPE huitem_messages_t,
      wa_emkpf TYPE emkpf.

" internal table to hold data from excel
DATA: it_tab TYPE STANDARD TABLE OF ty_tab,
      wa_tab TYPE ty_tab.

" final table containing all reqd data
DATA: it_data TYPE STANDARD TABLE OF ty_data,
      wa_data TYPE ty_data.

" interim tab for xcl to sap conversion
DATA: it_raw TYPE truxs_t_text_data.

*-----------------------------------------------------------------------
*   Variable Declarations
*-----------------------------------------------------------------------
" vlmove
DATA: lv_tcode TYPE sytcode.

" return parameters
DATA: lv_pstd TYPE sysubrc.

" tabix
DATA: cnt TYPE i VALUE '1'.

*-----------------------------------------------------------------------
*   Constants
*-----------------------------------------------------------------------
CONSTANTS: lv_process TYPE huwbevent_vl VALUE '0007',
           lv_mvttype TYPE bwart VALUE '301',
           c_x TYPE c VALUE 'X'.

*-----------------------------------------------------------------------
*   Macros
*-----------------------------------------------------------------------
DEFINE alpha_input.

  call function 'CONVERSION_EXIT_ALPHA_INPUT'
    exporting
      input  = &1 "wa_tab-handunit
    importing
      output = &2. "wa_tab-handunit.
END-OF-DEFINITION.
