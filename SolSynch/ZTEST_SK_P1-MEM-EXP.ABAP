*&---------------------------------------------------------------------*
*& Report  ZTEST_SK_P1
*&
*&---------------------------------------------------------------------*
*& Creadted By: Saurabh Khare
*& Created On: 22.09.2016
*& Descritption: Export value to another prog via memory id
*&---------------------------------------------------------------------*

REPORT  ztest_sk_p1.

DATA: var TYPE c LENGTH 10.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: input TYPE c LENGTH 10.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  var = input.

  EXPORT var TO MEMORY ID 'VAR'.

  SUBMIT ztest_sk_p2.
  
" ===================================
  *&---------------------------------------------------------------------*
*& Report  ZTEST_SK_P2
*&
*&---------------------------------------------------------------------*
*& Creadted By: Saurabh Khare
*& Created On: 22.09.2016
*& Descritption: Import value from another prog via memory id,
*& Calling prog: ZTEST_SK_P1
*&---------------------------------------------------------------------*

REPORT  ztest_sk_p2.

DATA: var TYPE c LENGTH 10.

START-OF-SELECTION.
  IMPORT var FROM MEMORY ID 'VAR'.

  WRITE: var.
