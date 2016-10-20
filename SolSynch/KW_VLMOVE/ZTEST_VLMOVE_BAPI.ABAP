*&---------------------------------------------------------------------*
*& Report ZTEST_VLMOVE_BAPI
*&
*&---------------------------------------------------------------------*
*& Created by Saurabh Khare, SolSynch Technologies
*& Creaton On: 18.10.2016
*& Desc: Program to create handling unit trasnfer posting document
*& (VLMOVE) using BAPI for mmultiple hand. units (from xcel sheet)
*&---------------------------------------------------------------------*

REPORT sy-repid.

INCLUDE ztest_vlmove_bapi_dd.     " Data Declarations

INCLUDE ztest_vlmove_bapi_ss.     " Selection Screen

INCLUDE ztest_vlmove_bapi_fr.     " Form Routines

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
