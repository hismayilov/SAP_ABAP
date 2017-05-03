FUNCTION zsol_material_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      T_HEADDATA TYPE  ZSOL_TT_HEADDATA
*"      T_CLIENTDATA TYPE  ZSOL_TT_CLIENTDATA
*"      T_CLIENTDATAX TYPE  ZSOL_TT_CLIENTDATAX
*"      T_PLANTDATA TYPE  ZSOL_TT_PLANTDATA
*"      T_PLANTDATAX TYPE  ZSOL_TT_PLANTDATAX
*"      T_STORAGELOCATIONDATA TYPE  ZSOL_TT_STORAGELOCATIONDATA
*"      T_STORAGELOCATIONDATAX TYPE  ZSOL_TT_STORAGELOCATIONDATAX
*"      T_VALUATIONDATA TYPE  ZSOL_TT_VALUATIONDATA
*"      T_VALUATIONDATAX TYPE  ZSOL_TT_VALUATIONDATAX
*"      T_SALESDATA TYPE  ZSOL_TT_SALESDATA
*"      T_SALESDATAX TYPE  ZSOL_TT_SALESDATAX
*"      T_MATERIALDESCRIPTIONS TYPE  ZSOL_TT_MATERIALDESCRIPTIONS
*"      T_TAXCLASSIFICATIONS TYPE  ZSOL_TT_TAXCLASSIFICATIONS
*"----------------------------------------------------------------------

  DATA: headdata       LIKE bapimathead,
        clientdata     LIKE bapi_mara,
        clientdatax    LIKE bapi_marax,
        plantdata      LIKE bapi_marc,
        plantdatax     LIKE bapi_marcx,
        STORAGELOCATIONDATA like bapi_mard,
        STORAGELOCATIONDATAX like bapi_mardx,
        valuationdata  LIKE bapi_mbew,
        valuationdatax LIKE bapi_mbewx,
        salesdata      LIKE bapi_mvke,
        salesdatax     LIKE bapi_mvkex.

  DATA: materialdescriptions TYPE TABLE OF bapi_makt        WITH HEADER LINE,
        taxclassifications   TYPE TABLE OF bapi_mlan        WITH HEADER LINE,
        returnmessages       TYPE TABLE OF bapi_matreturn2  WITH HEADER LINE,
        return               TYPE TABLE OF bapiret2         WITH HEADER LINE,
        log                  TYPE TABLE OF bapi_matreturn2  WITH HEADER LINE.

  DATA: wa_headdata             LIKE LINE OF t_headdata,
        wa_clientdata           LIKE LINE OF t_clientdata,
        wa_clientdatax          LIKE LINE OF t_clientdatax,
        wa_plantdata            LIKE LINE OF t_plantdata,
        wa_plantdatax           LIKE LINE OF t_plantdatax,
        wa_STORAGELOCATIONDATA  LIKE LINE OF t_STORAGELOCATIONDATA,
        wa_STORAGELOCATIONDATAX LIKE LINE OF t_STORAGELOCATIONDATAX,
        wa_valuationdata        LIKE LINE OF t_valuationdata,
        wa_valuationdatax       LIKE LINE OF t_valuationdatax,
        wa_salesdata            LIKE LINE OF t_salesdata,
        wa_salesdatax           LIKE LINE OF t_salesdatax,
        wa_materialdescriptions LIKE LINE OF t_materialdescriptions,
        wa_taxclassifications   LIKE LINE OF t_taxclassifications.

  DATA: flag         TYPE flag,
        file(128)    TYPE c VALUE '/usr/sap/tmp/mat_log',
        wa_file(256) TYPE c,
        date(10)     TYPE c,
        time(8)      TYPE c.

  LOOP AT t_headdata INTO wa_headdata.
* ---- Build headdata ---- *
    MOVE-CORRESPONDING wa_headdata TO headdata.

* ---- Build clientdata/x ---- *
    READ TABLE t_clientdata INTO wa_clientdata WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_clientdata TO clientdata.
    ENDIF.

    READ TABLE t_clientdatax INTO wa_clientdatax WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_clientdatax TO clientdatax.
    ENDIF.

* ---- Build plantdata/x ---- *
    READ TABLE t_plantdata INTO wa_plantdata WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_plantdata TO plantdata.
    ENDIF.

    READ TABLE t_plantdatax INTO wa_plantdatax WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_plantdatax TO plantdatax.
    ENDIF.

     READ TABLE t_STORAGELOCATIONDATA INTO wa_STORAGELOCATIONDATA WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_STORAGELOCATIONDATA TO STORAGELOCATIONDATA.
    ENDIF.

    READ TABLE t_STORAGELOCATIONDATAX INTO wa_STORAGELOCATIONDATAX WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_STORAGELOCATIONDATAX TO STORAGELOCATIONDATAX.
    ENDIF.

* ---- Build valuationdata/x ---- *
    READ TABLE t_valuationdata INTO wa_valuationdata WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_valuationdata TO valuationdata.
    ENDIF.

    READ TABLE t_valuationdatax INTO wa_valuationdatax WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_valuationdatax TO valuationdatax.
    ENDIF.
* ---- Build salesdata/x ---- *
    READ TABLE t_salesdata INTO wa_salesdata WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_salesdata TO salesdata.
    ENDIF.

    READ TABLE t_salesdatax INTO wa_salesdatax WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_salesdatax TO salesdatax.
    ENDIF.

* ---- Build materialdescription table ---- *
    READ TABLE t_materialdescriptions INTO wa_materialdescriptions WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_materialdescriptions TO materialdescriptions.
      APPEND materialdescriptions.
    ENDIF.

* ---- Build taxclassifications table ---- *
    READ TABLE t_taxclassifications INTO wa_taxclassifications WITH KEY num = wa_headdata-num.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_taxclassifications TO taxclassifications.
      APPEND taxclassifications.
    ENDIF.

    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata            = headdata
        clientdata          = clientdata
        clientdatax         = clientdatax
        plantdata           = plantdata
        plantdatax          = plantdatax
*       FORECASTPARAMETERS  =
*       FORECASTPARAMETERSX =
*       PLANNINGDATA        =
*       PLANNINGDATAX       =
       STORAGELOCATIONDATA  = STORAGELOCATIONDATA
       STORAGELOCATIONDATAX = STORAGELOCATIONDATAX
        valuationdata       = valuationdata
        valuationdatax      = valuationdatax
*       WAREHOUSENUMBERDATA =
*       WAREHOUSENUMBERDATAX =
        salesdata           = salesdata
        salesdatax          = salesdatax
*       STORAGETYPEDATA     =
*       STORAGETYPEDATAX    =
*       FLAG_ONLINE         = ' '
*       FLAG_CAD_CALL       = ' '
*       NO_DEQUEUE          = ' '
*       NO_ROLLBACK_WORK    = ' '
*       CLIENTDATACWM       =
*       CLIENTDATACWMX      =
*       VALUATIONDATACWM    =
*       VALUATIONDATACWMX   =
      IMPORTING
        return              = return
      TABLES
        materialdescription = materialdescriptions
*       UNITSOFMEASURE      =
*       UNITSOFMEASUREX     =
*       INTERNATIONALARTNOS =
*       MATERIALLONGTEXT    =
        taxclassifications  = taxclassifications
        returnmessages      = returnmessages
*       PRTDATA             =
*       PRTDATAX            =
*       EXTENSIONIN         =
*       EXTENSIONINX        =
*       UNITSOFMEASURECWM   =
*       UNITSOFMEASURECWMX  =
*       NFMCHARGEWEIGHTS    =
*       NFMCHARGEWEIGHTSX   =
*       NFMSTRUCTURALWEIGHTS        =
*       NFMSTRUCTURALWEIGHTSX       =
      .
    APPEND LINES OF returnmessages[] TO log[].
    APPEND INITIAL LINE TO log[].
    READ TABLE returnmessages WITH KEY type = 'E' TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      READ TABLE returnmessages WITH KEY type   = 'S'
                                         number = '800' TRANSPORTING message.
      IF sy-subrc = 0.
        flag = 'X'.
      ENDIF.
    ELSE.
      READ TABLE returnmessages WITH KEY type = 'E' TRANSPORTING message.
      IF sy-subrc = 0.
        CLEAR flag.
      ENDIF.
    ENDIF.

    UPDATE zsol_mmcreate SET   std_pr_val  = valuationdata-std_price
                               mat_created = flag
                               log         = returnmessages-message
                         WHERE matnr       = headdata-material_long.

    CLEAR: wa_headdata,
           headdata,
           wa_clientdata,
           clientdata,
           wa_clientdatax,
           clientdatax,
           wa_plantdata,
           plantdata,
           wa_plantdatax,
           plantdatax,
           wa_valuationdata,
           valuationdata,
           wa_valuationdatax,
           valuationdatax,
           wa_STORAGELOCATIONDATA,
           STORAGELOCATIONDATA,
           wa_STORAGELOCATIONDATAX,
           STORAGELOCATIONDATAX,
           wa_salesdata,
           salesdata,
           wa_salesdatax,
           salesdatax,
           wa_materialdescriptions,
           materialdescriptions,
           wa_taxclassifications,
           taxclassifications,
           returnmessages,
           return.
    REFRESH: return[], returnmessages[], materialdescriptions[], taxclassifications[].
  ENDLOOP.

  COMMIT WORK.

  IF log[] IS NOT INITIAL.
* ---- Add log to file on app server ---- *
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = sy-datum
      IMPORTING
        date_external            = date
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    WRITE sy-uzeit TO time USING EDIT MASK '__:__:__'.
    CONCATENATE file '_' date '_' time '.txt' INTO file.
    OPEN DATASET file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    CONCATENATE 'T' 'ID' 'No.' 'Message' INTO wa_file SEPARATED BY '|'.
    TRANSFER wa_file TO file.
    CLEAR wa_file.
    WRITE sy-uline TO wa_file.
    TRANSFER wa_file TO file.
    CLEAR wa_file.
    LOOP AT log.
      IF log IS INITIAL.
        WRITE sy-uline TO wa_file.
        TRANSFER wa_file TO file.
      ELSE.
        CONCATENATE log-type log-id log-number log-message
        INTO wa_file SEPARATED BY '|'.
        TRANSFER wa_file TO file.
      ENDIF.
      CLEAR: log, wa_file.
    ENDLOOP.

    CLOSE DATASET file.
  ENDIF.
ENDFUNCTION.
