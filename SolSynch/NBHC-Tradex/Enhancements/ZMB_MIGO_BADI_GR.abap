METHOD if_ex_mb_migo_badi~pai_header.

  DATA: delnote TYPE gohead-lfsnr.
  delnote = is_gohead-lfsnr.
  EXPORT delnote FROM delnote TO MEMORY ID 'DELNOTE'.

ENDMETHOD.

METHOD if_ex_mb_migo_badi~line_modify.

  DATA: delnote TYPE lfsnr1.
  IMPORT delnote TO delnote FROM MEMORY ID 'DELNOTE'.
  cs_goitem-charg = delnote.

ENDMETHOD.
