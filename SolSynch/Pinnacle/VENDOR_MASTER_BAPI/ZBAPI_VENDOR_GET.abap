FUNCTION zbapi_vendor_get.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VENDORIN) TYPE  ZVENDIN
*"  EXPORTING
*"     VALUE(RETURN) TYPE  ZTTRETURN
*"     VALUE(T_GENDET) TYPE  ZTTGENDET
*"     VALUE(T_EXCDET) TYPE  ZTTEXCDET
*"     VALUE(T_BANKDET) TYPE  ZTTBANKDET
*"     VALUE(T_VENDDET) TYPE  ZTTVENDDET
*"     VALUE(T_COMPDET) TYPE  ZTTCOMPDET
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_lfa1,
           vend     TYPE lfa1-lifnr,
           vendname TYPE lfa1-name1,
           telno    TYPE lfa1-telf1,
           mobno    TYPE lfa1-telf2,
           faxno    TYPE lfa1-telfx,
           addr     TYPE lfa1-name2,
           addr1    TYPE lfa1-name3,
           addr2    TYPE lfa1-name4,
           street   TYPE lfa1-stras,  " Additional
           city     TYPE lfa1-ort01,
           dist     TYPE lfa1-ort02,
           state    TYPE lfa1-regio,  " Additional
           country  TYPE lfa1-land1,  " Additional
           pin      TYPE lfa1-pstlz,
           adrnr    TYPE lfa1-adrnr,
           "servtyp  TYPE lfa1-brsch, (industry key) or lfa1-ktokk (Vendor account grp)
         END OF ty_lfa1,

         BEGIN OF ty_knvk,
           vend     TYPE knvk-lifnr,
           partnrno TYPE knvk-parnr,
           contpersf TYPE knvk-namev,
           contpersl TYPE knvk-name1,
           designtn  TYPE knvk-pafkt, " get designation/function desc from tpfkt
           personno  TYPE knvk-prsnr,
         END OF ty_knvk,

         BEGIN OF ty_adr6,
           addrnumber TYPE adr6-addrnumber,
           email      TYPE adr6-smtp_addr,
         END OF ty_adr6,

         BEGIN OF ty_j_1imovend,
           vend         TYPE j_1imovend-lifnr,
           pan          TYPE j_1imovend-j_1ipanno,
           sertaxregno  TYPE j_1imovend-j_1isern,
           excreg       TYPE j_1imovend-j_1iexrn,
           excdiv       TYPE j_1imovend-j_1iexdi,
           excrng       TYPE j_1imovend-j_1iexrg,
           eccno        TYPE j_1imovend-j_1iexcd,
           censaltaxno  TYPE j_1imovend-j_1icstno,
           locsaltaxno  TYPE j_1imovend-j_1ilstno,
           ssistat      TYPE j_1imovend-j_1issist,
           ventyp       TYPE j_1imovend-j_1ivtyp,
         END OF ty_j_1imovend,

         BEGIN OF ty_lfbk,
           vend    TYPE lfbk-lifnr,
           accno   TYPE lfbk-bankn,
           accname TYPE lfbk-koinh,
           acctype TYPE lfbk-bkont,
           bifsc   TYPE lfbk-bankl,
         END OF ty_lfbk,

         BEGIN OF ty_lfb1,
           vend    TYPE lfb1-lifnr,
           compc   TYPE lfb1-bukrs,
           paymeth TYPE lfb1-zwels,
         END OF ty_lfb1,

         BEGIN OF ty_bnka,
           bifsc   TYPE bnka-bankl,
           bname   TYPE bnka-banka,
           bbranch TYPE bnka-brnch,
           baddr1  TYPE bnka-stras,
           baddr2  TYPE bnka-ort01,
           baddr3  TYPE bnka-provz,
           bmicr   TYPE bnka-bnklz,
           bswift  TYPE bnka-swift,
         END OF ty_bnka.

*       Problem Fields:
*       1. GENDET: Contact Person, Service type, Email
*       2. EXCDET: Ex chapter head no, Ex duty appl, GST No, WCT No, Tax ind (WH Tax Code)
*       3. BANKDET: Bank AD Code(from bnka)
*       Notes: for servtyp:
*       if its brsch (T016 - Value table/T016T - Text table-brtxt) - for description
*       if its ktokk (T077K - Value table/T077Y - Text table-txt30) - for description

  " Data
  DATA: it_lfa1 TYPE TABLE OF ty_lfa1,              " vendor master gen. details
        wa_lfa1 TYPE ty_lfa1,

        it_knvk TYPE TABLE OF ty_knvk,              " vendor master cont pers. details
        wa_knvk TYPE ty_knvk,

        it_adr6 TYPE TABLE OF ty_adr6,              " vendor master email. details
        wa_adr6 TYPE ty_adr6,

        it_j_1imovend TYPE TABLE OF ty_j_1imovend,  " vendor master excise details
        wa_j_1imovend TYPE ty_j_1imovend,

        it_lfbk TYPE TABLE OF ty_lfbk,              " vendor master bank details
        wa_lfbk TYPE ty_lfbk,

        it_lfb1 TYPE TABLE OF ty_lfb1,              " Vendor master comp. details (Pay-Method)
        wa_lfb1 TYPE ty_lfb1,

        it_bnka TYPE TABLE OF ty_bnka,              " vendor master add. bank details
        wa_bnka TYPE ty_bnka,

        it_generaldetail TYPE TABLE OF zgendet,     " final gen details
        wa_generaldetail TYPE zgendet,

        it_excisedetail TYPE TABLE OF zexcdet,      " final excise details
        wa_excisedetail TYPE zexcdet,

        it_bankdetail TYPE TABLE OF zbankdet,       " final bank details
        wa_bankdetail TYPE zbankdet,

        it_compdetail TYPE TABLE OF zcompdet,       " final comp details
        wa_compdetail TYPE zcompdet,

        it_venddetail TYPE TABLE OF zvenddet,       " consolidated vendor details
        wa_venddetail TYPE zvenddet,

        wa_return LIKE LINE OF return,              " return messages

        it_venddetail_temp TYPE TABLE OF zvenddet,  " for internal processing
        wa_venddetail_temp TYPE zvenddet.

*        it_gdcp TYPE TABLE OF zgendet,              " for internal processing of multiple cont pers per vendor
*        wa_gdcp TYPE zgendet,
*
*        it_gdmail TYPE TABLE OF zgendet,            " for internal processing of multiple emails per vendor
*        wa_gdmail TYPE zgendet.

  DATA: BEGIN OF t_field OCCURS 0,      "Fieldlist im SELECT-Statement
         fname LIKE dntab-fieldname,
       END OF t_field.

  RANGES: s_lifnr FOR lfa1-lifnr.

  IF vendorin IS NOT INITIAL.
    s_lifnr-low = vendorin-vendfrom.
    s_lifnr-high = vendorin-vendto.
    IF s_lifnr-high < s_lifnr-low AND s_lifnr-high IS NOT INITIAL.
      s_lifnr-low = vendorin-vendto.
      s_lifnr-high = vendorin-vendfrom.
    ENDIF.
    s_lifnr-sign = 'I'.
    IF s_lifnr-high IS INITIAL.
      s_lifnr-option = 'EQ'.
    ELSE.
      s_lifnr-option = 'BT'.
    ENDIF.
    APPEND s_lifnr.
  ELSE.
    wa_return-type = 'I'.
    wa_return-id = 'ZVENBAP'.
    wa_return-number = 000.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = wa_return-type
        cl     = wa_return-id
        number = wa_return-number
      IMPORTING
        return = wa_return.
    APPEND wa_return TO return.
    CLEAR wa_return.
  ENDIF.

  t_field-fname = 'lifnr'.
  APPEND t_field.
  t_field-fname = 'name1'.
  APPEND t_field.
  t_field-fname = 'telf1'.
  APPEND t_field.
  t_field-fname = 'telf2'.
  APPEND t_field.
  t_field-fname = 'telfx'.
  APPEND t_field.
  t_field-fname = 'name2'.
  APPEND t_field.
  t_field-fname = 'name3'.
  APPEND t_field.
  t_field-fname = 'name4'.
  APPEND t_field.
  t_field-fname = 'stras'.
  APPEND t_field.
  t_field-fname = 'ort01'.
  APPEND t_field.
  t_field-fname = 'ort02'.
  APPEND t_field.
  t_field-fname = 'regio'.
  APPEND t_field.
  t_field-fname = 'land1'.
  APPEND t_field.
  t_field-fname = 'pstlz'.
  APPEND t_field.
  t_field-fname = 'adrnr'.
  APPEND t_field.

*** Get Data ***
  IF s_lifnr IS NOT INITIAL.
    SELECT (t_field)
     FROM lfa1
     INTO TABLE it_lfa1
     WHERE lifnr IN s_lifnr.
  ELSE.
    SELECT (t_field)
     FROM lfa1
     INTO TABLE it_lfa1.
  ENDIF.

  IF sy-subrc = 0 AND it_lfa1[] IS NOT INITIAL.
    SELECT lifnr
           bukrs
           zwels
      FROM lfb1
      INTO TABLE it_lfb1
      FOR ALL ENTRIES IN it_lfa1
      WHERE lifnr = it_lfa1-vend.

    SELECT lifnr
           parnr
           namev
           name1
           pafkt
           prsnr
      FROM knvk
      INTO TABLE it_knvk
      FOR ALL ENTRIES IN it_lfa1
      WHERE lifnr = it_lfa1-vend.

    SELECT addrnumber
           smtp_addr
      FROM adr6
      INTO TABLE it_adr6
      FOR ALL ENTRIES IN it_lfa1
      WHERE addrnumber = it_lfa1-adrnr
      AND flgdefault EQ 'X'. " gets only the default email, remove to get all emails for a vendor

    SELECT lifnr
           j_1ipanno
           j_1isern
           j_1iexrn
           j_1iexdi
           j_1iexrg
           j_1iexcd
           j_1icstno
           j_1ilstno
           j_1issist
           j_1ivtyp
      FROM j_1imovend
      INTO TABLE it_j_1imovend
      FOR ALL ENTRIES IN it_lfa1
      WHERE lifnr = it_lfa1-vend.

    SELECT lifnr
           bankn
           koinh
           bkont
           bankl
      FROM lfbk
      INTO TABLE it_lfbk
      FOR ALL ENTRIES IN it_lfa1
      WHERE lifnr = it_lfa1-vend.

    IF it_lfbk[] IS NOT INITIAL.
      SELECT bankl
             banka
             brnch
             stras
             ort01
             provz
             bnklz
             swift
        FROM bnka
        INTO TABLE it_bnka
        FOR ALL ENTRIES IN it_lfbk
        WHERE bankl = it_lfbk-bifsc.
    ENDIF.

**** Process Data ****
    LOOP AT it_lfa1 INTO wa_lfa1.
***  Build General Details ***
      MOVE-CORRESPONDING wa_lfa1 TO wa_generaldetail.

      READ TABLE it_knvk INTO wa_knvk WITH KEY vend = wa_lfa1-vend.
      " Loop this in the future if all contact persons for a vendor are required
      " Insert it after read adr6, so that lfa1 details and email details will get repeated for each row in the loop
      " Get function code from knvk and desc from tpfkt : eg marketing manager
      " Other details can ve fetched from knvk eg: tel no if reqd
      " Similarly for email addresses
      IF sy-subrc = 0.
        CONCATENATE wa_knvk-contpersf wa_knvk-contpersl INTO wa_generaldetail-contpers SEPARATED BY space.
      ENDIF.

      READ TABLE it_adr6 INTO wa_adr6 WITH KEY addrnumber = wa_lfa1-adrnr.
      IF sy-subrc = 0.
        wa_generaldetail-email = wa_adr6-email.
      ENDIF.
      APPEND wa_generaldetail TO it_generaldetail.
      CLEAR: wa_generaldetail, wa_knvk, wa_adr6.

***  Build Excise details ***
      READ TABLE it_j_1imovend INTO wa_j_1imovend WITH KEY vend = wa_lfa1-vend.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING wa_j_1imovend TO wa_excisedetail.
        APPEND wa_excisedetail TO it_excisedetail.
      ENDIF.
      CLEAR: wa_excisedetail, wa_j_1imovend.

***  Build Bank details ***
      LOOP AT it_lfbk INTO wa_lfbk WHERE vend = wa_lfa1-vend.
        MOVE-CORRESPONDING wa_lfbk TO wa_bankdetail.
        READ TABLE it_bnka INTO wa_bnka WITH KEY bifsc = wa_lfbk-bifsc.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING wa_bnka TO wa_bankdetail.
        ENDIF.
        APPEND wa_bankdetail TO it_bankdetail.
        CLEAR: wa_bankdetail, wa_bnka, wa_lfbk.
      ENDLOOP.

      LOOP AT it_lfb1 INTO wa_lfb1 WHERE vend = wa_lfa1-vend.
        MOVE-CORRESPONDING wa_lfb1 TO wa_compdetail.
        APPEND wa_compdetail TO it_compdetail.
        CLEAR: wa_lfb1, wa_compdetail.
      ENDLOOP.
      CLEAR: wa_lfa1.
    ENDLOOP.

    SORT it_generaldetail[] BY vend.
    SORT it_excisedetail[] BY vend.
    SORT it_bankdetail[] BY vend.
    SORT it_compdetail[] BY vend compc.
    t_gendet[]  = it_generaldetail[].
    t_excdet[]  = it_excisedetail[].
    t_bankdet[] = it_bankdetail[].
    t_compdet[] = it_compdetail[].

*** Build final vendor details table ***
***  Add gen and excise details to final vendor details 1:1(vendor : gen/excise) ***
    LOOP AT it_generaldetail INTO wa_generaldetail.
      MOVE-CORRESPONDING wa_generaldetail TO wa_venddetail_temp.

      READ TABLE it_excisedetail INTO wa_excisedetail WITH KEY vend = wa_generaldetail-vend.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING wa_excisedetail TO wa_venddetail_temp.
      ENDIF.

      APPEND wa_venddetail_temp TO it_venddetail_temp.
      CLEAR: wa_generaldetail, wa_excisedetail, wa_venddetail_temp.
    ENDLOOP.

***  Add bank details to final vendor details 1:n(vendor : bank) ***
    LOOP AT it_bankdetail INTO wa_bankdetail.                                             " N
      " :
      LOOP AT it_venddetail_temp INTO wa_venddetail_temp WHERE vend = wa_bankdetail-vend. " 1
        MOVE-CORRESPONDING wa_bankdetail TO wa_venddetail_temp.
        MOVE-CORRESPONDING wa_venddetail_temp TO wa_venddetail.
        APPEND wa_venddetail TO it_venddetail.  " at the end of this loop venddetail will have only vendors with bank
        CLEAR : wa_venddetail_temp.             " venddetails_temp has all vendors minus repeat for bank
      ENDLOOP.
      CLEAR: wa_bankdetail.
    ENDLOOP.

    LOOP AT it_venddetail_temp INTO wa_venddetail_temp.
      " delete from venddetails_temp vendors that are present in venddetails to avoid repeat
      READ TABLE it_venddetail INTO wa_venddetail WITH KEY vend = wa_venddetail_temp-vend.
      IF sy-subrc = 0.
        DELETE it_venddetail_temp.
      ENDIF.
      CLEAR: wa_venddetail_temp.
    ENDLOOP.
*   At the end of this loop venddetails_temp and venddetails will be disjoint sets/ no repeatition

*   We join them here
    APPEND LINES OF it_venddetail_temp[] TO it_venddetail[].

    SORT it_venddetail[] BY vend.

    t_venddet[] = it_venddetail[].
  ELSE.
    wa_return-type = 'E'.
    wa_return-id = 'ZVENBAP'.
    wa_return-number = 001.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = wa_return-type
        cl     = wa_return-id
        number = wa_return-number
      IMPORTING
        return = wa_return.
    APPEND wa_return TO return.
    CLEAR wa_return.
    EXIT.
  ENDIF.

ENDFUNCTION.
