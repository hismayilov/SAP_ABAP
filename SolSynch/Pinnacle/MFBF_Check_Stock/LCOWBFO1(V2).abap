FORM ok_code_process USING p_ok_code LIKE sy-xcode.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Form OK_CODE_PROCESS, Start                                                                                                                       A
*$*$-Start: (1)---------------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZSOL_CHECK_STOCK_MFBF.    "active version
IF ( ( p_ok_code EQ fc_weit ) OR ( sy-dynnr EQ '0130' AND p_ok_code EQ 'BACK' ) ) AND sy-tcode EQ 'MFBF' .
* ---- Check if sufficient stock available for BOM Materials---- *
    DATA: gs_comp     LIKE LINE OF gt_comp,
          ls_mard     TYPE mard,
          msg         TYPE string,
          avalqty(20) TYPE c,
          reqqty(20)  TYPE c.

    LOOP AT gt_comp INTO gs_comp.
      SELECT SINGLE *
        FROM mard
        INTO ls_mard
        WHERE matnr = gs_comp-matnr
        AND   werks = gs_comp-werks
        AND   lgort = gs_comp-lgort.

      IF gs_comp-erfmg GT ls_mard-labst.
        MOVE ls_mard-labst   TO avalqty.
        MOVE gs_comp-erfmg   TO reqqty.
        SHIFT avalqty LEFT DELETING LEADING space.
        SHIFT reqqty  LEFT DELETING LEADING space.
        CONCATENATE 'BOM material' gs_comp-matnr '| Available stock' avalqty  '| Required stock' reqqty
        INTO msg SEPARATED BY space.

        MESSAGE msg TYPE 'E'.
      ENDIF.

      CLEAR: gs_comp, ls_mard, avalqty, reqqty.
    ENDLOOP.
ENDIF.
ENDENHANCEMENT.
*$*$-End:   (1)---------------------------------------------------------------------------------$*$*
