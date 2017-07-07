*----------------------------------------------------------------------*
***INCLUDE LFSKBI06.
*----------------------------------------------------------------------*

*{   INSERT         IRPK900489                                        1
*&---------------------------------------------------------------------*
*&      Module  F4_HSN_SAC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_hsn_sac INPUT.
IF ( sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65' OR sy-tcode EQ 'FB70' OR sy-tcode EQ 'FB75' ).
  TYPES: BEGIN OF ty_hsnhlp,
           lifnr    TYPE zgst_vsac-lifnr,
           hsn_sac  TYPE zgst_vsac-hsn_sac,
           vtext    TYPE zhsn_sac-vtext,
         END OF ty_hsnhlp.

  DATA: it_vsac TYPE TABLE OF zgst_vsac,
        wa_vsac TYPE zgst_vsac,

        it_sac TYPE TABLE OF zhsn_sac,
        wa_sac TYPE zhsn_sac,

        it_hsnhlp TYPE TABLE OF ty_hsnhlp,
        wa_hsnhlp TYPE ty_hsnhlp,

        it_shret TYPE TABLE OF ddshretval,
        wa_shret TYPE ddshretval.

  DATA: gstpart TYPE invfo-gst_part,
        budat   TYPE invfo-budat,
        title(100) TYPE c.

  FIELD-SYMBOLS: <gstpart> TYPE invfo-gst_part,
                 <budat>   TYPE invfo-budat.

  CLEAR: gstpart, budat.
  REFRESH: it_vsac, it_sac, it_hsnhlp, it_shret.

  UNASSIGN: <budat>, <gstpart>.
  IF sy-tcode EQ 'FB60' OR sy-tcode EQ 'FB65'.
    ASSIGN ('(SAPLJ_1IG_VENDOR_SUBSCR)INVFO-BUDAT') TO <budat> .
    ASSIGN ('(SAPLJ_1IG_VENDOR_SUBSCR)INVFO-GST_PART') TO <gstpart> .
  ELSEIF sy-tcode EQ 'FB70' OR sy-tcode EQ 'FB75'.
    ASSIGN ('(SAPLJ_1IG_CUSTOMER_SUBSCR)INVFO-BUDAT') TO <budat> .
    ASSIGN ('(SAPLJ_1IG_CUSTOMER_SUBSCR)INVFO-GST_PART') TO <gstpart> .
  ENDIF.

  IF <gstpart> IS ASSIGNED AND <budat> IS ASSIGNED.
      budat   = <budat>.
      gstpart = <gstpart>.
    IF gstpart IS NOT INITIAL AND budat GT '20170630'.
      SELECT *
        FROM zgst_vsac
        INTO TABLE it_vsac
        WHERE lifnr = gstpart.

      IF sy-subrc = 0 AND it_vsac IS NOT INITIAL.
        SELECT *
          FROM zhsn_sac
          INTO TABLE it_sac
          FOR ALL ENTRIES IN it_vsac
          WHERE hsn_sac = it_vsac-hsn_sac.
      ENDIF.

      IF it_vsac[] IS NOT INITIAL AND it_sac[] IS NOT INITIAL.
        LOOP AT it_vsac INTO wa_vsac.
          wa_hsnhlp-lifnr   = wa_vsac-lifnr.
          wa_hsnhlp-hsn_sac = wa_vsac-hsn_sac.
          READ TABLE it_sac INTO wa_sac WITH KEY hsn_sac = wa_vsac-hsn_sac.
          IF sy-subrc = 0.
            wa_hsnhlp-vtext = wa_sac-vtext.
          ENDIF.

          APPEND wa_hsnhlp TO it_hsnhlp.
          CLEAR: wa_hsnhlp, wa_vsac, wa_sac.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  IF it_hsnhlp[] IS NOT INITIAL.
    CLEAR title.
    title = 'Value for HSN_SAC'.

    REFRESH: it_shret[].
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'HSN_SAC'
        dynpprog        = sy-repid
        dynpnr          = sy-dynnr
        dynprofield     = 'ACGL_ITEM-HSN_SAC'
        window_title    = title
        value_org       = 'S'
*       DISPLAY         = ' '
      TABLES
        value_tab       = it_hsnhlp
        return_tab      = it_shret
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
*  Implement suitable error handling here
    ENDIF.
  ELSE.
    MESSAGE 'No values found.' TYPE 'S'.
  ENDIF.
ENDIF.
ENDMODULE.
*}   INSERT
