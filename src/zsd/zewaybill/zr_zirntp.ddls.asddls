@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZIRN'
define root view entity ZR_ZIRNTP 
  as select from ztable_irn as ZIRN
  join zdt_user_item as UserItems on UserItems.plant = ZIRN.plant 
{
  key ZIRN.bukrs                 as Bukrs,
      @EndUserText.label: 'Document No'
  key ZIRN.billingdocno          as Billingdocno,
      ZIRN.moduletype            as Moduletype,
      ZIRN.plant                 as Plant,
      @EndUserText.label: 'Document Date'
      ZIRN.billingdate           as Billingdate,
      ZIRN.partycode             as Partycode,
      ZIRN.distributionchannel   as distributionchannel,
      ZIRN.billingdocumenttype   as billingdocumenttype,
      ZIRN.partyname             as Partyname,
      ZIRN.irnno                 as Irnno,
      ZIRN.ackno                 as Ackno,
      ZIRN.ackdate               as Ackdate,
      ZIRN.documentreferenceid   as documentreferenceid,
      ZIRN.irnstatus             as Irnstatus,
      ZIRN.canceldate            as Canceldate,
      ZIRN.irncanceldate         as IRNCancelDate,
      ZIRN.ewayvaliddate         as EwayValidDate,
      ZIRN.signedinvoice         as Signedinvoice,
      ZIRN.signedqrcode          as Signedqrcode,
      ZIRN.distance              as Distance,
      ZIRN.vehiclenum            as Vehiclenum,
      ZIRN.ewaybillno            as Ewaybillno,
      ZIRN.ewaydate              as Ewaydate,
      ZIRN.ewaystatus            as Ewaystatus,
      ZIRN.ewaycanceldate        as Ewaycanceldate,
      @Semantics.user.createdBy: true
      ZIRN.irncreatedby          as Irncreatedby,
      ZIRN.ewaycreatedby         as Ewaycreatedby,
      ZIRN.transportername       as Transportername,
      ZIRN.transportergstin      as Transportergstin,
      ZIRN.transportmode         as Transportmode,
      ZIRN.grno                  as Grno,
      ZIRN.grdate                as Grdate,
      ZIRN.containerno           as Containerno,
      ZIRN.linesealno            as Linesealno,
      ZIRN.customsealno          as Customsealno,
      ZIRN.grossweight           as Grossweight,  
      ZIRN.netweight             as Netweight,
      ZIRN.maxgrosswt            as MaxGrossWt,
      ZIRN.maxcargowt            as MaxCargoWt,
      ZIRN.ctarewt               as CTareWt,
      ZIRN.proformainvoiceno     as Proformainvoiceno,
      ZIRN.destinationcountry    as Destinationcountry,
      ZIRN.bookingno             as Bookingno,
      ZIRN.placereceipopre       as Placereceipopre,
      ZIRN.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ZIRN.created_at            as CreatedAt,
      ZIRN.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ZIRN.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      ZIRN.local_last_changed_at as LocalLastChangedAt
}
where UserItems.userid =  $session.user; 
