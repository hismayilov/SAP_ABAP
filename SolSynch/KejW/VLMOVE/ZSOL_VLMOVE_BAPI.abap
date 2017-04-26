" Version 1 -----------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Report ZSOL_VLMOVE_BAPI
*&
*&---------------------------------------------------------------------*
*& Created by Saurabh Khare, SolSynch Technologies
*& Creaton On: 18.10.2016
*& Desc: Program to create handling unit trasnfer posting document
*& (VLMOVE) using BAPI for mmultiple hand. units (from xcel sheet)
*&---------------------------------------------------------------------*

REPORT sy-repid.

INCLUDE zsol_vlmove_bapi_dd.     " Data Declarations

INCLUDE zsol_vlmove_bapi_ss.     " Selection Screen

INCLUDE zsol_vlmove_bapi_fr.     " Form Routines

*-----------------------------------------------------------------------
*   Initialization
*-----------------------------------------------------------------------
INITIALIZATION.

    PERFORM init.

*-----------------------------------------------------------------------
*   At Selection Screen
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_file.

*-----------------------------------------------------------------------
*   Start-of-selection
*-----------------------------------------------------------------------

START-OF-SELECTION.

  PERFORM upload.
  PERFORM get_data.
  PERFORM bapi.

" Version 2 -----------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Report ZTEST_VLMOVE_BAPI
*&
*&---------------------------------------------------------------------*
*& Created by Saurabh Khare, SolSynch Technologies
*& Creaton On: 18.10.2016
*& Desc: Program to create handling unit trasnfer posting document
*& (VLMOVE) using BAPI for mmultiple hand. units
*&---------------------------------------------------------------------*

REPORT sy-repid.

INCLUDE zsol_vlmove_bapi_dd.     " Data Declarations

INCLUDE zsol_vlmove_bapi_ss.     " Selection Screen

INCLUDE zsol_vlmove_bapi_fr.     " Form Routines

*-----------------------------------------------------------------------
*   Initialization
*-----------------------------------------------------------------------
INITIALIZATION.

  PERFORM init.

*-----------------------------------------------------------------------
*   Start-of-selection
*-----------------------------------------------------------------------

START-OF-SELECTION.

  PERFORM get_data.
  PERFORM bapi.
