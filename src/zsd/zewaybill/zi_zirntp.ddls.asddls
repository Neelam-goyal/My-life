//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Projection View forZIRN'
//define root view entity ZI_ZIRNTP
//  provider contract transactional_interface
//  as projection on ZR_ZIRNTP as ZIRN
// Try reactivating the CDS view
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for ZIRN'
define root view entity ZI_ZIRNTP
  provider contract transactional_interface
  as projection on ZR_ZIRNTP as ZIRN
{
key Bukrs,
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
Canceldate,
IRNCancelDate,
EwayValidDate,
Signedinvoice,
Signedqrcode,
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
