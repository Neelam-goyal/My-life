CLASS zcl_glaccountstatement DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS get_statement FOR TABLE FUNCTION ZTBLF_GLAccountStatement.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GLACCOUNTSTATEMENT IMPLEMENTATION.


  METHOD get_statement
          BY DATABASE FUNCTION FOR HDB
            LANGUAGE SQLSCRIPT
            OPTIONS READ-ONLY
            USING ZC_GLAccountStatement ZR_BillingDocumentRef ZR_PurchaseDocumentRef ZR_PaymentDocumentRef.

   result =  select
          100 as CLIENT,
                    ROW_NUMBER() OVER (
              ORDER BY
                item.companycode           ASC,
                item.postingdate           Desc,
                item.accountingdocument    Desc,
                item.accountingdocumentitem Desc

            ) AS srno,

          item.fiscalyear,
          item.companycode,
*          row_number ( ) over( order by item.postingdate Desc, item.accountingdocument Desc, item.AccountingDocumentItem Desc) srno,
          item.postingdate,
          item.accountingdocument,

          item.glaccount,
          item.glaccountname,

          item.documentdate,
          item.accountingdocumenttype,


          item.referencedocumenttype,
          item.originalreferencedocument,
          cast(


          case item.accountingdocumenttype
          when 'KG' then coalesce( item.DocumentReferenceID,'') || '.  '||coalesce( item.documentitemtext,'' )

          when 'UE'
          then 'Balance brought forward ' || item.glaccountname
          when 'DG'
          then 'To Credit Note No. ' || coalesce( item.DocumentReferenceID,'') || '.  '||coalesce( item.documentitemtext,'' )
          when 'RV'
          then 'To Inv. No. ' || BillingRef.InvNo ||
          ' Dtd. '|| To_varchar ( BillingDocumentDate , 'DD-MM-YYYY' ) || ( CASE when SalesOrders is null then  '' ELSE ' against SO. ' || SalesOrders END ) || ( CASE when OutBoundDlvs is null then '' ELSE ' Dlv. No. ' || OutBoundDlvs END )
          WHEN 'KR'
          then coalesce( 'By Bill No. ' || PurchaseRef.supplierinvoiceidbyinvcgparty || ' against entry no. ' || PurchaseRef.supplierinvoicewthnfiscalyear ||
          coalesce( ' Dtd. ' || To_varchar ( PurchaseRef.documentdate , 'DD-MM-YYYY' ), '') || coalesce( ' against PO. ' || PurchaseOrder ,''),
          'By Invoice ' || pymtref.OffsettingAccountName ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || item.documentitemtext)
          WHEN 'DZ'
          then 'By payment receved in ' || coalesce( pymtref.OffsettingAccountName ,'' )||' against ref. '|| coalesce( pymtref.AssignmentReference,'' )
          || ' ' || coalesce( PaymentReference,'' ) ||' Inv. Ref. '|| coalesce( InvoiceReference,'' ) || ' Doc.' || coalesce( SalesDocument,'' ) || coalesce( PurchasingDocument,'' ) || coalesce( item.documentitemtext,'' )
          when 'KG'
          then 'To Credit Document ' || pymtref.OffsettingAccountName ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || item.documentitemtext
          when 'RE'
          then 'By Bill No. ' || PurchaseRef.supplierinvoiceidbyinvcgparty || ' against entry no. ' || PurchaseRef.supplierinvoicewthnfiscalyear ||
          coalesce( ' Dtd. ' || To_varchar ( PurchaseRef.documentdate , 'DD-MM-YYYY' ), '') || coalesce( ' against PO. ' || PurchaseOrder ,'')

          WHEN 'EZ'
          then 'To payment made from '|| pymtref.OffsettingAccountName ||' under '|| item.glaccountname ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || item.documentitemtext
          when 'KZ'
          then 'To payment made from '|| pymtref.OffsettingAccountName ||' under '|| item.glaccountname ||' against ref. '|| pymtref.AssignmentReference
          || ' ' || item.documentitemtext
          else
          (CASE when item.documentitemtext is null or length( item.documentitemtext ) <= 2 then 'Pymt. Ref ' || PaymentReference ||' Inv. Ref. '|| InvoiceReference || ' Doc.' || SalesDocument || PurchasingDocument ELSE DocumentItemText end)
          END

          as varchar( 500 )) documentitemtext,

          item.BusinessTransactionType,
          item.Supplier,
          Item.Customer,
          item.CostCenter,
          item.ProfitCenter,
          item.FunctionalArea,
          item.BusinessArea,
          item.BusinessPlace,
          item.Segment,
          item.Plant,
          item.ControllingArea,

          item.ReversalReason,
          item.IsReversal,
          item.IsReversed,
          item.ReversedReferenceDocument,
          item.ReversalReferenceDocument,
          item.ReversedDocument,
          item.ReverseDocument,

          item.companycodecurrency,
          item.debitcreditcode,
          item.amountincompanycodecurrency,
          item.creditamountincmpcdcrcy,
          item.debitamountincmpcdcrcy,
          sum (item.amountincompanycodecurrency)
          over (order by
                item.companycode           ASC,
                item.postingdate           Desc,
                item.accountingdocument    Desc,
                item.accountingdocumentitem Desc
                rows between  current row and unbounded following  ) as runningbalance
    from
        ZC_GLAccountStatement( :pCompanyCode , :pGLAccount, :pFromDate, :pToDate, :pIsRevDoc) as item
        Left outer Join
             (
                SELECT x.companycode, x.FiscalYear, x.accountingdocument, x.billingdocument,x.InvNo,x.BillingDocumentDate,
                string_agg( SalesOrder , ', ' ) as SalesOrders,
                  string_agg( OutBoundDlv , ', ' ) as OutBoundDlvs
                from ZR_BillingDocumentRef as x
                group by x.companycode, x.FiscalYear, x.accountingdocument, x.billingdocument, x.InvNo,x.BillingDocumentDate
            ) as BillingRef
            on item.accountingdocument = BillingRef.accountingdocument
                and item.companycode = BillingRef.companycode
                and item.FiscalYear = BillingRef.FiscalYear
                and item.accountingdocumenttype = 'RV'
        Left outer join
            (
                SELECT p.companycode, p.fiscalyear, p.supplierinvoicewthnfiscalyear, p.supplierinvoiceidbyinvcgparty, p.documentdate,
                 string_agg( p.purchaseorder , ', ' ) as PurchaseOrder
                    From ZR_PurchaseDocumentRef as p
                    group by p.companycode, p.fiscalyear, p.supplierinvoicewthnfiscalyear, p.supplierinvoiceidbyinvcgparty, p.documentdate
            ) as PurchaseRef
            on item.originalreferencedocument = PurchaseRef.supplierinvoicewthnfiscalyear
                and item.companycode= PurchaseRef.companycode
                and (item.accountingdocumenttype = 'RE' or item.accountingdocumenttype = 'KR')

        Left outer join
            ZR_PaymentDocumentRef as pymtref
            ON pymtref.accountingdocument = item.accountingdocument
            and pymtref.accountingdocumentitem = item.accountingdocumentitem
            and pymtref.FiscalYear = item.FiscalYear
            and pymtref.companycode = item.companycode

        Order by item.companycode           ASC,
                item.postingdate           Desc,
                item.accountingdocument    Desc,
                item.accountingdocumentitem Desc
            ;
   return
    Select *
    From  :Result
    order by srno Desc;

  endmethod.
ENDCLASS.
