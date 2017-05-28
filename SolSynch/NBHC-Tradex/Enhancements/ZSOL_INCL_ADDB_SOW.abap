*&---------------------------------------------------------------------*
*&  Include           ZSOL_INCL_ADDB_SOW
*&---------------------------------------------------------------------*
*&  Developed by SaurabhK/Prasad Gurjar
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Data Declarations
*&---------------------------------------------------------------------*
"------------------------------------------------------------
***** Additional Tab B - Header level - sapmv45a - 8309 *****
"------------------------------------------------------------
TYPE-POOLS: vrm.

DATA: agfrdat  TYPE sy-datum, " Screen fields
      agtodat  TYPE sy-datum,
      salfrdat TYPE sy-datum,
      saltodat TYPE sy-datum.

DATA: cl1     TYPE tvkbt-vkbur,
      cl2     TYPE tvkbt-vkbur,
      cldesc1 TYPE tvkbt-bezei,
      cldesc2 TYPE tvkbt-bezei.

DATA: clper1   TYPE p LENGTH 3 DECIMALS 2,
      clper2   TYPE p LENGTH 3 DECIMALS 2,
      clpertot TYPE p LENGTH 3 DECIMALS 2.

DATA: chqno(100)  TYPE c,
      inschrg(12) TYPE c,
      qcchrg(12)  TYPE c,
      rsqty(12)   TYPE c,
      pc_chrg(19) TYPE c,
      wh_chrg(12) TYPE c.

DATA: wa_head TYPE ztb_specs_head.

DATA: gv_clstflg(1) TYPE c,
      gv_pcflg(1)   TYPE c,
      gv_visit(1)   TYPE c.

DATA: pc_values TYPE vrm_values WITH HEADER LINE.
"----------------------------------------------------------
***** Additional Tab B - Item level - sapmv45a - 8459 *****
"----------------------------------------------------------
DATA: it_characteristics TYPE TABLE OF  bapi_char,
      wa_characteristics TYPE bapi_char,
      it_char_values     TYPE TABLE OF  bapi_char_values.

DATA: v_obj TYPE inob-objek,
      wa_inob TYPE inob,
      wa_klah TYPE klah,
      wa_kssk TYPE kssk,
      wa_ksml TYPE ksml.

DATA: wa_vbap TYPE vbap,
      it_final TYPE TABLE OF ztb_trd_specs,
      it_final_modify TYPE TABLE OF ztb_trd_specs,
      wa_final TYPE ztb_trd_specs,
      wa_final_modify TYPE ztb_trd_specs.

DATA: it_chardata TYPE STANDARD TABLE OF ztb_trd_specs,
      wa_chardata TYPE ztb_trd_specs.

*&---------------------------------------------------------------------*
*&  Modules
*&---------------------------------------------------------------------*

"------------------------------------------------------------
***** Additional Tab B - Header level - sapmv45a - 8309 *****
"------------------------------------------------------------
"---------------------
***** PBO Module *****
"---------------------
*&---------------------------------------------------------------------*
*&      Module  HEAD_PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE head_pbo OUTPUT.

  IF vbak-auart NE 'YSOW' OR ( sy-tcode <> 'VA41' AND sy-tcode <> 'VA42' AND sy-tcode <> 'VA43' ).
    LOOP AT SCREEN.
      IF screen-group1 = 'GRP'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF vbak-auart = 'YSOW'.

    REFRESH pc_values[].

    pc_values-key = '1'.
    pc_values-text = 'Yes'.
    APPEND pc_values.

    pc_values-key = '2'.
    pc_values-text = 'No'.
    APPEND pc_values.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'PC_CHRG'
        values          = pc_values[]
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF sy-tcode = 'VA42' OR sy-tcode = 'VA43'.
      IF wa_head IS INITIAL.
        SELECT SINGLE * FROM ztb_specs_head
          INTO wa_head
          WHERE vbeln = vbak-vbeln.

        IF wa_head IS NOT INITIAL.
          chqno    =   wa_head-chqno.
          agfrdat  =   wa_head-agfrdat.
          agtodat  =   wa_head-agtodat.
          salfrdat =   wa_head-salfrdat.
          saltodat =   wa_head-saltodat.
          cl1      =   wa_head-cl1.
          cl2      =   wa_head-cl2.
          clper1   =   wa_head-clper1.
          clper2   =   wa_head-clper2.
          inschrg  =   wa_head-inschrg.
          qcchrg   =   wa_head-qcchrg.
          rsqty    =   wa_head-rsqty.
          pc_chrg  =   wa_head-pc_chrg.
          wh_chrg  =   wa_head-wh_chrg.
        ENDIF.

        IF cl1 IS NOT INITIAL.
          SELECT SINGLE * FROM tvkbt WHERE spras = sy-langu
                                     AND   vkbur = cl1.
          cldesc1 = tvkbt-bezei.
        ELSE.
          CLEAR: cl1, cldesc1.
        ENDIF.

        IF cl2 IS NOT INITIAL.
          SELECT SINGLE * FROM tvkbt WHERE spras = sy-langu
                                     AND   vkbur = cl2.
          cldesc2 = tvkbt-bezei.
        ELSE.
          CLEAR: cl2, cldesc2.
        ENDIF.
      ENDIF.
    ENDIF.

    IF sy-tcode = 'VA43'.
      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMODULE.                 " HEAD_PBO  OUTPUT
"---------------------
***** PAI Module *****
"---------------------
*&---------------------------------------------------------------------*
*&      Module  HEAD_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE head_pai INPUT.
  IF vbak-auart = 'YSOW'.
    IF sy-tcode = 'VA41' OR sy-tcode = 'VA42'.
      CLEAR gv_clstflg.

      gv_visit = 'X'.

      IF cl1 IS NOT INITIAL.
        SELECT SINGLE * FROM tvkbt WHERE spras = sy-langu
                                   AND   vkbur = cl1.
        cldesc1 = tvkbt-bezei.
      ELSE.
        CLEAR: cl1, cldesc1.
      ENDIF.

      IF cl2 IS NOT INITIAL.
        SELECT SINGLE * FROM tvkbt WHERE spras = sy-langu
                                   AND   vkbur = cl2.
        cldesc2 = tvkbt-bezei.
      ELSE.
        CLEAR: cl2, cldesc2.
      ENDIF.

      IF clper1 IS NOT INITIAL AND clper2 IS INITIAL.
        clper2 = '100.00' - clper1.
      ELSEIF clper1 IS INITIAL AND clper2 IS NOT INITIAL.
        clper1 = '100.00' - clper2.
      ENDIF.

      IF clper1 IS NOT INITIAL OR clper2 IS NOT INITIAL.
        clpertot = ( clper1 + clper2 ).

        IF clpertot <> '100.00'.
          MESSAGE 'Cluster total is not equal to 100.' TYPE 'W' DISPLAY LIKE 'E'.
          gv_clstflg = 'X'.
        ELSE.
          CLEAR gv_clstflg.
        ENDIF.
      ENDIF.

      IF pc_chrg IS INITIAL.
        MESSAGE 'No selection for procurement charges' TYPE 'W' DISPLAY LIKE 'E'.
        gv_pcflg = 'X'.
      ELSE.
        CLEAR gv_pcflg.
      ENDIF.

      wa_head-chqno     = chqno.
      wa_head-agfrdat   = agfrdat.
      wa_head-agtodat   = agtodat.
      wa_head-salfrdat  = salfrdat.
      wa_head-saltodat  = saltodat.
      wa_head-cl1       = cl1.
      wa_head-cl2       = cl2.
      wa_head-clper1    = clper1.
      wa_head-clper2    = clper2.
      wa_head-inschrg   = inschrg.
      wa_head-qcchrg    = qcchrg.
      wa_head-rsqty     = rsqty.
      wa_head-pc_chrg   = pc_chrg.
      wa_head-wh_chrg   = wh_chrg.
    ENDIF.

    EXPORT wa_head TO MEMORY ID 'HEAD'.
    EXPORT gv_clstflg TO MEMORY ID 'CLFLG'.
    EXPORT gv_pcflg TO MEMORY ID 'PCFLG'.
    EXPORT gv_visit TO MEMORY ID 'VSTFLG'.
  ENDIF.
ENDMODULE.                 " HEAD_PAI  INPUT
"-----------------------------------------------------------
***** Additional Tab B - Item level - sapmv45a - 8459 *****
"-----------------------------------------------------------
"---------------------
***** PBO Module *****
"---------------------
*&---------------------------------------------------------------------*
*&      Module  GET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_data OUTPUT.
  """""To invisible fields of date and payment terms
  IF ( ( sy-tcode = 'VA43' OR sy-tcode = 'VA42' OR sy-tcode = 'VA41' ) AND vbak-auart EQ 'YSOW' ).
    LOOP AT SCREEN.
      IF screen-name = 'VBAP-ZZDFROM' OR screen-name = 'VBAP-ZZDTO' OR screen-name = 'VBAP-ZZPTERM'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF vbak-auart = 'YSOW'.

    IF sy-tcode = 'VA41'.

      REFRESH it_chardata.

      PERFORM get_char.

      DATA : v_line(2) TYPE c.
      DESCRIBE TABLE it_characteristics LINES v_line.
      tbc_8459-lines = v_line.

      LOOP AT it_characteristics INTO wa_characteristics.
        READ TABLE it_final INTO wa_final WITH KEY matnr = vbap-matnr atnam = wa_characteristics-name_char.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING wa_final TO wa_chardata.
        ELSE.
          wa_chardata-atnam    = wa_characteristics-name_char.
          wa_chardata-atbez    = wa_characteristics-descr_char.
          wa_chardata-meins    = wa_characteristics-unit.
          wa_chardata-matnr    = vbap-matnr.
        ENDIF.
        APPEND wa_chardata TO it_chardata.
        CLEAR: wa_chardata, wa_characteristics.
      ENDLOOP.

    ELSEIF sy-tcode = 'VA42'.

      REFRESH it_chardata.

      SELECT *
        FROM ztb_trd_specs
        INTO CORRESPONDING FIELDS OF TABLE it_final_modify
        WHERE vbeln EQ vbap-vbeln
        AND   matnr EQ vbap-matnr
        AND   posnr EQ vbap-posnr.

      IF sy-subrc = 0.
        DELETE ADJACENT DUPLICATES FROM it_final_modify COMPARING atnam.
        DESCRIBE TABLE it_final_modify LINES v_line.
        tbc_8459-lines = v_line.
      ENDIF.

      LOOP AT it_final INTO wa_final WHERE matnr EQ vbap-matnr AND posnr EQ vbap-posnr.
        MOVE-CORRESPONDING wa_final TO wa_chardata.
        APPEND wa_chardata TO it_chardata.
        CLEAR : wa_final,wa_chardata.
      ENDLOOP.

      IF it_chardata[] IS INITIAL.
        IF it_final_modify[] IS NOT INITIAL.
          LOOP AT it_final_modify INTO wa_final_modify.
            MOVE-CORRESPONDING wa_final_modify TO wa_chardata.
            APPEND wa_chardata TO it_chardata.
            CLEAR : wa_final_modify,wa_chardata.
          ENDLOOP.
        ELSE.
          PERFORM get_char.
          DESCRIBE TABLE it_characteristics LINES v_line.
          tbc_8459-lines = v_line.
          LOOP AT it_characteristics INTO wa_characteristics.
            wa_chardata-atnam    = wa_characteristics-name_char.
            wa_chardata-atbez    = wa_characteristics-descr_char.
            wa_chardata-meins    = wa_characteristics-unit.
            wa_chardata-matnr    = vbap-matnr.
            APPEND wa_chardata TO it_chardata.
          ENDLOOP.
        ENDIF.
      ENDIF.

    ELSEIF sy-tcode = 'VA43'.

      REFRESH it_chardata[].

      SELECT *
          FROM ztb_trd_specs
          INTO CORRESPONDING FIELDS OF TABLE it_final_modify
          WHERE vbeln EQ vbap-vbeln
          AND   matnr EQ vbap-matnr
          AND   posnr EQ vbap-posnr.

      IF sy-subrc = 0.
        DELETE ADJACENT DUPLICATES FROM it_final_modify COMPARING atnam.
        DESCRIBE TABLE it_final_modify LINES v_line.
        tbc_8459-lines = v_line.
      ENDIF.

      IF it_final_modify[] IS NOT INITIAL.
        LOOP AT it_final_modify INTO wa_final_modify.
          MOVE-CORRESPONDING wa_final_modify TO wa_chardata.
          APPEND wa_chardata TO it_chardata.
          CLEAR : wa_final_modify,wa_chardata.
        ENDLOOP.
      ELSE.
        PERFORM get_char.
        DESCRIBE TABLE it_characteristics LINES v_line.
        tbc_8459-lines = v_line.
        LOOP AT it_characteristics INTO wa_characteristics.
          wa_chardata-atnam    = wa_characteristics-name_char.
          wa_chardata-atbez    = wa_characteristics-descr_char.
          wa_chardata-meins    = wa_characteristics-unit.
          wa_chardata-matnr    = vbap-matnr.
          APPEND wa_chardata TO it_chardata.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " GET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_data OUTPUT.
  " PLAACEHOLDER
ENDMODULE.                 " SET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TBC_8459_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tbc_8459_get_lines OUTPUT.
  IF sy-tcode = 'VA43'.
    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF vbak-auart NE 'YSOW' OR ( sy-tcode <> 'VA41' AND sy-tcode <> 'VA42' AND sy-tcode <> 'VA43' ).
    LOOP AT SCREEN.
      tbc_8459-invisible = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " TBC_8459_GET_LINES  OUTPUT
"---------------------
***** PAI Module *****
"---------------------
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  "PLACEHOLDER
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  STORE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE store_data INPUT.
  IF vbak-auart = 'YSOW'.

    IF sy-tcode EQ 'VA41'.
      CLEAR wa_final.

      LOOP AT it_characteristics INTO wa_characteristics.

        LOOP AT it_chardata INTO wa_chardata WHERE atnam EQ wa_characteristics-name_char.

          LOOP AT it_final INTO wa_final WHERE matnr = wa_chardata-matnr AND atnam = wa_chardata-atnam.
            wa_final-specs    = wa_chardata-specs.
            wa_final-low_lim  = wa_chardata-low_lim.
            wa_final-up_lim   = wa_chardata-up_lim .
            wa_final-dect     = wa_chardata-dect.
            MODIFY it_final FROM wa_final TRANSPORTING specs low_lim up_lim dect.
          ENDLOOP.

          IF wa_final IS INITIAL.
            wa_final-posnr        = vbap-posnr.
            wa_final-atnam        = wa_characteristics-name_char.
            wa_final-atbez        = wa_characteristics-descr_char.
            wa_final-meins        = wa_chardata-meins.
            wa_final-matnr        = wa_chardata-matnr.
            wa_final-specs        = wa_chardata-specs.
            wa_final-low_lim      = wa_chardata-low_lim.
            wa_final-up_lim       = wa_chardata-up_lim .
            wa_final-dect         = wa_chardata-dect.
            APPEND wa_final TO it_final.
          ENDIF.
          CLEAR: wa_final,wa_chardata.
        ENDLOOP.
      ENDLOOP.

      SORT it_final DESCENDING BY atnam matnr.
      DELETE ADJACENT DUPLICATES FROM it_final COMPARING atnam matnr.

    ELSEIF sy-tcode = 'VA42'.
      CLEAR wa_final.
      LOOP AT it_chardata INTO wa_chardata .
        LOOP AT it_final INTO wa_final WHERE matnr = wa_chardata-matnr AND atnam = wa_chardata-atnam.
          wa_final-specs    = wa_chardata-specs.
          wa_final-low_lim  = wa_chardata-low_lim.
          wa_final-up_lim   = wa_chardata-up_lim .
          wa_final-dect     = wa_chardata-dect.
          MODIFY it_final FROM wa_final TRANSPORTING specs low_lim up_lim dect.
        ENDLOOP.
        IF wa_final IS INITIAL.
          wa_final-posnr        = vbap-posnr.
          wa_final-atnam        = wa_chardata-atnam.
          wa_final-atbez        = wa_chardata-atbez.
          wa_final-meins        = wa_chardata-meins .
          wa_final-matnr        = wa_chardata-matnr.
          wa_final-specs        = wa_chardata-specs.
          wa_final-low_lim      = wa_chardata-low_lim.
          wa_final-up_lim       = wa_chardata-up_lim .
          wa_final-dect         = wa_chardata-dect.
          APPEND wa_final TO it_final.
        ENDIF.
        CLEAR: wa_final,wa_chardata.

      ENDLOOP.

    ENDIF.

*    IF sy-ucomm = 'SICH'.
    EXPORT it_final TO MEMORY ID 'FINAL'.
*    ENDIF.

  ENDIF.
ENDMODULE.                 " STORE_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  TBC_8459_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tbc_8459_modify INPUT.
  IF vbak-auart = 'YSOW'.
    MODIFY it_chardata FROM wa_chardata INDEX tbc_8459-current_line.
  ENDIF.
ENDMODULE.                 " TBC_8459_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Form  GET_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_char .
  CONCATENATE vbap-matnr vbap-charg INTO v_obj RESPECTING BLANKS.

  SELECT SINGLE *
    FROM inob
    INTO CORRESPONDING FIELDS OF wa_inob
    WHERE objek EQ v_obj.

  SELECT SINGLE *
    FROM kssk
    INTO CORRESPONDING FIELDS OF wa_kssk
    WHERE objek EQ wa_inob-cuobj.

  SELECT SINGLE *
    FROM klah
    INTO CORRESPONDING FIELDS OF wa_klah
    WHERE clint EQ wa_kssk-clint.

  DATA: v_clnum TYPE bapi1003_key-classnum,
        v_cltype TYPE bapi1003_key-classtype,
        v_objtab TYPE bapi1003_key-objecttable.

  v_clnum =  wa_klah-class.
  v_cltype = wa_inob-klart.
  v_objtab = wa_inob-obtab.

  CALL FUNCTION 'BAPI_CLASS_GET_CHARACTERISTICS'
    EXPORTING
      classnum              =  v_clnum
      classtype             =  v_cltype
*         LANGU_ISO             =
*         LANGU_INT             =
      key_date              =  sy-datum
      with_values           =  'X'
*       IMPORTING
*         RETURN                =
    TABLES
      characteristics       =  it_characteristics
      char_values           =  it_char_values.

  CLEAR: wa_vbap,wa_klah,wa_inob,wa_inob,v_clnum,v_cltype,v_objtab,v_obj.
ENDFORM.                    " GET_CHAR
