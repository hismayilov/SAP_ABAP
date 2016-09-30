" Tcode : ZCDNOTE
" Form Name: ZSF_SOL_CRDT_DBT_MEMO

"""added by Harsh Ariwala on 21.01.2016 start
SELECT knumv kposn kschl kbetr kwert
INTO TABLE it_konv1
FROM konv
WHERE knumv = wa_header-knumv
   AND ( kschl = 'RA00' OR kschl = 'RB00' OR kschl = 'RC00' )
   %_HINTS SYBASE 'INDEX("KONV" "KONV~ZI1")'.
   
" Suggested Addition of brackets around the OR conditions which sped up the print preview.
