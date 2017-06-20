Form USEREXIT_SAVE_DOCUMENT_PREPARE.
....
ENHANCEMENT 1  ZCHECK_STP_BTP_WE_RE.    "active version
*IF sy-tcode = 'VA01' OR sy-tcode = 'VA02'.
*  DATA: kunnr_re TYPE vbpa-kunnr,
*        kunnr_we TYPE vbpa-kunnr,
*        region_re TYPE kna1-regio,
*        region_we TYPE kna1-regio.
*
*  CLEAR: xvbpa, kunnr_re.
*  READ TABLE xvbpa with key parvw = 'RE'.
*  IF sy-subrc = 0.
*    kunnr_re = xvbpa-kunnr.
*  ENDIF.
*
*  CLEAR: xvbpa , kunnr_we.
*  READ TABLE xvbpa with key parvw = 'WE'.
*  IF sy-subrc = 0.
*    kunnr_we = xvbpa-kunnr.
*  ENDIF.
*
*  CLEAR: region_re, region_we.
*  IF kunnr_re = kunnr_we.
*    SELECT SINGLE regio
*      FROM kna1
*      INTO region_re
*      WHERE kunnr = kunnr_re.
*
*    SELECT SINGLE regio
*      FROM kna1
*      INTO region_we
*      WHERE kunnr = kunnr_we.
*
*    IF region_re <> region_we.
*      MESSAGE 'Ship to party region and Bill to party region do not match' TYPE 'E'.
*    ENDIF.
*  ELSE.
*    MESSAGE 'Sold to party and Ship to party do not match' TYPE 'E'.
*  ENDIF.
*ENDIF.
ENDENHANCEMENT.  
ENHANCEMENT 2  ZGSTIN_CHECK.    "active version
IF sy-tcode = 'VA01' OR sy-tcode = 'VA02'.
    DATA: vendor TYPE vbak-kunnr,
          gstin  TYPE kna1-stcd3,
          L_BUKRS  TYPE BUKRS,
          MSG  TYPE STRING,
          L_TAXKD  TYPE KNVI-TAXKD.

    TYPES: BEGIN OF ty_marc,
            matnr TYPE marc-matnr,
            werks TYPE marc-werks,
            steuc TYPE marc-steuc,
          END OF ty_marc.
    DATA :  LT_MARC TYPE TABLE OF ty_marc,
            LW_MARC TYPE          ty_marc.

      SELECT SINGLE BUKRS FROM T001K INTO L_BUKRS WHERE BWKEY = XVBAP-WERKS AND BUKRS = 'SCIL'.
        " VKORG 004 is export, No GST/HSN Check for same
        IF SY-SUBRC IS INITIAL AND XVBAK-VKORG NE '004'.
******* For HSN Code
          SELECT  matnr
                werks
                steuc
          FROM MARC
          INTO TABLE LT_MARC
          FOR ALL ENTRIES IN XVBAP[]
          WHERE MATNR = XVBAP-MATNR
          and WERKS = XVBAP-WERKS.

        CONCATENATE 'HSN code is not maintain for ( material &' 'Plant ) ' INTO MSG SEPARATED BY space.
        LOOP AT LT_MARC INTO LW_MARC WHERE steuc IS INITIAL.
          CONCATENATE MSG '(' LW_MARC-MATNR ' , ' LW_MARC-WERKS ')' INTO MSG .
        ENDLOOP .
        IF SY-SUBRC IS INITIAL.
*          MESSAGE MSG TYPE 'E'.
          MESSAGE 'HSN code is not maintain for material' TYPE 'E'.
        ENDIF.


****For Customer GSTIN Number
             IF xvbak-kunnr IS NOT INITIAL.
               SELECT SINGLE TAXKD
                 FROM KNVI
                 INTO L_TAXKD
                 WHERE KUNNR = xvbak-kunnr
                 and ALAND = TVKO_SADR-LAND1
                 and TATYP = 'JOIG'.
                 IF SY-SUBRC IS INITIAL AND L_TAXKD = '0' .
                       MOVE xvbak-kunnr TO vendor.
                       SELECT SINGLE stcd3 FROM kna1 INTO gstin WHERE kunnr = vendor .
                         IF SY-SUBRC IS INITIAL and  gstin IS INITIAL.
                            CLEAR MSG.
                             CONCATENATE 'Customer - ' xvbak-kunnr  'is not registered for GST' INTO MSG SEPARATED BY SPACE.
                           MESSAGE MSG TYPE 'E'.
                         ENDIF.
                  ENDIF.
             ENDIF.
ENDIF.
ENDIF.
ENDENHANCEMENT.
*$*$-End:   (2)---------------------------------------------------------------------------------$*$*
ENDFORM.
