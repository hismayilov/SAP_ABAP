*&---------------------------------------------------------------------*
*&  Include           ZTEST_VLMOVE_BAPI_SS
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE title.

PARAMETERS: p_werks TYPE marc-werks OBLIGATORY,     " plant
            p_lgort TYPE mard-lgort OBLIGATORY.     " stgloc

SELECT-OPTIONS: s_exidv FOR vekp-exidv OBLIGATORY.  " hand. unit

SELECTION-SCREEN END OF BLOCK b1.
