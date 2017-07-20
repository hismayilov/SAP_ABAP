*&---------------------------------------------------------------------*
*&  Include           LZGST_VSACF01
*&---------------------------------------------------------------------*

*{   INSERT         IRDK928385                                        1
FORM validate_hsn.
  TYPES: BEGIN OF ty_shp,
             j_1ichid TYPE j_1ichidtx-j_1ichid,
             j_1icht1 TYPE j_1ichidtx-j_1icht1,
           END OF ty_shp.

  DATA: it_shp TYPE TABLE OF ty_shp,
        wa_shp TYPE ty_shp.

  SELECT j_1ichid j_1icht1
    FROM j_1ichidtx
    INTO TABLE it_shp
    WHERE j_1ichid LIKE '99____'
    AND   langu EQ sy-langu.

  READ TABLE it_shp INTO wa_shp with key j_1ichid = zgst_vsac-hsn_sac.
    IF sy-subrc <> 0.
      SET CURSOR FIELD 'ZGST_VSAC-HSN_SAC' LINE sy-stepl.
      MESSAGE 'Invalid value for SAC code' TYPE 'E'.
    ENDIF.
ENDFORM.
*}   INSERT
