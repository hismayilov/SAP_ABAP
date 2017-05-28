*&---------------------------------------------------------------------*
*&      Form  USEREXIT_CHECK_VBAP
*&---------------------------------------------------------------------*
*                                                                     *
*       This Userexit can be used to add addtional logic for          *
*       checking the position for completeness and consistency.       *
*                                                                     *
*       US_DIALOG  -  Indicator, that can be used to suppress         *
*                     dialogs in certain routines, e.g. in            *
*                     copy mode.                                      *
*                                                                     *
*       This form is called from form VBAP_PRUEFEN_ENDE.              *
*                                                                     *
*---------------------------------------------------------------------*
FORM USEREXIT_CHECK_VBAP USING US_DIALOG.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1 ) Form USEREXIT_CHECK_VBAP, Start                                                                                                              D
*$*$-Start: (1 )--------------------------------------------------------------------------------$*$*
ENHANCEMENT 317  ZSOL_TRADEX_SOW_PO_QTY_CHECK.    "active version
* ------------  Implemetations for Tradex project  --------- *
* Added by SaurabhK on 08.03.2017
* ---- For SOW qnty change restrict after PO creation ---- *
  DATA : v_menge     TYPE ekkn-menge,
         sow_qty(30) TYPE c,
         po_qty(30)  TYPE c.
  DATA : msg TYPE string.
  IF sy-tcode = 'VA42' and xvbak-auart = 'YSOW'.
    IF xvbap IS NOT INITIAL.
      SELECT SINGLE MAX( menge )
        FROM ekkn
        INTO v_menge
        WHERE vbeln = xvbap-vbeln
        GROUP BY vbeln.
      IF sy-subrc = 0.
        MOVE xvbap-kwmeng to sow_qty.
        SHIFT sow_qty LEFT DELETING LEADING space.
        MOVE v_menge to po_qty.
        SHIFT po_qty LEFT DELETING LEADING space.
        IF xvbap-kwmeng < v_menge.
          CLEAR msg.
          CONCATENATE xvbap-vbeln xvbap-posnr 'quantity' sow_qty
          'is less than PO quantity' po_qty INTO msg SEPARATED BY space.
          MESSAGE msg TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDENHANCEMENT.
*$*$-End:   (1 )--------------------------------------------------------------------------------$*$*


ENDFORM.
*eject
