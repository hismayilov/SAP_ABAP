*&---------------------------------------------------------------------*
*& Report  ZSK_DEMO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZSK_EMPTY_FOR_ALL_ENTRIES.

TABLES: MARA, MAKT.

TYPES: BEGIN OF TY_MARA,
        MATNR TYPE MARA-MATNR,
        MTART TYPE MARA-MTART,
        MBRSH TYPE MARA-MBRSH,
        MATKL TYPE MARA-MATKL,
      END OF TY_MARA,

      BEGIN OF TY_MAKT,
        MATNR TYPE MAKT-MATNR,
        SPRAS TYPE MAKT-SPRAS,
        MAKTX TYPE MAKT-MAKTX,
      END OF TY_MAKT.

DATA: IT_MARA TYPE TABLE OF TY_MARA,
      WA_MARA TYPE TY_MARA,
      IT_MAKT TYPE TABLE OF TY_MAKT,
      WA_MAKT TYPE TY_MAKT.

START-OF-SELECTION.
  SELECT MATNR
         MTART
         MBRSH
         MATKL
         FROM MARA INTO TABLE IT_MARA WHERE MATNR = 'Something_that_doesn't_exist'.

    SELECT MATNR
           SPRAS
           MAKTX
           FROM MAKT INTO TABLE IT_MAKT FOR ALL ENTRIES IN IT_MARA WHERE MATNR = IT_MARA-MATNR.

  IF IT_MARA IS INITIAL.
    WRITE: 'MARA IS EMPTY'.
  ENDIF.

  IF IT_MAKT IS NOT INITIAL.
    WRITE: 'BUT MAKT HAS DATA.'.
  ENDIF.
