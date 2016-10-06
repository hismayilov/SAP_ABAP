*&---------------------------------------------------------------------*
*& Report  ZTEST_SK_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztest_sk_itab_xml.

TABLES: mara.

TYPES: BEGIN OF ty_mara,
        matnr LIKE mara-matnr,
        mbrsh LIKE mara-mbrsh,
        mtart LIKE mara-mtart,
        meins LIKE mara-meins,
      END OF ty_mara.

DATA: it_mara TYPE STANDARD TABLE OF ty_mara,
      wa_mara TYPE ty_mara.

SELECTION-SCREEN BEGIN OF BLOCK b1.
SELECT-OPTIONS: s_matnr FOR mara-matnr.
PARAMETERS: p_fname TYPE string DEFAULT 'E:\USR\SAP\PUT\FILE.XML'.
SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.

  PERFORM get_data.
  PERFORM xml_out.


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  SELECT * FROM mara INTO CORRESPONDING FIELDS OF TABLE it_mara
    WHERE matnr IN s_matnr.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  XML_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM xml_out .

  TYPES: BEGIN OF xml_line,
          data(255) TYPE x,
         END OF xml_line.

  DATA: l_ixml            TYPE REF TO if_ixml,
        l_streamfactory   TYPE REF TO if_ixml_stream_factory,
        l_ostream         TYPE REF TO if_ixml_ostream,
        l_renderer        TYPE REF TO if_ixml_renderer,
        l_document        TYPE REF TO if_ixml_document.

  DATA: l_element_root        TYPE REF TO if_ixml_element,
        ns_attribute          TYPE REF TO if_ixml_attribute,
        r_element_properties  TYPE REF TO if_ixml_element,
        r_element             TYPE REF TO if_ixml_element,
        r_worksheet           TYPE REF TO if_ixml_element,
        r_table               TYPE REF TO if_ixml_element,
        r_column              TYPE REF TO if_ixml_element,
        r_row                 TYPE REF TO if_ixml_element,
        r_cell                TYPE REF TO if_ixml_element,
        r_data                TYPE REF TO if_ixml_element,
        l_value               TYPE string,
        l_type                TYPE string,
        l_text(100)           TYPE c,
        r_styles              TYPE REF TO if_ixml_element,
        r_style               TYPE REF TO if_ixml_element,
        r_style1              TYPE REF TO if_ixml_element,
        r_format              TYPE REF TO if_ixml_element,
        r_border              TYPE REF TO if_ixml_element,
        num_rows              TYPE i,
        l_rc                  TYPE i,
        l_xml_size            TYPE i.


* Creating a ixml Factory
  l_ixml = cl_ixml=>create( ).

* Creating the DOM Object Model
  l_document = l_ixml->create_document( ).

* Create Root Node 'Workbook'
  l_element_root  = l_document->create_simple_element( name = 'Workbook'  parent = l_document ).
  l_element_root->set_attribute( name = 'xmlns'  value = 'urn:schemas-microsoft-com:office:spreadsheet' ).

  ns_attribute = l_document->create_namespace_decl( name = 'ss'  prefix = 'xmlns'  uri = 'urn:schemas-microsoft-com:office:spreadsheet' ).
  l_element_root->set_attribute_node( ns_attribute ).

  ns_attribute = l_document->create_namespace_decl( name = 'x'  prefix = 'xmlns'  uri = 'urn:schemas-microsoft-com:office:excel' ).
  l_element_root->set_attribute_node( ns_attribute ).

* Create node for document properties.
  r_element_properties = l_document->create_simple_element( name = 'TEST_REPORT'  parent = l_element_root ).
  l_value = sy-uname.
  l_document->create_simple_element( name = 'Author'  value = l_value  parent = r_element_properties  ).

* Styles
  r_styles = l_document->create_simple_element( name = 'Styles'  parent = l_element_root  ).

* Style for Header
  r_style  = l_document->create_simple_element( name = 'Style'   parent = r_styles  ).
  r_style->set_attribute_ns( name = 'ID'  prefix = 'ss'  value = 'Header' ).

  r_format  = l_document->create_simple_element( name = 'Font'  parent = r_style  ).
  r_format->set_attribute_ns( name = 'Bold'  prefix = 'ss'  value = '1' ).

  r_format  = l_document->create_simple_element( name = 'Interior' parent = r_style  ).
  r_format->set_attribute_ns( name = 'Color'   prefix = 'ss'  value = '#92D050' ).
  r_format->set_attribute_ns( name = 'Pattern' prefix = 'ss'  value = 'Solid' ).

  r_format  = l_document->create_simple_element( name = 'Alignment'  parent = r_style  ).
  r_format->set_attribute_ns( name = 'Vertical'  prefix = 'ss'  value = 'Center' ).
  r_format->set_attribute_ns( name = 'WrapText'  prefix = 'ss'  value = '1' ).

  r_border  = l_document->create_simple_element( name = 'Borders'  parent = r_style ).
  r_format  = l_document->create_simple_element( name = 'Border'   parent = r_border  ).
  r_format->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Bottom' ).
  r_format->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = 'Continuous' ).
  r_format->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = '1' ).

  r_format  = l_document->create_simple_element( name = 'Border'   parent = r_border  ).
  r_format->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Left' ).
  r_format->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = 'Continuous' ).
  r_format->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = '1' ).

  r_format  = l_document->create_simple_element( name = 'Border'   parent = r_border  ).
  r_format->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Top' ).
  r_format->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = 'Continuous' ).
  r_format->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = '1' ).

  r_format  = l_document->create_simple_element( name = 'Border'   parent = r_border  ).
  r_format->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Right' ).
  r_format->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = 'Continuous' ).
  r_format->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = '1' ).

* Style for Data
  r_style1  = l_document->create_simple_element( name = 'Style'   parent = r_styles  ).
  r_style1->set_attribute_ns( name = 'ID'  prefix = 'ss'  value = 'Data' ).

  r_border  = l_document->create_simple_element( name = 'Borders'  parent = r_style1 ).
  r_format  = l_document->create_simple_element( name = 'Border'   parent = r_border  ).
  r_format->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Bottom' ).
  r_format->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = 'Continuous' ).
  r_format->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = '1' ).

  r_format  = l_document->create_simple_element( name = 'Border'   parent = r_border  ).
  r_format->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Left' ).
  r_format->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = 'Continuous' ).
  r_format->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = '1' ).

  r_format  = l_document->create_simple_element( name = 'Border'   parent = r_border  ).
  r_format->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Top' ).
  r_format->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = 'Continuous' ).
  r_format->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = '1' ).

  r_format  = l_document->create_simple_element( name = 'Border'   parent = r_border  ).
  r_format->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Right' ).
  r_format->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = 'Continuous' ).
  r_format->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = '1' ).


* Worksheet
  r_worksheet = l_document->create_simple_element( name = 'Worksheet'  parent = l_element_root ).
  r_worksheet->set_attribute_ns( name = 'Name'  prefix = 'ss'  value = 'Sheet1' ).

* Table
  r_table = l_document->create_simple_element( name = 'Table'  parent = r_worksheet ).
  r_table->set_attribute_ns( name = 'FullColumns'  prefix = 'x'  value = '1' ).
  r_table->set_attribute_ns( name = 'FullRows'     prefix = 'x'  value = '1' ).

* Column Formatting
  r_column = l_document->create_simple_element( name = 'Column'  parent = r_table ).
  r_column->set_attribute_ns( name = 'Width'  prefix = 'ss'  value = '100' ).

  r_column = l_document->create_simple_element( name = 'Column'  parent = r_table ).
  r_column->set_attribute_ns( name = 'Width'  prefix = 'ss'  value = '100' ).

  r_column = l_document->create_simple_element( name = 'Column'  parent = r_table ).
  r_column->set_attribute_ns( name = 'Width'  prefix = 'ss'  value = '100' ).

  r_column = l_document->create_simple_element( name = 'Column'  parent = r_table ).
  r_column->set_attribute_ns( name = 'Width'  prefix = 'ss'  value = '100' ).


* Blank Row
  r_row = l_document->create_simple_element( name = 'Row'  parent = r_table ).

* Column Headers Row
  r_row = l_document->create_simple_element( name = 'Row'  parent = r_table ).
  r_row->set_attribute_ns( name = 'AutoFitHeight'  prefix = 'ss'  value = '1' ).

* MATNR
  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Header' ).
  r_data = l_document->create_simple_element( name = 'Data'  value = 'MATERIAL'  parent = r_cell ).
  r_data->set_attribute_ns( name = 'Type'  prefix = 'ss' value = 'String' ).

* MBRSH
  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Header' ).
  r_data = l_document->create_simple_element( name = 'Data'  value = 'IND SECTOR'  parent = r_cell ).
  r_data->set_attribute_ns( name = 'Type'  prefix = 'ss' value = 'String' ).

* MTART
  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Header' ).
  r_data = l_document->create_simple_element( name = 'Data'  value = 'MAT TYPE'  parent = r_cell ).
  r_data->set_attribute_ns( name = 'Type'  prefix = 'ss' value = 'String' ).

* MEINS
  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Header' ).
  r_data = l_document->create_simple_element( name = 'Data'  value = 'UNIT'  parent = r_cell ).
  r_data->set_attribute_ns( name = 'Type'  prefix = 'ss' value = 'String' ).

* Blank Row after Column Headers
  r_row = l_document->create_simple_element( name = 'Row'  parent = r_table ).
  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).

  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).

  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).

  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).

  r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
  r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).

* Data Table
  LOOP AT it_mara INTO wa_mara.

    r_row = l_document->create_simple_element( name = 'Row'  parent = r_table ).

* MATNR
    r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
    r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).
    l_value = wa_mara-matnr.
    "CONDENSE l_value NO-GAPS.
    r_data = l_document->create_simple_element( name = 'Data'  value = l_value   parent = r_cell ).           " Data
    r_data->set_attribute_ns( name = 'Type'  prefix = 'ss'  value = 'Number' ).                               " Cell format

* MBRSH
    r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
    r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).
    l_value = wa_mara-mbrsh.
    r_data = l_document->create_simple_element( name = 'Data'  value = l_value   parent = r_cell ).           " Data
    r_data->set_attribute_ns( name = 'Type'  prefix = 'ss'  value = 'String' ).                               " Cell format

* MTART
    r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
    r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).
    l_value = wa_mara-mtart.
    r_data = l_document->create_simple_element( name = 'Data'  value = l_value   parent = r_cell ).           " Data
    r_data->set_attribute_ns( name = 'Type'  prefix = 'ss'  value = 'String' ).                               " Cell format

* MEINS
    r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).
    r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = 'Data' ).
    l_value = wa_mara-meins.
    r_data = l_document->create_simple_element( name = 'Data'  value = l_value   parent = r_cell ).           " Data
    r_data->set_attribute_ns( name = 'Type'  prefix = 'ss'  value = 'String' ).                               " Cell format

  ENDLOOP.

* Creating a Stream Factory
  l_streamfactory = l_ixml->create_stream_factory( ).

* Connect Internal XML Table to Stream Factory
  "l_ostream = l_streamfactory->create_ostream_itable( table = l_xml_table ).
  l_ostream = l_streamfactory->create_ostream_uri( system_id = p_fname ).

* Rendering the Document
  l_renderer = l_ixml->create_renderer( ostream  = l_ostream  document = l_document ).

  l_ostream->set_pretty_print( 'X' ).

  l_rc = l_renderer->render( ).

* Saving the XML Document
  l_xml_size = l_ostream->get_num_written_raw( ).


ENDFORM.                    " XML_OUT
