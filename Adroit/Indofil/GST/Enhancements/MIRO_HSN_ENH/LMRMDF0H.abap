.....
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Form T_DRSEG_AUFBAUEN_PRUEFEN_1, End                                                                                                              A
*$*$-Start: (1)---------------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZMM_HSNCODE_MIRO.    "active version
IF sy-tcode EQ 'MIRO'.  " Code on tcode? Do we need post. date as well?
  DATA: w_drseg   LIKE LINE OF t_drseg,
        it_poview TYPE TABLE OF wb2_v_ekko_ekpo2,
        wa_poview LIKE LINE OF it_poview,
        subpackno TYPE esll-sub_packno,
        it_esll   TYPE TABLE OF esll,
        wa_esll   TYPE esll,
        msg       TYPE string,
        budat     TYPE rbkp-budat.

  FIELD-SYMBOLS: <budat> TYPE rbkp-budat.

  CLEAR: budat.

  UNASSIGN: <budat>.
  ASSIGN ('(SAPLMR1M)RBKPV-BUDAT') TO <budat> .

  IF <budat> IS ASSIGNED.
    budat   = <budat>.
    IF budat GT '20170630'.
      REFRESH: it_poview[].
      IF t_drseg[] IS NOT INITIAL.
        SELECT *
          FROM wb2_v_ekko_ekpo2
          INTO TABLE it_poview
          FOR ALL ENTRIES IN t_drseg[]
          WHERE ebeln_i = t_drseg-ebeln
          AND   ebelp_i = t_drseg-ebelp.

        LOOP AT t_drseg INTO w_drseg.
          IF w_drseg-ebeln IS NOT INITIAL AND w_drseg-matnr IS INITIAL
            AND w_drseg-txz01 IS NOT INITIAL AND w_drseg-srvpos IS INITIAL AND w_drseg-hsn_sac IS INITIAL.
            READ TABLE it_poview INTO wa_poview WITH KEY ebeln_i = w_drseg-ebeln ebelp_i = w_drseg-ebelp.
            IF sy-subrc = 0.
              IF ( wa_poview-bsart EQ 'IBDO' OR wa_poview-bsart EQ 'IBSD' OR wa_poview-bsart EQ 'IBSI' OR wa_poview-bsart EQ 'IBDO' OR
                wa_poview-bsart EQ 'YSED' OR wa_poview-bsart EQ 'YSEI' OR wa_poview-bsart EQ 'ZSED' OR wa_poview-bsart EQ 'ZSEI' )
                AND w_drseg-knttp EQ 'K'. " => This is a service PO, txz01 is description of service
                SELECT SINGLE sub_packno
                  FROM esll
                  INTO subpackno
                  WHERE packno EQ wa_poview-packno_i.

                IF subpackno IS NOT INITIAL.
                  SELECT *
                    FROM esll
                    INTO TABLE it_esll
                    WHERE packno = subpackno.

                  IF it_esll[] IS NOT INITIAL.
                    READ TABLE it_esll INTO wa_esll WITH KEY ktext1 = w_drseg-txz01.
                    IF sy-subrc = 0.
                      w_drseg-hsn_sac = wa_esll-taxtariffcode. " Please make control code/tax tariff code mandatory in PO
                    ENDIF.
                  ENDIF.
                ENDIF.
              ELSE. " => This is a material PO, txz01 is description of material
                w_drseg-hsn_sac = wa_poview-j_1bnbm_i.
              ENDIF.
            ENDIF.
          ENDIF.
          MODIFY t_drseg FROM w_drseg TRANSPORTING hsn_sac.
          REFRESH: it_esll[].
          CLEAR: w_drseg, wa_poview, wa_esll, subpackno.
        ENDLOOP.
      ENDIF.

      IF sy-ucomm EQ 'PB' OR sy-ucomm EQ 'BU'.
        IF t_drseg[] IS NOT INITIAL.
          LOOP AT t_drseg INTO w_drseg WHERE ebeln IS NOT INITIAL AND hsn_sac IS INITIAL.
            CLEAR msg.
            CONCATENATE w_drseg-ebeln w_drseg-ebelp ': HSN/SAC Code is mandatory' INTO msg SEPARATED BY space.
            SET CURSOR FIELD 'DRSEG-HSN_SAC' LINE sy-stepl.
            MESSAGE msg TYPE 'E'.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
ENDENHANCEMENT.
*$*$-End:   (1)---------------------------------------------------------------------------------$*$*
ENDFORM.                    "t_drseg_aufbauen_pruefen_1
