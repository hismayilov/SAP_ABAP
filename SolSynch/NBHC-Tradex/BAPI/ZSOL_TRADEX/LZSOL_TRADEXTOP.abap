FUNCTION-POOL zsol_tradex.                  "MESSAGE-ID ..

* ---- Types ---- *
TYPES: BEGIN OF ty_specs.
INCLUDE     STRUCTURE ztb_trd_specs.
TYPES:  act_val TYPE p LENGTH 7,
       END OF ty_specs.

* ---- Variables ---- *
DATA: v_obj    TYPE inob-objek,
      wa_inob  TYPE inob,
      wa_klah  TYPE klah,
      wa_kssk  TYPE kssk,
      v_clnum  TYPE bapi1003_key-classnum,
      v_cltype TYPE bapi1003_key-classtype,
      v_objtab TYPE bapi1003_key-objecttable,
      msg      TYPE bapi_msg,
      type     TYPE symsgty,
      v_status TYPE char1,
      v_check  TYPE char1,
      v_accept TYPE char1.

* ---- Tables ---- *
DATA: oldvaluesnum  TYPE zsol_tty_allocvaluesnum  WITH HEADER LINE,
      oldvalueschar TYPE zsol_tty_allocvalueschar WITH HEADER LINE,
      oldvaluescurr TYPE zsol_tty_allocvaluescurr WITH HEADER LINE,
      return_tab    TYPE bapiret2_t,
      it_mska       TYPE TABLE OF mska,
      it_specs      TYPE TABLE OF ty_specs,
      it_vbap       TYPE TABLE OF vbap.

* ---- Work Areas ---- *
DATA: wa_valuesnum  LIKE bapi1003_alloc_values_num,
      wa_valueschar LIKE bapi1003_alloc_values_char,
      wa_valuescurr LIKE bapi1003_alloc_values_curr,
      wa_return     LIKE bapiret2,
      wa_mska       TYPE mska,
      wa_specs      TYPE ty_specs,
      wa_vbap       TYPE vbap.

* ---- Goods Movement Related ---- *
DATA: wa_head TYPE bapi2017_gm_head_01,
      gm_code TYPE bapi2017_gm_code VALUE '04',
      it_item TYPE TABLE OF bapi2017_gm_item_create,
      wa_item TYPE bapi2017_gm_item_create,
      mat_doc    TYPE bapi2017_gm_head_ret-mat_doc,
      doc_year   TYPE bapi2017_gm_head_ret-doc_year.
