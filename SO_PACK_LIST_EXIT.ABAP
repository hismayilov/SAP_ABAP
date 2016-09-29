" Program Name: SAPLS38E 
" Include Name: MV45AFZZ

FORM userexit_save_document_prepare.
  """" BEGIN OF CHANGES BY SHRADDHA TANDEL. DATE: 29 SEP 2016
* User Exit to check if packaging list exists for a given sales order
* Do not allow deletion of that sales order if a packaging list exists

*BREAK ABAP_DEV.
  IF  sy-tcode = 'VA02'.

    DATA : wa_zpp_pack TYPE zpp_pack.
    DATA:  v_msgtxt(60).

    IF vbak-vbeln IS NOT INITIAL. " Check Sales order number
      SELECT SINGLE * FROM zpp_pack INTO wa_zpp_pack WHERE vbeln = vbak-vbeln .
      IF sy-subrc = 0 AND sy-ucomm = 'YES'. " After user clicks on 'Yes' button of deletion confirmation
        IF wa_zpp_pack-pklst IS NOT INITIAL.  " Check if packaging list exists
          v_msgtxt = 'Packaging list exists. Cannot be deleted.'.
          MESSAGE i002(sy) WITH v_msgtxt DISPLAY LIKE 'E'. " Info message display like error

          LEAVE TO SCREEN 102. " Exit to VA02 after error message

        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*""""""""""" END OF CHANGES BY SHRADDHA TANDEL.
