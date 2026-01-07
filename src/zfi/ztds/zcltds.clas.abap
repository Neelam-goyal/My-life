CLASS zcltds DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLTDS IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

  IF io_request->is_data_requested( ).

    DATA: lt_response    TYPE TABLE OF ZCETDS,
          ls_response    LIKE LINE OF lt_response,
          lt_responseout LIKE lt_response,
          ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lo_error).
          DATA(lv_msg) = lo_error->get_text( ).
      ENDTRY.

      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          lv_msg = lo_error->get_text( ).
      ENDTRY.

select from I_JournalEntry as a
left join I_AccountingDocumentJournal as z on a~accountingdocument = z~AccountingDocument
left join i_withholdingtaxitem as b on a~CompanyCode = b~companycode
left join I_BusinessAreaText as c on c~BusinessArea = a~Branch   " i_businessplace is not permitted so i used i_businessArea Text
left join I_BusinessPartner as e on b~CustomerSupplierAccount = e~BusinessPartnerName
left join I_BUSINESSPARTNERTAXNUMBER as f on e~BusinessPartner = f~BPTaxNumber
*left join  I_WIThholdingtaxcode as g on b~WithholdingTaxType = g~            ******TDS Section Code


fields
a~PostingDate ,
b~AccountingDocument,
c~BusinessAreaName,
b~CustomerSupplierAccount,
e~BusinessPartnerFullName,
f~BPTaxNumber,
b~WithholdingTaxPercent,
b~WhldgTaxBaseAmtInCoCodeCrcy,
b~WhldgTaxAmtInCoCodeCrcy,
b~WithholdingTaxCertificate
*where a~AccountingDocument = '1000'
into table @DATA(header)
privileged access.





* DELETE ADJACENT DUPLICATES FROM header COMPARING  ALL FIELDS.

   LOOP AT header INTO DATA(ls_header).

   ls_response-Voucher_date = ls_header-PostingDate.
   ls_response-voucher_no = ls_header-AccountingDocument.
   ls_response-location = ls_header-BusinessAreaName.
   ls_response-account_code = ls_header-CustomerSupplierAccount.
   ls_response-Supplier_Account_Name = ls_header-BusinessPartnerFullName.
   ls_response-Pan_No = ls_header-BPTaxNumber.
*   ls_response-TDS_Code = ls_header-.
   ls_response-TDS_Deduction_Rate = ls_header-WithholdingTaxPercent.
   ls_response-TDS_Base_Amount = ls_header-WhldgTaxBaseAmtInCoCodeCrcy.
   ls_response-TDS_Amount = ls_header-WhldgTaxAmtInCoCodeCrcy.
   ls_response-Lower_Deduction_No = ls_header-WithholdingTaxCertificate.

 APPEND ls_response TO lt_response.
*  COLLECT  ls_response INTO lt_response.

CLEAR: ls_response .

   ENDLOOP.

  lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

     CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).


    ENDIF.

  ENDMETHOD.
ENDCLASS.
