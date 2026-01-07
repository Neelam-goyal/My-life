@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl: {
                  authorizationCheck: #CHECK
                }
@EndUserText.label: 'Pivot Sales Register'
@AbapCatalog: {
                  sqlViewName: 'ZSALEREG_PIV',
                  compiler.compareFilter: true
                }

@Analytics: {
                dataCategory: #CUBE
//                ,query: true
            }
@ObjectModel:{
                supportedCapabilities: [ #ANALYTICAL_PROVIDER, #SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE ],
                modelingPattern: #ANALYTICAL_CUBE,
                usageType: {
                                dataClass:      #MIXED,
                                serviceQuality: #D,
                                sizeCategory:   #XL
                              }
              }
@Metadata: {
              allowExtensions: true,
              ignorePropagatedAnnotations:true
            }
@Aggregation.allowPrecisionLoss:true

define view ZC_SALEREG_PIV
  as select from    ZR_BillingLinesTP    as Sales
    left outer join I_FiscalCalendarDate as TimeDim on  TimeDim.CalendarDate      = Sales.Billingdocumentdate
                                                    and TimeDim.FiscalYearVariant = 'V3'
  association [1..1] to I_BillingDocument              as _BillingDocument on  Sales.billingdocument = _BillingDocument.BillingDocument                                                    
  association [1..1] to I_CompanyCode as _CompanyCode on $projection.CompanyCode = _CompanyCode.CompanyCode
  association [0..1] to I_Customer    as _SoldToParty on $projection.SoldToPartyCode = _SoldToParty.Customer
  association [0..1] to I_Product     as _Product     on $projection.MaterialNo = _Product.Product
{
      @ObjectModel.foreignKey.association: '_CompanyCode'
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } } ]
      @EndUserText.label: 'Company'

  key cast(Sales.bukrs as bukrs preserving type)       as CompanyCode,
  key Sales.Fiscalyearvalue                            as FinYear,
      @EndUserText.label: 'InvoiceNo'
  key Sales.billingdocument                            as InvoiceNo,
  key Sales.billingdocumentitem                        as LineItemNo,

      @AnalyticsDetails.query.axis: #ROWS
      @AnalyticsDetails.query.totals: #SHOW
      @AnalyticsDetails.query.display: #KEY_TEXT
      _BillingDocument.SalesOrganization,
      @AnalyticsDetails.query.display: #KEY_TEXT
      _BillingDocument.DistributionChannel,
      @AnalyticsDetails.query.display: #KEY_TEXT
      _BillingDocument.Division,
      
      
      @EndUserText.label: 'Quotation No.'
      Sales.referencesddocument                        as SalesQuotation,
      @EndUserText.label: 'Quotation Date'
      Sales.creationdate                               as CreationDate,
      @EndUserText.label: 'Sales Person'
      Sales.fullname                                   as SalesPerson,
      @EndUserText.label: 'Sale Order Number'
      Sales.salesdocument                              as SaleOrderNumber,
      @EndUserText.label: 'Sales Order Date'
      Sales.sales_creationdate                         as SalesCreationDate,
      @EndUserText.label: 'Customer PO No.'
      Sales.purchaseorderbycustomer                    as CustomerPONumber,

      @ObjectModel.foreignKey.association: '_SoldToParty'
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]
      cast(Sales.soldtoparty as kunag preserving type) as SoldToPartyCode,
      _SoldToParty,
      @EndUserText.label: 'Customer GSTIN'
      Sales.taxnumber3                                 as SoldToPartyGSTIN,

      @EndUserText.label: 'ShipTo'
      Sales.shiptoparty                                as ShipToPartyCode,
      @EndUserText.label: 'ShipTo Name'
      Sales.ship_customername                          as ShipToPartyName,
      @EndUserText.label: 'ShipTo GSTIN'
      Sales.ship_taxnumber3                            as ShipToPartyGSTIN,
      @EndUserText.label: 'Delivery State'
      //      Sales.del_place_state_code                       as DeliveryPlaceStateCode,
      Sales.sold_region_code                           as SoldToRegionCode,
      Sales.D_ReferenceSDDocument                      as DeliveryNumber,
      Sales.delivery_CreationDate                      as DeliveryDate,
      @EndUserText.label: 'Billing Type'
      Sales.BillingDocumentType                        as BillingType,
      @EndUserText.label: 'Doc Type'
      Sales.billing_doc_desc                           as BillingDocDesc,
      @EndUserText.label: 'Bill No.'
      Sales.documentreferenceid                        as BillNo,

      //      Sales.E_way_Bill_Number                          as EWayBillNumber,
      //      Sales.E_way_Bill_Date_Time                       as EWayBillDateTime,
      //      Sales.IRN_Ack_Number                             as IRNAckNumber,

      @EndUserText.label: 'Vehicle Number'
      Sales.Vehicle_Number                             as VehicleNumber,
      @EndUserText.label: 'Transporter Name'
      Sales.Tpt_Vendor_Name                            as TptVendorName,
      @EndUserText.label: 'Transport Mode'
      Sales.Tpt_Mode                                   as TptMode,
      @EndUserText.label: 'Net Weight'
      @DefaultAggregation: #SUM
      Sales.Actual_Netweight                           as Netweight,
      @EndUserText.label: 'Gross weight'
      @DefaultAggregation: #SUM
      Sales.Gross_Weight                               as GrossWeight,
      @EndUserText.label: 'GR Number'
      Sales.Grno                                       as Grno,

      @EndUserText.label: 'Plant'
      Sales.del_plant                                  as DeliveryPlant,

      @EndUserText.label: 'Invoice Date'
      Sales.Billingdocumentdate                        as InvoiceDate,
      @Semantics.fiscal.yearVariant: true
      TimeDim.FiscalYearVariant,
            
      @EndUserText.label: 'Year'
      TimeDim.FiscalYear                               as BillingYear,
      
      @EndUserText.label: 'Quarter'
      TimeDim.FiscalQuarter                            as BillingQuarter,
      
      @Semantics.calendar.yearMonth
      @EndUserText.label: 'YearMonth'
      TimeDim._CalendarDate.YearMonth                  as BillingYearMonth,

      @ObjectModel.foreignKey.association: '_Product'
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProductStdVH', element: 'Product' } } ]
      @EndUserText.label: 'Product'
      Sales.Product                                    as MaterialNo,
      _Product,
      //      @EndUserText.label: 'Product Name'
      //      Sales.Materialdescription                        as MaterialDescription,
      //      Sales.MaterialByCustomer                         as CustomerItemCode,
      @EndUserText.label: 'HSN/SAC'
      Sales.ConsumptionTaxCtrlCode                     as HSNCode,
      //      Sales.YY1_SOHSCODE_SDI                           as HSCode,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'UOM'
      @EndUserText.label: 'Sold Quantity'
      Sales.billingQuantity                            as SoldQty,

      @Semantics.unitOfMeasure: true
      @EndUserText.label: 'UOM'
      Sales.baseunit                                   as UOM,
      @Semantics.currencyCode:true
      @EndUserText.label: 'Currency'
      Sales.transactioncurrency                        as Currency,

      //      Sales.accountingexchangerate                     as ExchangeRate,

      //      Sales.Itemrate                                   as ItemRate,
      //      Sales.rate_in_inr                                as RateInINR,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'Value of Goods'
      Sales.taxable_value                              as TaxableValueBeforeDiscount,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'IGST Amount'
      Sales.Igst                                       as IGSTAmt,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'SGST Amount'
      Sales.Sgst                                       as SGSTAmt,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'CGST Amount'
      Sales.Cgst                                       as CGSTAmt,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'Sales Amount'
      Sales.taxable_value_dis                          as TaxableValueAfterDiscount,

      @EndUserText.label: 'Freight Amount'
      Sales.freight_charge_inr                         as FreightChargeINR,

      //      Sales.insurance_rate                             as InsuranceRateINR,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'Insurance Amount'
      Sales.insurance_amt                              as InsuranceAmountINR,

      @EndUserText.label: 'UGST Rate'
      Sales.rateugst                                   as UGSTRate,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'UGST Amount'
      Sales.ugst                                       as UGSTAmt,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'Round Off'
      Sales.Roundoff                                   as RoundOffAmt,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'Discount Amount'
      Sales.Discount                                   as DiscountAmount,
      //      Sales.ratediscount                               as DiscountRate,

      @DefaultAggregation: #SUM
      //      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Invoice Amount'
      Sales.Totalamount                                as InvoiceAmount,

      @EndUserText.label: 'IGST Rate'

      Sales.Rateigst                                   as IGSTRate,

      @EndUserText.label: 'CGST Rate'
      Sales.Ratecgst                                   as CGSTRate,

      @EndUserText.label: 'SGST Rate'
      Sales.Ratesgst                                   as SGSTRate,

      @EndUserText.label: 'TCS Rate'
      Sales.Ratetcs                                    as TCSRate,

      @DefaultAggregation: #SUM
      @EndUserText.label: 'TCS Amount'
      Sales.Tcs                                        as TCSAmount,

      @EndUserText.label: 'IsCancelled'
      Sales.cancelledinvoice                           as CancelledInvoice,

      _CompanyCode
}
