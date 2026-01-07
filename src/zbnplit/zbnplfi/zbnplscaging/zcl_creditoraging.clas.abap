
CLASS zcl_creditoraging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS get_data_creditoraging FOR TABLE FUNCTION ztblf_creditoraging.

  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_CREDITORAGING IMPLEMENTATION.


  METHOD get_data_creditoraging
            BY DATABASE FUNCTION FOR HDB
                       LANGUAGE SQLSCRIPT
                       OPTIONS READ-ONLY
                       USING ZR_PayablesTransactions ztf_split_range.

*      Closing Balance As On Date
    xd1 = Select PartyCode,Sum(AmountInCompanyCodeCurrency) a
          From ZR_PayablesTransactions
          where CompanyCode = :pCompany
          and PostingDate <= :pAsOnDate
          Group By PartyCode ;

*     Supplier with Debit Balance Records
    xd =  SELECT  PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,  DocumentReferenceID,
          PartyCode,PartyName,AmountInCompanyCodeCurrency VutAmt,
          ROW_NUMBER() over (Partition By PartyCode Order by NetDueDate Desc, AccountingDocumentType, AccountingDocument, AccountingDocumentItem) As r,
          Sum(AmountInCompanyCodeCurrency) Over(Partition By PartyCode) as Bal,
          Sum(case WHEN AmountInCompanyCodeCurrency > 0
                     then AmountInCompanyCodeCurrency
                     ELSE 0
                     END ) Over(Partition By PartyCode Order by NetDueDate Desc, AccountingDocumentType, AccountingDocument, AccountingDocumentItem) Running
          FROM ZR_PayablesTransactions
          where CompanyCode = :pCompany and PostingDate <= :pAsOnDate AND PartyCode in (SELECT PartyCode FROM :xd1 WHERE a>0);

*     Supplier with Credit Balance Records
    xc =  SELECT  PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,  DocumentReferenceID,
          PartyCode,PartyName,AmountInCompanyCodeCurrency VutAmt,
          ROW_NUMBER() over (Partition By PartyCode Order by NetDueDate Desc, AccountingDocumentType, AccountingDocument, AccountingDocumentItem) As r,
          Sum(AmountInCompanyCodeCurrency) Over(Partition By PartyCode) as Bal,
          Sum(case WHEN AmountInCompanyCodeCurrency < 0
                     then AmountInCompanyCodeCurrency
                     ELSE 0
                     END ) Over(Partition By PartyCode Order by NetDueDate Desc, AccountingDocumentType, AccountingDocument, AccountingDocumentItem) Running
          FROM ZR_PayablesTransactions
          where CompanyCode = :pCompany and PostingDate <= :pAsOnDate AND PartyCode in (SELECT PartyCode FROM :xd1 WHERE a<0);


     VAging_Xd =
          Select *,
          CASE when dd >= 0 then VutRefRcptAmt ELSE 0 END DueAmt,
          CASE when dd < 0 then VutRefRcptAmt ELSE 0 END NoDueAmt,
          Abs(dd) as DueDays

          From (
          SELECT PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,  DocumentReferenceID,
          PartyCode, PartyName, Balance, DocAmt,
          CASE When r=1 and Balance<0 and Cr<0 then Cr ELSE  VutRefRcptAmt END VutRefRcptAmt ,
          days_between(NetDueDate, :pAsOnDate ) dd
          From (
                SELECT PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,  DocumentReferenceID,
                  PartyCode, PartyName, Bal as Balance, Bal- Running as Bal,
                  Running, VutAmt DocAmt,
                 (CASE
                 when VutAmt >0 And (Bal-Running) >=0 then VutAmt
                 WHEN VutAmt >0 And (Bal-Running) <0 then ((Bal-Running)+VutAmt)
                 ELSE 0 end) VutRefRcptAmt,
                 CASE when  Bal<0 And r=1 then Bal ELSE 0 END as Cr, r
                From :Xd
               ) as a
              where  (Balance>0 And VutRefRcptAmt>0) or (Balance<0 And VutRefRcptAmt>=Balance And r=1 And Cr<0)

          union all

          SELECT PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,  DocumentReferenceID,
          PartyCode, PartyName, Balance, DocAmt,
          CASE When r=1 and Balance<0 and Cr<0 then Cr ELSE  VutRefRcptAmt END VutRefRcptAmt ,
          days_between(NetDueDate, :pAsOnDate ) dd
          From (
                SELECT PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,  DocumentReferenceID,
                  PartyCode, PartyName, Bal as Balance, Bal- Running as Bal,
                  Running, VutAmt DocAmt,
                  ( CASE
                    when VutAmt<0 And (Bal-Running)<=0 then VutAmt
                    when VutAmt<0 And (Bal-Running)>0 then ((Bal-Running)+VutAmt)
                    ELSE 0 end) VutRefRcptAmt,
                    CASE when  Bal>0 And r=1 then Bal ELSE 0 END as Cr, r
                From :xc
               ) as a
              where  (Balance<0 And VutRefRcptAmt<0) or (Balance>0 And VutRefRcptAmt<=Balance And r=1 And Cr>0)
          ) as Final;

  DaysTbl = SELECT  r.*
            from ztf_split_range( input_str => :pDaysStr ) as r;



  return

          Select
                100 as client,
                PartyCode, PartyName,
                PostingDate, NetDueDate,
                CompanyCode ,
                FiscalYear ,
                AccountingDocument,
                AccountingDocumentType,
                DocumentReferenceID,
                Balance, DocAmt, VutRefRcptAmt,DueAmt,NoDueAmt,DueDays,
                case
                when DaysTbl.Max_Value is Null then
                null
                when DaysTbl.Max_Value = 999 then
                DaysTbl.SrNo||'. >='||DaysTbl.Min_Value
                else
                DaysTbl.SrNo||'. '||DaysTbl.Min_Value||' - '||DaysTbl.Max_Value
                end as Range
          From :VAging_Xd as item
          left outer join :DaysTbl as DaysTbl
                 on item.DueDays between DaysTbl.min_value and DaysTbl.max_value;


  endmethod.
ENDCLASS.
