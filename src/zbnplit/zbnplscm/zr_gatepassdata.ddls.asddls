@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Pass Related Query'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_GatePassData
  with parameters
    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'From Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_from : sydate,

    @AnalyticsDetails.query.variableSequence: 2
    @EndUserText.label: 'To Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_to   : sydate
  as select from    zgatepassheader   as gpmst
    inner join      zdt_user_item     as _userAccess on  gpmst.plant        = _userAccess.plant
                                                     and _userAccess.userid = $session.user
    left outer join zgatepassline     as gpdata      on gpmst.gate_pass = gpdata.gate_pass
    left outer join I_BillingDocument as invmst      on gpdata.document_no = invmst.BillingDocument
{
      @EndUserText.label: 'GPNo'
  key gpmst.gate_pass                                                                          as GatePass,
      @EndUserText.label: 'GP Date'
      gpmst.entry_date                                                                         as GatePassDate,
      @EndUserText.label: 'Primary GPNo'
      case when gpmst.first_gp_number is initial or gpmst.first_gp_number = ''
      then gpmst.gate_pass
      else gpmst.first_gp_number
      end                                                                                      as PrimaryGatePass,
      @EndUserText.label: 'Plant'
      gpmst.plant                                                                              as Plant,

      @EndUserText.label: 'Salesman'
      @Semantics.text: true
      gpmst.salesman_name                                                                      as SalesmanName,
      @EndUserText.label: 'Vehicle'
      @Semantics.text: true
      gpmst.vehicle_number                                                                     as VehicleNumber,
      @EndUserText.label: 'Driver'
      @Semantics.text: true
      gpmst.driver_name                                                                        as DriverName,
      @EndUserText.label: 'DriverCode'
      @ObjectModel.text.element: [ 'DriverName' ]
      gpmst.driver_code                                                                        as DriverCode,
      @EndUserText.label: 'Route'
      @Semantics.text: true
      gpmst.route_name                                                                         as RouteName,
      @EndUserText.label: 'Remarks'
      @Semantics.text: true
      gpmst.remarks                                                                            as Remarks,
      @EndUserText.label: 'Out Remarks'
      @Semantics.text: true
      gpmst.veh_out_remarks                                                                    as VehOutRemarks,
      @EndUserText.label: 'Crates1'
      @Semantics.text: true
      gpmst.cmcrate_1                                                                          as Cmcrate1,
      @EndUserText.label: 'Crates2'
      @Semantics.text: true
      gpmst.cmcrate_2                                                                          as Cmcrate2,
      @EndUserText.label: 'Crates3'
      @Semantics.text: true
      gpmst.cmcrate_3                                                                          as Cmcrate3,
      @EndUserText.label: 'Crates4'
      @Semantics.text: true
      gpmst.cmcrate_4                                                                          as Cmcrate4,
      @EndUserText.label: 'GP Out Date'
      gpmst.out_date                                                                           as OutDate,
      @EndUserText.label: 'GP Out Time'
      gpmst.out_time                                                                           as OutTime,
      @EndUserText.label: 'Out Reading'
      gpmst.out_meter_reading                                                                  as OutMeterReading,
      @EndUserText.label: 'IsVehicleOut'
      gpmst.vehicle_out                                                                        as IsVehicleOut,
      @EndUserText.label: 'IsGPCancelled'
      gpmst.cancelled                                                                          as IsCancelled,
      @EndUserText.label: 'Dist. Channel'
      invmst.DistributionChannel,
      @EndUserText.label: 'Invoice No.'
      invmst.DocumentReferenceID                                                               as InvoiceNo,
      @EndUserText.label: 'Invoice Date'
      gpdata.document_date                                                                     as InvoiceDate,

      @EndUserText.label: 'Invoice Type'
      case when
            invmst.BillingDocumentType = 'F2' or invmst.BillingDocumentType = 'JSP'
            then 'INV'
           when
               invmst.BillingDocumentType = 'JDC' or invmst.BillingDocumentType = 'JSN'
            then 'DC'
           when
               invmst.BillingDocumentType = 'JSTO'
            then 'STO'
           when
               invmst.BillingDocumentType = 'JVR'
            then 'PURR'
           else 'NA'
      end                                                                                      as DocumentType,
      @EndUserText.label: 'Sold to Party'
      concat(concat( invmst._SoldToParty.CustomerName,'   -   '),invmst._SoldToParty.CityName) as SoldToPartyName,

      @EndUserText.label: 'Inv. Amount'
      @Semantics.amount.currencyCode: 'Currency'
      gpdata.amount                                                                            as Amount,
      @EndUserText.label: 'Sold Qty.'
      get_numeric_value(gpdata.quantity)                                                       as Quantity,
      @EndUserText.label: 'Bill Currency'
      gpdata.currency                                                                          as Currency,
      @Semantics.systemDateTime.createdAt: true
      gpmst.created_at                                                                         as GPCreatedOn

}
where
      gpmst.out_date >= $parameters.p_date_from
  and gpmst.out_date <= $parameters.p_date_to
