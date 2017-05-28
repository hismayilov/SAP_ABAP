FORM userexit_save_document.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1 ) Form USEREXIT_SAVE_DOCUMENT, Start                                                                                                           D
*$*$-Start: (1 )--------------------------------------------------------------------------------$*$*
ENHANCEMENT 315  ZCHARDATA_SAVE.    "active version

data: wa_update TYPE ztb_trd_specs,
      wa_final  TYPE ztb_trd_specs,
      it_final  TYPE STANDARD TABLE OF ztb_trd_specs,
      wa_head   TYPE ztb_specs_head.

IMPORT it_final FROM MEMORY ID 'FINAL'.
IMPORT wa_head  FROM MEMORY ID 'HEAD'.

IF sy-tcode = 'VA41'.
  IF it_final IS NOT INITIAL.
  LOOP AT it_final INTO wa_final.
    MOVE-CORRESPONDING wa_final to wa_update.
    wa_update-vbeln = vbak-vbeln.
    INSERT INTO ztb_trd_specs VALUES wa_update.
  ENDLOOP.
  ENDIF.

  IF wa_head IS NOT INITIAL.
    wa_head-vbeln = vbak-vbeln.
    INSERT INTO ztb_specs_head VALUES wa_head.
  ENDIF.
ENDIF.

IF sy-tcode = 'VA42'.
  IF it_final is not initial.
  LOOP AT it_final INTO wa_final.
    MOVE-CORRESPONDING wa_final TO wa_update.
    wa_update-vbeln = vbak-vbeln.
    "MODIFY ztb_trd_specs FROM wa_update.
    UPDATE ztb_trd_specs SET    specs    = wa_update-specs
                                low_lim  = wa_update-low_lim
                                up_lim   = wa_update-up_lim
                                dect     = wa_update-dect
                         WHERE  vbeln    = wa_update-vbeln
                         AND    atnam    = wa_update-atnam
                         AND    matnr    = wa_update-matnr
                         AND    posnr    = wa_update-posnr.
  ENDLOOP.
  ENDIF.

  IF wa_head IS NOT INITIAL.
    wa_head-vbeln = vbak-vbeln.
    UPDATE ztb_specs_head FROM wa_head.
  ENDIF.
ENDIF.

ENDENHANCEMENT.
*$*$-End:   (1 )--------------------------------------------------------------------------------$*$*

* Example:
* CALL FUNCTION 'ZZ_EXAMPLE'
*      IN UPDATE TASK
*      EXPORTING
*           ZZTAB = ZZTAB.

ENDFORM.                    "USEREXIT_SAVE_DOCUMENT
*eject
*---------------------------------------------------------------------*
*       FORM USEREXIT_SAVE_DOCUMENT_PREPARE                           *
*---------------------------------------------------------------------*
*       This userexit can be used for changes or checks, before a     *
*       document is saved.                                            *
*                                                                     *
*       If field T180-TRTYP contents 'H', the document will be        *
*       created, else it will be changed.                             *
*                                                                     *
*       This form is called at the beginning of form BELEG_SICHERN    *
*                                                                     *
*---------------------------------------------------------------------*
FORM userexit_save_document_prepare.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(2 ) Form USEREXIT_SAVE_DOCUMENT_PREPARE, Start                                                                                                   D
*$*$-Start: (2 )--------------------------------------------------------------------------------$*$*
ENHANCEMENT 316  ZSOL_TRADEX_ADDB_HEAD_CLUSTER.    "active version
* ------------  Implemetations for Tradex project  --------- *
* ---- For Add. tab B Head checks ---- *
* Added by SaurabhK on 17.01.2017
  DATA: gv_clstflg(1) TYPE c,
        gv_pcflg(1)   TYPE c,
        gv_visit(1)   TYPE c.

  IF sy-tcode = 'VA41' OR sy-tcode = 'VA42'.
    IMPORT gv_clstflg FROM MEMORY ID 'CLFLG'.
    IMPORT gv_pcflg   FROM MEMORY ID 'PCFLG'.
    IMPORT gv_visit   FROM MEMORY ID 'VSTFLG'.

* ------ Do not allow cluster total to be not equal to 100 ------ *
    IF gv_clstflg EQ 'X'.
      MESSAGE 'Cluster total is not equal to 100 in Header - Additional Tab B' TYPE 'E'.
    ENDIF.

* ------ Procurement charges selection Y/N is mandatory ------ *
    IF gv_pcflg EQ 'X'.
      MESSAGE 'No selection for procurement charges in Header - Additional Tab B' TYPE 'E'.
    ENDIF.

  ENDIF.

  IF sy-tcode = 'VA41'.
* ------ Procurement charges selection Y/N is mandatory ------ *
    IF gv_visit NE 'X'.
      MESSAGE 'No selection for procurement charges in Header - Additional Tab B' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDENHANCEMENT.
*$*$-End:   (2 )--------------------------------------------------------------------------------$*$*


ENDFORM.                    "USEREXIT_SAVE_DOCUMENT_PREPARE
*eject
