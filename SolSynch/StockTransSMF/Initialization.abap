
DATA: lv_meinh  TYPE lrmei. " To be used in Unit/Qty Conversion
DATA: count TYPE i. " Serial Number

count = 1.

" Get Doc Data from MSEG for given mat doc no
SELECT mblnr
       lgort
       umlgo
       matnr
       menge
       meins
       rsnum
       FROM mseg
       INTO TABLE it_mseg
       WHERE mblnr = v_mat_doc_no " user input
         AND bwart = '311'        " hard coded mvt type
         AND xauto <> 'X'.        " exclude auto generated duplicated rows

" Get values for header data
READ TABLE it_mseg
INTO wa_mseg
INDEX 1.                  " Same data in all rows, so pick one
v_lgort = wa_mseg-lgort.  " From stor loc
v_umlgo = wa_mseg-umlgo.  " To stor loc
v_rsnum = wa_mseg-rsnum.  " Res Num


IF it_mseg IS NOT INITIAL.

  " Get Doc Header data from MKPF
  SELECT mblnr
         budat
         cputm
         FROM mkpf
         INTO TABLE it_mkpf
         FOR ALL ENTRIES IN it_mseg
         WHERE mblnr = it_mseg-mblnr.

  " Get values for header data
  READ TABLE it_mkpf
  INTO wa_mkpf
  INDEX 1.
  v_budat = wa_mkpf-budat.  " Post Date
  v_cputm = wa_mkpf-cputm.  " Post Time

  " Get Desc for each mat in mseg from makt
  SELECT matnr
         maktx
         FROM makt
         INTO TABLE it_makt
         FOR ALL ENTRIES IN it_mseg
         WHERE matnr = it_mseg-matnr.

  " Delete duplicate mat rows from makt
  DELETE ADJACENT DUPLICATES FROM it_makt
  COMPARING ALL FIELDS.

  " Build it_final
  LOOP AT it_mseg
    INTO wa_mseg.

    CLEAR wa_final.

    wa_final-mblnr = wa_mseg-mblnr.
    wa_final-matnr = wa_mseg-matnr.
    wa_final-lgort = wa_mseg-lgort.
    wa_final-umlgo = wa_mseg-umlgo.
    wa_final-count = count.
    wa_final-menge = wa_mseg-menge.
    wa_final-meins = wa_mseg-meins.

    " Get header data from mkpf for current mblnr(doc)
    READ TABLE it_mkpf
    INTO wa_mkpf
    WITH KEY mblnr = wa_final-mblnr.

    wa_final-budat = wa_mkpf-budat.
    wa_final-cputm = wa_mkpf-cputm.

    " Get Alt units for current mat and perform conversion for alt qty
    " PC or ST to KG
    IF wa_final-meins = 'PC' OR wa_final-meins = 'ST'.

      lv_meinh  = 'KG'.

      PERFORM conversion  " Convert Qty to Alt Qty
        USING wa_final-matnr wa_final-meins lv_meinh wa_final-menge
        CHANGING wa_final-alqty.

      " KG or G to ST
    ELSEIF wa_final-meins = 'KG' OR wa_final-meins = 'G'.

      lv_meinh  = 'ST'.

      PERFORM conversion  " Convert Qty to Alt Qty
        USING wa_final-matnr wa_final-meins lv_meinh wa_final-menge
        CHANGING wa_final-alqty.

    ENDIF.

    " Alt unit from marm picked above inside loop
    wa_final-meinh = lv_meinh.

    " Display Base UoM and Base Qty in Alt if no suitable conversion found for Alt
    IF wa_final-alqty IS INITIAL
    AND wa_final-meinh IS INITIAL.

      wa_final-alqty = wa_final-menge.
      wa_final-meinh = wa_final-meins.

    ENDIF.

    " Get desc for current mat
    READ TABLE it_makt
    INTO wa_makt
    WITH KEY matnr = wa_final-matnr.

    wa_final-maktx = wa_makt-maktx.

    APPEND wa_final TO it_final.

    count = count + 1.
  ENDLOOP.

ENDIF.
