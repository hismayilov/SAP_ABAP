* ---- Begin Validation for Line Item Condition Group in Sales Order (VA01/02) ---- *
* Developer : Saurabh Khare
* Date      : Friday, September 01, 2017 12:20:07
* TR        : IRDK929010
* ---- ***** ----- *
* ---- Declaration ---- *
  DATA: BEGIN OF wa_check,
          vbeln TYPE vbkd-vbeln,
          posnr TYPE vbkd-posnr,
          kdkg1 TYPE vbkd-kdkg1,
          kdkg2 TYPE vbkd-kdkg2,
          kdkg3 TYPE vbkd-kdkg3,
          kdkg4 TYPE vbkd-kdkg4,
          kdkg5 TYPE vbkd-kdkg5,
        END OF wa_check,
        it_check LIKE TABLE OF wa_check,

*        it_vbkd  LIKE TABLE OF vbkdvb,
*        wa_vbkd  LIKE vbkdvb,
*
*        wa_vbak  LIKE vbakvb,

*        it_vbap  LIKE TABLE OF vbapvb,
        wa_vbap  LIKE vbapvb.

  DATA: lv_msg TYPE bapi_msg.

  IF sy-tcode EQ 'VA01' OR sy-tcode EQ 'VA02'.
    " Get data to be processed
    REFRESH: it_vbkd, it_vbap.
    CLEAR: wa_vbak, wa_vbap, wa_vbkd.
    IF xvbak IS NOT INITIAL.
      MOVE-CORRESPONDING xvbak TO wa_vbak.
    ELSEIF yvbak IS NOT INITIAL.
      MOVE-CORRESPONDING yvbak TO wa_vbak.
    ENDIF.

    IF xvbap[] IS NOT INITIAL.
      it_vbap[] = xvbap[].
    ELSEIF yvbap[] IS NOT INITIAL.
      it_vbap[] = yvbap[].
    ENDIF.

    IF xvbkd[] IS NOT INITIAL.
      it_vbkd[] = xvbkd[].
    ELSEIF yvbkd[] IS NOT INITIAL.
      it_vbkd[] = yvbkd[].
    ENDIF.
    DELETE it_vbkd WHERE posnr EQ '000000'.

    REFRESH: it_check.
    CLEAR: wa_check.
* ---- Checks for company code 1000 ---- *
    IF wa_vbak-bukrs_vf EQ '1000' AND wa_vbak-vtweg EQ '20'.
*      IF it_vbkd IS NOT INITIAL.
      LOOP AT it_vbkd INTO wa_vbkd.
        " Condition group should not be empty/is mandatory...
        IF  wa_vbkd-kdkg1 IS INITIAL
        AND wa_vbkd-kdkg2 IS INITIAL
        AND wa_vbkd-kdkg3 IS INITIAL
        AND wa_vbkd-kdkg4 IS INITIAL
        AND wa_vbkd-kdkg5 IS INITIAL.
          CLEAR lv_msg.
          CONCATENATE 'Item' wa_vbkd-posnr ': Condition group in Additional data A is mandatory'
                INTO lv_msg
                SEPARATED BY space.

          MESSAGE lv_msg TYPE 'E'.
        ELSE.
          MOVE-CORRESPONDING wa_vbkd TO wa_check.
          APPEND wa_check TO it_check.
        ENDIF.
        CLEAR: wa_vbkd, wa_check.
      ENDLOOP.

      " ...And should be identical for all line items
      IF it_check IS NOT INITIAL.
        DELETE ADJACENT DUPLICATES FROM it_check COMPARING kdkg1 kdkg2 kdkg3 kdkg4 kdkg5.
        IF lines( it_check ) GT 1.
          MESSAGE 'Condition group data for all items should be identical. Please check Additional data A.'
          TYPE 'E'.
        ENDIF.
      ENDIF.
*      ELSE.
*        CLEAR lv_msg.
*        CONCATENATE 'Condition Group in Additional Data A missing' space
*              INTO lv_msg
*              SEPARATED BY space.
*
*        MESSAGE lv_msg TYPE 'E'.
*      ENDIF.
    ENDIF.
* ---- Checks for company code 2000 ---- *
    IF wa_vbak-bukrs_vf EQ '2000' AND wa_vbak-vtweg EQ '20'.   .
      LOOP AT it_vbkd INTO wa_vbkd.
        CLEAR: wa_vbap.
        READ TABLE it_vbap INTO wa_vbap WITH KEY  vbeln = wa_vbkd-vbeln
                                                  posnr = wa_vbkd-posnr
                                                  werks = '2101'.
        " For items with plant 2101, condition group should not be supplied...
        IF sy-subrc = 0.
          IF wa_vbkd-kdkg1 IS NOT INITIAL
          OR wa_vbkd-kdkg2 IS NOT INITIAL
          OR wa_vbkd-kdkg3 IS NOT INITIAL
          OR wa_vbkd-kdkg4 IS NOT INITIAL
          OR wa_vbkd-kdkg5 IS NOT INITIAL.
            CLEAR lv_msg.
            CONCATENATE 'Item' wa_vbkd-posnr ': Condition group in Additional data A should not be supplied for plant' wa_vbap-werks
                  INTO lv_msg
                  SEPARATED BY space.

            MESSAGE lv_msg TYPE 'E'.
          ENDIF.
        " ...For all other items it is mandatory...
        ELSE.
          IF  wa_vbkd-kdkg1 IS INITIAL
          AND wa_vbkd-kdkg2 IS INITIAL
          AND wa_vbkd-kdkg3 IS INITIAL
          AND wa_vbkd-kdkg4 IS INITIAL
          AND wa_vbkd-kdkg5 IS INITIAL.
            CLEAR lv_msg.
            CONCATENATE 'Item' wa_vbkd-posnr ': Condition group in Additional data A is mandatory'
                  INTO lv_msg
                  SEPARATED BY space.

            MESSAGE lv_msg TYPE 'E'.
          ELSE.
            MOVE-CORRESPONDING wa_vbkd TO wa_check.
            APPEND wa_check TO it_check.
          ENDIF.
        ENDIF.
        CLEAR: wa_vbkd, wa_check.
      ENDLOOP.

      " ...And should be identical for all items
      IF it_check IS NOT INITIAL.
        DELETE ADJACENT DUPLICATES FROM it_check COMPARING kdkg1 kdkg2 kdkg3 kdkg4 kdkg5.
        IF lines( it_check ) GT 1.
          MESSAGE 'Condition group data for all items should be identical. Please check Additional data A.'
          TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
* ---- Checks for company code 2000 ---- *
    IF wa_vbak-bukrs_vf EQ '2050' AND wa_vbak-vtweg EQ '20'.   .
      LOOP AT it_vbkd INTO wa_vbkd.
        CLEAR: wa_vbap.
        READ TABLE it_vbap INTO wa_vbap WITH KEY  vbeln = wa_vbkd-vbeln
                                                  posnr = wa_vbkd-posnr
                                                  werks = '2510'.
        " For items with plant 2510, condition group should not be supplied
        IF sy-subrc = 0.
          IF wa_vbkd-kdkg1 IS NOT INITIAL
          OR wa_vbkd-kdkg2 IS NOT INITIAL
          OR wa_vbkd-kdkg3 IS NOT INITIAL
          OR wa_vbkd-kdkg4 IS NOT INITIAL
          OR wa_vbkd-kdkg5 IS NOT INITIAL.
            CLEAR lv_msg.
            CONCATENATE 'Item' wa_vbkd-posnr ': Condition group in Additional data A should not be supplied for plant' wa_vbap-werks
                  INTO lv_msg
                  SEPARATED BY space.

            MESSAGE lv_msg TYPE 'E'.
          ENDIF.
        ENDIF.
        CLEAR: wa_vbkd.
      ENDLOOP.
    ENDIF.
  ENDIF.
* ---- End validations for condition group ---- *
