*&---------------------------------------------------------------------*
*& Report  ZTEST_SK_06_DYNPRO
*&
*&---------------------------------------------------------------------*
*& Program to demonstrate 3 types of screen
*&
*&---------------------------------------------------------------------*

REPORT  ztest_sk_06_dynpro.

DATA: ok_code LIKE sy-ucomm.

* Selection Screen
PARAMETERS input(12) TYPE c DEFAULT 'Hello World!'.

* Dynpro
CALL SCREEN 100.  " Screen:InterimScreenForHellowworld

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'TITLE'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'NEXT'.
      PERFORM DISPLAY_LIST.
      LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
      "OR
      "LEAVE TO SCREEN 0. " SCREEN 0 = RETURN TO POINT OF LAST EXECUTION WHERE SCREEN WAS CALLED AND CONTINUE
      "OR
      "SET SCREEN 0.
      "LEAVE SCREEN.
    WHEN 'BACK'.
      CALL SELECTION-SCREEN 1000. " GO BACK TO SELECTION SCREEN
    WHEN 'EXIT'.
      CALL TRANSACTION 'SESSION_MANAGER'. " GO TO SAP EASY ACCESS MENU
      "LEAVE PROGRAM. " RETURN TO LOCATION FROM WHERE THE PROGRAM WAS CALLED
    WHEN 'CANCEL'.
      CALL SELECTION-SCREEN 1000.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form DISPLAY_LIST .
* List
  SKIP TO LINE 10.
  POSITION 40.
  WRITE input.
endform.                    " DISPLAY_LIST
