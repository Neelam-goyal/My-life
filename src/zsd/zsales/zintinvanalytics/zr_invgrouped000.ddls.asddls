@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Invoice Grouped'
define root view entity ZR_INVGROUPED000
  as select from zinv_grouped
  composition [0..*] of ZR_INV_MST000 as _InvoiceHeaders
  composition [0..*] of ZR_USDATAMST as _UnsoldHeaders
  composition [0..*] of ZR_CONTROLSHEET as _CtrlHeaders
  composition [0..*] of ZR_CRATESDATA000 as _CratesHeaders
  composition [0..*] of ZR_SCRAP as _ScrapHeaders
  composition [0..*] of ZR_CREDITNOTE as _CRNHeaders
  composition [0..*] of ZR_CASHROOMCR as _ReceiptHeaders
{
  key orderdate as Orderdate,
  key type as Type,
  nooforder as Nooforder,
  orderamount as Orderamount,
  processed as Processed,
  socreated as Socreated,
  soamount as Soamount,
  outboundcreated as Outboundcreated,
  orderbilled as Orderbilled,
  billedamount as Billedamount,
  pocreated as Pocreated,
  migocreated as Migocreated,
  datavalidated as Datavalidated,
  potobecreated as Potobecreated,
  
  
  case 
      when type = 'Sales' or type = 'Unsold' then (
        case
              when orderamount != billedamount then 1
              else 0 
        end
      )
      when type = 'Expenses' or type = 'Crates' 
      or   type = 'Scraps' or type = 'Credit Notes' 
      or   type = 'Receipts' then (
        case
              when processed != nooforder then 1
              else 0 
        end
      )
      else 0      
    end 
   as Highlight, 
   
   
   // View Only Fields Work in Metadata
   case when type = 'Sales' then '' else 'X' end as IsSales,
   case when type = 'Unsold' then '' else 'X' end as IsUnsold,
   case when type = 'Expenses' then '' else 'X' end as IsExpense,
   case when type = 'Crates' then '' else 'X' end as IsCrates,
   case when type = 'Credit Notes' then '' else 'X' end as IsCrn,
   case when type = 'Scraps' then '' else 'X' end as IsScrap,
   case when type = 'Receipts' then '' else 'X' end as IsReceipt,
   
   
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
    _InvoiceHeaders,
    _UnsoldHeaders,
    _CtrlHeaders,
    _CratesHeaders,
    _CRNHeaders,
    _ScrapHeaders,
    _ReceiptHeaders
  
}
