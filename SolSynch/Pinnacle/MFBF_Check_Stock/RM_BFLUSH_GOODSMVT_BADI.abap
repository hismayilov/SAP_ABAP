Global attribute in class:
GT_IMSEG	Instance Attribute	Private	Type	TY_T_BADI_IMSEG	Table Type for Goods Movements BAdI REM

METHOD IF_EX_RM_BFLUSH_GOODSMVT~MODIFY_GOODSMVT_BEFORE_DIALOG

REFRESH: gt_imseg[].
t_imseg[] = ch_imseg[].

ENDMETHOD.

METHOD if_ex_rm_bflush_goodsmvt~modify_goodsmvt_after_dialog.
* ---- Check if sufficient stock available for BOM Materials---- *
    DATA: ls_imseg    LIKE LINE OF gt_imseg,
          ls_mard     TYPE mard,
          msg         TYPE string,
          avalqty(20) TYPE c,
          reqqty(20)  TYPE c.

    LOOP AT gt_imseg INTO ls_imseg.
      SELECT SINGLE *
        FROM mard
        INTO ls_mard
        WHERE matnr = ls_imseg-matnr
        AND   werks = ls_imseg-werks
        AND   lgort = ls_imseg-lgort.

      IF ls_imseg-erfmg GT ls_mard-labst.
        MOVE ls_mard-labst   TO avalqty.
        MOVE ls_imseg-erfmg   TO reqqty.
        SHIFT avalqty LEFT DELETING LEADING space.
        SHIFT reqqty  LEFT DELETING LEADING space.
        CONCATENATE 'BOM material' ls_imseg-matnr '| Available stock' avalqty  '| Required stock' reqqty
        INTO msg SEPARATED BY space.

        MESSAGE msg TYPE 'E'.
      ENDIF.

      CLEAR: ls_imseg, ls_mard, avalqty, reqqty.
    ENDLOOP.
  ENDMETHOD.
