*&---------------------------------------------------------------------*
*& report  zsol_class_create
*&
*&---------------------------------------------------------------------*
*& bapi_class_create driver
*&
*&---------------------------------------------------------------------*

REPORT  sy-repid.

" data declaration
TYPE-POOLS: truxs.

CONSTANTS: c_x VALUE 'X',
           valid_to TYPE bapi1003_basic-valid_to VALUE '99991231'.

TYPES: BEGIN OF ty_class,
        classnumnew  TYPE bapi_class_key-classnum,    " import
        classtypenew TYPE bapi_class_key-classtype,   " import
        valid_from   TYPE bapi1003_basic-valid_from,  " classbasicdata - import
        catchword    TYPE bapi1003_catch-catchword,   " classdescriptions
        name_char    TYPE bapi1003_charact-name_char, " classcharacteristics
       END OF ty_class.

" import paramerts - structures
TYPES: classbasicdata TYPE bapi1003_basic.

" bapi tables - structures
TYPES: classdescriptions  LIKE bapi1003_catch,
       classcharacteristics LIKE bapi1003_charact.

" structures to hold bapi return messages
TYPES: return LIKE bapiret2.

" internal table to hold data from excel
DATA: it_class TYPE STANDARD TABLE OF ty_class,
      wa_class TYPE ty_class.

" copy table for internal processing of multi line items for chararcteristics
DATA: it_class_dup TYPE STANDARD TABLE OF ty_class,
      wa_class_dup TYPE ty_class.

" import paramerts
DATA: classnumnew  TYPE bapi_class_key-classnum,    " import
      classtypenew TYPE bapi_class_key-classtype.   " import

DATA: wa_basic TYPE classbasicdata. " structure

" bapi tables
DATA: it_desc TYPE TABLE OF classdescriptions,
      wa_desc TYPE classdescriptions,

      it_char TYPE TABLE OF classcharacteristics,
      wa_char TYPE classcharacteristics.

" return tables
DATA: it_return TYPE STANDARD TABLE OF return WITH HEADER LINE,
      it_ret_all TYPE STANDARD TABLE OF return WITH HEADER LINE.

" for file inport internal use
DATA: it_raw TYPE truxs_t_text_data.

" deletion check within loop - only once
DATA: del_check TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE title.
PARAMETERS: p_file LIKE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

" begin main logic

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'p_file'
    IMPORTING
      file_name     = p_file.

START-OF-SELECTION.

  IF p_file IS NOT INITIAL.

    " convert excel to internal table
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = c_x
        i_line_header        = c_x
        i_tab_raw_data       = it_raw
        i_filename           = p_file
      TABLES
        i_tab_converted_data = it_class
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

  SORT it_class BY classnumnew classtypenew.

  it_class_dup[] = it_class[].  " create a copy for classcharacteristics

  LOOP AT it_class INTO wa_class.

    CLEAR: classnumnew, classtypenew, wa_basic, wa_desc, it_desc, it_char, del_check.

    " populate classnumnew
    classnumnew = wa_class-classnumnew.

    " populate classtypenew
    classtypenew = wa_class-classtypenew.
    PERFORM conversion USING classtypenew CHANGING classtypenew.  " convert classtype in internal format

    " populate classbasicdata str
    wa_basic-status = '1'.
    wa_basic-valid_from = wa_class-valid_from.
    wa_basic-valid_to = valid_to.
    wa_basic-same_value_no = c_x.

    " populate classdescriptions tab
    wa_desc-langu = sy-langu.
    wa_desc-catchword = wa_class-catchword.
    APPEND wa_desc TO it_desc.

    LOOP AT it_class_dup INTO wa_class_dup WHERE classnumnew = wa_class-classnumnew.
      CLEAR wa_char.
      " populate classcharacteristics
      wa_char-name_char = wa_class_dup-name_char.

      APPEND wa_char TO it_char.

      IF del_check <> 1.
        DELETE it_class WHERE classnumnew = wa_class-classnumnew. " prevents duplicate/multiple class creation
        del_check = 1.
      ENDIF.

    ENDLOOP.  " end it_class_dup loop

    " bapi call
    CALL FUNCTION 'BAPI_CLASS_CREATE'
      EXPORTING
        classnumnew          = classnumnew
        classtypenew         = classtypenew
        classbasicdata       = wa_basic
      TABLES
        return               = it_return
        classdescriptions    = it_desc
        classcharacteristics = it_char.

    " commit document using another bapi
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
**      exporting
**        wait = c_x.

    " generate return table for all classes
    LOOP AT it_return.
      MOVE-CORRESPONDING it_return TO it_ret_all.
      APPEND it_ret_all.
    ENDLOOP.

  ENDLOOP.  " end it_tab loop

  " write o/p from bapi call
  LOOP AT it_ret_all.
    ULINE.
    WRITE: / it_ret_all-message.
  ENDLOOP.

*&---------------------------------------------------------------------*
*&      form  conversion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_wa-field  text
*      <--p_wa-field  text
*----------------------------------------------------------------------*
FORM conversion  USING    p_wa-field
                 CHANGING p_wa_field.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' " convert field in internal format
        EXPORTING
          input         = p_wa-field
        IMPORTING
          output        = p_wa-field
            .

ENDFORM.                    " conversion
