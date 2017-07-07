FORM set_form.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Form SET_FORM, Start                                                                                                                              A
*$*$-Start: (1)---------------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZFI_HSNCODE_DEFAULT_GET.    "active version
IF ( sy-tabix = 12 OR tab_fskb-hkont IS NOT INITIAL )
AND ( sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65' OR sy-tcode EQ 'FB70' OR sy-tcode EQ 'FB75' ).
  FIELD-SYMBOLS: <gstpart> TYPE invfo-gst_part,
                 <budat>   TYPE invfo-budat.
  DATA: gstpart TYPE invfo-gst_part,
        budat   TYPE invfo-budat,
        it_hac  TYPE TABLE OF zgst_vsac,
        wa_hac  TYPE zgst_vsac,
        lv_count TYPE i.

  UNASSIGN: <budat>, <gstpart>.
  IF sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65'.
    ASSIGN ('(SAPLJ_1IG_VENDOR_SUBSCR)INVFO-BUDAT') TO <budat> .
    ASSIGN ('(SAPLJ_1IG_VENDOR_SUBSCR)INVFO-GST_PART') TO <gstpart> .
  ELSEIF sy-tcode EQ 'FB70' OR sy-tcode EQ 'FB75'.
    ASSIGN ('(SAPLJ_1IG_CUSTOMER_SUBSCR)INVFO-BUDAT') TO <budat> .
    ASSIGN ('(SAPLJ_1IG_CUSTOMER_SUBSCR)INVFO-GST_PART') TO <gstpart> .
  ENDIF.

  CLEAR: gstpart, budat.
  REFRESH: it_hac[].
  IF <gstpart> IS ASSIGNED AND <budat> IS ASSIGNED.
      budat   = <budat>.
      gstpart = <gstpart>.
    IF gstpart IS NOT INITIAL AND budat GT '20170630'.
      SELECT *
        FROM zgst_vsac
        INTO TABLE it_hac
        WHERE lifnr = gstpart.

      IF sy-subrc = 0 AND it_hac[] IS NOT INITIAL.
        CLEAR lv_count.
        DESCRIBE TABLE it_hac LINES lv_count.
        IF lv_count = 1.
          CLEAR wa_hac.
          READ TABLE it_hac INTO wa_hac INDEX 1.
          IF sy-subrc = 0 AND wa_hac-hsn_sac IS NOT INITIAL.
            tab_fskb-hsn_sac = wa_hac-hsn_sac.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
ENDENHANCEMENT.
*$*$-End:   (1)---------------------------------------------------------------------------------$*$*
