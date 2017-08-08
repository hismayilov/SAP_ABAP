*&---------------------------------------------------------------------*
*&  Include           LZGST_VSACF01
*&---------------------------------------------------------------------*

*{   INSERT         IRDK928385                                        1
FORM validate_hsn.
*  Validation premise:
*  1. Allow modification in zvend_sac for current user only if
*   a. He specifically has access to zvend_sac tcode via a specific role
*   b. Next check whether in that role he has access to company code(object) of the vendor
*   c. Next check what kind of activity is permitted for that object in that role(01 is req here)

  CONSTANTS: v_profile    TYPE ust04-profile   VALUE 'SAP_ALL',
             v_object_tcd TYPE agr_1251-object VALUE 'S_TCODE',
             v_field_tcd  TYPE agr_1251-field  VALUE 'TCD',
             v_object_buk TYPE agr_1251-object VALUE 'F_BKPF_BUK',
             v_field_buk  TYPE agr_1251-field  VALUE 'BUKRS',
             v_field_act  TYPE agr_1251-field  VALUE 'ACTVT',
             v_tcode      TYPE sy-tcode        VALUE 'ZVEND_SAC'.

  TYPES: BEGIN OF ty_shp,
           j_1ichid TYPE j_1ichidtx-j_1ichid,
           j_1icht1 TYPE j_1ichidtx-j_1icht1,
         END OF ty_shp.

  DATA: it_shp TYPE TABLE OF ty_shp,
        wa_shp TYPE ty_shp.

  DATA: wa_ust04      TYPE ust04,               " User Profiles

        it_agrusr     TYPE TABLE OF agr_users,  " User Roles
        wa_agrusr     TYPE agr_users,

        it_agrtcode   TYPE TABLE OF agr_1251,   " Objects in Role
        wa_agrtcode   TYPE agr_1251,

        it_agrcmpcode TYPE TABLE OF agr_1251,
        wa_agrcmpcode TYPE agr_1251,

        it_agractvt   TYPE TABLE OF agr_1251,
        wa_agractvt   TYPE agr_1251,

        it_vend       TYPE TABLE OF lfb1,       " Vendor Company Data
        wa_vend       TYPE lfb1.

  RANGES: s_bukrs FOR agr_1251-low.

*  FIELD-SYMBOLS: <fs_tab> TYPE STANDARD TABLE,
*                 <fs_wa>  TYPE any,
*                 <fs>     TYPE any.
*
*  DATA: v_flag TYPE flag.

  REFRESH: it_shp[], it_agrusr[], it_agrtcode[], it_agrcmpcode[], it_agractvt[], it_vend[], s_bukrs[].
  CLEAR:   wa_ust04, wa_shp, wa_agrusr, wa_agrtcode, wa_agrcmpcode, wa_agractvt, wa_vend, s_bukrs." v_flag.
*  UNASSIGN: <fs_tab>, <fs_wa>, <fs>.
* Implicit assumption => User will reach the maintainance screen only if he has access to the transaction via the pre-defined role
* So, explicit check for authority on TCODE ZVEND_SAC as it is maintained in the role

*  Skip all checks and allow operation if user is admin(SAP_ALL Role is assigned)
  SELECT SINGLE *
    FROM ust04
    INTO wa_ust04
    WHERE bname EQ sy-uname
    AND   profile EQ v_profile.

  CHECK sy-subrc NE 0.  " Proceed only if SAP_ALL is not assigned to the user

* Check if company data exists for current vendor, no point in checking authorisation for non-existant company code
  SELECT *
    FROM lfb1
    INTO TABLE it_vend
    WHERE lifnr EQ zgst_vsac-lifnr.

  CHECK sy-subrc = 0.
*  ASSIGN it_vend TO <fs_tab>. " For later processing

*  Generate range for easy selection
  LOOP AT it_vend INTO wa_vend WHERE bukrs IS NOT INITIAL.
    s_bukrs-sign = 'I'.
    s_bukrs-option = 'EQ'.
    s_bukrs-low = wa_vend-bukrs.
    APPEND s_bukrs.
  ENDLOOP.

* Get roles of current user
  SELECT *
    FROM agr_users
    INTO TABLE it_agrusr
    WHERE uname EQ sy-uname
    AND   to_dat GE sy-datum.

* Check if any of the roles of the user has authorisation to TCODE => ZVEND_SAC
  IF sy-subrc = 0 AND it_agrusr[] IS NOT INITIAL.
    SELECT *
      FROM agr_1251
      INTO TABLE it_agrtcode
      FOR ALL ENTRIES IN it_agrusr
      WHERE agr_name EQ it_agrusr-agr_name
      AND   object   EQ v_object_tcd    " 'S_TCODE'
      AND   field    EQ v_field_tcd     " 'TCD'
      AND   low      EQ v_tcode.        " 'ZVEND_SAC'.  " Replace by sy-tcode?

* Check if user also has been given access to company code object of vendor in that role
    IF sy-subrc = 0 AND it_agrtcode[] IS NOT INITIAL.
      SELECT *
        FROM agr_1251
        INTO TABLE it_agrcmpcode
        FOR ALL ENTRIES IN it_agrtcode
        WHERE agr_name EQ it_agrtcode-agr_name
        AND   auth     EQ it_agrtcode-auth
        AND   object   EQ v_object_buk  " 'F_BKPF_BUK'
        AND   field    EQ v_field_buk   " 'BUKRS'
        AND   low      IN s_bukrs.      "EQ '1000'.     " Replace by vendor company code

* Check if activity access (01, 02, 03, 06) is also given in that role (01 - Create, 02 - Change, 03 - Display, 06 - Delete)
      IF sy-subrc = 0 AND it_agrcmpcode[] IS NOT INITIAL.
        IF sy-ucomm EQ 'DELE'.
          SELECT *
          FROM agr_1251
          INTO TABLE it_agractvt
          FOR ALL ENTRIES IN it_agrcmpcode
          WHERE agr_name EQ it_agrcmpcode-agr_name
          AND   auth     EQ it_agrcmpcode-auth
          AND   object   EQ v_object_buk  " 'F_BKPF_BUK'
          AND   field    EQ v_field_act   " 'ACTVT'
          AND   low      EQ '06'.   " Depending on mode of SM30
        ELSE.
          SELECT *
          FROM agr_1251
          INTO TABLE it_agractvt
          FOR ALL ENTRIES IN it_agrcmpcode
          WHERE agr_name EQ it_agrcmpcode-agr_name
          AND   auth     EQ it_agrcmpcode-auth
          AND   object   EQ v_object_buk  " 'F_BKPF_BUK'
          AND   field    EQ v_field_act   " 'ACTVT'
          AND   low      IN ('01', '02').   " Depending on mode of SM30
        ENDIF.

        IF it_agractvt[] IS NOT INITIAL. " AND <fs_tab> IS ASSIGNED.
*          LOOP AT <fs_tab> ASSIGNING <fs_wa>.
*            ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_wa> TO <fs>.
*            IF <fs> IS ASSIGNED.
*              AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*                ID 'BUKRS' FIELD <fs>   " Vend comp code
*                ID 'ACTVT' FIELD '01'.  " Depending on mode of SM30
**              ID 'ACTVT' FIELD '02'  " Depending on mode of SM30
**              ID 'ACTVT' FIELD '03' ." Depending on mode of SM30
*
*              IF sy-subrc <> 0.
*                MOVE 'X' TO v_flag.
*              ELSE.
*                CLEAR v_flag.
*                EXIT.
*              ENDIF.
*            ENDIF.
*          ENDLOOP.
*          IF v_flag IS NOT INITIAL.
*            SET CURSOR FIELD 'ZGST_VSAC-LIFNR' LINE sy-stepl.
*            MESSAGE 'You are not authorised.' TYPE 'E'.
*          ENDIF.
        ELSE.
          SET CURSOR FIELD 'ZGST_VSAC-LIFNR' LINE sy-stepl.
          MESSAGE 'You are not authorised.' TYPE 'E'.
        ENDIF.
      ELSE.
        SET CURSOR FIELD 'ZGST_VSAC-LIFNR' LINE sy-stepl.
        MESSAGE 'You are not authorised.' TYPE 'E'.
      ENDIF.
    ELSE.
      SET CURSOR FIELD 'ZGST_VSAC-LIFNR' LINE sy-stepl.
      MESSAGE 'You are not authorised.' TYPE 'E'.
    ENDIF.
  ENDIF.

* Validation premise:
* 1. Allow only sac codes starting with 99 and six characters in length (99____)
  SELECT j_1ichid j_1icht1
    FROM j_1ichidtx
    INTO TABLE it_shp
    WHERE j_1ichid LIKE '99____'
    AND   langu EQ sy-langu.

  READ TABLE it_shp INTO wa_shp WITH KEY j_1ichid = zgst_vsac-hsn_sac.
  IF sy-subrc <> 0.
    SET CURSOR FIELD 'ZGST_VSAC-HSN_SAC' LINE sy-stepl.
    MESSAGE 'Invalid value for SAC code' TYPE 'E'.
  ENDIF.
ENDFORM.
*}   INSERT
