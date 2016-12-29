"......
SELECTION-SCREEN BEGIN OF BLOCK deliv WITH FRAME TITLE text-del.

PARAMETERS: p_vkorg       TYPE vbrk-vkorg OBLIGATORY DEFAULT '1000'.
SELECTION-SCREEN: COMMENT 45(20) text FOR FIELD p_vkorg.

*** Added for stp-listbox by SaurabhK
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) text-001 FOR FIELD ls_kunag.
PARAMETERS: ls_kunag TYPE vbrk-kunag AS LISTBOX VISIBLE LENGTH 15 OBLIGATORY USER-COMMAND stp DEFAULT '1'.
*PARAMETERS: p_kunag       TYPE vbrk-kunag OBLIGATORY DEFAULT 'PK00001'.
SELECTION-SCREEN: COMMENT 45(20) textn FOR FIELD ls_kunag.
SELECTION-SCREEN END OF LINE.
*** Till here

SELECT-OPTIONS: s_vbeln   FOR vbrk-vbeln,
                s_fkdat   FOR vbrk-fkdat OBLIGATORY DEFAULT sy-datum TO sy-datum,
                s_matnr   FOR vbrp-matnr.
SELECTION-SCREEN END OF BLOCK deliv.
"......
