CLASS zcl_debtoraging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS get_data_debtoraging FOR TABLE FUNCTION ztblf_debtoraging.
    CLASS-METHODS split_range FOR TABLE FUNCTION ztf_split_range.


  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_DEBTORAGING IMPLEMENTATION.


  METHOD get_data_debtoraging
            BY DATABASE FUNCTION FOR HDB
                       LANGUAGE SQLSCRIPT
                       OPTIONS READ-ONLY
                       USING ZR_ReceivalsTransactions ztf_split_range.

*      Closing Balance As On Date
    xd1 = Select PartyCode,Sum(AmountInCompanyCodeCurrency) a
          From ZR_ReceivalsTransactions
          where CompanyCode = :pCompany
          and PostingDate <= :pAsOnDate
          Group By PartyCode ;

*     Customer with Debit Balance Records
    xd =  SELECT  PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,DocumentReferenceID,
          PartyCode,PartyName,AmountInCompanyCodeCurrency VutAmt,
          ROW_NUMBER() over (Partition By PartyCode Order by NetDueDate Desc, AccountingDocumentType, AccountingDocument, AccountingDocumentItem) As r,
          Sum(AmountInCompanyCodeCurrency) Over(Partition By PartyCode) as Bal,
          Sum(case WHEN AmountInCompanyCodeCurrency > 0
                     then AmountInCompanyCodeCurrency
                     ELSE 0
                     END ) Over(Partition By PartyCode Order by NetDueDate Desc, AccountingDocumentType, AccountingDocument, AccountingDocumentItem) Running
          FROM ZR_ReceivalsTransactions
          where CompanyCode = :pCompany and PostingDate <= :pAsOnDate AND PartyCode in (SELECT PartyCode FROM :xd1 WHERE a>0);

    xc =  SELECT  PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,DocumentReferenceID,
          PartyCode,PartyName,AmountInCompanyCodeCurrency VutAmt,
          ROW_NUMBER() over (Partition By PartyCode Order by NetDueDate Desc, AccountingDocumentType, AccountingDocument, AccountingDocumentItem) As r,
          Sum(AmountInCompanyCodeCurrency) Over(Partition By PartyCode) as Bal,
          Sum(case WHEN AmountInCompanyCodeCurrency < 0
                     then AmountInCompanyCodeCurrency
                     ELSE 0
                     END ) Over(Partition By PartyCode Order by NetDueDate Desc, AccountingDocumentType, AccountingDocument, AccountingDocumentItem) Running
          FROM ZR_ReceivalsTransactions
          where CompanyCode = :pCompany and PostingDate <= :pAsOnDate AND PartyCode in (SELECT PartyCode FROM :xd1 WHERE a<0);


     VAging_Xd =
          Select *,
          CASE when dd >= 0 then VutRefRcptAmt ELSE 0 END DueAmt,
          CASE when dd < 0 then VutRefRcptAmt ELSE 0 END NoDueAmt,
          Abs(dd) as DueDays

          From (
          SELECT PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,DocumentReferenceID,
          PartyCode, PartyName, Balance, DocAmt,
          CASE When r=1 and Balance<0 and Cr<0 then Cr ELSE  VutRefRcptAmt END VutRefRcptAmt ,
          days_between(NetDueDate, :pAsOnDate ) dd
          From (
                SELECT PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,DocumentReferenceID,
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

          SELECT PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,DocumentReferenceID,
          PartyCode, PartyName, Balance, DocAmt,
          CASE When r=1 and Balance<0 and Cr<0 then Cr ELSE  VutRefRcptAmt END VutRefRcptAmt ,
          days_between(NetDueDate, :pAsOnDate ) dd
          From (
                SELECT PostingDate,NetDueDate,CompanyCode,FiscalYear,AccountingDocument, AccountingDocumentType,DocumentReferenceID,
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


  METHOD split_range
  BY DATABASE FUNCTION FOR HDB
  LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY.

    declare lv_val   integer;
    declare lv_prev  integer = 0;
    declare idx      integer = 1;
    declare str_len  integer;
    declare pos      integer;
    declare val      nvarchar(100);

    -- Temporary table for split numbers
    declare ranges table (min_value int, max_value int);

    -- SPLIT and PROCESS values
    input_str = replace( :input_str,'=','' );
    WHILE idx <= length(:input_str) DO
      pos = instr(:input_str, ',', idx);

      IF pos = 0 THEN
        val = SUBSTRING(:input_str, idx);
        idx = LENGTH(:input_str) + 1;
      ELSE
        val = SUBSTRING(:input_str, idx, pos - idx);
        idx = pos + 1;
      END if;

      lv_val = to_int(val);

      INSERT INTO :ranges VALUES (:lv_prev, :lv_val);

      lv_prev = lv_val + 1;
    END while;

    -- ADD final range
    INSERT INTO :ranges VALUES (:lv_prev, 999);

    RETURN
    select 100 as CLIENT,row_number ( ) OVER( ORDER BY min_value ) as SrNo,*
    from :ranges;

  endmethod.
ENDCLASS.
