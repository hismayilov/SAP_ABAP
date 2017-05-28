METHOD if_ex_mb_document_badi~mb_document_before_update.

  IF sy-tcode = 'MIGO'.

    DATA: wa_mseg    TYPE mseg,
          wa_mkpf    TYPE mkpf.
    DATA: wa_update  TYPE ztb_trd_specs,
          it_update  TYPE TABLE OF ztb_trd_specs.

    SELECT *
           FROM ztb_trd_specs
           INTO TABLE it_update
           FOR ALL ENTRIES IN xmseg[]
           WHERE vbeln = xmseg-kdauf
           AND   posnr = xmseg-kdpos
           AND   matnr = xmseg-matnr.

    LOOP AT xmseg INTO wa_mseg.
      READ TABLE xmkpf INTO wa_mkpf INDEX 1.
      IF sy-subrc = 0.
        IF wa_mkpf-bktxt IS NOT INITIAL.
          TRANSLATE wa_mkpf-bktxt TO UPPER CASE.
          LOOP AT it_update INTO wa_update WHERE vbeln = wa_mseg-kdauf
                                           AND   posnr = wa_mseg-kdpos
                                           AND   matnr = wa_mseg-matnr.
            IF wa_update-lorry_no IS INITIAL.
              wa_update-charg = wa_mseg-charg.
              wa_update-lorry_no = wa_mkpf-bktxt.
              TRY.
                  UPDATE ztb_trd_specs
                  SET lorry_no = wa_update-lorry_no
                  charg = wa_update-charg
                  WHERE vbeln = wa_update-vbeln
                  AND   posnr = wa_update-posnr
                  AND   matnr = wa_update-matnr
                  AND   atnam = wa_update-atnam.
                CATCH cx_sy_dynamic_osql_error.
                  MESSAGE `Error in update!` TYPE 'I'.
              ENDTRY.
            ELSEIF wa_update-lorry_no IS NOT INITIAL.
              wa_update-charg = wa_mseg-charg.
              wa_update-lorry_no = wa_mkpf-bktxt.
              CLEAR: wa_update-act_dect.
              TRY.
                  INSERT into ztb_trd_specs values wa_update.
                CATCH cx_sy_dynamic_osql_error.
                  MESSAGE `Error in insert!` TYPE 'I'.
              ENDTRY.
            ENDIF.
            CLEAR wa_update.
          ENDLOOP.
        ENDIF.
      ENDIF.
      CLEAR wa_mseg.
    ENDLOOP.

  ENDIF.
ENDMETHOD.
