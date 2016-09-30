TYPES: BEGIN OF TY_MSEG,
         MBLNR TYPE MBLNR,    " Mat Doc No
         LGORT TYPE LGORT_D,  " From Stor Loc
         UMLGO TYPE UMLGO,    " To Stor Loc
         MATNR TYPE MATNR,    " Mat No
         MENGE TYPE MENGE_D,  " Qty
         MEINS TYPE MEINS,    " Base UoM
         RSNUM TYPE RSNUM,    " Res Num
       END OF TY_MSEG,

       BEGIN OF TY_MKPF,
         MBLNR TYPE MBLNR,    "
         BUDAT TYPE BUDAT,    " Post Date
         CPUTM TYPE CPUTM,    " Post Time
       END OF TY_MKPF,

       BEGIN OF TY_MAKT,
         MATNR TYPE MATNR,    "
         MAKTX TYPE MAKTX,    " Mat Description
       END OF TY_MAKT,

       BEGIN OF TY_FINAL,
         MBLNR TYPE MBLNR,    "
         LGORT TYPE LGORT_D,  "
         UMLGO TYPE UMLGO,    "
         COUNT TYPE I,        " Serial Number
         MATNR TYPE MATNR,    "
         MENGE TYPE MENGE_D,  "
         MEINS TYPE MEINS,    "
         ALQTY TYPE MENGE_D,  " Alt Qty after conversion
         MEINH TYPE LRMEI,    "
         BUDAT TYPE BUDAT,    "
         CPUTM TYPE CPUTM,    "
         MAKTX TYPE MAKTX,    "
       END OF TY_FINAL.
