@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Billing Lines CDS View'
define view entity ZR_BillingLinesTP
  as select from zbillinglines as BillingLines
    join         zdt_user_item as UserItems on UserItems.plant = BillingLines.deliveryplant
  association to parent ZR_BillingDocTP as _BillingDoc on  $projection.bukrs               = _BillingDoc.Bukrs
                                                       and $projection.Fiscalyearvalue     = _BillingDoc.Fiscalyearvalue
                                                       and $projection.billingdocumentitem = _BillingDoc.Billingdocument
{
      @EndUserText.label: 'Company Code'
  key BillingLines.companycode                as bukrs,
      @EndUserText.label: 'Fiscal Year Value'
  key BillingLines.fiscalyearvalue            as Fiscalyearvalue,
      // V
      @EndUserText.label: 'Invoice No'
  key BillingLines.invoice                    as billingdocument,
      // AB
      @EndUserText.label: 'Line Item No.'
  key BillingLines.lineitemno                 as billingdocumentitem,
      // A
      @EndUserText.label: 'Sales Quotation'
      @UI.hidden: true
      BillingLines.salesquotation             as referencesddocument,
      // B
      @EndUserText.label: 'Creation Date'
      @UI.hidden: true
      BillingLines.creationdate               as creationdate,
      // C
      @EndUserText.label: 'Sales Person'
      @UI.hidden: true
      BillingLines.salesperson                as fullname,
      // D
      @EndUserText.label: 'Order Number'
      BillingLines.saleordernumber            as salesdocument,
      // E
      @EndUserText.label: 'Order Creation Date'
      BillingLines.salescreationdate          as sales_creationdate,
      // F
      @EndUserText.label: 'Customer PO Number'
      BillingLines.customerponumber           as purchaseorderbycustomer,
      // G
      @EndUserText.label: 'Sold to party GSTIN'
      BillingLines.soldtopartygstin           as taxnumber3,
      //companycode             as companycode,
      // I
      @EndUserText.label: 'Sold-to Party Name'
      BillingLines.soldtopartyname            as customername,
      // J
      @EndUserText.label: 'Sold-to Party Number'
      BillingLines.soldtopartynumber          as soldtoparty,
      // K
      @EndUserText.label: 'Ship to Party Number'
      BillingLines.shiptopartynumber          as shiptoparty,
      // L
      @EndUserText.label: 'Ship to Party Name'
      BillingLines.shiptopartyname            as ship_customername,
      // M
      @EndUserText.label: 'Ship to Party GST No.'
      BillingLines.shiptopartygstno           as ship_taxnumber3,
      // N

      @EndUserText.label: 'Delivery Place City'
      BillingLines.deliveryplacecity          as del_place_city,

      @EndUserText.label: 'Delivery Place State'
      BillingLines.deliveryplacestatecode     as del_place_state_code,

      @EndUserText.label: 'Delivery Place Postal Code'
      BillingLines.deliveryplacepostalcode    as del_place_postal_code,
      // P
      @EndUserText.label: 'Sold to Region'
      BillingLines.soldtoregioncode           as sold_region_code,
      // Q
      @EndUserText.label: 'Delivery Number'
      BillingLines.deliverynumber             as D_ReferenceSDDocument,
      // R
      @EndUserText.label: 'Delivery Date'
      BillingLines.deliverydate               as delivery_CreationDate,
      // S
      @EndUserText.label: 'Billing Type'
      BillingLines.billingtype                as BillingDocumentType,
      // T
      @EndUserText.label: 'Billing Doc. Desc.'
      BillingLines.billingdocdesc             as billing_doc_desc,
      // U
      @EndUserText.label: 'Bill No.'
      BillingLines.billno                     as documentreferenceid,
      // X
      @EndUserText.label: 'E - way Bill Number'
      BillingLines.ewaybillnumber             as E_way_Bill_Number,
      // Y
      @EndUserText.label: 'E way Bill Date & Time'
      @UI.hidden: true
      BillingLines.ewaybilldatetime           as E_way_Bill_Date_Time,
      // Z
      @EndUserText.label: 'E way Bill Valid Date'
      BillingLines.ewaydatetime               as E_way_Bill_Date,

      @EndUserText.label: 'IRN Ack Number'
      BillingLines.irnacknumber               as IRN_Ack_Number,

      @EndUserText.label: 'Vehicle Number'
      BillingLines.vehiclenumber              as Vehicle_Number,
      @EndUserText.label: ' Transporter Name'
      BillingLines.tptvendorname              as Tpt_Vendor_Name,
      @EndUserText.label: 'Tranport Mode'
      BillingLines.tptmode                    as Tpt_Mode,
      @EndUserText.label: 'Actual Netweight'
      BillingLines.actualnetweight            as Actual_Netweight,
      @EndUserText.label: 'Gross weight'
      BillingLines.grossweight                as Gross_Weight,
      @EndUserText.label: 'Gr Number'
      BillingLines.grno                       as Grno,

      // AA
      @EndUserText.label: 'Delivery Plant'
      BillingLines.deliveryplant              as del_plant,
      // W
      @EndUserText.label: 'Invoice Date'
      BillingLines.invoicedate                as Billingdocumentdate,
      // AC
      @EndUserText.label: 'Material No'
      BillingLines.materialno                 as Product,
      @EndUserText.label: 'Brand Name'
      BillingLines.brandname                  as BrandName,
      // AD
      @EndUserText.label: 'Material Description'
      BillingLines.materialdescription        as Materialdescription,
      // AE
      @EndUserText.label: 'Material Group'
      BillingLines.materialgroup              as MaterialGroup,
      @EndUserText.label: 'Material Group Description'
      BillingLines.materialgroupdescription   as MaterialGroupDescription,
      @EndUserText.label: 'Division'
      BillingLines.division                   as Division,
      @EndUserText.label: 'Distribution Channel'
      BillingLines.distributionchannel        as DistributionChannel,
      @EndUserText.label: 'Customer Item Code'
      @UI.hidden: true
      BillingLines.customeritemcode           as MaterialByCustomer,
      // AF
      @EndUserText.label: 'HSN Code'
      BillingLines.hsncode                    as ConsumptionTaxCtrlCode,
      // AG
      @EndUserText.label: 'HS Code'
      @UI.hidden: true
      BillingLines.hscode                     as YY1_SOHSCODE_SDI,
      // AH
      @EndUserText.label: 'QTY'
      BillingLines.qty                        as billingQuantity,
      // AI
      @EndUserText.label: 'UOM'
      BillingLines.uom                        as baseunit,
      // AK
      @EndUserText.label: 'Document currency'
      BillingLines.documentcurrency           as transactioncurrency,
      // AL
      @EndUserText.label: 'Exchange rate'
      BillingLines.exchangerate               as accountingexchangerate,
      // AJ
      @EndUserText.label: 'Rate'
      BillingLines.rate                       as Itemrate,
      // AM
      @EndUserText.label: 'Rate in INR'
      BillingLines.rateininr                  as rate_in_inr,
      // AN
      @EndUserText.label: 'Taxable Value before Discount'
      BillingLines.taxablevaluebeforediscount as taxable_value,
      // AV
      @EndUserText.label: 'IGST Amt'
      BillingLines.igstamt                    as Igst,
      // AZ
      @EndUserText.label: 'SGST Amt'
      BillingLines.sgstamt                    as Sgst,
      // AX
      @EndUserText.label: 'CGST Amt'
      BillingLines.cgstamt                    as Cgst,
      // AQ
      @EndUserText.label: 'Taxable Value After Discount'
      BillingLines.taxablevalueafterdiscount  as taxable_value_dis,
      // AR
      @EndUserText.label: 'Freight Charge INR'
      BillingLines.freightchargeinr           as freight_charge_inr,
      // AS
      @EndUserText.label: 'Insurance Rate INR'
      BillingLines.insurancerateinr           as insurance_rate,
      // AT
      @EndUserText.label: 'Insurance Amount INR'
      BillingLines.insuranceamountinr         as insurance_amt,
      @EndUserText.label: 'Developmental Rate INR'
      BillingLines.packingchargerateinr       as packaging_rate,
      // AT
      @EndUserText.label: 'Developmental Amount INR'
      BillingLines.packingamountinr           as packing_amt,

      // BA
      @EndUserText.label: 'UGST Rate'
      BillingLines.ugstrate                   as rateugst,
      // BB
      @EndUserText.label: 'UGST Amt'
      BillingLines.ugstamt                    as ugst,
      // BE
      @EndUserText.label: 'Roundoff Value'
      BillingLines.roundoffvalue              as Roundoff,
      // AP
      @EndUserText.label: 'Discount Amount'
      BillingLines.discountamount             as Discount,
      // AO
      @EndUserText.label: 'Discount Rate'
      BillingLines.discountrate               as ratediscount,
      // BF

      @EndUserText.label: 'Tax Amount'
      BillingLines.taxamount                  as TaxAmount,
      @EndUserText.label: 'Total Taxable Amount'
      BillingLines.totaltaxamount             as TotalTaxAmount,

      @EndUserText.label: 'Total Amount'
      BillingLines.totalamount                as Total_amount,

      @EndUserText.label: 'Invoice Amount'
      BillingLines.invoiceamount              as Totalamount,
      // AU
      @EndUserText.label: 'IGST Rate'
      BillingLines.igstrate                   as Rateigst,
      // AW
      @EndUserText.label: 'CGST Rate'
      BillingLines.cgstrate                   as Ratecgst,
      // AY
      @EndUserText.label: 'SGST Rate'
      BillingLines.sgstrate                   as Ratesgst,
      // BC
      @EndUserText.label: 'TCS Rate'
      BillingLines.tcsrate                    as Ratetcs,
      // BD
      @EndUserText.label: 'TCS Amount'
      BillingLines.tcsamount                  as Tcs,

      @EndUserText.label: 'Sale Type'
      BillingLines.saletype                   as SaleType,

      @EndUserText.label: 'Tax Exempted'
      BillingLines.taxexempted                as TaxExempted,


      @EndUserText.label: 'Cancelled Invoice'
      BillingLines.cancelledinvoice           as cancelledinvoice,
      case when BillingLines.cancelledinvoice = 'X' then
      1 else 0 end                            as Cancelled,

      _BillingDoc

}
where
  UserItems.userid = $session.user;
