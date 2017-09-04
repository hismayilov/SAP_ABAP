*&---------------------------------------------------------------------*
*& Report  Z6SD002R_COND_TYPE_DET
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  z6sd002r_cond_type_det.

*&********************************************************************&*
*& Object Id       : <REPS>                                           &*
*& Object Name     : ZRPT_SD_006                                      &*
*& Trasaction Code : YF02                                             &*
*& Func Consultant : Kazi                                             &*
*& Author          : K.R.K.Chaitanya                                  &*
*& Module Name     : S.D       Sub-Module     : Billing               &*
*& Program Type    : Reports   Create Date    : Sept 13,2002          &*
*& SAP Release     : 4.6c      Transport No   : DEVK900469            &*
*& Description     : Condition Types                                  &*
*&                                                                    &*
*&                                                                    &*
*&                                                                    &*
*--------------------------CHANGE HISTORY------------------------------*
*  USER NAME  |  CHANGED DATE  |        CHANGE DESCRIPTION             *
*  Anees      |  1/19/2010     | Added logic for Exc. inv.no fetch     |
*  pradeep K  |  01/05/2015    | Added sales  inv ref no               |
*&--------------------------------------------------------------------&*
* REVISION HISTORY-----------------------------------------------------*
*
*        REVISION NO:
*        DEVELOPER:   Naren Karra          DATE:   07.10.2015, 19.10.2015
*        DESCRIPTION: New Authorization added for SD
*----------------------------------------------------------------------*
* REVISION HISTORY-----------------------------------------------------*
*
*        REVISION NO:
*        DEVELOPER:   Naren Karra             DATE:   20.10.2015
*        DESCRIPTION: FI: Authorization code snippet modified
*----------------------------------------------------------------------*
* REVISION HISTORY-----------------------------------------------------*
*
*        REVISION NO:
*        DEVELOPER:   Naren Karra             DATE:   04.11.2015
*        DESCRIPTION: SD: Authorization code commented for REGIO & VKGRP
*        REQUEST :    IRDK921485
*----------------------------------------------------------------------*
* REVISION HISTORY-----------------------------------------------------*
*
*        REVISION NO:
*        DEVELOPER:   Naren Karra             DATE:   23.12.2015
*        DESCRIPTION: SD: Auth. Check for KTGRD
*        REQUEST :    IRDK921983
*----------------------------------------------------------------------*
* REVISION HISTORY-----------------------------------------------------*
*
*        REVISION NO:
*        DEVELOPER:   Naren Karra             DATE:   23.12.2015
*        DESCRIPTION: SD: Auth. Check for KTGRD for SPART = 10
*        REQUEST :    IRDK921991
*----------------------------------------------------------------------*
* REVISION HISTORY-----------------------------------------------------*
*
*        REVISION NO:
*        DEVELOPER:   Naren Karra             DATE:   27.07.2016
*        DESCRIPTION: SD:Appending a blank value in KTGRD for SPART = 40
*        REQUEST :    IRDK924649
*----------------------------------------------------------------------*
* REVISION HISTORY-----------------------------------------------------*
*
*        REVISION NO:
*        DEVELOPER:   Naren Karra             DATE:   14.03.2017
*        DESCRIPTION: SD: Issue in decimals points for EUR4
*        REQUEST :  IRDK927197
*----------------------------------------------------------------------*
************************************************************************
*                           TABLES
************************************************************************
TABLES:vbrk,
       vbrp,
       konv,
       t685t,
       tvfkt,
       cabnt,
       vbak,
       vbap,
       vbfa,
       t171t,
       tvzbt.
************************************************************************
*                           GLOBAL DATA DECLARATION
************************************************************************
TYPE-POOLS : slis.
DATA : vkorg      LIKE vbrk-vkorg,
       due_days   LIKE t052-ztag1,
       bezei      LIKE tvkbt-bezei,
       h_text(18),
       test(6),
       flag       TYPE i,
       p          TYPE i,
       text(30)   TYPE  c,
       butxt      LIKE t001-butxt,
       traid      LIKE likp-traid,
       lifnr      LIKE lfa1-lifnr,
       d_date     LIKE vbrk-fkdat,
       bstkd      LIKE vbkd-bstkd,
       bstdk(10),
       kunrg      LIKE kna1-kunnr,
       name1      LIKE kna1-name1,
       option(10)           ,
       v_tabix    LIKE sy-tabix,
       name2      LIKE kna1-name1,
       bzirk      LIKE vbrk-bzirk,
       ktext      LIKE t151t-ktext,
       frate      LIKE konv-kbetr,
       erate      LIKE konv-kbetr,
       evalue     LIKE konv-kwert,
       fvalue     LIKE konv-kwert,
       bismt      TYPE mara-bismt,
       extwg      TYPE extwg,
       ewbez      TYPE ewbez,
       pckg(4)    TYPE c,
       bwrks(4)   TYPE c,
       exnum      LIKE j_1iexchdr-exnum,
       exdat      LIKE j_1iexchdr-exdat,

       tname      LIKE lfa1-name1,
       vtext      LIKE tvtwt-vtext,
       konda1     LIKE vbkd-konda,
       vtext1     LIKE t188t-vtext,
       gv_text    LIKE t188t-vtext,
       bztxt      LIKE t171t-bztxt.

*      VKGRP LIKE TVKGRT-VKGRP,
*      VBEZEI LIKE TVKBT-BEZEI,

***********************************************************************
*                           INTERNAL TABLE DECLARATION
************************************************************************
DATA  : BEGIN OF iitem OCCURS 1,
          kunnr  LIKE kna1-kunnr,
          name1  LIKE kna1-name1,
          " gstn_no/stcd3 required?
          matnr  LIKE vbrp-matnr,
          arktx  LIKE vbrp-arktx,
          konda1 LIKE vbkd-konda,
          vtext1 LIKE t188t-vtext,
        END OF iitem.
DATA  : BEGIN OF t_konv OCCURS 0,
          knumv LIKE konv-knumv,
          kposn LIKE konv-kposn,
          krech LIKE konv-krech,
          kwert LIKE konv-kwert,
          kbetr LIKE konv-kbetr,
          kawrt LIKE konv-kawrt,
          kschl LIKE konv-kschl,
        END OF t_konv.

DATA : BEGIN OF tlines OCCURS 5.
        INCLUDE STRUCTURE tline .
DATA : END OF tlines.
*
*DATA: BEGIN OF itabxt,           " structure for getting sales text
*         matnr LIKE vbdpr-matnr,
*         vkorg LIKE vbdkr-vkorg,
*         vtweg LIKE vbdkr-vtweg,
*      END OF itabxt.
*The Below Declaration is for converting to alv.
DATA:keyinfo  TYPE slis_keyinfo_alv.
DATA:keyinfo1  TYPE slis_keyinfo_alv.
DATA: gruppen TYPE slis_t_sp_group_alv WITH HEADER LINE.
DATA:xt         LIKE stxh-tdname,
     sales_text LIKE makt-maktx.
DATA: BEGIN OF header OCCURS 0 ,
        fkart  LIKE vbrk-fkart,
        vtweg  LIKE vbrk-vtweg,
        vbeln  LIKE vbrk-vbeln,
        fkdat  LIKE vbrk-fkdat,
        vtext  LIKE tvfkt-vtext,
        vtext1 LIKE tvtwt-vtext,
      END OF header.
DATA: BEGIN OF kheader OCCURS 0 ,
        kunnr LIKE vbrk-kunrg,
        name1 LIKE kna1-name1,
*      VBELN LIKE VBRK-VBELN,
*      FKDAT LIKE VBRK-FKDAT,
*      VTEXT LIKE TVFKT-VTEXT,
*      VTEXT1 LIKE TVTWT-VTEXT,
      END OF kheader.

DATA: len LIKE sy-tabix.

DATA: BEGIN OF ivbrp OCCURS 1.
        INCLUDE STRUCTURE z6sdd_vbrk_vbrp.
*      charg like vbrp-charg,
DATA: k1   LIKE konv-kwert,
      k1d  LIKE t685t-vtext,
      k2   LIKE konv-kwert,
      k2d  LIKE t685t-vtext,
      k3   LIKE konv-kwert,
      k3d  LIKE t685t-vtext,
      k4   LIKE konv-kwert,
      k4d  LIKE t685t-vtext,
      k5   LIKE konv-kwert,
      k5d  LIKE t685t-vtext,
      k6   LIKE konv-kwert,
      k6d  LIKE t685t-vtext,
      k7   LIKE konv-kwert,
      k7d  LIKE t685t-vtext,
      k8   LIKE konv-kwert,
      k8d  LIKE t685t-vtext,
      k9   LIKE konv-kwert,
      k9d  LIKE t685t-vtext,
      k10  LIKE konv-kwert,
      k10d LIKE t685t-vtext,
      k11  LIKE konv-kwert,
      k11d LIKE t685t-vtext,
      k12  LIKE konv-kwert,
      k12d LIKE t685t-vtext.
DATA: END OF ivbrp.

DATA: BEGIN OF tab_stxh OCCURS 0.
        INCLUDE STRUCTURE stxh.
DATA: END OF tab_stxh.

DATA BEGIN OF lv_vehicle OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA END OF lv_vehicle.

DATA: l_name TYPE tdobname."TR


DATA: BEGIN OF ivbrp1 OCCURS 1.
        INCLUDE STRUCTURE z6sdd_vbrk_vbrp.
DATA: traid          LIKE likp-traid,
      lifnr          LIKE lfa1-lifnr,
      d_date         LIKE vbrk-fkdat,
      bstkd          LIKE vbkd-bstkd,
      bstdk(10)," LIKE VBKD-BSTDK,
      vfdat          TYPE mch1-vfdat,
      bismt          TYPE mara-bismt,
      pckg(4)        TYPE c,
      bplnt          TYPE werks_d,
      phtxt          TYPE bezei40,
      srtxt          TYPE bezei20,
      wgbez          TYPE wgbez,
      gr1tx          TYPE bezei40,
      gr2tx          TYPE bezei40,
      gr3tx          TYPE bezei40,
      gr4tx          TYPE bezei40,
      gr5tx          TYPE bezei40,
      kwmeng         TYPE kwmeng,
      rfmng          TYPE rfmng,
      balance        TYPE kwmeng,
      delay          TYPE i,
      month          TYPE t247-ltx,
      extwg          TYPE extwg,
      ewbez          TYPE ewbez,
*      kunnr LIKE kna1-kunnr,
      ship_party     TYPE likp-kunnr,
      party_name     TYPE kna1-name1,
      shp_contry     TYPE kna1-land1,
      shp_ctry_name  TYPE t005t-landx,
      bill_contry    TYPE kna1-land1,
      bill_ctry_name TYPE t005t-landx,
      gstn_no        TYPE kna1-stcd3,         " GSTN NO, Added by SaurabhK on Monday, August 07, 2017 12:51:53
      hsn_no         TYPE marc-steuc,         " HSN Code of material => SaurabhK
      hsn_text       TYPE t604n-text1,        " Descr of HSN Code    => SaurabhK
      vtext          LIKE tvtwt-vtext,
      bztxt          LIKE t171t-bztxt,
      k1             LIKE konv-kwert,
      k1r(13),
      k1d            LIKE t685t-vtext,
      k2             LIKE konv-kwert,
      k2r(13),
      k2d            LIKE t685t-vtext,
      k3             LIKE konv-kwert,
      k3r(13),
      k3d            LIKE t685t-vtext,
      k4             LIKE konv-kwert,
      k4r(13),
      k4d            LIKE t685t-vtext,
      k5             LIKE konv-kwert,
      k5r(13),
      k5d            LIKE t685t-vtext,
      k6             LIKE konv-kwert,
      k6r(13),
      k6d            LIKE t685t-vtext,
      k7             LIKE konv-kwert,
      k7r(13),
      k7d            LIKE t685t-vtext,
      k8             LIKE konv-kwert,
      k8r(13),
      k8d            LIKE t685t-vtext,
      k9             LIKE konv-kwert,
      k9r(13),
      k9d            LIKE t685t-vtext,
      k10            LIKE konv-kwert,
      k10r(13),
      k10d           LIKE t685t-vtext,

      k11            LIKE konv-kwert,
      k11r(13),
      k11d           LIKE t685t-vtext,
      k12            LIKE konv-kwert,
      k12r(13),
      k12d           LIKE t685t-vtext,
      tot_amt        LIKE vbrp-netwr,
      ktext          LIKE t151t-ktext,
      char1          LIKE  ausp-atwrt ,                 " Characteristic
      char2          LIKE  ausp-atwrt ,                 " Characteristic
      char3          LIKE  ausp-atwrt ,                 " Characteristic
      char4          LIKE  ausp-atwrt ,                 " Characteristic
      char5          LIKE  ausp-atwrt ,                 " Characteristic
      char6          LIKE  ausp-atwrt ,                 " Characteristic
      char7          LIKE  ausp-atwrt ,                 " Characteristic
      char8          LIKE  ausp-atwrt ,                 " Characteristic
      char9          LIKE  ausp-atwrt ,                 " Characteristic
      char10         LIKE ausp-atwrt ,              " Characteristic
      frate          LIKE konv-kbetr,
      erate          LIKE konv-kbetr,
      evalue         LIKE konv-kwert,
      fvalue         LIKE konv-kwert,

      exnum          LIKE j_1iexchdr-exnum,
      exdat          LIKE j_1iexchdr-exdat,
      adrnr          TYPE kna1-adrnr , """added by sachin
      tname          LIKE lfa1-name1,
      bezei          LIKE tvkbt-bezei,
      l_bezei        LIKE tvgrt-bezei,
      auart          LIKE vbak-auart,
      fr_agt         LIKE vbpa-lifnr,
      forw_name      LIKE lfa1-name1,
      lr_no(15)," LIKE LIKP-XABLN,
      vehicle        TYPE tline-tdline,
      frc1_kwert     TYPE konv-kwert, "FRC1 PO CONDITION ADDED BY PUNAM
      city           TYPE adrc-city1,     "city added by sachin 08-082014.
      frc1_kbetr     TYPE konv-kbetr, "FRC1 PO CONDITION RATE
      vtext1         TYPE t188t-vtext,
      konda1         TYPE vbkd-konda , """added code by sachin
      ref_no         TYPE vbfa-vbeln,                                                 " REF NUMBER - ADDED BY PRADEEP KODINAGULA, 05/01/2015
      ref_date       TYPE vbrk-fkdat,
      zstceg         TYPE kna1-stceg,
      spart_txt      TYPE tspat-vtext,
      zland1         TYPE vbap-zland1,
      landx          TYPE t005t-landx,
      zterm11        TYPE vbrk-zterm, "added by pravin
      vtext11        TYPE tvzbt-vtext,
      orig_inv       TYPE vbfa-vbeln, " Corresp. Original Invoice for cancelled invoices => SaurabhK
      orig_inv_itm   TYPE vbfa-posnn, " Corresp. Original Invoice Line for cancelled invoices => SaurabhK
      orig_inv_typ   TYPE vbrk-fkart. " Corresp. Original Invoice Type for cancelled invoices => SaurabhK
DATA: END OF ivbrp1.

DATA: BEGIN OF wa_knvv,
        kunnr TYPE knvv-kunnr,
        bzirk TYPE knvv-bzirk,
        vkorg TYPE knvv-vkorg,
        vtweg TYPE knvv-vtweg,
        spart TYPE knvv-spart,
        vkgrp TYPE knvv-vkgrp,
        kvgr1 TYPE knvv-kvgr1,
        ktgrd TYPE knvv-ktgrd,    " added by NarenK on 23.12.2015
      END OF wa_knvv,
      it_knvv LIKE TABLE OF wa_knvv.


DATA:  BEGIN  OF i_char OCCURS 0 ,
         tabix(2)   TYPE c,
         descrp(30) TYPE c.

DATA   END    OF i_char .
DATA : srtxt TYPE bezei20,
       phtxt TYPE bezei40,
       gr1tx TYPE bezei40,
       gr2tx TYPE bezei40,
       gr3tx TYPE bezei40,
       gr4tx TYPE bezei40,
       gr5tx TYPE bezei40,

       wgbez TYPE wgbez.

DATA: BEGIN OF wa_vbap,
        vbeln  TYPE vbeln_va,
        posnr  TYPE posnr_va,
        kwmeng TYPE kwmeng,
        zland1 TYPE vbap-zland1,
      END OF wa_vbap,
      it_vbap LIKE STANDARD TABLE OF wa_vbap.
DATA: BEGIN OF wa_vbak,
        vbeln TYPE vbeln_va,
        auart TYPE auart,
        vdatu TYPE edatu_vbak,
      END OF wa_vbak,
      it_vbak LIKE STANDARD TABLE OF wa_vbak.
DATA: BEGIN OF wa_vbfa,
        vbelv   TYPE vbeln_von,
        posnv   TYPE posnr_von,
        vbeln   TYPE vbeln_nach,
        posnn   TYPE posnr_nach,
        vbtyp_n TYPE vbtyp_n,
      END OF wa_vbfa,
      it_vbfa LIKE STANDARD TABLE OF wa_vbfa.
DATA: it_tvkbt TYPE STANDARD TABLE OF tvkbt,
      wa_tvkbt TYPE tvkbt,
      it_tvgrt TYPE STANDARD TABLE OF tvgrt,
      wa_tvgrt TYPE tvgrt.
DATA: BEGIN OF wa_mch1,
        matnr TYPE matnr,
        charg TYPE charg_d,
        vfdat TYPE vfdat,
      END OF wa_mch1,
      it_mch1 LIKE STANDARD TABLE OF wa_mch1.
DATA: BEGIN OF wa_likp,
        vbeln TYPE vbeln_vl,
        traid TYPE traid,
      END OF wa_likp,
      it_likp LIKE STANDARD TABLE OF wa_likp.
DATA: BEGIN OF wa_mara,
        matnr TYPE matnr,
        bismt TYPE bismt,
        extwg TYPE extwg,
      END OF wa_mara,
      it_mara LIKE STANDARD TABLE OF wa_mara.
* ---- Added for Material HSN Code/Decr on Sunday, September 03, 2017 12:33:09 => SaurabhK ---- *
DATA: BEGIN OF wa_marc,
        matnr TYPE marc-matnr,
        steuc TYPE marc-steuc,
      END OF wa_marc,
      it_marc LIKE STANDARD TABLE OF wa_marc.
DATA: BEGIN OF wa_t604n,
        steuc TYPE t604n-steuc,
        text1 TYPE t604n-text1,
      END OF wa_t604n,
      it_t604n LIKE STANDARD TABLE OF wa_t604n.
* ---- End of addition for HSN Code ---- *
DATA: BEGIN OF wa_z6ppa_plnt_map,
        werks TYPE werks_d,
        bwrks TYPE zzwrks,
      END OF wa_z6ppa_plnt_map,
      it_z6ppa_plnt_map LIKE STANDARD TABLE OF wa_z6ppa_plnt_map.
DATA: BEGIN OF wa_vbpa,
        vbeln TYPE vbeln,
        parvw TYPE parvw,
        lifnr TYPE lifnr,
      END OF wa_vbpa,
      it_vbpa LIKE STANDARD TABLE OF wa_vbpa.
DATA: BEGIN OF wa_vbkd,
        vbeln TYPE vbeln,
        posnr TYPE posnr,
        bstkd TYPE bstkd,
        bstdk TYPE bstdk,
        konda TYPE konda,
      END OF wa_vbkd.
DATA: BEGIN OF wa_vbkd1,
        vbeln TYPE vbeln,
        posnr TYPE posnr,
        bstkd TYPE bstkd,
        bstdk TYPE bstdk,
        konda TYPE konda,
      END OF wa_vbkd1.
DATA: it_vbkd LIKE STANDARD TABLE OF wa_vbkd.
DATA: it_vbkd1 LIKE STANDARD TABLE OF wa_vbkd1.
DATA: BEGIN OF wa_t171t,
        bzirk TYPE bzirk,
        bztxt TYPE bztxt,
      END OF wa_t171t,
      it_t171t LIKE STANDARD TABLE OF wa_t171t.
DATA: BEGIN OF wa_tvtwt,
        vtweg TYPE vtweg,
        vtext TYPE vtxtk,
      END OF wa_tvtwt,
      it_tvtwt LIKE STANDARD TABLE OF wa_tvtwt.
DATA: BEGIN OF wa_t151t,
        kdgrp TYPE kdgrp,
        ktext TYPE vtxtk,
      END OF wa_t151t,
      it_t151t LIKE STANDARD TABLE OF wa_t151t.
DATA: BEGIN OF wa_tvv1t,
        kvgr1 TYPE kvgr1,
        bezei TYPE bezei20,
      END OF wa_tvv1t,
      it_tvv1t LIKE STANDARD TABLE OF wa_tvv1t.
DATA: BEGIN OF wa_t023t,
        matkl TYPE matkl,
        wgbez TYPE wgbez,
      END OF wa_t023t,
      it_t023t LIKE STANDARD TABLE OF wa_t023t.
DATA: BEGIN OF wa_tvm1t,
        mvgr1 TYPE mvgr1,
        bezei TYPE bezei40,
      END OF wa_tvm1t,
      it_tvm1t LIKE STANDARD TABLE OF wa_tvm1t.
DATA: BEGIN OF wa_tvm2t,
        mvgr2 TYPE mvgr2,
        bezei TYPE bezei40,
      END OF wa_tvm2t,
      it_tvm2t LIKE STANDARD TABLE OF wa_tvm2t.
DATA: BEGIN OF wa_tvm3t,
        mvgr3 TYPE mvgr3,
        bezei TYPE bezei40,
      END OF wa_tvm3t,
      it_tvm3t LIKE STANDARD TABLE OF wa_tvm3t.
DATA: BEGIN OF wa_tvm4t,
        mvgr4 TYPE mvgr4,
        bezei TYPE bezei40,
      END OF wa_tvm4t,
      it_tvm4t LIKE STANDARD TABLE OF wa_tvm4t.
DATA: BEGIN OF wa_tvm5t,
        mvgr5 TYPE mvgr5,
        bezei TYPE bezei40,
      END OF wa_tvm5t,
      it_tvm5t LIKE STANDARD TABLE OF wa_tvm5t.
DATA: BEGIN OF wa_t179t,
        prodh TYPE prodh_d,
        vtext TYPE bezei40,
      END OF wa_t179t,
      it_t179t LIKE STANDARD TABLE OF wa_t179t.
DATA: BEGIN OF wa_j_1iexchdr,
        rdoc  TYPE j_1irdoc1,
        exnum TYPE j_1iexcnum,
        exdat TYPE j_1iexcdat,
      END OF wa_j_1iexchdr,
      it_j_1iexchdr LIKE STANDARD TABLE OF wa_j_1iexchdr.
DATA: BEGIN OF wa_j_1irg23d,
        vbeln    TYPE vbeln_vl,
        depexnum TYPE j_1iexcnum,
      END OF wa_j_1irg23d,
      it_j_1irg23d LIKE STANDARD TABLE OF wa_j_1irg23d.
DATA: BEGIN OF wa_lfa1,
        lifnr TYPE lifnr,
        name1 TYPE name1_gp,
      END OF wa_lfa1,
      it_lfa1 LIKE STANDARD TABLE OF wa_lfa1.
DATA: BEGIN OF wa_lips,
        vbeln TYPE vbeln_vl,
        posnr TYPE posnr_vl,
        lfimg TYPE lfimg,
      END OF wa_lips,
      it_lips LIKE STANDARD TABLE OF wa_lips.
DATA: BEGIN OF wa_twewt,
        extwg TYPE extwg,
        ewbez TYPE ewbez,
      END OF wa_twewt,
      it_twewt LIKE STANDARD TABLE OF wa_twewt.
*DATA: it_vbap TYPE STANDARD TABLE OF vbap,
*      it_vbfa TYPE STANDARD TABLE OF vbfa,
*      it_vbak TYPE STANDARD TABLE OF vbak,
*      it_vbrk TYPE STANDARD TABLE OF vbrk.
DATA: lv_auth_bukrs_flg,                              " added by Naren Karra on 14.10.2015
      lv_auth_vkorg_flg,                              " added by NK on 14.10.2015
      lv_auth_spart_flg,                              " added by NK on 14.10.2015
      lv_auth_vtweg_flg,                              " added by NK on 14.10.2015
      lv_auth_vkbur_flg,                              " added by NK on 14.10.2015
      lv_auth_bzirk_flg,                              " added by NK on 14.10.2015
      lv_auth_regio_flg,                              " added by NK on 14.10.2015
      lv_auth_kvgr1_flg,                              " added by NK on 14.10.2015
      lv_auth_vkgrp_flg,                              " added by NK on 14.10.2015
      lv_auth_ktgrd_flg.                              " added by NK on 23.12.2015
************************************************************************
*                           DECLARATIOM FOR ALV
************************************************************************


CONSTANTS: formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
DATA: fieldtab   TYPE slis_t_fieldcat_alv,
      p_heading  TYPE slis_t_listheader,
      layout     TYPE slis_layout_alv,
      events     TYPE slis_t_event,
      repname    LIKE sy-repid,
      f2code     LIKE sy-ucomm VALUE  '&ETA',
      g_save(1)  TYPE c,
      g_exit(1)  TYPE c,
      g_variant  LIKE disvariant,
      gx_variant LIKE disvariant,
      p_vairaint LIKE disvariant.
DATA: alv_print        TYPE slis_print_alv.
DATA: gv_ktgrd TYPE tvkt-ktgrd.       " added by NK on 23.12.2015
************************************************************************
*                           SELECTION-SCREEN
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK d WITH FRAME TITLE text-004.
PARAMETERS: p_vari LIKE disvariant-variant. " ALV Variant
SELECTION-SCREEN END OF BLOCK d.

SELECTION-SCREEN BEGIN OF BLOCK salesdetail WITH FRAME TITLE text-001.
PARAMETERS : p_bukrs LIKE vbrk-bukrs OBLIGATORY.
*PARAMETERS   :  p_muebs LIKE zvbmuez-muebs .
SELECT-OPTIONS : s_vkorg FOR vbrk-vkorg,
s_vtweg FOR vbrk-vtweg,
s_spart FOR vbrp-spart,
*                 s_werks FOR vbrp-werks,
s_vkgrp FOR vbrp-vkgrp,
s_vkbur FOR vbrp-vkbur,
s_regio FOR vbrk-regio,
s_bzirk FOR vbrk-bzirk,
s_kvgr1 FOR vbrp-kvgr1,
s_fkart FOR vbrk-fkart,
s_auart FOR vbak-auart,
s_fkdat FOR vbrk-fkdat,
s_vbeln FOR vbrk-vbeln,
s_matnr FOR vbrp-matnr,
s_kdgrp FOR vbrp-kdgrp_auft,
s_kunnr FOR vbrk-kunrg,
*                 s_werks FOR zvbrpvbrk-werks
*PARAMETERS : p_bukrs LIKE zvbrpvbrk-bukrs OBLIGATORY.
s_ktgrd FOR gv_ktgrd."tvkt-ktgrd.      " added by NarenK on 23.12.2015
SELECTION-SCREEN END OF BLOCK salesdetail.

SELECTION-SCREEN BEGIN OF BLOCK options WITH FRAME TITLE text-003.
*PARAMETERS: detail RADIOBUTTON GROUP rad1,
*            summary RADIOBUTTON GROUP rad1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 3.
PARAMETERS: cus RADIOBUTTON GROUP rad2.
SELECTION-SCREEN COMMENT 5(15) text-005.

SELECTION-SCREEN POSITION 35.
PARAMETERS: mat RADIOBUTTON GROUP rad2.
SELECTION-SCREEN COMMENT 37(15) text-006.
SELECTION-SCREEN POSITION 54.
PARAMETERS: inv RADIOBUTTON GROUP rad2 DEFAULT 'X'.   " (No Selection Criteria)Set as default as most users select this primarily => SaurabhK
SELECTION-SCREEN COMMENT 56(21) text-007.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK options.

SELECTION-SCREEN BEGIN OF BLOCK condtypes WITH FRAME TITLE text-002.
SELECTION-SCREEN : SKIP.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : POSITION 1.
PARAMETERS: pk1 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 10.
PARAMETERS: pk1d LIKE t685t-vtext.
SELECTION-SCREEN : POSITION 42.
PARAMETERS: pk2 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 51.
PARAMETERS: pk2d LIKE t685t-vtext.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN : SKIP.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : POSITION 1.
PARAMETERS: pk3 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 10.
PARAMETERS: pk3d LIKE t685t-vtext.
SELECTION-SCREEN : POSITION 42.
PARAMETERS: pk4 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 51.
PARAMETERS: pk4d LIKE t685t-vtext.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN : SKIP.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : POSITION 1.
PARAMETERS: pk5 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 10.
PARAMETERS: pk5d LIKE t685t-vtext.
SELECTION-SCREEN : POSITION 42.
PARAMETERS: pk6 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 51.
PARAMETERS:pk6d  LIKE t685t-vtext.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN : SKIP.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : POSITION 1.
PARAMETERS: pk7 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 10.
PARAMETERS: pk7d LIKE t685t-vtext.
SELECTION-SCREEN : POSITION 42.
PARAMETERS: pk8 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 51.
PARAMETERS: pk8d LIKE t685t-vtext.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN : SKIP.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : POSITION 1.
PARAMETERS: pk9 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 10.
PARAMETERS: pk9d LIKE t685t-vtext.
SELECTION-SCREEN : POSITION 42.
PARAMETERS: pk10 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 51.
PARAMETERS: pk10d LIKE t685t-vtext.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN : SKIP.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : POSITION 1.
PARAMETERS: pk11 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 10.
PARAMETERS: pk11d LIKE t685t-vtext.
SELECTION-SCREEN : POSITION 42.
PARAMETERS: pk12 LIKE konv-kschl.
SELECTION-SCREEN : POSITION 51.
PARAMETERS: pk12d LIKE t685t-vtext.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN : SKIP.
SELECTION-SCREEN END OF BLOCK condtypes.

************************************************************************
*                         INITIALIZATION
************************************************************************

INITIALIZATION.
  repname = sy-repid.
  PERFORM initialize_variant.
  PERFORM build_eventtab USING events[].

************************************************************************
*                         AT SELECTION-SCREEN
************************************************************************

AT SELECTION-SCREEN.
  PERFORM pai_of_selection_screen.
  PERFORM check_input_data.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk1.
  PERFORM f4_for_pk CHANGING pk1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk2.
  PERFORM f4_for_pk CHANGING pk2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk3.
  PERFORM f4_for_pk CHANGING pk3.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk4.
  PERFORM f4_for_pk CHANGING pk4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk5.
  PERFORM f4_for_pk CHANGING pk5.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk6.
  PERFORM f4_for_pk CHANGING pk6.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk7.
  PERFORM f4_for_pk CHANGING pk7.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk8.
  PERFORM f4_for_pk CHANGING pk8.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk9.
  PERFORM f4_for_pk CHANGING pk9.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk10.
  PERFORM f4_for_pk CHANGING pk10.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk11.
  PERFORM f4_for_pk CHANGING pk11.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pk12.
  PERFORM f4_for_pk CHANGING pk12.
************************************************************************
*                         START-OF-SELECTION
************************************************************************

START-OF-SELECTION.

  PERFORM chk_auth_obj.                                           " added by Naren Karra on 13.10.2015
  PERFORM get_characterstics.

  PERFORM build_comment USING p_heading[].

  PERFORM get_data_into_ivbrp1.
  PERFORM initialize_fieldcat USING fieldtab[].
************************Start********************************     " added by NK on 20.10.2015   &  modified by NK on 23.12.2015
  IF ( lv_auth_vkorg_flg = 'X' OR lv_auth_spart_flg = 'X' OR lv_auth_vtweg_flg = 'X' OR lv_auth_ktgrd_flg = 'X' OR           " LV_AUTH_BUKRS_FLG = 'X' OR
  lv_auth_vkbur_flg = 'X' OR lv_auth_bzirk_flg = 'X' OR lv_auth_regio_flg = 'X' OR lv_auth_vkgrp_flg = 'X' OR lv_auth_kvgr1_flg ='X' )
  AND ivbrp1 IS INITIAL.
    MESSAGE 'No records found/ Missing Authorization' TYPE 'S' DISPLAY LIKE 'W'.
*  ELSEIF IVBRP1[] IS INITIAL AND iitem[] IS INITIAL.
*    MESSAGE 'No records found' TYPE 'S' DISPLAY LIKE 'W'.
  ENDIF.
*************************End*********************************
* ---- Commented by SaurabhK on Monday, September 04, 2017 13:04:12 ---- *
* ---- IRDK929081 ---- *
* ---- Not required as relevant message will be displayed above if final table is empty ---- *
* ---- Displayed unnecessary auth. warning message even after displaying data ---- *
*  IF lv_auth_vkorg_flg = 'X' OR lv_auth_spart_flg = 'X' OR lv_auth_vtweg_flg = 'X' OR lv_auth_ktgrd_flg = 'X' OR           " LV_AUTH_BUKRS_FLG = 'X' OR
*    lv_auth_vkbur_flg = 'X' OR lv_auth_bzirk_flg = 'X' OR lv_auth_regio_flg = 'X' OR lv_auth_vkgrp_flg = 'X' OR lv_auth_kvgr1_flg ='X'.
*    MESSAGE 'Missing Authorization' TYPE 'S' DISPLAY LIKE 'W'.
*  ENDIF.
*  ---- End of Comment ---- *
  PERFORM data_into_ivbrp2_ivbrp3_ivbrp.


************************************************************************
*                         END-OF-SELECTION
************************************************************************

END-OF-SELECTION.

*---------------------------------------------------------------------*
*       FORM INITIALIZE_FIELDCAT                                      *
*---------------------------------------------------------------------*
FORM initialize_fieldcat USING p_fieldtab TYPE slis_t_fieldcat_alv.
  DATA: fieldcat TYPE slis_fieldcat_alv.
* fixed columns (obligatory)
  CLEAR fieldcat.
  IF cus NE space.
    fieldcat-tabname    = 'IITEM'.
*   FIELDCAT-fix_column = 'X'.
*    FIELDCAT-key           = 'X'.
    fieldcat-fieldname     = 'KUNNR'.
    fieldcat-ref_tabname   = 'KNA1'.
    fieldcat-col_pos       = '1'.
    fieldcat-seltext_s     = 'Customer'.
    fieldcat-seltext_m     = 'Customer'.
    fieldcat-seltext_l     = 'Customer'.
*    fieldcat-outputlen       = 20.

    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    fieldcat-tabname    = 'IITEM'.
*  FIELDCAT-fix_column = 'X'.
*  FIELDCAT-no_out     = 'O'.
*  FIELDCAT-key           = 'X'.
    fieldcat-fieldname  = 'NAME1'.
    fieldcat-ref_tabname   = 'KNA1'.
    fieldcat-col_pos       = '2'.
*    fieldcat-outputlen    = '20'.
    fieldcat-seltext_m    = 'Name'.
    fieldcat-seltext_l    = 'Name'.
    fieldcat-seltext_s    = 'Name'.
    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
  ENDIF.
  IF mat NE space.
    fieldcat-tabname    = 'IITEM'.
    fieldcat-fieldname     = 'MATNR'.
    fieldcat-ref_fieldname = 'MATNR'.
    fieldcat-ref_tabname   = 'MARA'.
    fieldcat-col_pos       = '1'.
    fieldcat-seltext_s     = 'Material'.
    fieldcat-seltext_m     = 'Material'.
    fieldcat-seltext_l     = 'Material'.

    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    fieldcat-tabname    = 'IITEM'.
    fieldcat-fieldname  = 'ARKTX'.
    fieldcat-ref_fieldname  = 'ARKTX'.
    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-col_pos       = '2'.
    fieldcat-seltext_m    = 'Mat.Desc'.
    fieldcat-seltext_l    = 'Mat.Desc'.
    fieldcat-seltext_s    = 'Mat.Desc'.
    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
  ENDIF.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'VBELN'.
  fieldcat-ref_fieldname ='VBELN'.
  fieldcat-ref_tabname ='ZVBRKVBRP'.
  fieldcat-col_pos       = '1'.
  fieldcat-seltext_m = 'Billing Doc'.
  fieldcat-seltext_l = 'Billing Doc'.
  fieldcat-seltext_s = 'Billing Doc'.
  fieldcat-hotspot   = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'POSNR'.
  fieldcat-col_pos       = '2'.
  fieldcat-seltext_m = 'Billing Item'.
  fieldcat-seltext_l = 'Billing Item'.
  fieldcat-seltext_s = 'Billing Item'.
*  fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.
*
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'NAME1'.
  fieldcat-col_pos       = '4'.
  fieldcat-seltext_m = 'Name'.
  fieldcat-seltext_l = 'Name'.
  fieldcat-seltext_s = 'Name'.
*  fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'KUNNR'.
  fieldcat-col_pos       = '3'.
  fieldcat-seltext_m = 'Customer'.
  fieldcat-seltext_l = 'Customer'.
  fieldcat-seltext_s = 'Customer'.
*  fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'ORT01'.
  fieldcat-col_pos       = '5'.
  fieldcat-seltext_m = 'City'.
  fieldcat-seltext_l = 'City'.
  fieldcat-seltext_s = 'City'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'FKART'.
  fieldcat-col_pos       = '6'.
  fieldcat-seltext_m = 'Billing Type'.
  fieldcat-seltext_l = 'Billing Type'.
  fieldcat-seltext_s = 'Billing Type'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'MATNR'.
  fieldcat-col_pos       = '7'.
  fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-ref_tabname = 'MARA'.
  fieldcat-outputlen = '18'.
  fieldcat-seltext_m = 'Material'.
  fieldcat-seltext_l = 'Material'.
  fieldcat-seltext_s = 'Material'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'ARKTX'.
  fieldcat-col_pos       = '8'.
  fieldcat-seltext_m = 'Mat. Desc.'.
  fieldcat-seltext_l = 'Mat. Desc.'.
  fieldcat-seltext_s = 'Mat. Desc.'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.
* --- Added for HSN Code on Sunday, September 03, 2017 12:48:34 => SaurabhK --- *
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'HSN_NO'.
*  fieldcat-col_pos       = '8'.
  fieldcat-seltext_m = 'Mat. HSN Code'.
  fieldcat-seltext_l = 'Mat. HSN Code'.
  fieldcat-seltext_s = 'Mat. HSN Code'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'HSN_TEXT'.
*  fieldcat-col_pos       = '8'.
  fieldcat-seltext_m = 'HSN Desc.'.
  fieldcat-seltext_l = 'HSN Desc.'.
  fieldcat-seltext_s = 'HSN Desc.'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.
* --- End of addition for HSN Code --- *


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'FKIMG'.
  fieldcat-col_pos       = '9'.
  fieldcat-seltext_m = 'Bill.Qty'.
  fieldcat-seltext_l = 'Bill.Qty'.
  fieldcat-seltext_s = 'Bill.Qty'.
*    fieldcat-fix_column = 'X'.
  fieldcat-do_sum  = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'VRKME'.
  fieldcat-col_pos       = '10'.
  fieldcat-seltext_m = 'Sales Unit'.
  fieldcat-seltext_l = 'Sales Unit'.
  fieldcat-seltext_s = 'Sales Unit'.

  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'NETWR'.
  fieldcat-ref_tabname = 'VBRP'.
  fieldcat-ref_fieldname = 'NETWR'.
  fieldcat-col_pos       = '11'.
  fieldcat-do_sum       = 'X'.
  fieldcat-seltext_m = 'Inv.Amount'.
  fieldcat-seltext_l = 'Inv.Amount'.
  fieldcat-seltext_s = 'Inv.Amount'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.
*
**
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'WAERK'.
  fieldcat-col_pos       = '12'.
  fieldcat-seltext_m = 'Doc.Currency'.
  fieldcat-seltext_l = 'Doc.Currency'.
  fieldcat-seltext_s = 'Doc.Currency'.

  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'VKORG'.
  fieldcat-col_pos       = '13'.
  fieldcat-seltext_m = 'Sales Org'.
  fieldcat-seltext_l = 'Sales Org'.
  fieldcat-seltext_s = 'Sales Org'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'VTWEG'.
  fieldcat-col_pos       = '14'.
  fieldcat-seltext_m = 'Distr.Channel'.
  fieldcat-seltext_l = 'Distr.Channel'.
  fieldcat-seltext_s = 'Distr.Channel'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'VTEXT'.
  fieldcat-col_pos       = '15'.
  fieldcat-seltext_m = 'Distr.Text'.
  fieldcat-seltext_l = 'Distr.Text'.
  fieldcat-seltext_s = 'Distr.Text'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'VKBUR'.
  fieldcat-col_pos       = '16'.
  fieldcat-seltext_m = 'Plant'.
  fieldcat-seltext_l = 'Plant'.
  fieldcat-seltext_s = 'Plant'.
*    fieldcat-fix_column = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'BEZEI'.
  fieldcat-col_pos       = '17'.
  fieldcat-seltext_m = 'Plant Name'.
  fieldcat-seltext_l = 'Plant Name'.
  fieldcat-seltext_s = 'Plant Name'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'VKGRP'.
  fieldcat-col_pos       = '18'.
  fieldcat-seltext_m = 'Territory'.
  fieldcat-seltext_l = 'Territory'.
  fieldcat-seltext_s = 'Territory'.
  fieldcat-do_sum = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'L_BEZEI'.
  fieldcat-col_pos = '19'.
  fieldcat-seltext_m = 'Territory description'.
  fieldcat-seltext_l = 'Territory description'.
  fieldcat-seltext_s = 'Territory description'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'FKDAT'.
  fieldcat-ref_tabname = 'VBRK'.
  fieldcat-ref_fieldname = 'FKDAT'.
  fieldcat-col_pos       = '20'.
  fieldcat-seltext_m = 'Bill Date'.
  fieldcat-seltext_l = 'Bill Date'.
  fieldcat-seltext_s = 'Bill Date'.
  fieldcat-do_sum = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'AUBEL'.
  fieldcat-col_pos       = '21'.
  fieldcat-seltext_m = 'Sales Doc.'.
  fieldcat-seltext_l = 'Sales Doc.'.
  fieldcat-seltext_s = 'Sales Doc.'.
  fieldcat-do_sum = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'AUPOS'.
  fieldcat-col_pos       = '22'.
  fieldcat-seltext_m = 'Sales Item.'.
  fieldcat-seltext_l = 'Sales Item.'.
  fieldcat-seltext_s = 'Sales Item.'.
  fieldcat-do_sum = 'X'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'PSTYV'.
  fieldcat-ref_tabname = 'VBRP'.
  fieldcat-ref_fieldname = 'PSTYV'.
  fieldcat-col_pos       = '23'.
  fieldcat-seltext_m = 'Item Category'.
  fieldcat-seltext_l = 'Item Category'.
  fieldcat-seltext_s = 'Item Category'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  IF pk1d NE space.


    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

    fieldcat-do_sum    = 'X'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K1'.
    fieldcat-col_pos       = '24'.
    fieldcat-seltext_l     = pk1d.
    fieldcat-seltext_s     = pk1d.
    fieldcat-seltext_m     = pk1d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.
    pk1d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K1R'.
    fieldcat-col_pos       = '25'.
    fieldcat-seltext_l     = pk1d.
    fieldcat-seltext_s     = pk1d.
    fieldcat-seltext_m     = pk1d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
  ENDIF.
  IF pk2d NE space.
    fieldcat-tabname   = 'IVBRP1'.
    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K2'.
    fieldcat-seltext_l     = pk2d.
    fieldcat-seltext_m     = pk2d.
    fieldcat-seltext_s     = pk2d.
    fieldcat-reptext_ddic      = 'l'.
*    fieldcat-outputlen = len.
*    FIELDCAT-cfieldname = 'VBRP'.
*    FIELDCAT-ctabname   = 'NETWR'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-col_pos       = '26'.

    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk2d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K2R'.
    fieldcat-col_pos       = '27'.
    fieldcat-seltext_l     = pk2d.
    fieldcat-seltext_s     = pk2d.
    fieldcat-seltext_m     = pk2d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
*
  IF pk3d NE space.
    fieldcat-tabname   = 'IVBRP1'.

    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K3'.
    fieldcat-seltext_l     = pk3d.
    fieldcat-seltext_m     = pk3d.
    fieldcat-seltext_s     = pk3d.

*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.

    fieldcat-col_pos       = '28'.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk3d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K3R'.
    fieldcat-col_pos       = '29'.
    fieldcat-seltext_l     = pk3d.
    fieldcat-seltext_s     = pk3d.
    fieldcat-seltext_m     = pk3d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
  IF pk4d NE space.
    len = strlen( pk4d ).
    fieldcat-tabname   = 'IVBRP1'.

    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K4'.


*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.

    fieldcat-seltext_m     = pk4d.
    fieldcat-seltext_s     = pk4d.
    fieldcat-seltext_l     = pk4d.
    fieldcat-reptext_ddic      = 'l'.

    fieldcat-col_pos       = '30'.
    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk4d = 'Rate'.
    CLEAR len.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K4R'.
    fieldcat-col_pos       = '31'.
    fieldcat-seltext_l     = pk4d.
    fieldcat-seltext_s     = pk4d.
    fieldcat-seltext_m     = pk4d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

  ENDIF.
  IF pk5d NE space.
    fieldcat-tabname   = 'IVBRP1'.

    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K5'.
    fieldcat-seltext_l     = pk5d.
    fieldcat-seltext_m     = pk5d.
    fieldcat-seltext_s     = pk5d.

*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-reptext_ddic      = 'l'.
    fieldcat-col_pos       = '32'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.
    pk5d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K5R'.
    fieldcat-col_pos       = '33'.
    fieldcat-seltext_l     = pk5d.
    fieldcat-seltext_s     = pk5d.
    fieldcat-seltext_m     = pk5d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
  IF pk6d NE space.

    fieldcat-tabname   = 'IVBRP1'.

    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K6'.
    fieldcat-seltext_l     = pk6d.
    fieldcat-seltext_m     = pk6d.
    fieldcat-seltext_s     = pk6d.

*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.

    fieldcat-col_pos       = '34'.
    fieldcat-reptext_ddic      = 'l'.
    fieldcat-no_out   = 'X'.
    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk6d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K6R'.
    fieldcat-col_pos       = '35'.
    fieldcat-seltext_l     = pk6d.
    fieldcat-seltext_s     = pk6d.
    fieldcat-seltext_m     = pk6d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
  IF pk7d NE space.

    fieldcat-tabname   = 'IVBRP1'.
*   FIELDCAT-SP_GROUP  = 'A'.
    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K7'.
    fieldcat-seltext_l     = pk7d.
    fieldcat-seltext_m     = pk7d.
    fieldcat-seltext_s     = pk7d.
*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-reptext_ddic      = 'l'.
    fieldcat-col_pos       = '36'.
    fieldcat-no_out   = 'X'.

    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk7d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K7R'.
    fieldcat-col_pos       = '37'.
    fieldcat-seltext_l     = pk7d.
    fieldcat-seltext_s     = pk7d.
    fieldcat-seltext_m     = pk7d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
  IF pk8d NE space.


    fieldcat-tabname   = 'IVBRP1'.
    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K8'.
    fieldcat-seltext_l     = pk8d.
    fieldcat-seltext_m     = pk8d.
    fieldcat-seltext_s     = pk8d.
*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-reptext_ddic      = 'l'.
    fieldcat-col_pos       = '38'.

    fieldcat-no_out   = 'X'.
    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk8d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K8R'.
    fieldcat-col_pos       = '39'.
    fieldcat-seltext_l     = pk8d.
    fieldcat-seltext_s     = pk8d.
    fieldcat-seltext_m     = pk8d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
  IF pk9d NE space.


    fieldcat-tabname   = 'IVBRP1'.
    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K9'.
    fieldcat-seltext_l    = pk9d.
    fieldcat-seltext_m     = pk9d.
    fieldcat-seltext_s     = pk9d.
    fieldcat-reptext_ddic      = 'l'.
*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.

    fieldcat-col_pos       = '40'.
    fieldcat-no_out   = 'X'.

    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk9d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K9R'.
    fieldcat-col_pos       = '41'.
    fieldcat-seltext_l     = pk9d.
    fieldcat-seltext_s     = pk9d.
    fieldcat-seltext_m     = pk9d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
  IF pk10d NE space.

    len = strlen( pk10d ).

    fieldcat-tabname   = 'IVBRP1'.

    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K10'.
    fieldcat-seltext_l     = pk10d.
    fieldcat-seltext_m     = pk10d.
    fieldcat-seltext_s     = pk10d.
    fieldcat-reptext_ddic      = 'l'.
*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.

    fieldcat-col_pos       = '42'.
    fieldcat-no_out   = 'X'.

    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk10d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K10R'.
    fieldcat-col_pos       = '43'.
    fieldcat-seltext_l     = pk10d.
    fieldcat-seltext_s     = pk10d.
    fieldcat-seltext_m     = pk10d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
  IF pk11d NE space.

    fieldcat-fieldname = 'K11'.
    fieldcat-tabname   = 'IVBRP1'.
    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'NETWR'.
*    fieldcat-ref_tabname   = 'VBRP'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.

    fieldcat-seltext_l     = pk11d.
    fieldcat-seltext_m     = pk11d.
    fieldcat-seltext_s     = pk11d.
    fieldcat-reptext_ddic      = 'l'.
    fieldcat-col_pos       = '44'.
    fieldcat-no_out   = 'X'.

    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.
    pk11d = 'Rate'.
    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*    fieldcat-do_sum    = 'X'.
*    fieldcat-ref_fieldname = 'KBETR'.
*    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-fieldname = 'K11R'.
    fieldcat-col_pos       = '45'.
    fieldcat-seltext_l     = pk11d.
    fieldcat-seltext_s     = pk11d.
    fieldcat-seltext_m     = pk11d.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.

    CLEAR len.
  ENDIF.
  IF pk12d NE space.

    fieldcat-tabname   = 'IVBRP1'.

    fieldcat-do_sum    = 'X'.
    fieldcat-fieldname = 'K12'.
    fieldcat-seltext_l     = pk12d.
    fieldcat-seltext_m     = pk12d.
    fieldcat-seltext_s     = pk12d.
    fieldcat-reptext_ddic      = 'l'.
    fieldcat-ref_fieldname = 'KWERT'.
    fieldcat-ref_tabname   = 'KONV'.
    fieldcat-col_pos       = '46'.
    fieldcat-no_out   = 'X'.

    APPEND fieldcat TO p_fieldtab.
    CLEAR fieldcat.

    fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

    fieldcat-fieldname = 'K12R'.
    fieldcat-col_pos       = '50'.
    fieldcat-seltext_l     = 'Rate'.
    fieldcat-seltext_s     = 'Rate'.
    fieldcat-seltext_m     = 'Rate'.
    fieldcat-reptext_ddic      = 'l'.
    APPEND fieldcat TO p_fieldtab.

    CLEAR fieldcat.



  ENDIF.
  fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

  fieldcat-fieldname = 'TOT_AMT'.

  fieldcat-col_pos       = '47'.
  fieldcat-ref_tabname = 'VBRP'.
  fieldcat-ref_fieldname = 'NETWR'.
  fieldcat-seltext_l     = 'Tot Amount'.
  fieldcat-seltext_s     = 'Tot Amount'.
  fieldcat-seltext_m     = 'Tot Amount'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO p_fieldtab.

  CLEAR fieldcat.

  fieldcat-tabname   = 'IVBRP1'.
*FIELDCAT-no_out     = 'X'.

*  fieldcat-fieldname = 'BWTAR'.
*  fieldcat-col_pos       = '52'.
*  fieldcat-seltext_l     = 'Valuation Type'.
*  fieldcat-seltext_s     = 'Valuation Type'.
*  fieldcat-seltext_m     = 'Valuation Type'.
*
*  APPEND fieldcat TO p_fieldtab.
*
*  CLEAR fieldcat.

  fieldcat-fieldname = 'KDGRP_AUFT'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '48'.
  fieldcat-ref_fieldname = 'KDGRP'.
  fieldcat-ref_tabname = 'KNVV'.
  fieldcat-seltext_l     = 'Customer Group'.
  fieldcat-seltext_s     = 'Customer Group'.
  fieldcat-seltext_m     = 'Customer Group'.
  fieldcat-outputlen     = 10.
  APPEND fieldcat TO p_fieldtab.

  CLEAR fieldcat.

  fieldcat-fieldname = 'KTEXT'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '49'.
  fieldcat-outputlen     = 20.
  fieldcat-ref_fieldname = 'KTEXT'.
  fieldcat-ref_tabname = 'T151T'.
  fieldcat-seltext_l     = 'Customer Group Desc'.
  fieldcat-seltext_s     = 'Customer Group Desc'.
  fieldcat-seltext_m     = 'Customer Group Desc'.

  APPEND fieldcat TO p_fieldtab.

  CLEAR fieldcat.

*  fieldcat-fieldname = 'VEHNO'.
*  fieldcat-tabname = 'IVBRP1'.
*  fieldcat-col_pos       = '55'.
*  fieldcat-outputlen     = 20.
*  fieldcat-ref_fieldname = 'VEHNO'.
*  fieldcat-ref_tabname = 'ZGTSD_MAST'.
*  fieldcat-seltext_l     = 'Vehicle Number'.
*  fieldcat-seltext_s     = 'Vehicle Number'.
*  fieldcat-seltext_m     = 'Vehicle Number'.
*  APPEND fieldcat TO p_fieldtab.
*  CLEAR fieldcat.

  fieldcat-fieldname = 'LIFNR'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '50'.
  fieldcat-outputlen     = 20.
  fieldcat-ref_fieldname = 'LIFNR'.
  fieldcat-ref_tabname = 'LFA1'.
  fieldcat-seltext_l     = 'Transporter'.
  fieldcat-seltext_s     = 'Transporter'.
  fieldcat-seltext_m     = 'Transporter'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'TNAME'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '51'.
  fieldcat-outputlen     = 20.
  fieldcat-ref_fieldname = 'NAME1'.
  fieldcat-ref_tabname = 'LFA1'.
  fieldcat-seltext_l     = 'Transp Name'.
  fieldcat-seltext_s     = 'Transp Name'.
  fieldcat-seltext_m     = 'Transp Name'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'EXNUM'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '51'.
  fieldcat-outputlen     = 10.
  fieldcat-ref_fieldname = 'EXNUM'.
  fieldcat-ref_tabname = 'J_1IEXCHDR'.
  fieldcat-seltext_l     = 'Exc.Inv.No'.
  fieldcat-seltext_s     = 'Exc.Inv.No'.
  fieldcat-seltext_m     = 'Exc.Inv.No'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'EXDAT'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '52'.
  fieldcat-outputlen     = 10.
  fieldcat-ref_fieldname = 'EXDAT'.
  fieldcat-ref_tabname = 'J_1IEXCHDR'.
  fieldcat-seltext_l     = 'Exc.Inv.Date'.
  fieldcat-seltext_s     = 'Exc.Inv.Date'.
  fieldcat-seltext_m     = 'Exc.Inv.Date'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.



  fieldcat-fieldname = 'VGBEL'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '53'.
  fieldcat-outputlen     = 10.
  fieldcat-ref_fieldname = 'VBELN'.
  fieldcat-ref_tabname = 'LIKP'.
  fieldcat-seltext_l     = 'Delivery No'.
  fieldcat-seltext_s     = 'Delivery No'.
  fieldcat-seltext_m     = 'Delivery No'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'VGPOS'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '54'.
  fieldcat-outputlen     = 10.
  fieldcat-ref_fieldname = 'POSNR'.
  fieldcat-ref_tabname = 'LIPS'.
  fieldcat-seltext_l     = 'Del.Item'.
  fieldcat-seltext_s     = 'Del.Item'.
  fieldcat-seltext_m     = 'Del.Item'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.





  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'CHARG'.
  fieldcat-ref_tabname = 'VBRP'.
  fieldcat-ref_fieldname = 'CHARG'.
  fieldcat-col_pos       = '55'.
  fieldcat-seltext_m = 'Batch'.
  fieldcat-seltext_l = 'Batch'.
  fieldcat-seltext_s = 'Batch'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'VFDAT'.
  fieldcat-ref_tabname = 'MCH1'.
  fieldcat-ref_fieldname = 'VFDAT'.
  fieldcat-col_pos       = '56'.
  fieldcat-seltext_m = 'Batch Exp.Date'.
  fieldcat-seltext_l = 'Batch Exp.Date'.
  fieldcat-seltext_s = 'Batch Exp.Date'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.
*

  fieldcat-fieldname = 'KVGR1'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '57'.
  fieldcat-outputlen     = 10.
  fieldcat-ref_fieldname = 'KVGR1'.
  fieldcat-ref_tabname = 'VBRP'.
  fieldcat-seltext_l     = 'Sub Region'.
  fieldcat-seltext_s     = 'Sub Region'.
  fieldcat-seltext_m     = 'Sub Region'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'SRTXT'.
  fieldcat-ref_tabname = 'VBRP'.
  fieldcat-ref_fieldname = 'ARKTX'.
  fieldcat-col_pos       = '58'.
  fieldcat-seltext_m = 'Sub Reg.Name'.
  fieldcat-seltext_l = 'Sub Reg.Name'.
  fieldcat-seltext_s = 'Sub Reg.Name'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'PRODH'.
  fieldcat-ref_tabname = 'VBRP'.
  fieldcat-ref_fieldname = 'PRODH'.
  fieldcat-col_pos       = '59'.
  fieldcat-seltext_m = 'Prod.Hierarchy'.
  fieldcat-seltext_l = 'Prod.Hierarchy'.
  fieldcat-seltext_s = 'Prod.Hierarchy'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'PHTXT'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '60'.

  fieldcat-ref_fieldname = 'VTEXT'.
  fieldcat-ref_tabname = 'T179T'.
  fieldcat-seltext_l     = 'Prod.H.Desc'.
  fieldcat-seltext_s     = 'Prod.H.Desc'.
  fieldcat-seltext_m     = 'Prod.H.Desc'.
  fieldcat-reptext_ddic      = 'l'.

  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.



  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'MATKL'.
  fieldcat-ref_tabname = 'VBRP'.
  fieldcat-ref_fieldname = 'MATKL'.
  fieldcat-col_pos       = '62'.
  fieldcat-seltext_m = 'Mat.Group'.
  fieldcat-seltext_l = 'Mat.Group'.
  fieldcat-seltext_s = 'Mat.Group'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'WGBEZ'.
  fieldcat-ref_tabname = 'T023T'.
  fieldcat-ref_fieldname = 'WGBEZ'.
  fieldcat-col_pos       = '63'.
  fieldcat-seltext_m = 'Mat.Group.Desc'.
  fieldcat-seltext_l = 'Mat.Group.Desc'.
  fieldcat-seltext_s = 'Mat.Group.Desc'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'BZIRK'.
  fieldcat-ref_tabname = 'VBRK'.
  fieldcat-ref_fieldname = 'BZIRK'.
  fieldcat-col_pos       = '64'.
  fieldcat-seltext_m = 'Region Code'.
  fieldcat-seltext_l = 'Region Code'.
  fieldcat-seltext_s = 'Region Code'.
  fieldcat-reptext_ddic      = 'l'.


  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'BZTXT'.
  fieldcat-ref_tabname = 'T171T'.
  fieldcat-ref_fieldname = 'BZTXT'.
  fieldcat-col_pos       = '65'.
  fieldcat-seltext_m = 'Region.Desc'.
  fieldcat-seltext_l = 'Region.Desc'.
  fieldcat-seltext_s = 'Region.Desc'.
  fieldcat-reptext_ddic      = 'l'.

  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'BISMT'.
  fieldcat-ref_tabname = 'MARA'.
  fieldcat-ref_fieldname = 'BISMT'.
  fieldcat-col_pos       = '66'.
  fieldcat-seltext_m = 'BAAN Code'.
  fieldcat-seltext_l = 'BAAN Code'.
  fieldcat-seltext_s = 'BAAN Code'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'PCKG'.

  fieldcat-col_pos       = '66'.
  fieldcat-seltext_m = 'Cont.Code'.
  fieldcat-seltext_l = 'Cont.Code'.
  fieldcat-seltext_s = 'Cont.Code'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'BPLNT'.
  fieldcat-ref_tabname = 'MARC'.
  fieldcat-ref_fieldname = 'WERKS'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'Bann Plant'.
  fieldcat-seltext_l = 'Bann Plant'.
  fieldcat-seltext_s = 'Bann Plant'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'MVGR1'.
  fieldcat-ref_tabname = 'TVM1T'.
  fieldcat-ref_fieldname = 'MVGR1'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'Mat.Group.1'.
  fieldcat-seltext_l = 'Mat.Group.1'.
  fieldcat-seltext_s = 'Mat.Group.1'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'GR1TX'.
  fieldcat-ref_tabname = 'TVM1T'.
  fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'Mat.Grp.1.Desc'.
  fieldcat-seltext_l = 'Mat.Grp.1.Desc'.
  fieldcat-seltext_s = 'Mat.Grp.1.Desc'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'MVGR2'.
  fieldcat-ref_tabname = 'TVM2T'.
  fieldcat-ref_fieldname = 'MVGR2'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'CST Grp.'.
  fieldcat-seltext_l = 'CST Grp.'.
  fieldcat-seltext_s = 'CST.Grp'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'GR2TX'.
  fieldcat-ref_tabname = 'TVM2T'.
  fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'CST Grp.Desc'.
  fieldcat-seltext_l = 'CST Grp.Desc'.
  fieldcat-seltext_s = 'CST Grp.Desc'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'MVGR3'.
  fieldcat-ref_tabname = 'TVM3T'.
  fieldcat-ref_fieldname = 'MVGR3'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'ABC Grp.'.
  fieldcat-seltext_l = 'ABC Grp.'.
  fieldcat-seltext_s = 'ABC Grp.'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'GR3TX'.
  fieldcat-ref_tabname = 'TVM3T'.
  fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'ABC Grp.Desc'.
  fieldcat-seltext_l = 'ABC Grp.Desc'.
  fieldcat-seltext_s = 'ABC Grp.Desc'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'MVGR4'.
  fieldcat-ref_tabname = 'TVM4T'.
  fieldcat-ref_fieldname = 'MVGR4'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'Prod.Mgr.'.
  fieldcat-seltext_l = 'Prod.Mgr.'.
  fieldcat-seltext_s = 'Prod.Mgr.'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'GR4TX'.
  fieldcat-ref_tabname = 'TVM4T'.
  fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'Prod.Mgr.Desc'.
  fieldcat-seltext_l = 'Prod.Mgr.Desc'.
  fieldcat-seltext_s = 'Prod.Mgr.Desc'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'MVGR5'.
  fieldcat-ref_tabname = 'TVM5T'.
  fieldcat-ref_fieldname = 'MVGR5'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'Nature'.
  fieldcat-seltext_l = 'Nature'.
  fieldcat-seltext_s = 'Nature'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'GR5TX'.
  fieldcat-ref_tabname = 'TVM5T'.
  fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-col_pos       = '67'.
  fieldcat-seltext_m = 'Nature'.
  fieldcat-seltext_l = 'Nature'.
  fieldcat-seltext_s = 'Nature'.
  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  "Anees
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'BALANCE'.
  fieldcat-col_pos   = '68'.
  fieldcat-seltext_m = 'Bal.Qty.'.
  fieldcat-seltext_l = 'Bal.Qty.'.
  fieldcat-seltext_s = 'Bal.Qty.'.
*  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'DELAY'.
  fieldcat-col_pos   = '69'.
  fieldcat-seltext_m = 'Delayed.By'.
  fieldcat-seltext_l = 'Delayed.By'.
  fieldcat-seltext_s = 'Delayed.By'.
*  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'MONTH'.
  fieldcat-col_pos   = '70'.
  fieldcat-seltext_m = 'Billing.Month'.
  fieldcat-seltext_l = 'Billing.Month'.
  fieldcat-seltext_s = 'Billing.Month'.
*  fieldcat-reptext_ddic      = 'l'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'EXTWG'.
  fieldcat-col_pos   = '71'.
  fieldcat-seltext_m = 'Ext.Matl.Grp'.
  fieldcat-seltext_l = 'Ext.Matl.Grp'.
  fieldcat-seltext_s = 'Ext.Matl.Grp'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.

  fieldcat-tabname = 'IVBRP1'.
  fieldcat-fieldname = 'EWBEZ'.
  fieldcat-col_pos   = '72'.
  fieldcat-seltext_m = 'Ext.Matl.Desc'.
  fieldcat-seltext_l = 'Ext.Matl.Desc'.
  fieldcat-seltext_s = 'Ext.Matl.Desc'.
  APPEND fieldcat TO fieldtab.
  CLEAR fieldcat.


  fieldcat-fieldname = 'SHIP_PARTY'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '73'.
  fieldcat-outputlen     = 10.
  fieldcat-ref_fieldname = 'KUNNR'.
  fieldcat-ref_tabname = 'LIKP'.
  fieldcat-seltext_l     = 'Ship-to-Party'.
  fieldcat-seltext_s     = 'Ship-to-Party'.
  fieldcat-seltext_m     = 'Ship-to-Party'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'PARTY_NAME'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '74'.
  fieldcat-outputlen     = 10.
  fieldcat-ref_fieldname = 'NAME1'.
  fieldcat-ref_tabname = 'KNA1'.
  fieldcat-seltext_l     = 'Ship-to-Party name'.
  fieldcat-seltext_s     = 'Ship-to-Party'.
  fieldcat-seltext_m     = 'Ship-to-Party'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.



  fieldcat-fieldname = 'AUART'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '75'.
  fieldcat-outputlen     = 10.
  fieldcat-ref_fieldname = 'AUART'.
  fieldcat-ref_tabname = 'VBAK'.
  fieldcat-seltext_l     = 'SD.Doc.Type'.
  fieldcat-seltext_s     = 'SD.Doc.Type'.
  fieldcat-seltext_m     = 'SD.Doc.Type'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'FR_AGT'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '76'.
  fieldcat-outputlen     = 10.
*  FIELDCAT-REF_FIELDNAME = ''.
  fieldcat-ref_tabname = 'VBPA'.
  fieldcat-seltext_l     = 'Freight service agt'.
  fieldcat-seltext_s     = 'Freight serv.agt'.
  fieldcat-seltext_m     = 'Freight.serv.agt'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'FORW_NAME'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '77'.
  fieldcat-outputlen     = 20.
*  FIELDCAT-REF_FIELDNAME = ''.
  fieldcat-ref_tabname = 'LFA1'.
  fieldcat-seltext_l     = 'Freight serv.agt Name'.
  fieldcat-seltext_s     = 'Freight.serv.agt.Name'.
  fieldcat-seltext_m     = 'Freight.serv.agt.Name'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.


  fieldcat-fieldname = 'LR_NO'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '78'.
  fieldcat-outputlen     = 15.
*  FIELDCAT-REF_FIELDNAME = ''.
  fieldcat-ref_tabname = 'LIKP'.
  fieldcat-seltext_l     = 'LR Number'.
  fieldcat-seltext_s     = 'LR No.'.
  fieldcat-seltext_m     = 'LR No.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.


  fieldcat-fieldname = 'VEHICLE'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '79'.
  fieldcat-outputlen     = 20.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Vehicle details'.
  fieldcat-seltext_s     = 'Vehicle det.'.
  fieldcat-seltext_m     = 'Vehicle det.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'FRC1_KWERT'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '80'.
  fieldcat-outputlen     = 17.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'SPCD Freight/Qty FRC1'.
  fieldcat-seltext_s     = 'SPCD Frgt./Qty'.
  fieldcat-seltext_m     = 'SPCD Frgt./Qty'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

*   TYPE KNA1-LAND1,
*       TYPE T005T-landx,
*       TYPE KNA1-LAND1,
*       TYPE T005T-landx,

  fieldcat-fieldname = 'SHP_CONTRY'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '81'.
  fieldcat-outputlen     = 04.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Shp.to Party Country'.
  fieldcat-seltext_s     = 'Shp.to Ctry.'.
  fieldcat-seltext_m     = 'Shp.to Ctry.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'SHP_CTRY_NAME'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '82'.
  fieldcat-outputlen     = 15.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Shp.to Party Ctry.Txt'.
  fieldcat-seltext_s     = 'Shp.to Ctry.'.
  fieldcat-seltext_m     = 'Shp.to Ctry.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'BILL_CONTRY'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '83'.
  fieldcat-outputlen     = 04.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Bill.to Party Country'.
  fieldcat-seltext_s     = 'Bill.to Ctry.'.
  fieldcat-seltext_m     = 'Bill.to Ctry.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'BILL_CTRY_NAME'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '84'.
  fieldcat-outputlen     = 15.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Bill.to Party Ctry.Txt'.
  fieldcat-seltext_s     = 'Bill.to Ctry.'.
  fieldcat-seltext_m     = 'Bill.to Ctry.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

*  Added by SaurabhK for GST_NO on Monday, August 07, 2017 13:04:19
  fieldcat-fieldname = 'GSTN_NO'.
  fieldcat-tabname = 'IVBRP1'.
*  fieldcat-col_pos       = '84'.
  fieldcat-outputlen     = 18.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Customer GSTN No'.
  fieldcat-seltext_s     = 'GSTN No'.
  fieldcat-seltext_m     = 'Cust. GSTN No'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.
* End of addition by SaurabhK for GSTN_NO

  fieldcat-fieldname = 'BSTKD'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos = '85'.
*  FIELDCAT-OUTPUTLEN     = 15.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME   = 'LIKP'.
  fieldcat-seltext_l     = 'Customer PO No.'.
  fieldcat-seltext_s     = 'PO No.'.
  fieldcat-seltext_m     = 'Cust.PO No.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'BSTDK'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '86'.
*  FIELDCAT-OUTPUTLEN     = 15.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Customer PO Date'.
  fieldcat-seltext_s     = 'PO date'.
  fieldcat-seltext_m     = 'Cust.PO dt.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

******field added by sachin
  fieldcat-fieldname = 'CITY'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '87'.
*  FIELDCAT-OUTPUTLEN     = 15.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'SH Party Location'.
  fieldcat-seltext_s     = 'SH Party Location'.
  fieldcat-seltext_m     = 'SH Party Location'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.


  fieldcat-fieldname = 'KONDA1'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '88'.
*  FIELDCAT-OUTPUTLEN     = 15.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Price group'.
  fieldcat-seltext_s     = 'Price group'.
  fieldcat-seltext_m     = 'Price group'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname = 'VTEXT1'.
  fieldcat-tabname = 'IVBRP1'.
  fieldcat-col_pos       = '89'.
*  FIELDCAT-OUTPUTLEN     = 15.
*  FIELDCAT-REF_FIELDNAME = ''.
*  FIELDCAT-REF_TABNAME = 'LIKP'.
  fieldcat-seltext_l     = 'Price group desc.'.
  fieldcat-seltext_s     = 'Price group desc.'.
  fieldcat-seltext_m     = 'Price group desc.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

*******end of added 0808.2014

  fieldcat-fieldname     = 'REF_NO'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '90'.
  fieldcat-seltext_l     = 'Sales Inv Ref No'.
  fieldcat-seltext_s     = 'Sales Inv Ref No'.
  fieldcat-seltext_m     = 'Sales Inv Ref No'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname     = 'REF_DATE'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '91'.
  fieldcat-seltext_l     = 'Sales Inv Ref Date'.
  fieldcat-seltext_s     = 'Sales Inv Ref Date'.
  fieldcat-seltext_m     = 'Sales Inv Ref Date'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.


  fieldcat-fieldname     = 'ZSTCEG'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '92'.
  fieldcat-seltext_l     = 'VAT/LST/Tin'.
  fieldcat-seltext_s     = 'VAT/LST/Tin'.
  fieldcat-seltext_m     = 'VAT/LST/Tin'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname     = 'SPART'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '93'.
  fieldcat-seltext_l     = 'Division'.
  fieldcat-seltext_s     = 'Division'.
  fieldcat-seltext_m     = 'Division'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.



  fieldcat-fieldname     = 'SPART_TXT'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '94'.
  fieldcat-seltext_l     = 'Division'.
  fieldcat-seltext_s     = 'Division'.
  fieldcat-seltext_m     = 'Division'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname     = 'ZLAND1'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '95'.
  fieldcat-seltext_l     = 'Destination Country'.
  fieldcat-seltext_s     = 'Dest.Cntry'.
  fieldcat-seltext_m     = 'Dest.Cntry'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname   = 'LANDX'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '96'.
  fieldcat-seltext_l     = 'Destination Country'.
  fieldcat-seltext_s     = 'Dest.Cntry'.
  fieldcat-seltext_m     = 'Dest.Cntry'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname   = 'ZTERM11'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '97'.
  fieldcat-seltext_l     = 'Payment Term'.
  fieldcat-seltext_s     = 'Payment Term'.
  fieldcat-seltext_m     = 'Payment Term'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname   = 'VTEXT11'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '98'.
  fieldcat-outputlen        = '30'.
  fieldcat-seltext_l     = 'Payment Term desc.'.
  fieldcat-seltext_s     = 'Payment Term desc.'.
  fieldcat-seltext_m     = 'Payment Term desc.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.
************************Start********************************     " added by NK on 23.12.2015
  fieldcat-fieldname     = 'KTGRD'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '99'.
  fieldcat-outputlen     = '3'.
  fieldcat-seltext_l     = 'AcctAssgGr'.
  fieldcat-seltext_s     = 'AcctAssgGr'.
  fieldcat-seltext_m     = 'AcctAssgGr'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.
*************************End*********************************
* ---- Added for Original Invoice for Cancelled Invoices => SaurabhK ---- *
  fieldcat-fieldname     = 'ORIG_INV'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '100'.
  fieldcat-seltext_l     = 'Orig. Inv.'.
  fieldcat-seltext_s     = 'Orig. Inv.'.
  fieldcat-seltext_m     = 'Orig. Inv.'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname     = 'ORIG_INV_ITM'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '101'.
  fieldcat-seltext_l     = 'Orig. Item'.
  fieldcat-seltext_s     = 'Orig. Item'.
  fieldcat-seltext_m     = 'Orig. Item'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.

  fieldcat-fieldname     = 'ORIG_INV_TYP'.
  fieldcat-tabname       = 'IVBRP1'.
  fieldcat-col_pos       = '102'.
  fieldcat-seltext_l     = 'Orig. Inv. Doc. Type'.
  fieldcat-seltext_s     = 'Orig. Type'.
  fieldcat-seltext_m     = 'Orig. Type'.
  APPEND fieldcat TO p_fieldtab.
  CLEAR fieldcat.
* ---- End of addition ---- *

ENDFORM.                               " INITIALIZE_FIELDCAT

*&---------------------------------------------------------------------
FORM build_eventtab USING    p_events TYPE slis_t_event.
  DATA: ls_event TYPE slis_alv_event.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = p_events.

  READ TABLE p_events WITH KEY name = slis_ev_top_of_page
  INTO ls_event.
  IF sy-subrc = 0.
    MOVE formname_top_of_page TO ls_event-form.
    APPEND ls_event TO p_events.
  ENDIF.

  ls_event-name = 'USER_COMMAND'.                                     " Event Internal Table
  ls_event-form = 'ZUC'.
  APPEND ls_event TO p_events.

ENDFORM.                               " BUILD_EVENTTAB
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_for_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      p_vari = gx_variant-variant.
    ENDIF.
    flag = 1.
  ENDIF.

ENDFORM.                               " F4_FOR_VARIANT



*---------------------------------------------------------------------*
*  -->  P_HEADING                                                     *
*---------------------------------------------------------------------*
FORM build_comment USING p_heading TYPE slis_t_listheader.
  DATA gt_stack-is_layout-s_variant LIKE p_vairaint.
  DATA: hline    TYPE slis_listheader,
        text(60) TYPE c,
        sep(20)  TYPE c.
  CLEAR: hline, text.
*  IF option IS INITIAL.
*    hline-typ  = 'H'.
* ELSE.
  hline-typ  = 'S'.
* ENDIF.
  WRITE: 'RunDate:' TO text,
  sy-datum TO text+9,
  'Period' TO text+23.
  IF NOT s_fkdat-low IS INITIAL.
    WRITE      s_fkdat-low TO text+31.
    WRITE 'To' TO text+42.
  ELSE.
    WRITE ' UpTo ' TO text+31.
  ENDIF.
  IF NOT s_fkdat-high IS INITIAL.
    WRITE  s_fkdat-high TO text+45.
  ELSE.
    WRITE sy-datum TO text+45.
  ENDIF.
  IF NOT s_fkdat-low IS INITIAL AND  s_fkdat-high IS INITIAL.
    WRITE  s_fkdat-low TO text+45.
  ENDIF.
  hline-info = text.
  APPEND hline TO p_heading.
  CLEAR text.
  IF cus NE space.
    hline-info = 'Customer Wise '.
    APPEND hline TO p_heading.
    CLEAR text.
  ENDIF.
  IF mat NE space.
    hline-info = 'Material Wise '.
    APPEND hline TO p_heading.
    CLEAR text.
  ENDIF.
  IF inv NE space.
    hline-info = 'Report with No Selection Criteria '.
    APPEND hline TO p_heading.
    CLEAR text.
  ENDIF.
  IF NOT g_variant-text IS INITIAL.
    MOVE g_variant-text TO text.
    hline-info = text.
    APPEND hline TO p_heading.
    CLEAR text.

    IF s_fkdat-low IS INITIAL AND s_fkdat-high IS INITIAL.
      MOVE 'Up To ' TO text+25.
      WRITE sy-datum TO text+32 DD/MM/YYYY.
    ENDIF.
    IF NOT s_fkdat-low IS INITIAL AND s_fkdat-high IS INITIAL.
      MOVE 'On ' TO text+25.
      WRITE s_fkdat-low TO text+32 DD/MM/YYYY.

    ENDIF.
    IF NOT s_fkdat-low IS INITIAL AND NOT s_fkdat-high IS INITIAL.
      MOVE 'From ' TO text+25.
      WRITE s_fkdat-low TO text+32 DD/MM/YYYY.
      MOVE 'To ' TO text+44.
      WRITE s_fkdat-high TO text+49 DD/MM/YYYY.

    ENDIF.
    IF  s_fkdat-low IS INITIAL AND NOT s_fkdat-high IS INITIAL.
      MOVE 'Up To ' TO text+25.
      WRITE s_fkdat-high TO text+32 DD/MM/YYYY.

    ENDIF.
    hline-info = text.
    APPEND hline TO p_heading.
    CLEAR text.
  ENDIF.
  IF NOT s_vkbur-low IS INITIAL AND s_vkbur-high IS INITIAL.
    MOVE 'For Depot ' TO text.
    PERFORM get_pname USING s_vkbur-low CHANGING name1.
    WRITE name1 TO text+11 DD/MM/YYYY.

  ENDIF.
  IF NOT s_vkbur-low IS INITIAL AND NOT s_vkbur-high IS INITIAL.
    MOVE 'From Depot ' TO text.
    PERFORM get_pname USING s_vkbur-low CHANGING name1.
    WRITE name1 TO text+11.
    MOVE 'To ' TO text+34.
    PERFORM get_pname USING s_vkbur-low CHANGING name1.
    WRITE name1 TO text+38.
  ENDIF.
  IF s_vkbur-low IS INITIAL AND NOT s_vkbur-high IS INITIAL.
    MOVE ' To Depot ' TO text.
    PERFORM get_pname USING s_vkbur-high CHANGING name1.
    WRITE name1(20) TO text+11 .

  ENDIF.
  hline-info = text.
  APPEND hline TO p_heading.
  CLEAR text.
  IF NOT p_bukrs IS INITIAL.
    SELECT SINGLE butxt FROM t001 INTO butxt
    WHERE bukrs EQ p_bukrs
    AND spras EQ sy-langu.
    MOVE 'For' TO text.
    MOVE butxt TO text+6.
    hline-info = text.
    APPEND hline TO p_heading.
    CLEAR text.
  ENDIF.





*  INCLUDE ZSELECTIONSALV.
ENDFORM.                               " BUILD_COMMENT

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM top_of_page.
  DATA : rs_variant LIKE disvariant,
         pline      TYPE slis_listheader,
         v_lines    TYPE i.
  CLEAR rs_variant.
  IMPORT rs_variant FROM MEMORY ID 'VARIANT'.
*  FREE MEMORY ID 'VARIANT'.
  IF NOT rs_variant-text IS INITIAL.
    pline-typ = 'S'.
    pline-info = rs_variant-text.
    APPEND pline TO p_heading.

  ENDIF.

  CALL FUNCTION 'Z6XX_REUSE_ALV_COMMENTARY_WR'
    EXPORTING
      it_list_commentary = p_heading.

  IF NOT rs_variant-text IS INITIAL.
    DESCRIBE TABLE p_heading LINES v_lines.
    DELETE p_heading INDEX v_lines.

  ENDIF.

ENDFORM.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  INITIALIZE_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_variant.
  g_save = 'A'.
  CLEAR g_variant.
  g_variant-report = repname.
  g_variant-variant = p_vari.
  gx_variant = g_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = gx_variant-variant.
    g_variant = gx_variant.

  ENDIF.
  layout-get_selinfos = 'X'.
  layout-group_change_edit = 'X'.

  alv_print-no_print_selinfos  = 'X'.
  alv_print-no_coverpage       = 'X'.
  alv_print-no_print_listinfos = 'X'.

ENDFORM.                               " INITIALIZE_VARIANT
*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_of_selection_screen.
  PERFORM initialize_variant.
ENDFORM.                               " PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_layout.
  layout-f2code       = f2code.
  layout-zebra        = 'X'.
  layout-detail_popup = 'X'.

ENDFORM.                               " BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM READ_TEXT                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  T_ID                                                          *
*  -->  T_NAM                                                         *
*  -->  OBJ                                                           *
*  -->  TEXT1                                                         *
*---------------------------------------------------------------------*
FORM read_text USING t_id t_nam obj CHANGING text1.
  REFRESH :  tlines . CLEAR tlines.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = t_id
      language                = 'E'
      name                    = t_nam
      object                  = obj
*     ARCHIVE_HANDLE          = 0
*    IMPORTING
*     HEADER                  =
    TABLES
      lines                   = tlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc EQ 0.
    READ TABLE tlines INDEX 1.
    text1 = tlines-tdline.
    CONDENSE text1.
  ENDIF.
ENDFORM.                    "read_text

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_INTO_IVBRP1
*&---------------------------------------------------------------------*
FORM get_data_into_ivbrp1.
  DATA: temp TYPE lfimg.
  DATA: po_knumv TYPE ekko-knumv.
*  SELECT * FROM Z6SDD_VBRK_VBRP AS A JOIN knvv as b
*                                      on A~KUNNR = B~KUNNR
*                                      AND A~VKORG = B~VKORG
*                                      AND A~VTWEG = B~VTWEG
*                                      AND A~SPART = B~SPART
*                                      INTO CORRESPONDING FIELDS  OF TABLE ivbrp1
*                                      WHERE A~vbeln IN s_vbeln
*                                        AND A~fkdat IN s_fkdat
*                                        AND A~fkart IN s_fkart
*                                        AND A~vtweg IN s_vtweg
*                                        AND A~vkorg IN s_vkorg
*                                        AND A~regio IN s_regio
*                                        and B~bzirk in s_bzirk
*                                        and A~kvgr1 in s_kvgr1
*                                        and A~spart in s_spart
**                                        AND werks IN s_werks
*                                        AND A~matnr IN s_matnr
*                                        AND A~bukrs EQ p_bukrs
*                                        AND A~kdgrp_auft IN s_kdgrp
*                                         AND A~VKGRP IN S_VKGRP
*                                        AND A~VKBUR IN S_VKBUR
*                                        AND ( A~sfakn EQ space
*                                        AND  A~fksto EQ space
*                                        AND  A~rfbsk NE 'E' )
*                                        AND A~kunnr in s_kunnr.

  SELECT kunnr bzirk vkorg vtweg spart vkgrp kvgr1 ktgrd     " modified by NarenK on 23.12.2015
  FROM knvv INTO CORRESPONDING FIELDS OF TABLE it_knvv
  WHERE kunnr  IN s_kunnr
  AND vtweg IN s_vtweg
  AND spart IN s_spart
  AND bzirk IN s_bzirk
  AND kvgr1 IN s_kvgr1
  AND vkgrp IN s_vkgrp " <-- CHANGES DONE IN selection of Sales Group as per buisnes requirement disscuss with mitra sir on 28.07.2015
*     now Sales Group will fetch from master
  AND ktgrd IN s_ktgrd. " added by NarenK on 23.12.2015
*    AND VKGRP IN S_VKGRP. " this will select all customers belongs to territory enter at selection screen
*                           and based on customers below sales records will be selected .
*                            these chng done on 20.02.2015 after disscussion with mitra sir

  CHECK it_knvv IS NOT INITIAL.

  SELECT * FROM z6sdd_vbrk_vbrp INTO CORRESPONDING FIELDS
  OF TABLE ivbrp1
  FOR ALL ENTRIES IN it_knvv
  WHERE vbeln IN s_vbeln
  AND fkdat IN s_fkdat
  AND fkart IN s_fkart
  AND vtweg IN s_vtweg
  AND vkorg IN s_vkorg
  AND regio IN s_regio
*                                        and bzirk in s_bzirk
*                                        and kvgr1 in s_kvgr1
  AND spart IN s_spart
**                                        AND werks IN s_werks
  AND matnr IN s_matnr
  AND bukrs = p_bukrs
  AND kdgrp_auft IN s_kdgrp
*                                       AND VKGRP IN S_VKGRP
  AND vkbur IN s_vkbur
*                                       AND ( SFAKN EQ SPACE "Cancelled billing document number
*                                       AND  FKSTO EQ SPACE " Billing document is cancelled
  AND  rfbsk NE 'E'  " Status for transfer to accounting
  AND kunnr = it_knvv-kunnr
  AND fkart <> 'ZF8' AND fkart <> 'ZSTO'.
  SORT  s_fkart BY low.
  DELETE ADJACENT DUPLICATES FROM s_fkart.

  LOOP AT s_fkart .
    IF s_fkart-high = 'ZF8' OR s_fkart-low = 'ZF8'.

      SELECT * FROM z6sdd_vbrk_vbrp
      APPENDING CORRESPONDING FIELDS OF TABLE ivbrp1
      FOR ALL ENTRIES IN it_knvv
      WHERE vbeln IN s_vbeln
      AND fkdat IN s_fkdat
*                                       AND FKART IN S_FKART
      AND vtweg IN s_vtweg
      AND vkorg IN s_vkorg
      AND regio IN s_regio
*                                        and bzirk in s_bzirk
*                                        and kvgr1 in s_kvgr1
*                                        AND SPART IN S_SPART
**                                        AND werks IN s_werks
      AND matnr IN s_matnr
      AND bukrs = p_bukrs
      AND kdgrp_auft IN s_kdgrp
*                                       AND VKGRP IN S_VKGRP
      AND vkbur IN s_vkbur
*                                       AND ( SFAKN EQ SPACE "Cancelled billing document number
*                                       AND  FKSTO EQ SPACE " Billing document is cancelled
      AND  rfbsk NE 'E'  " Status for transfer to accounting
      AND kunnr = it_knvv-kunnr
      AND fkart = 'ZF8'.

    ELSEIF s_fkart-high = 'ZSTO' OR s_fkart-low = 'ZSTO'.

      SELECT * FROM z6sdd_vbrk_vbrp INTO CORRESPONDING FIELDS
      OF TABLE ivbrp1
      FOR ALL ENTRIES IN it_knvv
      WHERE vbeln IN s_vbeln
      AND fkdat IN s_fkdat
      AND fkart IN s_fkart
      AND vtweg IN s_vtweg
      AND vkorg IN s_vkorg
      AND regio IN s_regio
*                                        and bzirk in s_bzirk
*                                        and kvgr1 in s_kvgr1
      AND spart IN s_spart
      AND werks IN s_vkbur
      AND matnr IN s_matnr
      AND bukrs = p_bukrs
      AND kdgrp_auft IN s_kdgrp
*                                       AND VKGRP IN S_VKGRP
*                                       AND vkbur IN s_vkbur
*                                       AND ( SFAKN EQ SPACE "Cancelled billing document number
*                                       AND  FKSTO EQ SPACE " Billing document is cancelled
      AND  rfbsk NE 'E'  " Status for transfer to accounting
      AND kunnr = it_knvv-kunnr
      AND fkart = 'ZSTO'.

    ENDIF.
  ENDLOOP.


  DELETE ivbrp1 WHERE fkimg EQ 0.
  CLEAR ivbrp1.
  CHECK ivbrp1[] IS NOT INITIAL.

  PERFORM collect_data.

  LOOP AT ivbrp1.
    IF ivbrp1-fkart = 'ZSTO'.
      IF ivbrp1-vkbur IS INITIAL.
        ivbrp1-vkbur = ivbrp1-werks.
      ENDIF.
    ENDIF.

    IF s_auart IS NOT INITIAL.
      READ TABLE it_vbak INTO wa_vbak WITH KEY vbeln = ivbrp1-aubel.
      IF sy-subrc <> 0.
        DELETE ivbrp1 WHERE aubel = ivbrp1-aubel.
        CLEAR ivbrp1.
      ELSE.
        ivbrp1-auart = wa_vbak-auart.
      ENDIF.
    ENDIF.

    IF ivbrp1 IS NOT INITIAL.

      READ TABLE it_vbak INTO wa_vbak WITH KEY vbeln = ivbrp1-aubel auart = 'ZTSN' BINARY SEARCH." REMOVE TSTANES SO AND f2 AFETR gst
      IF sy-subrc = 0.
        DELETE ivbrp1 WHERE aubel = ivbrp1-aubel.
        CLEAR ivbrp1.
      ENDIF.


      READ TABLE it_vbak INTO wa_vbak WITH KEY vbeln = ivbrp1-aubel BINARY SEARCH.
      IF sy-subrc = 0.
        ivbrp1-auart = wa_vbak-auart.
        IF wa_vbak-auart NOT IN s_auart.
          CLEAR wa_vbak.
          CONTINUE.
        ENDIF.
      ENDIF.

      READ TABLE it_knvv INTO wa_knvv WITH KEY kunnr = ivbrp1-kunnr.
      IF sy-subrc = 0.
        ivbrp1-bzirk = wa_knvv-bzirk. " SALES dISTRICT
*        IVBRP1-SPART = WA_KNVV-SPART. " DIVISION
        ivbrp1-vkgrp = wa_knvv-vkgrp.
        ivbrp1-kvgr1 = wa_knvv-kvgr1.
        ivbrp1-ktgrd = wa_knvv-ktgrd. " added by NarenK on 23.12.2015
*        IVBRP1-VTWEG = WA_KNVV-VTWEG.
      ENDIF.

      SELECT SINGLE lifnr
      FROM vbpa
      INTO ivbrp1-fr_agt
      WHERE vbeln = ivbrp1-vgbel
      AND parvw = 'TF'.
      IF ivbrp1-fr_agt IS INITIAL.
        SELECT SINGLE lifnr
        FROM vbpa
        INTO ivbrp1-fr_agt
        WHERE vbeln = ivbrp1-vgbel
        AND parvw = 'SP'.
      ENDIF.


      SELECT SINGLE name1
      FROM lfa1
      INTO ivbrp1-forw_name
      WHERE lifnr = ivbrp1-fr_agt.

      SELECT SINGLE xabln "LR NUMBER
      FROM likp
      INTO ivbrp1-lr_no
      WHERE vbeln = ivbrp1-vgbel.

      l_name = ivbrp1-vgbel.


*     Add FRC1 PO Condition in column
*      if IVBRP1-fkart = 'ZF8'.
      SELECT SINGLE knumv FROM ekko INTO po_knumv
      WHERE ebeln = ivbrp1-aubel.
      IF sy-subrc <> 0. CLEAR : po_knumv. ENDIF.

*      IF IVBRP1-SPART = '20'. " comment because in ZF8 billing division is always 10
      SELECT SINGLE kbetr
      FROM konv INTO ivbrp1-frc1_kbetr
      WHERE knumv = po_knumv
      AND kposn = ivbrp1-aupos
      AND kschl = 'FRC1'.

      IF sy-subrc <> 0.
        CLEAR : ivbrp1-frc1_kbetr.
      ENDIF.

      IF ivbrp1-frc1_kbetr > 0.
        ivbrp1-frc1_kwert =  ivbrp1-fkimg * ivbrp1-frc1_kbetr.
      ENDIF.
*      ENDIF.

      CLEAR: ivbrp1-konda1.
      SELECT SINGLE konda FROM vbkd INTO ivbrp1-konda1
      WHERE  vbeln = ivbrp1-aubel
      AND posnr = ivbrp1-aupos.

      IF sy-subrc = 0 .

        SELECT SINGLE vtext
        FROM t188t
        INTO ivbrp1-vtext1
        WHERE spras = 'EN'
        AND   konda = ivbrp1-konda1.

*         vtext1 = gv_text.
*         clear : gv_text.
      ENDIF.

**********code added by sachin 30.09.2014****
*if not IVBRP1[] is initial.
*select VBELN POSNR BSTKD bstdk konda
*FROM VBKD
*into corresponding fields of table it_vbkd1
*FOR ALL ENTRIES IN IVBRP1
*WHERE VBELN = IVBRP1-aubel
*AND POSNR = IVBRP1-aupos.
*endif.
***********end of added code ****************
*
*********code added by sachin 30.09.2014.
*        READ TABLE IT_VBKD1 INTO WA_VBKD1 WITH KEY VBELN = IVBRP1-AUBEL
*                                                   posnr = IVBRP1-AUPOS.
**                                                 BINARY SEARCH.
*        if sy-subrc = 0 .
*
*         konda1 = WA_VBKD1-konda.
*
*         select single VTEXT
*         from T188T
*         into gv_text
*         where SPRAS = 'EN'
*         and   KONDA = konda1.
*
*         vtext1 = gv_text.
**         clear : gv_text.
*        endif.
************end of added code 30.09.2014

*      select single KWERT
*        FROM KONV INTO IVBRP1-FRC1_KWERT
*        WHERE KNUMV = po_knumv
*        AND KPOSN = IVBRP1-AUPOS
*        AND KSCHL = 'FRC1'.
*        IF SY-SUBRC <> 0. CLEAR : IVBRP1-FRC1_KWERT. ENDIF.

*      endif.
*******************************************************

      SELECT * FROM stxh INTO TABLE tab_stxh "Transport info.
      WHERE tdname = ivbrp1-vgbel
      AND tdid = 'ZTRA' AND tdspras = 'E'.
      IF sy-subrc = 0.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
*           CLIENT   = SY-MANDT
            id       = 'ZTRA'
            language = 'E'
            name     = l_name
            object   = 'VBBK'
*           ARCHIVE_HANDLE                = 0
*           LOCAL_CAT                     = ' '
*      IMPORTING
*           HEADER   =
          TABLES
            lines    = lv_vehicle
*      EXCEPTIONS
*           ID       = 1
*           LANGUAGE = 2
*           NAME     = 3
*           NOT_FOUND                     = 4
*           OBJECT   = 5
*           REFERENCE_CHECK               = 6
*           WRONG_ACCESS_TO_ARCHIVE       = 7
*           OTHERS   = 8
          .
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        READ TABLE lv_vehicle INDEX 1.
        IF lv_vehicle-tdline NE ''.
          MOVE lv_vehicle-tdline TO ivbrp1-vehicle.
        ENDIF.
      ELSE.
        CLEAR: ivbrp1-vehicle.
      ENDIF.
* Comment By AB27042017
**********************************************************************  added by NK ~ 03.10.2016
*      if ivbrp1-waerk = 'EUR4'.
*        ivbrp1-netwr = ivbrp1-netwr / 10.
*      endif.
**********************************************************************
* Comment By AB27042017
      CLEAR: wa_vbap, wa_vbfa, wa_vbak.
      READ TABLE it_vbap INTO wa_vbap WITH KEY vbeln = ivbrp1-aubel
      posnr = ivbrp1-aupos." BINARY SEARCH.
      IF sy-subrc = 0.
        ivbrp1-kwmeng = wa_vbap-kwmeng.
        CLEAR: ivbrp1-zland1  , ivbrp1-landx.
        ivbrp1-zland1 = wa_vbap-zland1.
        SELECT SINGLE landx FROM t005t INTO ivbrp1-landx WHERE spras = sy-langu
        AND land1 = ivbrp1-zland1.

      ENDIF.

      CLEAR: ivbrp1-rfmng, temp.
      LOOP AT it_vbfa INTO wa_vbfa WHERE vbelv = ivbrp1-aubel AND posnv = ivbrp1-aupos.
        AT NEW vbeln.
          REFRESH: it_lips. CLEAR: wa_lips.
          SELECT vbeln posnr lfimg FROM lips INTO TABLE it_lips WHERE vbeln = wa_vbfa-vbeln.
          IF sy-subrc = 0.
            SORT it_lips BY vbeln posnr.
          ENDIF.
        ENDAT.

        READ TABLE it_lips INTO wa_lips WITH KEY vbeln = wa_vbfa-vbeln
        posnr = wa_vbfa-posnv.
        IF sy-subrc = 0.
          ivbrp1-rfmng = ivbrp1-rfmng + wa_lips-lfimg.
        ENDIF.
*
*      SELECT SINGLE lfimg FROM lips INTO temp
*        WHERE vbeln = wa_vbfa-vbeln
*        AND posnr = wa_vbfa-posnv.
*      ivbrp1-rfmng = ivbrp1-rfmng + temp.
      ENDLOOP.

* ---- Added for fetching Corresp. Original Invoice of Cancelled Invoice 'S1' or 'RE' => SaurabhK ---- *
* ---- Monday, September 04, 2017 23:45:58 ---- *
* ---- IRDK929081 ---- *
      IF ( ivbrp1-fkart EQ 'S1' OR ivbrp1-fkart EQ 'RE' ) AND ivbrp1-vbtyp EQ 'N'.
        MOVE ivbrp1-sfakn TO ivbrp1-orig_inv.
        MOVE ivbrp1-posnr TO ivbrp1-orig_inv_itm.

        SELECT SINGLE fkart FROM vbrk INTO ivbrp1-orig_inv_typ WHERE vbeln EQ ivbrp1-orig_inv.
      ENDIF.
* ---- End of addition ---- *

      SELECT SINGLE kunnr FROM likp INTO ivbrp1-ship_party WHERE vbeln = ivbrp1-vgbel.
*********code added by sachin 08.08.2014 """"city1 added by sachin
      " Modified by SaurabhK for GSTN_NO on Monday, August 07, 2017 12:55:05
      SELECT SINGLE name1 land1 adrnr stcd3 FROM kna1 INTO (ivbrp1-party_name, ivbrp1-shp_contry, ivbrp1-adrnr, ivbrp1-gstn_no )
      WHERE kunnr = ivbrp1-ship_party
      AND spras EQ sy-langu.
      " End of modification for GSTN_NO by SaurabhK
      SELECT SINGLE city1 FROM adrc INTO (ivbrp1-city)
      WHERE addrnumber = ivbrp1-adrnr.

***********end of addedcode

*      SELECT SINGLE NAME1 LAND1 FROM KNA1 INTO (IVBRP1-PARTY_NAME , IVBRP1-SHP_CONTRY )
*        WHERE KUNNR = IVBRP1-SHIP_PARTY
*        AND SPRAS EQ SY-LANGU.

      SELECT SINGLE landx FROM t005t INTO ivbrp1-shp_ctry_name
      WHERE land1 = ivbrp1-shp_contry
      AND  spras EQ sy-langu.

      SELECT SINGLE land1 FROM kna1 INTO (ivbrp1-bill_contry )
      WHERE kunnr = ivbrp1-kunnr
      AND spras EQ sy-langu.

      SELECT SINGLE landx FROM t005t INTO ivbrp1-bill_ctry_name
      WHERE land1 = ivbrp1-bill_contry
      AND  spras EQ sy-langu.

      READ TABLE it_vbak INTO wa_vbak WITH KEY vbeln = ivbrp1-aubel BINARY SEARCH.
      IF sy-subrc = 0.
        ivbrp1-delay = ivbrp1-fkdat - wa_vbak-vdatu.
      ENDIF.
      ivbrp1-balance = ivbrp1-kwmeng - ivbrp1-rfmng.

      READ TABLE it_tvkbt INTO wa_tvkbt WITH KEY vkbur = ivbrp1-vkbur BINARY SEARCH.
      IF sy-subrc = 0.
        ivbrp1-bezei = wa_tvkbt-bezei.
      ENDIF.

      READ TABLE it_tvgrt INTO wa_tvgrt WITH KEY vkgrp = ivbrp1-vkgrp BINARY SEARCH.
      IF sy-subrc = 0.
        ivbrp1-l_bezei = wa_tvgrt-bezei.
      ENDIF.

* ---- Added for HSN Code on Sunday, September 03, 2017 12:46:55 => SaurabhK ---- *
      CLEAR wa_marc.
      READ TABLE it_marc INTO wa_marc WITH KEY matnr = ivbrp1-matnr.
*                                               werks = ivbrp1-werks.
      IF sy-subrc = 0.
        MOVE wa_marc-steuc TO ivbrp1-hsn_no.
        " HSN Code Descriptions
        CLEAR wa_t604n.
        READ TABLE it_t604n INTO wa_t604n WITH KEY steuc = wa_marc-steuc.
        IF sy-subrc = 0.
          MOVE wa_t604n-text1 TO ivbrp1-hsn_text.
        ENDIF.
      ENDIF.
* ---- End of addition ---- *

      READ TABLE it_mch1 INTO wa_mch1 WITH KEY matnr = ivbrp1-matnr
      charg = ivbrp1-charg BINARY SEARCH.
      IF sy-subrc = 0.
        ivbrp1-vfdat = wa_mch1-vfdat.
      ENDIF.

      ON CHANGE OF ivbrp1-vgbel.
        CLEAR : traid.
        READ TABLE it_likp INTO wa_likp WITH KEY vbeln = ivbrp1-vgbel BINARY SEARCH.
        IF sy-subrc = 0.
          traid = wa_likp-traid.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-matnr.
        CLEAR : bismt,pckg.
        READ TABLE it_mara INTO wa_mara WITH KEY matnr = ivbrp1-matnr BINARY SEARCH.
        IF sy-subrc = 0.
          extwg = wa_mara-extwg.
          bismt = wa_mara-bismt.
          SPLIT bismt AT ' ' INTO bismt pckg.
          READ TABLE it_twewt INTO wa_twewt WITH KEY extwg = wa_mara-extwg BINARY SEARCH.
          IF sy-subrc = 0.
            ewbez = wa_twewt-ewbez.
          ENDIF.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-werks.
        CLEAR : bwrks.
        READ TABLE it_z6ppa_plnt_map INTO wa_z6ppa_plnt_map WITH KEY werks = ivbrp1-werks BINARY SEARCH.
        IF sy-subrc = 0.
          bwrks = wa_z6ppa_plnt_map-bwrks.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-vbeln OR ivbrp1-posnr.
        CLEAR: lifnr,bstkd, bstdk.
        READ TABLE it_vbpa INTO wa_vbpa WITH KEY vbeln = ivbrp1-vbeln BINARY SEARCH.
        IF sy-subrc = 0.
          lifnr = wa_vbpa-lifnr.
        ENDIF.
        READ TABLE it_vbkd INTO wa_vbkd WITH KEY vbeln = ivbrp1-aubel
        BINARY SEARCH.
        IF sy-subrc = 0.
          bstkd = wa_vbkd-bstkd.
*
          CONCATENATE wa_vbkd-bstdk+06(02)'.' wa_vbkd-bstdk+04(02) '.' wa_vbkd-bstdk(04) INTO bstdk.
        ENDIF.
*********code added by sachin 30.09.2014.
*        READ TABLE IT_VBKD1 INTO WA_VBKD1 WITH KEY VBELN = IVBRP1-AUBEL
*                                                   posnr = IVBRP1-AUPOS
*                                                 BINARY SEARCH.
*        if sy-subrc = 0 .
*
*         konda1 = WA_VBKD1-konda.
*
*         select single VTEXT
*         from T188T
*         into gv_text
*         where SPRAS = 'EN'
*         and   KONDA = konda1.
*
*         vtext1 = gv_text.
**         clear : gv_text.
*        endif.
************end of added code 30.09.2014
      ENDON.

      ON CHANGE OF ivbrp1-bzirk.
        CLEAR : bztxt.
        READ TABLE it_t171t INTO wa_t171t WITH KEY bzirk = ivbrp1-bzirk BINARY SEARCH.
        IF sy-subrc = 0.
          bztxt = wa_t171t-bztxt.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-vtweg.
        CLEAR : vtext.
        READ TABLE it_tvtwt INTO wa_tvtwt WITH KEY vtweg = ivbrp1-vtweg BINARY SEARCH.
        IF sy-subrc = 0.
          vtext = wa_tvtwt-vtext.
        ENDIF.
      ENDON.

*-- For retrieving text for Customer Group
      ON CHANGE OF ivbrp1-kdgrp_auft.
        CLEAR : ktext.
        READ TABLE it_t151t INTO wa_t151t WITH KEY kdgrp = ivbrp1-kdgrp_auft BINARY SEARCH.
        IF sy-subrc = 0.
          ktext = wa_t151t-ktext.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-kvgr1.
        CLEAR : srtxt.
        READ TABLE it_tvv1t INTO wa_tvv1t WITH KEY kvgr1 = ivbrp1-kvgr1 BINARY SEARCH.
        IF sy-subrc = 0.
          srtxt = wa_tvv1t-bezei.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-matkl.
        CLEAR : wgbez.
        READ TABLE it_t023t INTO wa_t023t WITH KEY matkl = ivbrp1-matkl BINARY SEARCH.
        IF sy-subrc = 0.
          wgbez = wa_t023t-wgbez.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-mvgr1.
        CLEAR : gr1tx.
        READ TABLE it_tvm1t INTO wa_tvm1t WITH KEY mvgr1 = ivbrp1-mvgr1 BINARY SEARCH.
        IF sy-subrc = 0.
          gr1tx = wa_tvm1t-bezei.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-mvgr2.
        CLEAR : gr2tx.
        READ TABLE it_tvm2t INTO wa_tvm2t WITH KEY mvgr2 = ivbrp1-mvgr2 BINARY SEARCH.
        IF sy-subrc = 0.
          gr2tx = wa_tvm2t-bezei.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-mvgr3.
        CLEAR : gr3tx.
        READ TABLE it_tvm3t INTO wa_tvm3t WITH KEY mvgr3 = ivbrp1-mvgr3 BINARY SEARCH.
        IF sy-subrc = 0.
          gr3tx = wa_tvm3t-bezei.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-mvgr4.
        CLEAR : gr4tx.
        READ TABLE it_tvm4t INTO wa_tvm4t WITH KEY mvgr4 = ivbrp1-mvgr4 BINARY SEARCH.
        IF sy-subrc = 0.
          gr4tx = wa_tvm4t-bezei.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-mvgr5.
        CLEAR : gr5tx.
        READ TABLE it_tvm5t INTO wa_tvm5t WITH KEY mvgr5 = ivbrp1-mvgr5 BINARY SEARCH.
        IF sy-subrc = 0.
          gr5tx = wa_tvm5t-bezei.
        ENDIF.
      ENDON.

      ON CHANGE OF ivbrp1-prodh.
        CLEAR : phtxt.
        READ TABLE it_t179t INTO wa_t179t WITH KEY prodh = ivbrp1-prodh BINARY SEARCH.
        IF sy-subrc = 0.
          phtxt = wa_t179t-vtext.
        ENDIF.
      ENDON.
*      ON CHANGE OF ivbrp1-zterm.
*        CLEAR : due_days.
*        SELECT SINGLE ztag1  FROM t052 INTO due_days
*                                           WHERE zterm EQ ivbrp1-zterm.
*      ENDON.
*
*      ivbrp1-d_date = ivbrp1-fkdat + due_days.

*    SELECT SINGLE KUNNR FROM VBPA INTO IVBRP1-KUNNR
*                                  WHERE VBELN EQ IVBRP1-VBELN AND
*                                               PARVW EQ 'WE'.
*
*    SELECT SINGLE NAME1 FROM KNA1 INTO IVBRP1-NAME1
*                                   WHERE KUNNR EQ IVBRP1-KUNRG
*                                   AND SPRAS EQ SY-LANGU.
*    SELECT SINGLE NAME1 FROM KNA1 INTO IVBRP1-NAME2
*                                   WHERE KUNNR EQ IVBRP1-KUNNR
*                                   AND SPRAS EQ SY-LANGU.
*   PERFORM GETDATASUM USING IVBRP1-KNUMV IVBRP1-POSNR CHANGING
*                            IVBRP1-ZBASEPRICE.
      ivbrp1-lifnr = lifnr.
      ivbrp1-bztxt = bztxt.
      ivbrp1-ktext = ktext.
      ivbrp1-bstkd = bstkd.
      ivbrp1-bstdk = bstdk.
      ivbrp1-vtext = vtext.
      ivbrp1-traid = traid.
      ivbrp1-srtxt = srtxt.
      ivbrp1-wgbez = wgbez.
      ivbrp1-phtxt = phtxt.
      ivbrp1-bismt = bismt.
      ivbrp1-extwg = extwg.
      ivbrp1-ewbez = ewbez.
      ivbrp1-pckg  = pckg.
      ivbrp1-bplnt = bwrks.
      ivbrp1-gr1tx = gr1tx.
      ivbrp1-gr2tx = gr2tx.
      ivbrp1-gr3tx = gr3tx.
      ivbrp1-gr4tx = gr4tx.
      ivbrp1-gr5tx = gr5tx.
*      IVBRP1-konda1 = konda1.
*      IVBRP1-VTEXT1 = VTEXT1.

      IF pk1 NE space AND pk1d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk1 CHANGING
          ivbrp1-k1 ivbrp1-k1r.
        IF sy-subrc EQ 0.
          MOVE pk1d TO ivbrp1-k1d.
        ENDIF.
      ELSE.
        ivbrp1-k1 = 0.
      ENDIF.

      IF pk2 NE space AND pk2d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk2 CHANGING
          ivbrp1-k2 ivbrp1-k2r.
        IF sy-subrc EQ 0.
          MOVE pk2d TO ivbrp1-k2d.
        ENDIF.
      ELSE.
        ivbrp1-k2 = 0.
      ENDIF.
      IF pk3 NE space AND pk3d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk3 CHANGING
          ivbrp1-k3 ivbrp1-k3r.

        IF sy-subrc EQ 0.
          MOVE pk3d TO ivbrp1-k3d.
        ENDIF.
      ELSE.
        ivbrp1-k3 = 0.
      ENDIF.
      IF pk4 NE space AND pk4d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk4 CHANGING
          ivbrp1-k4 ivbrp1-k4r.

        IF sy-subrc EQ 0.
          MOVE pk4d TO ivbrp1-k4d.
        ENDIF.
      ELSE.
        ivbrp1-k4 = 0.
      ENDIF.
      IF pk5 NE space AND pk5d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk5 CHANGING
          ivbrp1-k5 ivbrp1-k5r.

        IF sy-subrc EQ 0.
          MOVE pk5d TO ivbrp1-k5d.
        ENDIF.
      ELSE.
        ivbrp1-k5 = 0.
      ENDIF.
      IF pk6 NE space AND pk6d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk6 CHANGING
          ivbrp1-k6 ivbrp1-k6r.

        IF sy-subrc EQ 0.
          MOVE pk6d TO ivbrp1-k6d.
        ENDIF.
      ELSE.
        ivbrp1-k6 = 0.
      ENDIF.
      IF pk7 NE space AND pk7d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk7 CHANGING
          ivbrp1-k7 ivbrp1-k7r.

        IF sy-subrc EQ 0.
          MOVE pk7d TO ivbrp1-k7d.
        ENDIF.
      ELSE.
        ivbrp1-k7 = 0.
      ENDIF.
      IF pk8 NE space AND pk8d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk8 CHANGING
          ivbrp1-k8  ivbrp1-k8r.

        IF sy-subrc EQ 0.
          MOVE pk8d TO ivbrp-k8d.
        ENDIF.
      ELSE.
        ivbrp1-k8 = 0.
      ENDIF.
      IF pk9 NE space AND pk9d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk9 CHANGING
          ivbrp1-k9 ivbrp1-k9r.

        IF sy-subrc EQ 0.
          MOVE pk9d TO ivbrp1-k9d.
        ENDIF.
      ELSE.
        ivbrp1-k9 = 0.
      ENDIF.
      IF pk10 NE space AND pk10d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk10 CHANGING
          ivbrp1-k10 ivbrp1-k10r.

        IF sy-subrc EQ 0.
          MOVE pk10d TO ivbrp1-k10d.
        ENDIF.
      ELSE.
        ivbrp1-k10 = 0.
      ENDIF.
      IF pk11 NE space AND pk11d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk11 CHANGING
          ivbrp1-k11 ivbrp1-k11r.

        IF sy-subrc EQ 0.
          MOVE pk11d TO ivbrp1-k11d.
        ENDIF.
      ELSE.
        ivbrp1-k11 = 0.
      ENDIF.
      IF pk12 NE space AND pk12d NE space.
        PERFORM getdata USING ivbrp1-knumv ivbrp1-posnr pk12 CHANGING
          ivbrp1-k12 ivbrp1-k12r.

        IF sy-subrc EQ 0.
          MOVE pk12d TO ivbrp1-k12d.
        ENDIF.
      ELSE.
        ivbrp1-k12 = 0.
      ENDIF.

      ON CHANGE OF ivbrp1-vbeln OR ivbrp1-posnr.
        CLEAR : exnum,exdat.
        READ TABLE it_j_1iexchdr INTO wa_j_1iexchdr WITH KEY rdoc = ivbrp1-vbeln BINARY SEARCH.
        IF sy-subrc = 0.
          exnum = wa_j_1iexchdr-exnum.
          exdat = wa_j_1iexchdr-exdat.
        ENDIF.
        IF exnum IS INITIAL.
          READ TABLE it_j_1irg23d INTO wa_j_1irg23d WITH KEY vbeln = ivbrp1-vgbel BINARY SEARCH.
          IF sy-subrc = 0.
            exnum = wa_j_1irg23d-depexnum.
          ENDIF.
        ENDIF.
      ENDON.

*      IF NOT i_char[] IS INITIAL .
*        PERFORM  read_characteristics        USING    ivbrp1-spart
*                                                      ivbrp1-matnr
*                                                      ivbrp1-cuobj
*                                             CHANGING ivbrp1-char1
*                                                      ivbrp1-char2
*                                                      ivbrp1-char3
*                                                      ivbrp1-char4
*                                                      ivbrp1-char5
*                                                      ivbrp1-char6
*                                                      ivbrp1-char7
*                                                      ivbrp1-char8
*                                                      ivbrp1-char9
*                                                      ivbrp1-char10 .
*      ENDIF .
* For Truck Number and Transporter
*      ON CHANGE OF ivbrp1-vgbel OR ivbrp1-vgpos.
**        CLEAR : vehno,lifnr,tname.
**        SELECT SINGLE * FROM zgtsd_tran WHERE vbeln EQ ivbrp1-vgbel
**                                          AND posnr EQ ivbrp1-vgpos.
**        IF sy-subrc EQ 0.
**          SELECT SINGLE vehno lifnr FROM zgtsd_mast
**                              INTO (vehno,lifnr)
**                              WHERE gtno EQ zgtsd_tran-gtno.
**          IF sy-subrc EQ 0.
**            SELECT SINGLE name1 FROM lfa1 INTO tname
**
**                                      WHERE lifnr EQ lifnr.
**          ENDIF.
**        ENDIF.
*      ENDON.
* Get Frieght Rate ,Frieght Value,Excise Value.
*      ON CHANGE OF ivbrp1-knumv OR ivbrp1-posnr.
*        CLEAR : frate,fvalue,evalue.
*        IF ivbrp1-fkimg NE 0.
*          SELECT * FROM konv INTO CORRESPONDING FIELDS OF TABLE t_konv
*                                  WHERE knumv EQ ivbrp1-knumv
*                                    AND kposn EQ ivbrp1-posnr
*                                    AND ( kschl EQ  'ZF01'
*                                    OR    kschl EQ  'ZF02'
*                                    OR    kschl EQ  'ZEX2'
*                                    OR    kschl EQ  'JEX2'
*                                    OR    kschl EQ  'ZB00'
*                                    OR    kschl EQ  'ZNSR'
*                                    OR    kschl EQ  'JMOD' ).
*
*          IF NOT t_konv[] IS INITIAL.
*            LOOP AT t_konv.
*              CASE t_konv-kschl.
*                WHEN 'ZF01' OR 'ZF02'.
*                  IF t_konv-krech EQ 'A'.
*                    frate  = frate  + t_konv-kbetr.
*                    frate  = frate / 10.
*                  ENDIF.
*                  fvalue = fvalue + t_konv-kwert.
*                WHEN 'JEX2' OR 'ZEX2'.
*                  evalue = evalue + t_konv-kwert.
*                WHEN 'JMOD'.
*                  IF t_konv-krech EQ 'A'.
*                    erate  = erate  + t_konv-kbetr.
*                    erate  = erate / 10.
*                  ENDIF.
**                WHEN 'ZB00'.
**
**                  ivbeln-baspr  = ivbeln-baspr  + t_konv-kwert.
**
**                WHEN 'ZNSR'.
**                  ivbeln-znsr   = ivbeln-znsr + t_konv-kwert.
*
*              ENDCASE.
*            ENDLOOP.
*          ENDIF.
*        ENDIF.
*      ENDON.
*      ivbrp1-frate = frate.
*      ivbrp1-tname = tname.
*      ivbrp1-fvalue = fvalue.
*      ivbrp1-evalue = evalue.
*      ivbrp1-erate = erate.
      READ TABLE it_lfa1 INTO wa_lfa1 WITH KEY lifnr = ivbrp1-lifnr BINARY SEARCH.
      IF sy-subrc = 0.
        ivbrp1-tname = wa_lfa1-name1.
      ENDIF.
      ivbrp1-exnum = exnum.
      ivbrp1-exdat = exdat.
*      ivbrp1-vehno = vehno.
*      ivbrp1-lifnr = lifnr.

      ivbrp1-tot_amt =  ivbrp1-k1 + ivbrp1-k2 + ivbrp1-k3
      + ivbrp1-k4 + ivbrp1-k5 + ivbrp1-k6 + ivbrp1-k7
      + ivbrp1-k8 + ivbrp1-k9 + ivbrp1-k10 + ivbrp1-k11
      + ivbrp1-k12.
      IF ivbrp1-fkart EQ 'RE'.
        ivbrp1-tot_amt = ivbrp1-tot_amt * -1.
        ivbrp1-netwr = ivbrp1-netwr * -1.
        ivbrp1-fkimg = ivbrp1-fkimg * -1.
      ENDIF.

      IF ivbrp1-fkart EQ 'S1'.
        ivbrp1-tot_amt = ivbrp1-tot_amt * -1.
        ivbrp1-netwr = ivbrp1-netwr * -1.
        ivbrp1-fkimg = ivbrp1-fkimg * -1.
      ENDIF.

      IF ivbrp1-fkart EQ 'RE'.
        PERFORM cond_re_val.
      ENDIF.

      IF ivbrp1-fkart EQ 'S1'.
        PERFORM cond_re_val.
      ENDIF.

      IF ivbrp1-fkdat IS NOT INITIAL.
        CALL FUNCTION 'ISP_GET_MONTH_NAME'
          EXPORTING
            date     = ivbrp1-fkdat
            language = sy-langu
*           MONTH_NUMBER       = '00'
          IMPORTING
*           LANGU_BACK         =
            longtext = ivbrp1-month
*           SHORTTEXT          =
*   EXCEPTIONS
*           CALENDAR_ID        = 1
*           DATE_ERROR         = 2
*           NOT_FOUND          = 3
*           WRONG_INPUT        = 4
*           OTHERS   = 5
          .
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.

      IF ivbrp1-matnr = '000000000020001059' OR ivbrp1-matnr = '000000000020001060'.
        SELECT SINGLE matkl
        FROM mara INTO ivbrp1-matkl
        WHERE matnr = ivbrp1-matnr.
        IF sy-subrc <> 0. CLEAR  ivbrp1-matkl. ENDIF.
        SELECT SINGLE wgbez FROM t023t INTO ivbrp1-wgbez
        WHERE matkl = ivbrp1-matkl
        AND spras = sy-langu.
      ENDIF.


      SELECT SINGLE stceg
      FROM kna1 INTO ivbrp1-zstceg
      WHERE kunnr = ivbrp1-kunnr.
      IF ivbrp1-zstceg IS INITIAL.
        SELECT SINGLE j_1ilstno FROM j_1imocust
        INTO ivbrp1-zstceg
        WHERE kunnr = ivbrp1-kunnr.
      ENDIF.

      SELECT SINGLE vtext
      FROM tspat INTO ivbrp1-spart_txt
      WHERE spart = ivbrp1-spart
      AND spras = sy-langu.

      IF ivbrp1-fkart = 'RE'.                                                        " ADDING SALES INVOICE REF NO - PRADEEP K

*        SELECT SINGLE VBELV FROM VBFA
*                    INTO IVBRP1-REF_NO
*                    WHERE VBELN = IVBRP1-VBELN
*                    AND   POSNV   = IVBRP1-POSNR
*                    AND   POSNN   = IVBRP1-POSNR
*                    AND   VBTYP_N = 'O'
*                    AND   VBTYP_V = 'M'.
*       IF IVBRP1-REF_NO is NOT INITIAL.
*         SELECT SINGLE fkdat FROM VBRk
*           INTO IVBRP1-REF_date
*           WHERE vbeln = IVBRP1-REF_NO.

*       ENDIF.

      ENDIF.
      SELECT SINGLE zterm FROM vbrk INTO ivbrp1-zterm11
      WHERE vbeln = ivbrp1-vbeln.
      IF sy-subrc = 0.
        SELECT SINGLE vtext FROM tvzbt INTO ivbrp1-vtext11 WHERE zterm = ivbrp1-zterm AND spras = 'EN'.
      ENDIF.
      MODIFY ivbrp1.
      CLEAR ivbrp1.
    ENDIF.
  ENDLOOP.

*LOOP AT IVBRP1.                                          " Added Sales Inv Ref.No - Added by Pradeep Kodinagula.
*
*  SELECT SINGLE VBELV FROM VBFA
*                INTO IVBRP1-REF_NO
*                WHERE VBELN = IVBRP1-VBELN
*                AND VBTYP_V = 'M'.
*
*   MODIFY IVBRP1 FROM IVBRP1 TRANSPORTING REF_NO WHERE VBELN = IVBRP1-VBELN.
*ENDLOOP.
ENDFORM.                               " GET_DATA_INTO_IVBRP1

*&---------------------------------------------------------------------*
*&      Form  DATA_INTO_IVBRP2_IVBRP3_IVBRP
*&---------------------------------------------------------------------*
FORM data_into_ivbrp2_ivbrp3_ivbrp.
  IF cus NE space .
    SORT ivbrp1 BY kunnr.
    keyinfo-header01 = 'KUNNR'.
    keyinfo-item01 = 'KUNNR'.
    keyinfo-header02 = 'KONDA1'.
    keyinfo-item02 = 'KONDA1'.
    keyinfo-header03 = 'VTEXT1'.
    keyinfo-item03 = 'VTEXT1'.
    LOOP AT ivbrp1.

      ON CHANGE OF ivbrp1-kunnr.
        MOVE ivbrp1-kunnr TO iitem-kunnr.
        MOVE ivbrp1-name1 TO iitem-name1.
        MOVE ivbrp1-konda1 TO iitem-konda1.
        MOVE ivbrp1-vtext1 TO iitem-vtext1.
        APPEND iitem.
        CLEAR  iitem.
      ENDON.
    ENDLOOP.
    PERFORM display-output-head TABLES ivbrp1 iitem
                                USING 'IITEM' 'IVBRP1'.
  ENDIF.

  IF mat NE space .
    SORT ivbrp1 BY matnr.
    keyinfo-header01 = 'MATNR'.
    keyinfo-item01 = 'MATNR'.
    keyinfo-header02 = 'KONDA1'.
    keyinfo-item02 = 'KONDA1'.
    keyinfo-header03 = 'VTEXT1'.
    keyinfo-item03 = 'VTEXT1'.
    LOOP AT ivbrp1.

      ON CHANGE OF ivbrp1-matnr.
        MOVE ivbrp1-matnr TO iitem-matnr.
        MOVE ivbrp1-arktx TO iitem-arktx.
        MOVE ivbrp1-konda1 TO iitem-konda1.
        MOVE ivbrp1-vtext1 TO iitem-vtext1.
        APPEND iitem.
        CLEAR  iitem.
      ENDON.
    ENDLOOP.

    PERFORM display-output-head
    TABLES ivbrp1 iitem
    USING 'IITEM' 'IVBRP1'.


  ENDIF.
  IF inv NE space.
    PERFORM display-output TABLES ivbrp1.
  ENDIF.

ENDFORM.                               " DATA_INTO_IVBRP2_IVBRP3_IVBRP
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_input_data.
  IF pk1 NE space.
    PERFORM check_condtype USING pk1 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK1'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk1d EQ space.
        SET CURSOR FIELD 'PK1D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.
  IF pk2 NE space.
    PERFORM check_condtype USING pk2 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK2'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk2d EQ space.
        SET CURSOR FIELD 'PK2D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk3 NE space.
    PERFORM check_condtype USING pk3 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK3'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk3d EQ space.
        SET CURSOR FIELD 'PK3D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk4 NE space.
    PERFORM check_condtype USING pk4 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK4'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk4d EQ space.
        SET CURSOR FIELD 'PK4D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk5 NE space.
    PERFORM check_condtype USING pk5 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK5'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk5d EQ space.
        SET CURSOR FIELD 'PK5D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk6 NE space.
    PERFORM check_condtype USING pk6 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK6'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk6d EQ space.
        SET CURSOR FIELD 'PK6D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk7 NE space.
    PERFORM check_condtype USING pk7 CHANGING p .
    IF p = 1.
      SET CURSOR FIELD 'PK7'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk7d EQ space.
        SET CURSOR FIELD 'PK7D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk8 NE space.
    PERFORM check_condtype USING pk8 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK8'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk8d EQ space.
        SET CURSOR FIELD 'PK8D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk9 NE space.
    PERFORM check_condtype USING pk9 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK9'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk9d EQ space.
        SET CURSOR FIELD 'PK9D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk10 NE space.
    PERFORM check_condtype USING pk10 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK10'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk10d EQ space.
        SET CURSOR FIELD 'PK10D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk11 NE space.
    PERFORM check_condtype USING pk11 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK11'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk11d EQ space.
        SET CURSOR FIELD 'PK11D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk12 NE space.
    PERFORM check_condtype USING pk12 CHANGING p.
    IF p = 1.
      SET CURSOR FIELD 'PK12'.
      p = 0.
      MESSAGE e002(sy) WITH 'Check Condition Type'.
    ELSE.
      IF pk12d EQ space.
        SET CURSOR FIELD 'PK12D'.
        p = 0.
        MESSAGE e002(sy) WITH 'Enter Description'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF pk1d NE space AND  pk1 EQ space.
    SET CURSOR FIELD 'PK1'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk2d NE space AND  pk2 EQ space.
    SET CURSOR FIELD 'PK2'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk3d NE space AND  pk3 EQ space.
    SET CURSOR FIELD 'PK3'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk4d NE space AND  pk4 EQ space.
    SET CURSOR FIELD 'PK4'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk5d NE space AND  pk5 EQ space.
    SET CURSOR FIELD 'PK1'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk6d NE space AND  pk6 EQ space.
    SET CURSOR FIELD 'PK6'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk7d NE space AND  pk7 EQ space.
    SET CURSOR FIELD 'PK7'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk8d NE space AND  pk8 EQ space.
    SET CURSOR FIELD 'PK8'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk9d NE space AND  pk9 EQ space.
    SET CURSOR FIELD 'PK9'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk10d NE space AND  pk10 EQ space.
    SET CURSOR FIELD 'PK10'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk11d NE space AND  pk11 EQ space.
    SET CURSOR FIELD 'PK11'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
  IF pk12d NE space AND  pk12 EQ space.
    SET CURSOR FIELD 'PK12'.
    MESSAGE e002(sy) WITH 'Enter Condition Type'.
  ENDIF.
ENDFORM.                               " CHECK_INPUT_DATA

*&---------------------------------------------------------------------*
*&      Form  CHECK_CONDTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PK12  text                                                 *
*----------------------------------------------------------------------*
FORM check_condtype USING    p_cond CHANGING p.
  SELECT SINGLE * FROM t685t WHERE kschl EQ p_cond
  AND spras EQ sy-langu.

  IF sy-subrc NE 0.
    p = 1.
  ENDIF.
ENDFORM.                               " CHECK_CONDTYPE
*&---------------------------------------------------------------------*
*&      Form  GETDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IVBRP1_KNUMV  text                                         *
*      -->P_IVBRP1_POSNR  text                                         *
*      -->P_PK1  text                                                  *
*      <--P_IVBRP1_K1  text                                            *
*----------------------------------------------------------------------*
FORM getdata USING    p_ivbrp1_knumv
      p_ivbrp1_posnr
      p_pk1
CHANGING p_ivbrp1_k1 p_ivbrp1_k1r.
  DATA : pkbetr LIKE konv-kbetr.

  CALL FUNCTION 'Z6SD_CONDVAL_CONVER'
    EXPORTING
      i_knumv = p_ivbrp1_knumv
      i_kposn = p_ivbrp1_posnr
      i_kschl = p_pk1
      i_waerk = ivbrp1-waerk
    IMPORTING
      e_kwert = p_ivbrp1_k1.

  CALL FUNCTION 'Z6SD_CONDRATE_CONVER'
    EXPORTING
      i_knumv = p_ivbrp1_knumv
      i_kposn = p_ivbrp1_posnr
      i_kschl = p_pk1
      i_waerk = ivbrp1-waerk
    IMPORTING
      e_kbetr = pkbetr.
  IF sy-subrc EQ 0.
    p_ivbrp1_k1r = pkbetr.
  ENDIF.

ENDFORM.                    " GETDATA
*---------------------------------------------------------------------*
*       FORM GETDATASUM                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_IVBRP1_KNUMV                                                *
*  -->  P_IVBRP1_POSNR                                                *
*  -->  P_IVBRP1_K1                                                   *
*---------------------------------------------------------------------*
FORM getdatasum USING     p_ivbrp1_knumv
                          p_ivbrp1_posnr
                CHANGING  p_ivbrp1_k1.
  DATA:zpr0 LIKE konv-kwert,
       zcon LIKE konv-kwert,
       zexp LIKE konv-kwert.

  SELECT SINGLE kwert FROM konv INTO  zpr0
    WHERE knumv = p_ivbrp1_knumv
    AND kposn EQ  p_ivbrp1_posnr
    AND kschl EQ 'ZPR0' AND kinak NE 'X'.

  SELECT SINGLE kwert FROM konv INTO  zcon
    WHERE knumv = p_ivbrp1_knumv
    AND kposn EQ  p_ivbrp1_posnr
    AND kschl EQ 'ZCON' AND kinak NE 'X'.

  SELECT SINGLE kwert FROM konv INTO  zexp
    WHERE knumv = p_ivbrp1_knumv
    AND kposn EQ  p_ivbrp1_posnr
    AND kschl EQ 'ZEXP' AND kinak NE 'X'.

  p_ivbrp1_k1 = zpr0 + zcon + zexp.

ENDFORM.                    " GETDATA


*---------------------------------------------------------------------*
*       FORM display-output-head                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IHEADER                                                       *
*  -->  IITEM                                                         *
*  -->  VALUE(P_1135)                                                 *
*  -->  VALUE(P_1136)                                                 *
*---------------------------------------------------------------------*
FORM display-output-head TABLES   iheader STRUCTURE ivbrp1
  iitem  STRUCTURE  iitem
USING    VALUE(p_1135)
      VALUE(p_1136).
  IF iheader[] IS NOT INITIAL AND iitem[] IS NOT INITIAL.               " added by Naren Karra on 20.10.2015

    CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
      EXPORTING
*       I_INTERFACE_CHECK       = ' '
        i_callback_program      = repname
*       I_CALLBACK_PF_STATUS_SET =
        i_callback_user_command = 'USER_COMMAND'
        is_layout               = layout
        it_fieldcat             = fieldtab
        is_print                = alv_print
*       IT_EXCLUDING            =
*       IT_SPECIAL_GROUPS       =
*       IT_SORT                 =
*       IT_FILTER               =
*       IS_SEL_HIDE             =
*       I_SCREEN_START_COLUMN   = 0
*       i_screen_start_line     = 70
*       I_SCREEN_END_COLUMN     = 0
*       I_SCREEN_END_LINE       = 0
        i_default               = 'A'
        i_save                  = g_save
        is_variant              = g_variant
        it_events               = events[]
*       IT_EVENT_EXIT           =
        i_tabname_header        = p_1135
        i_tabname_item          = p_1136
*       I_STRUCTURE_NAME_HEADER =
*       I_STRUCTURE_NAME_ITEM   =
        is_keyinfo              = keyinfo
*       IS_PRINT                =
*    IMPORTING
*       E_EXIT_CAUSED_BY_CALLER =
*       ES_EXIT_CAUSED_BY_USER  =
      TABLES
        t_outtab_header         = iitem
        t_outtab_item           = iheader
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.
  ELSE.
    MESSAGE 'No records found / Missing Authorization' TYPE 'S' DISPLAY LIKE 'W'.         " modified by Naren Karra on 20.10.2015
  ENDIF.

ENDFORM.                    " display-output-HEAD

*&---------------------------------------------------------------------*
*&      For Display Output
*&---------------------------------------------------------------------*
FORM display-output TABLES   p_ivbeln STRUCTURE ivbrp1.
  IF p_ivbeln[] IS NOT INITIAL.                     " added by Naren Karra on 13.10.2015

    EXPORT p_ivbeln[] TO MEMORY ID 'ZRP'.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = repname
        is_layout          = layout
        i_buffer_active    = ' '
        it_fieldcat        = fieldtab[]
        i_save             = g_save
        is_variant         = g_variant
        it_events          = events[]
        is_print           = alv_print
      TABLES
        t_outtab           = p_ivbeln
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
  ELSE.
    MESSAGE 'No records found / Missing Authorization' TYPE 'S' DISPLAY LIKE 'W'.         " modified by Naren Karra on 20.10.2015
  ENDIF.
ENDFORM.                    " display-output
*&---------------------------------------------------------------------*
*&      Form  get_pname
*&---------------------------------------------------------------------*
FORM get_pname USING    p_s_werks_high
CHANGING p_name1.
  SELECT SINGLE bezei FROM tvkbt INTO p_name1
  WHERE vkbur EQ p_s_werks_high
  AND spras EQ sy-langu.
ENDFORM.                    " get_pname
*&---------------------------------------------------------------------*
*&      Form  f4_for_pk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_for_pk CHANGING v_pk.
  CALL FUNCTION 'DYN_FIELD_F4_HELP'
    EXPORTING
      i_table = 'T685A'
      i_field = 'KSCHL'
    CHANGING
      c_value = v_pk.
ENDFORM.                                                    " f4_for_pk


*&---------------------------------------------------------------------*
*&      Form  read_characteristics
*&---------------------------------------------------------------------*
FORM read_characteristics USING    p_spart  TYPE  vbap-spart
      p_matnr  TYPE  vbap-matnr
      p_cuobj  TYPE  vbap-cuobj
CHANGING p_char1
  p_char2
  p_char3
  p_char4
  p_char5
  p_char6
  p_char7
  p_char8
  p_char9
  p_char10 .

  DATA:  t_conf  TYPE econf_out OCCURS 10 WITH HEADER LINE .
  DATA   text(30) TYPE c .

  FIELD-SYMBOLS: <char> .

*  CALL FUNCTION 'ME_VAR_GET_CLASSIFICATION'
*       EXPORTING
*            i_matnr    = p_matnr
*            i_cuobj    = p_cuobj
*       TABLES
*            t_conf_out = t_conf.
*
*  LOOP AT t_conf .
*    READ TABLE i_char WITH KEY atnam = t_conf-atnam .
*    IF sy-subrc EQ 0 .
*      CONCATENATE 'P_CHAR' i_char-tabix INTO text .
*      ASSIGN (text) TO <char> .
*      IF sy-subrc EQ 0 .
*        <char> = t_conf-atwrt .
*      ENDIF .
*      i_char-descrp = t_conf-atbez .
*      MODIFY i_char INDEX i_char-tabix .
*    ENDIF .
*  ENDLOOP .
*
*  CLEAR: zvbmuez , t_conf , t_conf[] , text.

ENDFORM.                    " read_characteristics
*&---------------------------------------------------------------------*
*&      Form  Get_characterstics
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_characterstics.
*-- Get Characteristics Defined                                      --*
*  SELECT * FROM zvbmuez
*           INTO CORRESPONDING FIELDS OF TABLE i_char
*           UP TO 10 ROWS
*           WHERE muebs EQ p_muebs.
*
*
*
*  LOOP AT i_char .
*    i_char-tabix = sy-tabix .
*    CONDENSE i_char-tabix .
*    MODIFY i_char .
*  ENDLOOP .

ENDFORM.                    " Get_characterstics
*&---------------------------------------------------------------------*
*&      Form  COND_RE_VAL
*&---------------------------------------------------------------------*
*       Created : Anees
*       Req     : Trade commission (ZTCO) values must be postitive. (2/04/2011)
*               : The conditions UTX1, ZVAT, ZAVT,ZCST,ZPRS should show –ve
*                 when the type of Invoice is RE. (25/08/2011)
*               : Condition K004, K007,ZKF2 should show +ve when billing
*                 type is RE. (25/08/2011)
*               : Condition Z100 should show -ve when billing
*                 type is RE. (15/05/2012)
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cond_re_val .

*LOOP AT ivbrp1 WHERE fkart = 'RE'.
  IF pk1 = 'ZTCO' OR pk1 = 'K004' OR pk1 = 'K007' OR pk1 = 'ZKF2'.
    IF ivbrp1-k1 < 0.
      ivbrp1-k1 = ivbrp1-k1 * -1.
    ENDIF.
  ELSEIF pk1 = 'UTX1' OR pk1 = 'ZVAT' OR pk1 = 'ZAVT' OR pk1 = 'ZCST' OR pk1 = 'ZPRS' OR pk1 = 'Z100' OR pk1 = 'JOCG' OR pk1 = 'JOSG' OR pk1 = 'JOIG'.
    IF ivbrp1-k1 > 0.
      ivbrp1-k1 = ivbrp1-k1 * -1.
    ENDIF.
  ENDIF.

  IF pk2 = 'ZTCO' OR pk2 = 'K004' OR pk2 = 'K007' OR pk2 = 'ZKF2'.
    IF ivbrp1-k2 < 0.
      ivbrp1-k2 = ivbrp1-k2 * -1.
    ENDIF.
  ELSEIF pk2 = 'UTX1' OR pk2 = 'ZVAT' OR pk2 = 'ZAVT' OR pk2 = 'ZCST' OR pk2 = 'ZPRS' OR pk2 = 'Z100'OR pk2 = 'JOCG' OR pk2 = 'JOSG' OR pk2 = 'JOIG'.
    IF ivbrp1-k2 > 0.
      ivbrp1-k2 = ivbrp1-k2 * -1.
    ENDIF.
  ENDIF.

  IF pk3 = 'ZTCO' OR pk3 = 'K004' OR pk3 = 'K007' OR pk3 = 'ZKF2'.
    IF ivbrp1-k3 < 0.
      ivbrp1-k3 = ivbrp1-k3 * -1.
    ENDIF.
  ELSEIF pk3 = 'UTX1' OR pk3 = 'ZVAT' OR pk3 = 'ZAVT' OR pk3 = 'ZCST' OR pk3 = 'ZPRS' OR pk3 = 'Z100' OR pk3 = 'JOCG' OR pk3 = 'JOSG' OR pk3 = 'JOIG'.
    IF ivbrp1-k3 > 0.
      ivbrp1-k3 = ivbrp1-k3 * -1.
    ENDIF.
  ENDIF.

  IF pk4 = 'ZTCO' OR pk4 = 'K004' OR pk4 = 'K007' OR pk4 = 'ZKF2'.
    IF ivbrp1-k4 < 0.
      ivbrp1-k4 = ivbrp1-k4 * -1.
    ENDIF.
  ELSEIF pk4 = 'UTX1' OR pk4 = 'ZVAT' OR pk4 = 'ZAVT' OR pk4 = 'ZCST' OR pk4 = 'ZPRS' OR pk4 = 'Z100' OR pk4 = 'JOCG' OR pk4 = 'JOSG' OR pk4 = 'JOIG'.
    IF ivbrp1-k4 > 0.
      ivbrp1-k4 = ivbrp1-k4 * -1.
    ENDIF.
  ENDIF.

  IF pk5 = 'ZTCO' OR pk5 = 'K004' OR pk5 = 'K007' OR pk5 = 'ZKF2'.
    IF ivbrp1-k5 < 0.
      ivbrp1-k5 = ivbrp1-k5 * -1.
    ENDIF.
  ELSEIF pk5 = 'UTX1' OR pk5 = 'ZVAT' OR pk5 = 'ZAVT' OR pk5 = 'ZCST' OR pk5 = 'ZPRS' OR pk5 = 'Z100' OR pk5 = 'JOCG' OR pk5 = 'JOSG' OR pk5 = 'JOIG'.
    IF ivbrp1-k5 > 0.
      ivbrp1-k5 = ivbrp1-k5 * -1.
    ENDIF.
  ENDIF.

  IF pk6 = 'ZTCO' OR pk6 = 'K004' OR pk6 = 'K007' OR pk6 = 'ZKF2'.
    IF ivbrp1-k6 < 0.
      ivbrp1-k6 = ivbrp1-k6 * -1.
    ENDIF.
  ELSEIF pk6 = 'UTX1' OR pk6 = 'ZVAT' OR pk6 = 'ZAVT' OR pk6 = 'ZCST' OR pk6 = 'ZPRS' OR pk6 = 'Z100' OR pk6 = 'JOCG' OR pk6 = 'JOSG' OR pk6 = 'JOIG'.
    IF ivbrp1-k6 > 0.
      ivbrp1-k6 = ivbrp1-k6 * -1.
    ENDIF.
  ENDIF.

  IF pk7 = 'ZTCO' OR pk7 = 'K004' OR pk7 = 'K007' OR pk7 = 'ZKF2'.
    IF ivbrp1-k7 < 0.
      ivbrp1-k7 = ivbrp1-k7 * -1.
    ENDIF.
  ELSEIF pk7 = 'UTX1' OR pk7 = 'ZVAT' OR pk7 = 'ZAVT' OR pk7 = 'ZCST' OR pk7 = 'ZPRS' OR pk7 = 'Z100' OR pk7 = 'JOCG' OR pk7 = 'JOSG' OR pk7 = 'JOIG'.
    IF ivbrp1-k7 > 0.
      ivbrp1-k7 = ivbrp1-k7 * -1.
    ENDIF.
  ENDIF.

  IF pk8 = 'ZTCO' OR pk8 = 'K004' OR pk8 = 'K007' OR pk8 = 'ZKF2'.
    IF ivbrp1-k8 < 0.
      ivbrp1-k8 = ivbrp1-k8 * -1.
    ENDIF.
  ELSEIF pk8 = 'UTX1' OR pk8 = 'ZVAT' OR pk8 = 'ZAVT' OR pk8 = 'ZCST' OR pk8 = 'ZPRS' OR pk8 = 'Z100' OR pk8 = 'JOCG' OR pk8 = 'JOSG' OR pk8 = 'JOIG'.
    IF ivbrp1-k8 > 0.
      ivbrp1-k8 = ivbrp1-k8 * -1.
    ENDIF.
  ENDIF.

  IF pk9 = 'ZTCO' OR pk9 = 'K004' OR pk9 = 'K007' OR pk9 = 'ZKF2'.
    IF ivbrp1-k9 < 0.
      ivbrp1-k9 = ivbrp1-k9 * -1.
    ENDIF.
  ELSEIF pk9 = 'UTX1' OR pk9 = 'ZVAT' OR pk9 = 'ZAVT' OR pk9 = 'ZCST' OR pk9 = 'ZPRS' OR pk9 = 'Z100' OR pk9 = 'JOCG' OR pk9 = 'JOSG' OR pk9 = 'JOIG'.
    IF ivbrp1-k9 > 0.
      ivbrp1-k9 = ivbrp1-k9 * -1.
    ENDIF.
  ENDIF.

  IF pk10 = 'ZTCO' OR pk10 = 'K004' OR pk10 = 'K007' OR pk10 = 'ZKF2'.
    IF ivbrp1-k10 < 0.
      ivbrp1-k10 = ivbrp1-k10 * -1.
    ENDIF.
  ELSEIF pk10 = 'UTX1' OR pk10 = 'ZVAT' OR pk10 = 'ZAVT' OR pk10 = 'ZCST' OR pk10 = 'ZPRS' OR pk10 = 'Z100' OR pk10 = 'JOCG' OR pk10 = 'JOSG' OR pk10 = 'JOIG'.
    IF ivbrp1-k10 > 0.
      ivbrp1-k10 = ivbrp1-k10 * -1.
    ENDIF.
  ENDIF.

  IF pk11 = 'ZTCO' OR pk11 = 'K004' OR pk11 = 'K007' OR pk11 = 'ZKF2'.
    IF ivbrp1-k11 < 0.
      ivbrp1-k11 = ivbrp1-k11 * -1.
    ENDIF.
  ELSEIF pk11 = 'UTX1' OR pk11 = 'ZVAT' OR pk11 = 'ZAVT' OR pk11 = 'ZCST' OR pk11 = 'ZPRS' OR pk11 = 'Z100' OR pk11 = 'JOCG' OR pk11 = 'JOSG' OR pk11 = 'JOIG'.
    IF ivbrp1-k11 > 0.
      ivbrp1-k11 = ivbrp1-k11 * -1.
    ENDIF.
  ENDIF.

  IF pk12 = 'ZTCO' OR pk12 = 'K004' OR pk12 = 'K007' OR pk12 = 'ZKF2'.
    IF ivbrp1-k12 < 0.
      ivbrp1-k12 = ivbrp1-k12 * -1.
    ENDIF.
  ELSEIF pk12 = 'UTX1' OR pk12 = 'ZVAT' OR pk12 = 'ZAVT' OR pk12 = 'ZCST' OR pk12 = 'ZPRS' OR pk12 = 'Z100' OR pk12 = 'JOCG' OR pk12 = 'JOSG' OR pk12 = 'JOIG'.
    IF ivbrp1-k12 > 0.
      ivbrp1-k12 = ivbrp1-k12 * -1.
    ENDIF.
  ENDIF.

*MODIFY ivbrp1.
*CLEAR  ivbrp1.
*ENDLOOP.

ENDFORM.                    " COND_RE_VAL
*&---------------------------------------------------------------------*
*&      Form  COLLECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_data .
  " For delay kwmeng rfmng balance.
  SORT ivbrp1 BY aubel aupos vbtyp.
  SELECT vbeln auart vdatu FROM vbak INTO TABLE it_vbak FOR ALL ENTRIES IN ivbrp1
  WHERE vbeln = ivbrp1-aubel AND auart IN s_auart.
  IF sy-subrc = 0.
    SORT it_vbak BY vbeln.
  ENDIF.

  SELECT vbeln posnr kwmeng zland1 FROM vbap INTO TABLE it_vbap FOR ALL ENTRIES IN ivbrp1
  WHERE vbeln = ivbrp1-aubel
  AND posnr = ivbrp1-aupos.
  IF sy-subrc = 0.
    SORT it_vbap BY vbeln posnr.
  ENDIF.

  SELECT vbelv posnv vbeln posnn vbtyp_n FROM vbfa INTO TABLE it_vbfa FOR ALL ENTRIES IN ivbrp1
  WHERE vbelv = ivbrp1-aubel
  AND posnv = ivbrp1-aupos
  AND vbtyp_n = 'J'.

  IF sy-subrc = 0.
    SORT it_vbfa BY vbelv posnv vbtyp_n.
  ENDIF.

  SORT ivbrp1 BY vkbur.
  SELECT * FROM tvkbt INTO TABLE it_tvkbt FOR ALL ENTRIES IN ivbrp1
  WHERE vkbur = ivbrp1-vkbur
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvkbt BY vkbur.
  ENDIF.

  SORT ivbrp1 BY vkgrp.
  SELECT * FROM tvgrt INTO TABLE it_tvgrt FOR ALL ENTRIES IN ivbrp1
  WHERE vkgrp = ivbrp1-vkgrp
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvgrt BY vkgrp.
  ENDIF.

  SORT ivbrp1 BY matnr charg.
  SELECT matnr charg vfdat FROM mch1 INTO TABLE it_mch1 FOR ALL ENTRIES IN ivbrp1
  WHERE matnr = ivbrp1-matnr
  AND charg = ivbrp1-charg.
  IF sy-subrc = 0.
    SORT it_mch1 BY matnr charg.
  ENDIF.
  SELECT matnr bismt extwg FROM mara INTO TABLE it_mara FOR ALL ENTRIES IN ivbrp1
  WHERE matnr = ivbrp1-matnr.
  IF sy-subrc = 0.
    SORT it_mara BY extwg.
    SELECT extwg ewbez FROM twewt INTO TABLE it_twewt FOR ALL ENTRIES IN it_mara
    WHERE extwg = it_mara-extwg.
    IF sy-subrc = 0.
      SORT it_twewt BY extwg.
    ENDIF.
    SORT it_mara BY matnr.
  ENDIF.

* ---- Added for HSN Code/Descr on Sunday, September 03, 2017 12:40:28 => SaurabhK ---- *
  SELECT matnr steuc
  FROM marc
  INTO TABLE it_marc
  FOR ALL ENTRIES IN ivbrp1
  WHERE matnr EQ ivbrp1-matnr
  AND   werks EQ ivbrp1-werks.

  IF sy-subrc = 0.
    SELECT steuc text1
    FROM t604n
    INTO TABLE it_t604n
    FOR ALL ENTRIES IN it_marc
    WHERE steuc EQ it_marc-steuc.
  ENDIF.
* ---- End addition for HSN Code ---- *

  SORT ivbrp1 BY vgbel.
  SELECT vbeln traid FROM likp INTO TABLE it_likp FOR ALL ENTRIES IN ivbrp1
  WHERE vbeln = ivbrp1-vgbel.
  IF sy-subrc = 0.
    SORT it_likp BY vbeln.
  ENDIF.

  SORT ivbrp1 BY werks.
  SELECT werks bwrks FROM z6ppa_plnt_map INTO TABLE it_z6ppa_plnt_map FOR ALL ENTRIES IN ivbrp1
  WHERE werks = ivbrp1-werks.
  IF sy-subrc = 0.
    SORT it_z6ppa_plnt_map BY werks.
  ENDIF.

  SORT ivbrp1 BY vbeln posnr.
  SELECT vbeln parvw lifnr FROM vbpa INTO TABLE it_vbpa FOR ALL ENTRIES IN ivbrp1
  WHERE vbeln = ivbrp1-vbeln
  AND parvw = 'TF'.
  IF sy-subrc = 0.
    SORT it_vbpa BY vbeln.
  ENDIF.

  SELECT vbeln posnr bstkd bstdk konda FROM vbkd
  INTO CORRESPONDING FIELDS OF TABLE it_vbkd FOR ALL ENTRIES IN ivbrp1
  WHERE vbeln = ivbrp1-aubel.
*                                                          AND POSNR = IVBRP1-aupos.
**********code added by sachin 30.09.2014****
*if not IVBRP1[] is initial.
*select VBELN POSNR BSTKD bstdk konda
*FROM VBKD
*into corresponding fields of table it_vbkd1
*FOR ALL ENTRIES IN IVBRP1
*WHERE VBELN = IVBRP1-aubel
*AND POSNR = IVBRP1-aupos.
*endif.
***********end of added code ****************
  IF sy-subrc = 0.
    SORT it_vbkd BY vbeln posnr.
  ENDIF.

  SORT ivbrp1 BY bzirk.
  SELECT bzirk bztxt FROM t171t INTO TABLE it_t171t FOR ALL ENTRIES IN ivbrp1
  WHERE bzirk = ivbrp1-bzirk
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_t171t BY bzirk.
  ENDIF.

  SORT ivbrp1 BY vtweg.
  SELECT vtweg vtext FROM tvtwt INTO TABLE it_tvtwt FOR ALL ENTRIES IN ivbrp1
  WHERE vtweg = ivbrp1-vtweg
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvtwt BY vtweg.
  ENDIF.

  SORT ivbrp1 BY kdgrp_auft.
  SELECT kdgrp ktext FROM t151t INTO TABLE it_t151t FOR ALL ENTRIES IN ivbrp1
  WHERE kdgrp = ivbrp1-kdgrp_auft
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_t151t BY kdgrp.
  ENDIF.

  SORT ivbrp1 BY kvgr1.
  SELECT kvgr1 bezei FROM tvv1t INTO TABLE it_tvv1t FOR ALL ENTRIES IN ivbrp1
  WHERE kvgr1 = ivbrp1-kvgr1
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvv1t BY kvgr1.
  ENDIF.

  SORT ivbrp1 BY matkl.
  SELECT matkl wgbez FROM t023t INTO TABLE it_t023t FOR ALL ENTRIES IN ivbrp1
  WHERE matkl = ivbrp1-matkl
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_t023t BY matkl.
  ENDIF.

  SORT ivbrp1 BY mvgr1.
  SELECT mvgr1 bezei FROM tvm1t INTO TABLE it_tvm1t FOR ALL ENTRIES IN ivbrp1
  WHERE mvgr1 = ivbrp1-mvgr1
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvm1t BY mvgr1.
  ENDIF.

  SORT ivbrp1 BY mvgr2.
  SELECT mvgr2 bezei FROM tvm2t INTO TABLE it_tvm2t FOR ALL ENTRIES IN ivbrp1
  WHERE mvgr2 = ivbrp1-mvgr2
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvm2t BY mvgr2.
  ENDIF.

  SORT ivbrp1 BY mvgr3.
  SELECT mvgr3 bezei FROM tvm3t INTO TABLE it_tvm3t FOR ALL ENTRIES IN ivbrp1
  WHERE mvgr3 = ivbrp1-mvgr3
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvm3t BY mvgr3.
  ENDIF.

  SORT ivbrp1 BY mvgr4.
  SELECT mvgr4 bezei FROM tvm4t INTO TABLE it_tvm4t FOR ALL ENTRIES IN ivbrp1
  WHERE mvgr4 = ivbrp1-mvgr4
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvm4t BY mvgr4.
  ENDIF.

  SORT ivbrp1 BY mvgr5.
  SELECT mvgr5 bezei FROM tvm5t INTO TABLE it_tvm5t FOR ALL ENTRIES IN ivbrp1
  WHERE mvgr5 = ivbrp1-mvgr5
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_tvm5t BY mvgr5.
  ENDIF.

  SORT ivbrp1 BY prodh.
  SELECT prodh vtext FROM t179t INTO TABLE it_t179t FOR ALL ENTRIES IN ivbrp1
  WHERE prodh = ivbrp1-prodh
  AND spras = sy-langu.
  IF sy-subrc = 0.
    SORT it_t179t BY prodh.
  ENDIF.

  SORT ivbrp1 BY vbeln.
  SELECT rdoc exnum exdat FROM j_1iexchdr INTO TABLE it_j_1iexchdr FOR ALL ENTRIES IN ivbrp1
  WHERE  trntyp = 'DLFC'
  AND  rdoc   = ivbrp1-vbeln
  AND  rind   = 'N'
  AND  status = 'C'.
  IF sy-subrc = 0.
    SORT it_j_1iexchdr BY rdoc.
  ENDIF.

  SORT ivbrp1 BY vgbel.
  SELECT vbeln depexnum FROM j_1irg23d INTO TABLE it_j_1irg23d FOR ALL ENTRIES IN ivbrp1
  WHERE vbeln = ivbrp1-vgbel.
  IF sy-subrc = 0.
    SORT it_j_1irg23d BY vbeln.
  ENDIF.

  SORT ivbrp1 BY lifnr.
  SELECT lifnr name1 FROM lfa1 INTO TABLE it_lfa1 FOR ALL ENTRIES IN ivbrp1
  WHERE lifnr = ivbrp1-lifnr.
  IF sy-subrc = 0.
    SORT it_lfa1 BY lifnr.
  ENDIF.

  SORT ivbrp1 BY vbeln posnr.

ENDFORM.                    " COLLECT_DATA
*&---------------------------------------------------------------------*
*&      Form  CHK_AUTH_OBJ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_auth_obj .
* ---- Changes by SaurabhK on Monday, September 04, 2017 13:06:04 ---- *
* ---- IRDK929081 ----- *
* Change position of 'refresh select_option' statement after check on master tables *
* If user enters an invalid value, master data will not be fetched *
* If refresh is done before the init check on master, select option will be clear *
* Since master is empty due to invalid value, no other entry will be appended to selection option *
* Select option will remain blank, fetching all entries even for invalid input *
* Hence the fix *

* ---- Changes by SaurabhK on Monday, September 04, 2017 23:27:34 ---- *
* Commented the section/s
* CLEAR: flag_all.
* IF s_abcd[] IS INITIAL.
*   flag_all = 'X'.
* ENDIF.
* Reason: This flag was later checked and if found true a line containing low = '' was appened to the selection option *
* Such a line has to be added as certain documents contain empty values(space) for these fields => to fetch these documents *
* But if such documents indeed need to be fetched then they should be fetched irrespective of whether the user has ...
* supplied any value in select options or not, hence this check is removed

* Logic flow based on: https://gist.github.com/saurabhk-nbssap/d75b073c6ee3eea5db42fce35b2a1c61 *

*****
*data declaration
*****
  TYPES: BEGIN OF ty_tspat,
           spart TYPE spart,
         END OF ty_tspat,
         BEGIN OF ty_tvkot,
           vkorg TYPE vkorg,
         END OF ty_tvkot,
         BEGIN OF ty_tvtwt,
           vtweg TYPE vtweg,
         END OF ty_tvtwt,
         BEGIN OF ty_tvbur,
           vkbur TYPE vkbur,       " Sales Office - Plant
         END OF ty_tvbur,
         BEGIN OF ty_tvkgr,
           vkgrp TYPE vkgrp,
         END OF ty_tvkgr,
         BEGIN OF ty_t171t,
           bzirk TYPE bzirk,
         END OF ty_t171t,
         BEGIN OF ty_t005s,
           bland TYPE regio,
         END OF ty_t005s,
         BEGIN OF ty_tvv1t,
           kvgr1 TYPE kvgr1,
         END OF ty_tvv1t,
         BEGIN OF ty_tvktt,                 " added by NarenK on 23.12.2015
           ktgrd TYPE ktgrd,       " Acct Assgmt Group
         END OF ty_tvktt.
  DATA: wa_tspat TYPE ty_tspat, i_tspat TYPE STANDARD TABLE OF ty_tspat,
        wa_tvkot TYPE ty_tvkot, i_tvkot TYPE STANDARD TABLE OF ty_tvkot,
        wa_tvtwt TYPE ty_tvtwt, i_tvtwt TYPE STANDARD TABLE OF ty_tvtwt,
        wa_tvbur TYPE ty_tvbur, i_tvbur TYPE STANDARD TABLE OF ty_tvbur,
        wa_tvkgr TYPE ty_tvkgr, i_tvkgr TYPE STANDARD TABLE OF ty_tvkgr,
        wa_t171t TYPE ty_t171t, i_t171t TYPE STANDARD TABLE OF ty_t171t,
        wa_t005s TYPE ty_t005s, i_t005s TYPE STANDARD TABLE OF ty_t005s,
        wa_tvv1t TYPE ty_tvv1t, i_tvv1t TYPE STANDARD TABLE OF ty_tvv1t,
        wa_tvktt TYPE ty_tvktt, i_tvktt TYPE STANDARD TABLE OF ty_tvktt. " added by NarenK on 23.12.2015
  DATA: lv_ktgrd_spart TYPE c.        " added by NarenK on 23.12.2015
*Authorization for Company Code
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
  ID 'BUKRS' FIELD p_bukrs
  ID 'ACTVT' FIELD '03'.
  IF sy-subrc NE 0.
    MESSAGE 'User not Authorized for the Company Code' TYPE 'I' DISPLAY LIKE 'E'.                         " modified by Naren Karra on 19.10.2015
*  LV_AUTH_BUKRS_FLG = 'X'.
*  STOP.
*  LEAVE TO TRANSACTION 'ZSD002'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  DATA: flag_all.

*  CLEAR: flag_all.
*
*  IF s_vkorg[] IS INITIAL.
*    flag_all = 'X'.
*  ENDIF.

  SELECT vkorg
  FROM tvkot
  INTO TABLE i_tvkot
  WHERE vkorg IN s_vkorg
  AND  spras EQ sy-langu.

*IF S_VKORG[] IS NOT INITIAL.                           " modified by Naren Karra on 20.10.2015
  CLEAR: s_vkorg, lv_auth_vkorg_flg.
  IF i_tvkot[] IS NOT INITIAL.
    REFRESH: s_vkorg[].           " IRDK929081
    LOOP AT i_tvkot INTO wa_tvkot.
      AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
      ID 'VKORG' FIELD wa_tvkot-vkorg
      ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        s_vkorg-sign = 'I'.
        s_vkorg-option = 'EQ'.
        s_vkorg-low = wa_tvkot-vkorg.
        APPEND s_vkorg.
        CLEAR s_vkorg.
      ELSE.
        IF lv_auth_vkorg_flg IS INITIAL.
          lv_auth_vkorg_flg = 'X'.
        ENDIF.
      ENDIF.
      CLEAR wa_tvkot.
    ENDLOOP.
  ENDIF.
*ENDIF.

*  IF flag_all = 'X'.
*  IF s_vkorg[] IS INITIAL.
  s_vkorg-sign = 'I'.
  s_vkorg-option = 'EQ'.
  s_vkorg-low = ''.
  APPEND s_vkorg.
*  ENDIF.\
*  ENDIF.

*  CLEAR: flag_all.
*
*  IF s_spart[] IS INITIAL.
*    flag_all = 'X'.
*  ENDIF.

  SELECT spart
  FROM tspat
  INTO TABLE i_tspat
  WHERE spart IN s_spart
  AND   spras EQ sy-langu.

*IF S_SPART[] IS NOT INITIAL.
  CLEAR: s_spart, lv_auth_spart_flg.
  IF i_tspat[] IS NOT INITIAL.
    REFRESH: s_spart[].             " IRDK929081
    LOOP AT i_tspat INTO wa_tspat.
      AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
      ID 'SPART' FIELD wa_tspat-spart
      ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        s_spart-sign = 'I'.
        s_spart-option = 'EQ'.
        s_spart-low = wa_tspat-spart.
        IF lv_ktgrd_spart IS INITIAL AND wa_tspat-spart = '10'.      " added by NarenK on 23.12.2015
          lv_ktgrd_spart = 'X'.
        ELSEIF lv_ktgrd_spart IS INITIAL AND wa_tspat-spart = '40'.      " added by NarenK on 27.07.2016
          lv_ktgrd_spart = 'X'.
        ELSEIF lv_ktgrd_spart IS INITIAL AND wa_tspat-spart = '15'.      " added by AmolB on 27.04.2017
          lv_ktgrd_spart = 'X'.
        ENDIF.
        APPEND s_spart.
        CLEAR s_spart.
      ELSE.
        IF lv_auth_spart_flg IS INITIAL.
          lv_auth_spart_flg = 'X'.
        ENDIF.
      ENDIF.
      CLEAR wa_tspat.
    ENDLOOP.
  ENDIF.
*ENDIF.

*  IF flag_all = 'X'.
*  IF s_spart[] IS INITIAL.
  s_spart-sign = 'I'.
  s_spart-option = 'EQ'.
  s_spart-low = ''.
  APPEND s_spart.
*  ENDIF.
*  ENDIF.
*  CLEAR: flag_all.
*
*  IF s_vtweg[] IS INITIAL.
*    flag_all = 'X'.
*  ENDIF.


  SELECT vtweg
  FROM tvtwt
  INTO TABLE i_tvtwt
  WHERE vtweg IN s_vtweg
  AND   spras EQ sy-langu.

*IF S_VTWEG[] IS NOT INITIAL.
  CLEAR: s_vtweg, lv_auth_vtweg_flg.
  IF i_tvtwt[] IS NOT INITIAL.
    REFRESH: s_vtweg[].           " IRDK929081
    LOOP AT i_tvtwt INTO wa_tvtwt.
      AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
      ID 'VTWEG' FIELD wa_tvtwt-vtweg
      ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        s_vtweg-sign = 'I'.
        s_vtweg-option = 'EQ'.
        s_vtweg-low = wa_tvtwt-vtweg.
        APPEND s_vtweg.
        CLEAR s_vtweg.
      ELSE.
        IF lv_auth_vtweg_flg IS INITIAL.
          lv_auth_vtweg_flg = 'X'.
        ENDIF.
      ENDIF.
      CLEAR wa_tvtwt.
    ENDLOOP.
  ENDIF.
*ENDIF.

*  IF flag_all = 'X'.
*  IF s_vtweg[] IS INITIAL.
  s_vtweg-sign = 'I'.
  s_vtweg-option = 'EQ'.
  s_vtweg-low = ''.
  APPEND s_vtweg.
*  ENDIF.
*  ENDIF.
**********************************************************************  " commented by Naren Karra on 04.11.2015
*SELECT VKGRP                                                           " since VKGRP & REGIO will be given full auth. &
*  FROM TVKGR                                                           "  auth. checking is not req. in this cases
*  INTO TABLE I_TVKGR
*  WHERE VKGRP IN S_VKGRP.
*
**IF S_VKGRP[] IS NOT INITIAL.
*CLEAR: S_VKGRP, LV_AUTH_VKGRP_FLG.
*REFRESH: S_VKGRP[].
*IF I_TVKGR[] IS NOT INITIAL.
* LOOP AT I_TVKGR INTO WA_TVKGR.
*  AUTHORITY-CHECK OBJECT 'Z_SALESD'
*                      ID 'VKGRP' FIELD WA_TVKGR-VKGRP
*                      ID 'ACTVT' FIELD '03'.
*   IF SY-SUBRC EQ 0.
*    S_VKGRP-SIGN = 'I'.
*    S_VKGRP-OPTION = 'EQ'.
*    S_VKGRP-LOW = WA_TVKGR-VKGRP.
*    APPEND S_VKGRP.
*    CLEAR S_VKGRP.
*   ELSE.
*     IF LV_AUTH_VKGRP_FLG IS INITIAL.
*       LV_AUTH_VKGRP_FLG = 'X'.
*     ENDIF.
*   ENDIF.
*   CLEAR WA_TVKGR.
* ENDLOOP.
*ENDIF.
**ENDIF.
*
*IF S_VKGRP[] IS INITIAL.
* S_VKGRP-SIGN = 'I'.
* S_VKGRP-OPTION = 'EQ'.
* S_VKGRP-LOW = ''.
* APPEND S_VKGRP.
*ENDIF.
**********************************************************************
*  CLEAR: flag_all.
*
*  IF s_vkbur[] IS INITIAL.
*    flag_all = 'X'.
*  ENDIF.


  SELECT vkbur                                   " Sales Office  ( Plant )
  FROM tvbur
  INTO TABLE i_tvbur
  WHERE vkbur IN s_vkbur.

*IF S_VKBUR[] IS NOT INITIAL.
  CLEAR: s_vkbur, lv_auth_vkbur_flg.
  IF i_tvbur[] IS NOT INITIAL.
    REFRESH: s_vkbur[].             " IRDK929081
    LOOP AT i_tvbur INTO wa_tvbur.
      AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
      ID 'WERKS' FIELD wa_tvbur-vkbur
*                      ID 'VKBUR' FIELD WA_TVBUR-VKBUR
      ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        s_vkbur-sign = 'I'.
        s_vkbur-option = 'EQ'.
        s_vkbur-low = wa_tvbur-vkbur.
        APPEND s_vkbur.
        CLEAR s_vkbur.
      ELSE.
        IF lv_auth_vkbur_flg IS INITIAL.
          lv_auth_vkbur_flg = 'X'.
        ENDIF.
      ENDIF.
      CLEAR wa_tvbur.
    ENDLOOP.
  ENDIF.
*ENDIF.

*  IF flag_all = 'X'.
*  IF s_vkbur[] IS INITIAL.
  s_vkbur-sign = 'I'.
  s_vkbur-option = 'EQ'.
  s_vkbur-low = ''.
  APPEND s_vkbur.
*  ENDIF.
*  ENDIF.

**********************************************************************      " commented by Naren Karra on 04.11.2015
*SELECT BLAND                          " State, Province, Country -> REGIO
*  FROM T005S                                                               " since VKGRP & REGIO will be given full auth. &
*  INTO TABLE I_T005S                                                       "  auth. checking is not req. in this cases
*  WHERE BLAND IN S_REGIO.
*
**IF S_REGIO[] IS NOT INITIAL.
*CLEAR: S_REGIO, LV_AUTH_REGIO_FLG.
*REFRESH: S_REGIO[].
*IF I_T005S[] IS NOT INITIAL.
* LOOP AT I_T005S INTO WA_T005S.
*  AUTHORITY-CHECK OBJECT 'Z_SALESD'
*                      ID 'REGIO' FIELD WA_T005S-BLAND
*                      ID 'ACTVT' FIELD '03'.
*   IF SY-SUBRC EQ 0.
*    S_REGIO-SIGN = 'I'.
*    S_REGIO-OPTION = 'EQ'.
*    S_REGIO-LOW = WA_T005S-BLAND.
*    APPEND S_REGIO.
*    CLEAR S_REGIO.
*   ELSE.
*     IF LV_AUTH_REGIO_FLG IS INITIAL.
*       LV_AUTH_REGIO_FLG = 'X'.
*     ENDIF.
*   ENDIF.
*   CLEAR WA_T005S.
* ENDLOOP.
*ENDIF.
**ENDIF.
*
*IF S_REGIO[] IS INITIAL.
* S_REGIO-SIGN = 'I'.
* S_REGIO-OPTION = 'EQ'.
* S_REGIO-LOW = ''.
* APPEND S_REGIO.
*ENDIF.
**********************************************************************


*  CLEAR: flag_all.
*
*  IF s_bzirk[] IS INITIAL.
*    flag_all = 'X'.
*  ENDIF.

  SELECT bzirk                    " Region ( Sale District )
  FROM t171t
  INTO TABLE i_t171t
  WHERE bzirk IN s_bzirk
  AND   spras EQ sy-langu.

*IF S_BZIRK[] IS NOT INITIAL.
  CLEAR: s_bzirk, lv_auth_bzirk_flg.
  IF i_t171t[] IS NOT INITIAL.
    REFRESH: s_bzirk[].           " IRDK929081
    LOOP AT i_t171t INTO wa_t171t.
      AUTHORITY-CHECK OBJECT 'Z_SALESD'
      ID 'BZIRK' FIELD wa_t171t-bzirk
      ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        s_bzirk-sign = 'I'.
        s_bzirk-option = 'EQ'.
        s_bzirk-low = wa_t171t-bzirk.
        APPEND s_bzirk.
        CLEAR s_bzirk.
      ELSE.
        IF lv_auth_bzirk_flg IS INITIAL.
          lv_auth_bzirk_flg = 'X'.
        ENDIF.
      ENDIF.
      CLEAR wa_t171t.
    ENDLOOP.
  ENDIF.
*ENDIF.
*  IF flag_all = 'X'.
*  IF s_bzirk[] IS INITIAL.
  s_bzirk-sign = 'I'.
  s_bzirk-option = 'EQ'.
  s_bzirk-low = ''.
  APPEND s_bzirk.
*  ENDIF.
*  ENDIF.

*  CLEAR: flag_all.
*
*  IF s_kvgr1[] IS INITIAL.
*    flag_all = 'X'.
*  ENDIF.

  SELECT kvgr1
  FROM tvv1t
  INTO TABLE i_tvv1t
  WHERE kvgr1 IN s_kvgr1
  AND   spras EQ sy-langu.

*IF S_KVGR1[] IS NOT INITIAL.
  CLEAR: s_kvgr1, lv_auth_kvgr1_flg.
  IF i_tvv1t[] IS NOT INITIAL.
    REFRESH: s_kvgr1[].             " IRDK929081
    LOOP AT i_tvv1t INTO wa_tvv1t.
      AUTHORITY-CHECK OBJECT 'ZKVGR1'
      ID 'KVGR1' FIELD wa_tvv1t-kvgr1
      ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        s_kvgr1-sign = 'I'.
        s_kvgr1-option = 'EQ'.
        s_kvgr1-low = wa_tvv1t-kvgr1.
        APPEND s_kvgr1.
        CLEAR s_kvgr1.
      ELSE.
        IF lv_auth_kvgr1_flg IS INITIAL.
          lv_auth_kvgr1_flg = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
*ENDIF.

*  IF flag_all = 'X'.
*  IF s_kvgr1[] IS INITIAL.
  s_kvgr1-sign = 'I'.
  s_kvgr1-option = 'EQ'.
  s_kvgr1-low = ''.
  APPEND s_kvgr1.
*  ENDIF.
*  ENDIF.
************************Start********************************     " added by NK on 23.12.2015

*  CLEAR: flag_all.
*
*  IF s_ktgrd[] IS INITIAL.
*    flag_all = 'X'.
*  ENDIF.

  SELECT ktgrd
  FROM tvktt
  INTO TABLE i_tvktt
  WHERE ktgrd IN s_ktgrd
  AND   spras EQ sy-langu.

  CLEAR: s_ktgrd, lv_auth_ktgrd_flg.
  IF i_tvktt[] IS NOT INITIAL.
    REFRESH: s_ktgrd[].           " IRDK929081
    LOOP AT i_tvktt INTO wa_tvktt.
      AUTHORITY-CHECK OBJECT 'ZKTGRD'
      ID 'KTGRD' FIELD wa_tvktt-ktgrd
      ID 'ACTVT' FIELD '03'.
      IF sy-subrc EQ 0.
        s_ktgrd-sign = 'I'.
        s_ktgrd-option = 'EQ'.
        s_ktgrd-low = wa_tvktt-ktgrd.

        APPEND s_ktgrd.
        CLEAR s_ktgrd.
      ELSE.
        IF lv_auth_ktgrd_flg IS INITIAL.
          lv_auth_ktgrd_flg = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lv_ktgrd_spart = 'X'. "  if SPART = 10 & 40 here we are appending a BLANK value since Account assigment grp is not maintained @ transaction level
    s_ktgrd-sign = 'I'.
    s_ktgrd-option = 'EQ'.
    s_ktgrd-low = ''.
    APPEND s_ktgrd.
  ELSE.
    IF s_ktgrd[] IS INITIAL.
      s_ktgrd-sign = 'I'.
      s_ktgrd-option = 'EQ'.
      s_ktgrd-low = ''.
      APPEND s_ktgrd.
    ENDIF.
  ENDIF.
*************************End*********************************
*CLEAR: s_spart, lv_spart_auth_flg.
*REFRESH: s_spart[].

*Sales Document: Authorization for Sales Areas

*  IF flag_all = 'X'.
  s_ktgrd-sign = 'I'.
  s_ktgrd-option = 'EQ'.
  s_ktgrd-low = ''.
  APPEND s_ktgrd.
*  ENDIF.

ENDFORM.                    " CHK_AUTH_OBJ

FORM zuc USING a LIKE sy-ucomm
      b TYPE slis_selfield.

  IF b-fieldname = 'VBELN'.
    SET PARAMETER ID 'VF' FIELD b-value.
    CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.
