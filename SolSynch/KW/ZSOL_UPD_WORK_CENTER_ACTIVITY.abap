REPORT sy-repid.

TYPES: BEGIN OF ty_crco,
        objty TYPE crco-objty,
        objid TYPE crco-objid,
        laset TYPE crco-laset,
        endda TYPE char10,
        lanum TYPE crco-lanum,
        begda TYPE char10,
        aedat_kost TYPE char10,
        aenam_kost TYPE crco-aenam_kost,
        kokrs TYPE crco-kokrs,
        kostl TYPE crco-kostl,
        lstar TYPE crco-lstar,
        lstar_ref TYPE crco-lstar_ref,
        forml TYPE crco-forml,
        prz TYPE crco-prz,
        actxy TYPE crco-actxy,
        actxk TYPE crco-actxk,
        leinh TYPE crco-leinh,
        bde TYPE crco-bde,
        sakl TYPE crco-sakl,
      END OF ty_crco,


      BEGIN OF ty_crhd_prd,
        objty TYPE crhd-objty,
        objid TYPE crhd-objid,
        begda TYPE char10,
        endda TYPE char10,
        aedat_grnd TYPE char10,
        aenam_grnd TYPE crhd-aenam_grnd,
        aedat_vora TYPE char10,
        aenam_vora TYPE crhd-aenam_vora,
        aedat_term TYPE char10,
        aenam_term TYPE crhd-aenam_term,
        aedat_tech TYPE char10,
        aenam_tech TYPE crhd-aenam_tech,
        arbpl TYPE crhd-arbpl,
        werks TYPE crhd-werks,
        verwe TYPE crhd-verwe,
        lvorm TYPE crhd-lvorm,
        par01 TYPE crhd-par01,
        par02 TYPE crhd-par02,
        par03 TYPE crhd-par03,
        par04 TYPE crhd-par04,
        par05 TYPE crhd-par05,
        par06 TYPE crhd-par06,
        paru1 TYPE crhd-paru1,
        paru2 TYPE crhd-paru2,
        paru3 TYPE crhd-paru3,
        paru4 TYPE crhd-paru4,
        paru5 TYPE crhd-paru5,
        paru6 TYPE crhd-paru6,
        parv1 TYPE crhd-parv1,
        parv2 TYPE crhd-parv2,
        parv3 TYPE crhd-parv3,
        parv4 TYPE crhd-parv4,
        parv5 TYPE crhd-parv5,
        parv6 TYPE crhd-parv6,
        planv TYPE crhd-planv,
        stand TYPE crhd-stand,
        veran TYPE crhd-veran,
        vgwts TYPE crhd-vgwts,
        vgm01 TYPE crhd-vgm01,
        vgm02 TYPE crhd-vgm02,
        vgm03 TYPE crhd-vgm03,
        vgm04 TYPE crhd-vgm04,
        vgm05 TYPE crhd-vgm05,
        vgm06 TYPE crhd-vgm06,
        xdefa TYPE crhd-xdefa,
        xkost TYPE crhd-xkost,
        xsprr TYPE crhd-xsprr,
        xterm TYPE crhd-xterm,
        zgr01 TYPE crhd-zgr01,
        zgr02 TYPE crhd-zgr02,
        zgr03 TYPE crhd-zgr03,
        zgr04 TYPE crhd-zgr04,
        zgr05 TYPE crhd-zgr05,
        zgr06 TYPE crhd-zgr06,
        ktsch TYPE crhd-ktsch,
        loanz TYPE crhd-loanz,
        loart TYPE crhd-loart,
        logrp TYPE crhd-logrp,
        qualf TYPE crhd-qualf,
        rasch TYPE crhd-rasch,
        steus TYPE crhd-steus,
        vge01 TYPE crhd-vge01,
        vge02 TYPE crhd-vge02,
        vge03 TYPE crhd-vge03,
        vge04 TYPE crhd-vge04,
        vge05 TYPE crhd-vge05,
        vge06 TYPE crhd-vge06,
        ktsch_ref TYPE crhd-ktsch_ref,
        loart_ref TYPE crhd-loart_ref,
        loanz_ref TYPE crhd-loanz_ref,
        logrp_ref TYPE crhd-logrp_ref,
        qualf_ref TYPE crhd-qualf_ref,
        rasch_ref TYPE crhd-rasch_ref,
        steus_ref TYPE crhd-steus_ref,
        fort1 TYPE crhd-fort1,
        fort2 TYPE crhd-fort2,
        fort3 TYPE crhd-fort3,
        kapid TYPE crhd-kapid,
        ortgr TYPE crhd-ortgr,
        zeiwn TYPE crhd-zeiwn,
        zwnor TYPE crhd-zwnor,
        zeiwm TYPE crhd-zeiwm,
        zwmin TYPE crhd-zwmin,
        formr TYPE crhd-formr,
        matyp TYPE crhd-matyp,
        cplgr TYPE crhd-cplgr,
        sortb TYPE crhd-sortb,
        mtrvp TYPE crhd-mtrvp,
        mtmvp TYPE crhd-mtmvp,
        mtpvp TYPE crhd-mtpvp,
        rsanz TYPE crhd-rsanz,
        pdest TYPE crhd-pdest,
        hroid TYPE crhd-hroid,
        fortn TYPE crhd-fortn,
        zgr01_ref TYPE crhd-zgr01_ref,
        zgr02_ref TYPE crhd-zgr02_ref,
        zgr03_ref TYPE crhd-zgr03_ref,
        zgr04_ref TYPE crhd-zgr04_ref,
        zgr05_ref TYPE crhd-zgr05_ref,
        zgr06_ref TYPE crhd-zgr06_ref,
        steus_c TYPE crhd-steus_c,
        steus_i TYPE crhd-steus_i,
        steus_n TYPE crhd-steus_n,
        steus_q TYPE crhd-steus_q,
        ruzus TYPE crhd-ruzus,
        rsanz_ref TYPE crhd-rsanz_ref,
        hr TYPE crhd-hr,
        prvbe TYPE crhd-prvbe,
        subsys TYPE crhd-subsys,
        bdegr TYPE crhd-bdegr,
        rgekz TYPE crhd-rgekz,
        hrtyp TYPE crhd-hrtyp,
        slwid TYPE crhd-slwid,
        lifnr TYPE crhd-lifnr,
        slwid_ref TYPE crhd-slwid_ref,
        lifnr_ref TYPE crhd-lifnr_ref,
        vgarb TYPE crhd-vgarb,
        vgdim TYPE crhd-vgdim,
        hrplvar TYPE crhd-hrplvar,
        vgdau TYPE crhd-vgdau,
        stobj TYPE crhd-stobj,
        resgr TYPE crhd-resgr,
        lgort_res TYPE crhd-lgort_res,
        mixmat TYPE crhd-mixmat,
        istbed_kz TYPE crhd-istbed_kz,
        srtype TYPE crhd-srtype,
        sntype TYPE crhd-sntype,
      END OF ty_crhd_prd.

DATA: it_raw TYPE truxs_t_text_data.

DATA: it_crco TYPE TABLE OF ty_crco,
      wa_crco TYPE ty_crco,

      it_crhd_prd TYPE TABLE OF ty_crhd_prd,
      wa_crhd_prd TYPE ty_crhd_prd,

      it_crhd TYPE TABLE OF crhd,
      wa_crhd TYPE crhd.

PARAMETERS: f_crco TYPE rlgrap-filename OBLIGATORY,
            f_crhd TYPE rlgrap-filename OBLIGATORY.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR f_crco.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = ' '
    IMPORTING
      file_name     = f_crco.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR f_crhd.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = ' '
    IMPORTING
      file_name     = f_crhd.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

START-OF-SELECTION.

  IF f_crco IS NOT INITIAL.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = 'X'
        i_line_header        = 'X'
        i_tab_raw_data       = it_raw
        i_filename           = f_crco
      TABLES
        i_tab_converted_data = it_crco
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ENDIF.

  IF f_crhd IS NOT INITIAL.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = 'X'
        i_line_header        = 'X'
        i_tab_raw_data       = it_raw
        i_filename           = f_crhd
      TABLES
        i_tab_converted_data = it_crhd_prd
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ENDIF.

  IF it_crco[] IS NOT INITIAL AND it_crhd_prd[] IS NOT INITIAL.
    SELECT *
      FROM crhd
      INTO TABLE it_crhd
      WHERE objty = 'A'.

    IF sy-subrc = 0.
      LOOP AT it_crhd_prd INTO wa_crhd_prd.
        READ TABLE it_crhd INTO wa_crhd WITH KEY arbpl = wa_crhd_prd-arbpl.
        IF sy-subrc = 0.
          LOOP AT it_crco INTO wa_crco WHERE objty = wa_crhd_prd-objty
                                       AND   objid = wa_crhd_prd-objid.
            wa_crco-objty = wa_crhd-objty.
            wa_crco-objid = wa_crhd-objid.
            MODIFY crco FROM wa_crco.
            CLEAR wa_crco.
          ENDLOOP.
        ENDIF.
        CLEAR: wa_crhd, wa_crhd_prd.
      ENDLOOP.
    ENDIF.
  ENDIF.

  COMMIT WORK.
  IF sy-subrc = 0.
    MESSAGE 'Work Center Activities Updated Successfully.' TYPE 'I'.
  ENDIF.
