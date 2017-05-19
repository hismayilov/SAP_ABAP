*----------------------------------------------------------------------*
***INCLUDE LCOWBFO1 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OK_CODE_PROCESS
*&---------------------------------------------------------------------*
*       Abhandlung der Funktionscodes
*----------------------------------------------------------------------*
FORM ok_code_process USING p_ok_code LIKE sy-xcode.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Form OK_CODE_PROCESS, Start                                                                                                                       A
*$*$-Start: (1)---------------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZSOL_CHECK_STOCK_MFBF.    "active version
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(2) Form OK_CODE_PROCESS, Start, Enhancement ZSOL_CHECK_STOCK_MFBF, Start                                                                             A
IF p_ok_code EQ fc_weit AND sy-tcode EQ 'MFBF'.
* ---- Check if sufficient stock available for BOM Materials---- *
    DATA: gs_comp     LIKE LINE OF gt_comp,
          wmdvsx      TYPE TABLE OF bapiwmdvs,
          wmdvex      TYPE TABLE OF bapiwmdve,
          endleadtme  TYPE bapicm61m-wzter,
          av_qty_plt  TYPE bapicm61v-wkbst,
          return      TYPE bapireturn,
          plant       TYPE bapimatvp-werks,
          material    TYPE bapimatvp-matnr,
          unit        TYPE bapiadmm-unit,
          stge_loc    TYPE bapicm61v-lgort,
          msg         TYPE string,
          avalqty(20) TYPE c,
          reqqty(20)  TYPE c.

    LOOP AT gt_comp INTO gs_comp.
      plant    = gs_comp-werks.
      material = gs_comp-matnr.
      unit     = gs_comp-erfme.
      stge_loc = gs_comp-lgort.

      CALL FUNCTION 'BAPI_MATERIAL_AVAILABILITY'
        EXPORTING
          plant      = plant
          material   = material
          unit       = unit
          stge_loc   = stge_loc
        IMPORTING
          endleadtme = endleadtme
          av_qty_plt = av_qty_plt
          return     = return
        TABLES
          wmdvsx     = wmdvsx
          wmdvex     = wmdvex.

      IF gs_comp-erfmg GT av_qty_plt.
        MOVE av_qty_plt      TO avalqty.
        MOVE gs_comp-erfmg   TO reqqty.
        SHIFT avalqty LEFT DELETING LEADING space.
        SHIFT reqqty  LEFT DELETING LEADING space.
        CONCATENATE 'BOM material' material '| Available stock' avalqty  '| Required stock' reqqty
        INTO msg SEPARATED BY space.

        MESSAGE msg TYPE 'E'.
      ENDIF.

      CLEAR: gs_comp, plant, material, unit, stge_loc, endleadtme, av_qty_plt, return.
      REFRESH: wmdvsx[], wmdvex[].
    ENDLOOP.
ENDIF.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(3) Form OK_CODE_PROCESS, Start, Enhancement ZSOL_CHECK_STOCK_MFBF, End                                                                               A
ENDENHANCEMENT.
*$*$-End:   (1)---------------------------------------------------------------------------------$*$*

*... Tabelle der Warenbewegung ...
 ... 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(27) Include LCOWBFO1, End                                                                                                                            S
