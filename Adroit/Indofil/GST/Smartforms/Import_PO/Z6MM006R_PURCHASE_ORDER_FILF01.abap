*----------------------------------------------------------------------*
***INCLUDE Z6MM006R_PURCHASE_ORDER_FILF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILL_CONTROL_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAST  text
*      -->P_IF_PREVIEW  text
*      <--P_FP_OUTPUTPARAMS  text
*----------------------------------------------------------------------*
FORM FILL_CONTROL_STRUCTURE  USING    P_NAST
                                      P_IF_PREVIEW
                             CHANGING P_FP_OUTPUTPARAMS.
* CLEAR: es_outparms.
*  IF if_preview IS INITIAL.
*    CLEAR: es_outparms-preview.
*  ELSE.
*    es_outparms-preview = 'X'.
*  ENDIF.
*  es_outparms-nodialog = 'X'.
*  es_outparms-dest = is_nast-ldest.
*  es_outparms-reqimm = is_nast-dimme.
*  es_outparms-reqdel = is_nast-delet.
*  es_outparms-copies = is_nast-anzal.
*  es_outparms-dataset = is_nast-dsnam.
*  es_outparms-suffix1 = is_nast-dsuf1.
*  es_outparms-suffix2 = is_nast-dsuf2.
*  es_outparms-covtitle = is_nast-tdcovtitle.
*  es_outparms-cover = is_nast-tdocover.
*  es_outparms-receiver = is_nast-tdreceiver.
*  es_outparms-division = is_nast-tddivision.
*  es_outparms-reqfinal = 'X'.
*  es_outparms-arcmode = is_nast-tdarmod.
*  es_outparms-schedule = is_nast-tdschedule.
*  es_outparms-senddate = is_nast-vsdat.
*  es_outparms-sendtime = is_nast-vsura.

ENDFORM.                    " FILL_CONTROL_STRUCTURE
