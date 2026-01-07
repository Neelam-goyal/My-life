@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZIRN'
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_ZIRNTP
  provider contract transactional_query
  as projection on ZR_ZIRNTP as ZIRN
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Billingdocno,
  Moduletype,
  Plant,
  Billingdate,
  Partycode,
  distributionchannel,
  billingdocumenttype,
  Partyname,
  Irnno,
  Ackno,
  Ackdate,
  documentreferenceid,
  Irnstatus,
  Signedinvoice,
  Signedqrcode,
  Canceldate,
  IRNCancelDate,
  EwayValidDate,
  Distance,
  Vehiclenum,
  Ewaybillno,
  Ewaydate,
  Ewaystatus,
  Ewaycanceldate,
  Irncreatedby,
  Ewaycreatedby,
  Transportername,
  Transportergstin,
  Transportmode,
  Grno,
  Grdate,
  Containerno,
  Linesealno,
  Customsealno,
  Grossweight,
  Netweight,
  MaxGrossWt,
  MaxCargoWt,
  CTareWt,
  Proformainvoiceno,
  Destinationcountry,
  Bookingno,
  Placereceipopre,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
where billingdocumenttype != 'S1' and billingdocumenttype != 'S2';
