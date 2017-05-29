Include ZSOL_CR_BLOCK.

*&---------------------------------------------------------------------*
*&  Include           ZSOL_CR_BLOCK
*&---------------------------------------------------------------------*
 IF xvbak-auart NE 'ZCCM' OR xvbak-auart NE 'ZCCR' OR xvbak-auart NE 'ZCDM' OR xvbak-auart NE 'ZCEM' OR xvbak-auart NE 'ZCIM' OR xvbak-auart NE 'ZDCR' OR
     xvbak-auart NE 'ZDDE' OR xvbak-auart NE 'ZDIM' OR xvbak-auart NE 'ZEDM' OR xvbak-auart NE 'ZEER' OR xvbak-auart NE 'ZPF1' OR xvbak-auart NE 'ZTCR' OR
     xvbak-auart NE 'ZWCM' OR xvbak-auart NE 'ZWCR' OR xvbak-auart NE 'ZWDM'.
*
   DATA: oldest_item_date TYPE rfpos-faedt,
         open_rcvbl       TYPE knkk-skfor,
         credit_limit     TYPE knkk-klimk,
         overdue_days     TYPE rfpos-verzn.

   CALL FUNCTION 'CREDIT_EXPOSURE'
     EXPORTING
       kkber       = '1000'
       kunnr       = vbak-kunnr
*      DATE_CREDIT_EXPOSURE       = '99991231'
     IMPORTING
       creditlimit = credit_limit
       open_items  = open_rcvbl.

   CALL FUNCTION 'CUSTOMER_OLDEST_OPEN_ITEM'
     EXPORTING
       i_kkber = '1000'
       i_kunnr = vbak-kunnr
     IMPORTING
       e_faedt = oldest_item_date
       e_verzn = overdue_days.
   "till here.

   DATA: v_faksp   TYPE vbap-faksp.
   DATA: v_seq     TYPE zsol_billblock-sqnce,
         wa_update TYPE zsol_billblock.

   IF open_rcvbl > credit_limit OR
     ( open_rcvbl > 2000 AND overdue_days > 30 ).

     LOOP AT xvbap.
       IF xvbap-vbeln IS NOT INITIAL.

         SELECT SINGLE MAX( sqnce )
           FROM zsol_billblock
           INTO v_seq.

         CLEAR wa_vbap.

         SELECT SINGLE *
           FROM vbap
           INTO wa_vbap
           WHERE vbeln = xvbap-vbeln
           AND   posnr = xvbap-posnr.

         IF sy-subrc = 0.
           IF xvbap-faksp NE wa_vbap-faksp.
             IF ( xvbap-faksp IS INITIAL AND wa_vbap-faksp EQ 'ZC' )
             OR ( wa_vbap-faksp IS INITIAL AND xvbap-faksp EQ 'ZC' ).
               ADD 1 TO v_seq.
               wa_update-sqnce  = v_seq.
               wa_update-vbeln  = xvbap-vbeln.
               wa_update-posnr  = xvbap-posnr.
               wa_update-faksp  = xvbap-faksp.
               wa_update-relby  = sy-uname.
               wa_update-reldat = sy-datum.
               wa_update-reltim = sy-uzeit.

*                INSERT INTO zsol_billblock VALUES wa_update.
               MODIFY zsol_billblock FROM wa_update.
             ENDIF.
           ENDIF.
         ENDIF.
         CLEAR: xvbap, yvbap, wa_update.

       ELSE ."IF sy-tcode = 'VA01'.
         MESSAGE 'Credit Limit exceeded-Items will be blocked for Billing' TYPE 'I'.
         xvbap-faksp = 'ZC'.
         MODIFY xvbap TRANSPORTING faksp.
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDIF.
