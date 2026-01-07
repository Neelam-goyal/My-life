CLASS lhc_ZR_TBLBOXEXPHDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR ExpenseHeader RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ExpenseHeader RESULT result.

    METHODS fetchExpensesFromApi FOR MODIFY
      IMPORTING keys FOR ACTION ExpenseHeader~fetchExpensesFromApi RESULT result.
    METHODS syncPaymentStatus FOR MODIFY
      IMPORTING keys FOR ACTION ExpenseHeader~syncPaymentStatus RESULT result.
    METHODS clearTableData FOR MODIFY
      IMPORTING keys FOR ACTION ExpenseHeader~clearTableData RESULT result.

ENDCLASS.

CLASS lhc_ZR_TBLBOXEXPHDR IMPLEMENTATION.

*  METHOD get_instance_authorizations.
*  ENDMETHOD.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD fetchExpensesFromApi.

    DATA lv_json TYPE string.

    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    DATA(FromDate) = ls_key-%param-FromDate.
    DATA(ToDate) = ls_key-%param-ToDate.

    DATA lv_tgtURL TYPE String.
    Data lv_cred Type String.
    Data(lv_key) = 'c5e7b04fe2b1555799a225e6daf1aa3355f2b5f0a325759798360c23f9e36c4d9481586a3864c407b62ba80237d292ce1445102b714279c11f2d327d93d2c021'.
    Data lv_sid TYPE c LENGTH 2.

    lv_sid = sy-sysid.

    IF lv_sid = 'NX' OR lv_sid = 'PC'.
      lv_tgtURL = 'https://bonnuat.stage.darwinbox.io'.
      lv_cred = 'Basic cmVpbWJ1cnNlbWVudF9pbnRlZ3JhdGlvbjoyUTgmSWdrOE9vNkI='.
      Data(lv_key_u) = 'c5e7b04fe2b1555799a225e6daf1aa3355f2b5f0a325759798360c23f9e36c4d9481586a3864c407b62ba80237d292ce1445102b714279c11f2d327d93d2c021'.
      lv_key = lv_key_u.
    ELSEIF lv_sid = 'PR'.
      lv_tgtURL = 'https://1bonn.darwinbox.in'.
      lv_cred = 'Basic YXR0ZW5kYW5jZV9pbnRlZ3JhdGlvbl91c2VyOmthakBzI3ZTRDQ1a2pmczI3MA=='.
      Data(lv_key_l) = 'b86e51b0a7720b84a444fe627bfa13b5484d4bf29ef5878370169e0008aae6ea6d4fa9707cfc3c3f49bf36b7fcc0784a18d2d609afb2834a9e0896e09f43a326'.
      lv_key = lv_key_l.
    ENDIF.

    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_url( i_url = lv_tgtURL ).
        DATA(lo_http) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_req) = lo_http->get_http_request( ).
        lo_req->set_uri_path( '/reimbursementapi/reimbursementlist' ).
        lo_req->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_req->set_header_field( i_name = 'Authorization' i_value = lv_cred ).

        lv_json =
           `{` &&
              `"api_key": "` && |{ lv_key }| && `",` &&
              `"from": "` && |{ FromDate+0(4) }-{ FromDate+4(2) }-{ FromDate+6(2) } 00:00:00| && `",` &&
              `"to": "`   && |{ ToDate+0(4) }-{ ToDate+4(2) }-{ ToDate+6(2) } 23:59:59|   && `",` &&
              `"status": "1"` &&
           `}`.

        lo_req->set_text( lv_json ).

        DATA(lo_resp) = lo_http->execute( if_web_http_client=>get ).

        DATA(lv_code) = lo_resp->get_status( ).
        DATA(lv_body) = lo_resp->get_text( ).


        IF lv_code-code >= 300.
          APPEND VALUE #(
            %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |HTTP { lv_code-code }: { lv_code-reason }|
            )
          ) TO reported-ExpenseHeader.
          RETURN.
        ENDIF.
        lv_json = lo_resp->get_text( ).
      CATCH cx_root INTO DATA(lx_http).
        APPEND VALUE #( %msg = new_message_with_text( text = lx_http->get_text( ) ) ) TO reported-expenseheader.
        RETURN.
    ENDTRY.

    "-- Item
    TYPES: BEGIN OF ty_expense_item,
             id                        TYPE string,
             description               TYPE string,
             item_code                 TYPE string,
             type                      TYPE string,
             ledger                    TYPE string,
             expense_category          TYPE string,
             project_code              TYPE string,
             invoice_number            TYPE string,
             date_of_expense           TYPE string,
             currency                  TYPE string,
             conversion_factor         TYPE string,
             claimed_amount            TYPE string,
             approved_amount           TYPE string,
             processed_amount          TYPE string,
             unit                      TYPE string,
             is_exceeded               TYPE string,
             is_exceeded_text          TYPE string,
             travel_id                 TYPE string,
             trip_unique_id            TYPE string,
             trip_id                   TYPE string,
             travel_details            TYPE string,
             travel_project_code       TYPE string,
             travel_type_tagged        TYPE string,
             " --- shortened ≤30, mapped via NAME_MAPPINGS
             claimed_amt_base_curr     TYPE string,
             claimed_amt_def_curr      TYPE string,
             claimed_amt_conv_factor   TYPE string,
             approved_amt_base_curr    TYPE string,
             approved_amt_def_curr     TYPE string,
             approvedamt_conv_factor   TYPE string,
             processed_amt_base_curr   TYPE string,
             processed_amt_def_curr    TYPE string,
             processed_amt_conv_factor TYPE string,
             is_billable               TYPE i,
             start_date                TYPE string,
             end_date                  TYPE string,
             location                  TYPE string,
             vehicle_type              TYPE string,
             from_location             TYPE string,
             to_location               TYPE string,
             distance                  TYPE string,
             admin_comments            TYPE string,
             no_of_participants        TYPE i,
             participant_wise_split    TYPE string,
             co_payment_percent        TYPE string,
             co_payment_amount         TYPE string,
             dependent_name            TYPE string,
             budget_applied            TYPE string,
             tax_group                 TYPE string,
             status                    TYPE string,
             item_cost_centers         TYPE STANDARD TABLE OF string WITH EMPTY KEY,
             attachments               TYPE STANDARD TABLE OF string WITH EMPTY KEY,
             merchant                  TYPE string,
           END OF ty_expense_item.

    TYPES ty_expense_items TYPE STANDARD TABLE OF ty_expense_item WITH EMPTY KEY.

    " -- Header
    TYPES: BEGIN OF ty_expense_header,
             applied_expense_id       TYPE string,
             reimb_code               TYPE string,
             employee_name            TYPE string,
             designation              TYPE string,
             department               TYPE string,
             cost_center              TYPE string,
             claimed_by               TYPE string,
             company_name             TYPE string,
             group_company_code       TYPE string,
             employee_no              TYPE string,
             claim_title              TYPE string,
             applied_date             TYPE string,
             responder                TYPE string,
             approved_or_rejected_on  TYPE string,
             responder_comment        TYPE string,
             pending_with             TYPE string,
             advance_id               TYPE string,
             advance_name             TYPE string,
             advance_amount           TYPE string,
             advance_amt_def_curr     TYPE string, " fits (<=30)
             advance_type             TYPE string,
             advance_processed_on     TYPE string,
             project_name_with_code   TYPE string,
             project_name             TYPE string,
             project_code             TYPE string,
             acted_by                 TYPE string,
             advance_payment_status   TYPE string,
             trip_unique_id           TYPE string,
             trip_id                  TYPE string,
             trip_name                TYPE string,
             trip_description         TYPE string,
             trip_start_date          TYPE string,
             trip_end_date            TYPE string,
             settlement_amount        TYPE string,
             settlement_amt_base_curr TYPE string,  " mapped
             settlement_amt_def_curr  TYPE string,  " mapped
             settlement_type          TYPE string,
             settled_by               TYPE string,
             settled_on               TYPE string,
             paid_date                TYPE string,
             paid_by                  TYPE string,
             status                   TYPE string,
             expense_items            TYPE ty_expense_items,
             payment_status           TYPE string,
             transaction_id           TYPE string,
             payment_comments         TYPE string,
             overall_comments         TYPE string,
             item_total               TYPE string,
             claimed_item_total       TYPE string,
             processed_item_total     TYPE string,  " can be number or 'INR 350' -> string
             total_claimed_amount     TYPE string,
             total_processed_amount   TYPE string,
           END OF ty_expense_header.

    TYPES ty_expense_headers TYPE STANDARD TABLE OF ty_expense_header WITH EMPTY KEY.

    " -- Top-level response
    TYPES: BEGIN OF ty_message,
             status  TYPE i,
             data    TYPE ty_expense_headers,
             message TYPE string,
           END OF ty_message.

    DATA lv_message TYPE ty_message.

    DATA lt_map TYPE /ui2/cl_json=>name_mappings.

    lt_map = VALUE #(
      ( abap = 'CLAIMED_AMT_BASE_CURR'       json = 'claimed_amount_base_currency'       )
      ( abap = 'CLAIMED_AMT_DEF_CURR'        json = 'claimed_amount_default_currency'    )
      ( abap = 'CLAIMED_AMT_CONV_FACTOR'     json = 'claimed_amount_conversion_factor'   )
      ( abap = 'APPROVED_AMT_BASE_CURR'      json = 'approved_amount_base_currency'      )
      ( abap = 'APPROVED_AMT_DEF_CURR'       json = 'approved_amount_default_currency'   )
      ( abap = 'APPROVEDAMT_CONV_FACTOR'     json = 'approvedamount_conversion_factor'   )
      ( abap = 'PROCESSED_AMT_BASE_CURR'     json = 'processed_amount_base_currency'     )
      ( abap = 'PROCESSED_AMT_DEF_CURR'      json = 'processed_amount_default_currency'  )
      ( abap = 'PROCESSED_AMT_CONV_FACTOR'   json = 'processed_amount_conversion_factor' )
      ( abap = 'SETTLEMENT_AMT_BASE_CURR'    json = 'settlement_amount_base_currency'    )
      ( abap = 'SETTLEMENT_AMT_DEF_CURR'     json = 'settlement_amount_default_currency' )
      ( abap = 'advance_amt_def_curr'     json = 'advance_amount_default_currency' )
    ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json          = lv_json
        name_mappings = lt_map          " <-- key step
      CHANGING
        data          = lv_message
    ).

    IF lv_message IS NOT INITIAL.

      " EML-specific internal tables based on the Behavior Definition
      DATA: lt_headers_to_create TYPE TABLE FOR CREATE zr_tblboxexphdr,
            lt_detail_to_create  TYPE TABLE FOR CREATE zr_tblboxexphdr\_Details,
            ls_header_to_create  LIKE LINE OF lt_headers_to_create,
            ls_detail_to_create  LIKE LINE OF lt_detail_to_create.

      LOOP AT lv_message-data INTO DATA(ls_hdr_json).

        DATA(lv_header_cid) = |header_{ sy-tabix }|.
        CLEAR ls_header_to_create.
        IF ls_hdr_json-status = 'Processed'.
          ls_header_to_create-%cid = lv_header_cid.

          "--- Header fields ---
          ls_header_to_create-%data-AppliedExpenseId      = ls_hdr_json-applied_expense_id.
          ls_header_to_create-%data-ReimbCode             = ls_hdr_json-reimb_code.
          ls_header_to_create-%data-EmployeeName          = ls_hdr_json-employee_name.
          ls_header_to_create-%data-Designation           = ls_hdr_json-designation.
          ls_header_to_create-%data-Department            = ls_hdr_json-department.
          ls_header_to_create-%data-CostCenter            = ls_hdr_json-cost_center.
          ls_header_to_create-%data-ClaimedBy             = ls_hdr_json-claimed_by.
          ls_header_to_create-%data-CompanyName           = ls_hdr_json-company_name.
          ls_header_to_create-%data-GroupCompanyCode      = ls_hdr_json-group_company_code.
          ls_header_to_create-%data-EmployeeNo            = ls_hdr_json-employee_no.
          ls_header_to_create-%data-ClaimTitle            = ls_hdr_json-claim_title.
          ls_header_to_create-%data-AppliedDate           = zcl_date_utils=>parse_date( iv_date_str = ls_hdr_json-applied_date iv_format   = 'dd-MM-yyyy' ).
          ls_header_to_create-%data-Responder             = ls_hdr_json-responder.
          ls_header_to_create-%data-ApprovedOrRejectedOn  = zcl_date_utils=>parse_date( iv_date_str = ls_hdr_json-approved_or_rejected_on iv_format   = 'dd-MM-yyyy' ).
          ls_header_to_create-%data-ResponderComnt        = ls_hdr_json-responder_comment.
          ls_header_to_create-%data-PendingWith           = ls_hdr_json-pending_with.
          ls_header_to_create-%data-AdvanceID             = ls_hdr_json-advance_id.
          ls_header_to_create-%data-AdvanceName           = ls_hdr_json-advance_name.
          ls_header_to_create-%data-AdvanceAmount         = zcl_number_utils=>parse_decimal( ls_hdr_json-advance_amount ).
          ls_header_to_create-%data-AdvanceAmtDefCurr     = ls_hdr_json-advance_amt_def_curr.
          ls_header_to_create-%data-AdvanceType           = ls_hdr_json-advance_type.
          ls_header_to_create-%data-AdvanceProcessedOn  = zcl_date_utils=>parse_date( iv_date_str = ls_hdr_json-advance_processed_on iv_format   = 'dd-MM-yyyy' ).
          ls_header_to_create-%data-ProjectNameWithCode   = ls_hdr_json-project_name_with_code.
          ls_header_to_create-%data-ProjectName           = ls_hdr_json-project_name.
          ls_header_to_create-%data-ProjectCode           = ls_hdr_json-project_code.
          ls_header_to_create-%data-ActedBy               = ls_hdr_json-acted_by.
          ls_header_to_create-%data-AdvancePaymentStatus  = ls_hdr_json-advance_payment_status.
          ls_header_to_create-%data-TripUniqueID          = ls_hdr_json-trip_unique_id.
          ls_header_to_create-%data-TripID                = ls_hdr_json-trip_id.
          ls_header_to_create-%data-TripName              = ls_hdr_json-trip_name.
          ls_header_to_create-%data-TripDescription       = ls_hdr_json-trip_description.
          ls_header_to_create-%data-TripStartDate  = zcl_date_utils=>parse_date( iv_date_str = ls_hdr_json-trip_start_date iv_format   = 'dd-MM-yyyy' ).
          ls_header_to_create-%data-TripEndDate  = zcl_date_utils=>parse_date( iv_date_str = ls_hdr_json-trip_end_date iv_format   = 'dd-MM-yyyy' ).
          ls_header_to_create-%data-SettlementAmount      = zcl_number_utils=>parse_decimal( ls_hdr_json-settlement_amount ).
          ls_header_to_create-%data-SettlementAmtBaseCurr = ls_hdr_json-settlement_amt_base_curr.
          ls_header_to_create-%data-SettlementAmtDefCurr  = ls_hdr_json-settlement_amt_def_curr.
          ls_header_to_create-%data-SettlementType        = ls_hdr_json-settlement_type.
          ls_header_to_create-%data-SettledBy             = ls_hdr_json-settled_by.
          ls_header_to_create-%data-SettledOn  = zcl_date_utils=>parse_date( iv_date_str = ls_hdr_json-settled_on iv_format   = 'dd-MM-yyyy' ).
          ls_header_to_create-%data-PaidDate  = zcl_date_utils=>parse_date( iv_date_str = ls_hdr_json-paid_date iv_format   = 'dd-MM-yyyy' ).
          ls_header_to_create-%data-PaidBy                = ls_hdr_json-paid_by.
          ls_header_to_create-%data-Status                = ls_hdr_json-status.
          ls_header_to_create-%data-PaymentStatus         = ls_hdr_json-payment_status.
          ls_header_to_create-%data-TransactionID         = ls_hdr_json-transaction_id.
          ls_header_to_create-%data-PaymentComments       = ls_hdr_json-payment_comments.
          ls_header_to_create-%data-OverallComments       = ls_hdr_json-overall_comments.
          ls_header_to_create-%data-ItemTotal             = zcl_number_utils=>parse_decimal( ls_hdr_json-item_total ).
          ls_header_to_create-%data-ClaimedItemTotal      = zcl_number_utils=>parse_decimal( ls_hdr_json-claimed_item_total ).
          ls_header_to_create-%data-ProcessedItemTotal    = zcl_number_utils=>parse_decimal( ls_hdr_json-processed_item_total ).
          ls_header_to_create-%data-TotalClaimedAmount    = zcl_number_utils=>parse_decimal( ls_hdr_json-total_claimed_amount ).
          ls_header_to_create-%data-TotalProcessedAmount  = zcl_number_utils=>parse_decimal( ls_hdr_json-total_processed_amount ).

          " Collect header now
          APPEND ls_header_to_create TO lt_headers_to_create.

          "--- Child items (Details) ---
          LOOP AT ls_hdr_json-expense_items INTO DATA(ls_itm_json).
            CLEAR ls_detail_to_create.

            APPEND VALUE #(
                        ItemSeq                   = ls_itm_json-id
                        Description               = ls_itm_json-description
                        ItemCode                  = ls_itm_json-item_code
                        Type                      = ls_itm_json-type
                        Ledger                    = ls_itm_json-ledger
                        ExpenseCategory           = ls_itm_json-expense_category
                        ProjectCode               = ls_itm_json-project_code
                        InvoiceNumber             = ls_itm_json-invoice_number
                        DateOfExpense             = zcl_date_utils=>parse_date( iv_date_str = ls_itm_json-date_of_expense iv_format   = 'dd-MM-yyyy' )
                        ConversionFactor          = ls_itm_json-conversion_factor
                        ClaimedAmount             = zcl_number_utils=>parse_decimal( ls_itm_json-claimed_amount )
                        ApprovedAmount            = zcl_number_utils=>parse_decimal( ls_itm_json-approved_amount )
                        ProcessedAmount           = zcl_number_utils=>parse_decimal( ls_itm_json-processed_amount )
                        UnitQty                   = zcl_number_utils=>parse_decimal( ls_itm_json-unit )
                        IsExceeded                = ls_itm_json-is_exceeded
                        IsExceededText            = ls_itm_json-is_exceeded_text
                        TravelId                  = ls_itm_json-travel_id
                        TripUniqueId              = ls_itm_json-trip_unique_id
                        TripId                    = ls_itm_json-trip_id
                        TravelDetails             = ls_itm_json-travel_details
                        TravelProjectCode         = ls_itm_json-travel_project_code
                        TravelTypeTagged          = ls_itm_json-travel_type_tagged
                        ClaimedAmtBaseCurrTxt     = ls_itm_json-claimed_amt_base_curr
                        ClaimedAmtDefCurrTxt      = ls_itm_json-claimed_amt_def_curr
                        ClaimedAmtConvFactorTxt   = ls_itm_json-claimed_amt_conv_factor
                        ApprovedAmtBaseCurrTxt    = ls_itm_json-approved_amt_base_curr
                        ApprovedAmtDefCurrTxt     = ls_itm_json-approved_amt_def_curr
                        ApprovedAmtConvFactorTxt  = ls_itm_json-approvedamt_conv_factor
                        ProcessedAmtBaseCurrTxt   = ls_itm_json-processed_amt_base_curr
                        ProcessedAmtDefCurrTxt    = ls_itm_json-processed_amt_def_curr
                        ProcessedAmtConvFactorTxt = ls_itm_json-processed_amt_conv_factor
                        IsBillable                = ls_itm_json-is_billable
                        StartDate                 = zcl_date_utils=>parse_date( iv_date_str = ls_itm_json-start_date iv_format   = 'dd-MM-yyyy' )
                        EndDate                   = zcl_date_utils=>parse_date( iv_date_str = ls_itm_json-end_date iv_format   = 'dd-MM-yyyy' )
                        Location                  = ls_itm_json-location
                        VehicleType               = ls_itm_json-vehicle_type
                        FromLocation              = ls_itm_json-from_location
                        ToLocation                = ls_itm_json-to_location
                        DistanceTxt               = ls_itm_json-distance
                        AdminComments             = ls_itm_json-admin_comments
                        NoOfParticipants          = ls_itm_json-no_of_participants
                        ParticipantWiseSplitStr   = ls_itm_json-participant_wise_split
                        CoPaymentPercent          = ls_itm_json-co_payment_percent
                        CoPaymentAmount           = ls_itm_json-co_payment_amount
                        DependentName             = ls_itm_json-dependent_name
                        BudgetApplied             = ls_itm_json-budget_applied
                        TaxGroup                  = ls_itm_json-tax_group
                        Status                    = ls_itm_json-status
                        Merchant                  = ls_itm_json-merchant

            ) TO ls_detail_to_create-%target.
            " Link to parent via its temporary key
            ls_detail_to_create-%cid_ref = lv_header_cid.
            ls_detail_to_create-AppliedExpenseId = ls_header_to_create-AppliedExpenseId.

            APPEND ls_detail_to_create TO lt_detail_to_create.
          ENDLOOP.
        ENDIF.
      ENDLOOP.


      IF lt_headers_to_create IS NOT INITIAL.

        MODIFY ENTITIES OF zr_tblboxexphdr IN LOCAL MODE
        ENTITY ExpenseHeader
          CREATE FIELDS (
          AppliedExpenseId ReimbCode EmployeeNo EmployeeName Designation Department CostCenter ClaimedBy
          CompanyName GroupCompanyCode ClaimTitle AppliedDate Responder ApprovedOrRejectedOn ResponderComnt
          PendingWith AdvanceID AdvanceName AdvanceAmount AdvanceAmtDefCurr AdvanceType AdvanceProcessedOn
          ProjectNameWithCode ProjectName ProjectCode ActedBy AdvancePaymentStatus TripUniqueID TripID TripName
          TripDescription TripStartDate TripEndDate SettlementAmount SettlementAmtBaseCurr SettlementAmtDefCurr
          SettlementType SettledBy SettledOn PaidDate PaidBy SapCompanycode SapAccountingdocument SapFiscalyear
          Status PaymentStatus TransactionID PaymentComments OverallComments ItemTotal ClaimedItemTotal ProcessedItemTotal
          TotalClaimedAmount TotalProcessedAmount ) " List all fields
          WITH lt_headers_to_create  " Use the prepared table
          CREATE BY \_Details
          FIELDS (
          ItemSeq Description ItemCode Type Ledger ExpenseCategory ProjectCode InvoiceNumber DateOfExpense
          ConversionFactor Currency ClaimedAmount ApprovedAmount ProcessedAmount UnitQty IsExceeded IsExceededText TravelId
          TripUniqueId TripId TravelDetails TravelProjectCode TravelTypeTagged ClaimedAmtBaseCurrTxt ClaimedAmtDefCurrTxt
          ClaimedAmtConvFactorTxt ApprovedAmtBaseCurrTxt ApprovedAmtDefCurrTxt ApprovedAmtConvFactorTxt ProcessedAmtBaseCurrTxt
          ProcessedAmtDefCurrTxt ProcessedAmtConvFactorTxt IsBillable StartDate EndDate Location VehicleType FromLocation
          ToLocation DistanceTxt AdminComments NoOfParticipants ParticipantWiseSplitStr CoPaymentPercent CoPaymentAmount
          DependentName BudgetApplied TaxGroup CustomFieldsStr ItemCostCentersStr AttachmentsStr Status Merchant ) " List all fields
          WITH lt_detail_to_create " Use the prepared table
        REPORTED DATA(ls_reported)
        FAILED DATA(ls_failed)
        MAPPED DATA(ls_mapped).

        UPDATE ztbldboxexphdr
          SET
            sap_accountingdocument = substring( transaction_id, 9, length( transaction_id ) - 8 ),
            sap_companycode        = substring( transaction_id, 1, 4 ),
            sap_fiscalyear         = substring( transaction_id, 5, 4 )
        WHERE transaction_id IS NOT INITIAL
            AND length( transaction_id ) > 8 AND
            applied_date BETWEEN  @FromDate AND @ToDate.

*        update ztbldboxexphdr set payment_status = '' where payment_status = 'Paid'.

        " Optional: Provide a success message if the creation worked
        IF ls_failed IS NOT INITIAL.
          APPEND VALUE #( %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-success
              text     = |{ lines( ls_failed-expenseheader ) } # { lines( ls_failed-expensedetail ) } expense records and their items were successfully saved.| )
          ) TO reported-expenseheader.
        ENDIF.


        APPEND VALUE #( %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-information
          text     = 'Data Synced with DBOX.' )
        ) TO reported-expenseheader.
      ENDIF.
    ELSE.
      UPDATE ztbldboxexphdr
        SET
          sap_accountingdocument = substring( transaction_id, 9, length( transaction_id ) - 8 ),
          sap_companycode        = substring( transaction_id, 1, 4 ),
          sap_fiscalyear         = substring( transaction_id, 5, 4 )
        WHERE transaction_id IS NOT INITIAL
          AND length( transaction_id ) > 8 AND
          applied_date BETWEEN  @FromDate AND @ToDate.

      " Report if no data was found
      APPEND VALUE #( %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-information
          text     = 'No new expense data found in the specified date range.' )
      ) TO reported-expenseheader.
    ENDIF.
  ENDMETHOD.


  METHOD syncPaymentStatus.
    "Response Types (D-Box API)
    TYPES: BEGIN OF ty_expense_item,
             status    TYPE string,
             message   TYPE string,
             unique_id TYPE string,
           END OF ty_expense_item.
    TYPES tt_expense_data TYPE STANDARD TABLE OF ty_expense_item WITH EMPTY KEY.
    TYPES: BEGIN OF ty_expense_response,
             status       TYPE i,
             expense_data TYPE tt_expense_data,
           END OF ty_expense_response.

    DATA lv_tgtURL TYPE String.
    Data lv_cred Type String.
    Data(lv_key) = '29d234a6b405372684e6ce3af4ad5491718fcd7013be013a26eaaae33bcdd871a71762b4b240ccf2ed34aedd80aeb17d73817a9a97a2231f7860defa0187fccc'.
    Data lv_sid TYPE c LENGTH 2.

    lv_sid = sy-sysid.

    IF lv_sid = 'NX' OR lv_sid = 'PC'.
      lv_tgtURL = 'https://bonnuat.stage.darwinbox.io'.
      lv_cred = 'Basic cmVpbWJ1cnNlbWVudF9pbnRlZ3JhdGlvbjoyUTgmSWdrOE9vNkI='.
      Data(lv_key_u) = '29d234a6b405372684e6ce3af4ad5491718fcd7013be013a26eaaae33bcdd871a71762b4b240ccf2ed34aedd80aeb17d73817a9a97a2231f7860defa0187fccc'.
      lv_key = lv_key_u.
    ELSEIF lv_sid = 'PR'.
      lv_tgtURL = 'https://1bonn.darwinbox.in'.
      lv_cred = 'Basic YXR0ZW5kYW5jZV9pbnRlZ3JhdGlvbl91c2VyOmthakBzI3ZTRDQ1a2pmczI3MA=='.
      Data(lv_key_l) = '5348a0cbc4678126f855629039b43fab9dc1b04f544138d1293992b5db42c8e04f17fa0d46e614dd194da3f5e0ee4a0c0bf04c6db87c2ec4faf05b85b77a1b3c'.
      lv_key = lv_key_l.
    ENDIF.

    "Fetch unpaid headers
    SELECT *
      FROM zr_tblboxexphdr
      WHERE PaymentStatus IS INITIAL OR PaymentStatus = ''
      INTO TABLE @DATA(lt_unpaid).

    IF lt_unpaid IS INITIAL.
      RETURN.
    ENDIF.

    "If there is any Un-Paid Record
    "Loop on table and process each record.
    IF lt_unpaid IS NOT INITIAL.
      LOOP AT lt_unpaid INTO DATA(expRecord).

        "Search in SAP for Posting Voucher
        SELECT SINGLE CompanyCode, FiscalYear,AccountingDocument,PostingDate,DocumentReferenceID
        FROM i_journalentry
        WHERE accountingdocumenttype = 'KZ'
        AND documentreferenceid = @expRecord-ReimbCode
        AND DocumentReferenceID IS NOT INITIAL
        INTO @DATA(journalEntry).

        "Check if it found any record
        IF journalEntry IS NOT INITIAL.

          " Posting to Darwin Box API
          DATA lv_json TYPE string.
          TRY.
              DATA(lo_dest) = cl_http_destination_provider=>create_by_url( i_url = lv_tgtURL ).
              DATA(lo_http) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
              DATA(lo_req) = lo_http->get_http_request( ).
              lo_req->set_uri_path( '/reimbursementapi/processreimbursement' ).
              lo_req->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
              lo_req->set_header_field( i_name = 'Authorization' i_value = lv_cred ).

              DATA(transaction_id) = |{ journalentry-CompanyCode }{ journalEntry-FiscalYear }{ journalentry-AccountingDocument }|.

              lv_json =
              `{` &&
                  `"api_key": "` && |{ lv_key }| && `",` &&
                  `"expense": [` &&
                                `{` &&
                                    `"employee_id": "` && |{ expRecord-EmployeeNo }| && `",` &&
                                    `"request_id": "` && |{ expRecord-ReimbCode }| && `",` &&
                                    `"payment_status": "Paid",` &&
                                    `"transaction_id": "` && |{ transaction_id }| && `",` &&
                                    `"transaction_date": "` && |{ journalentry-PostingDate+6(2) }-{ journalentry-PostingDate+4(2) }-{ journalentry-PostingDate(4) }| && `",` &&
                                    `"comments": "Applied reimbursements are processed"` &&
                                `}` &&

                            `]` &&
                `}`.

              lo_req->set_text( lv_json ).

              DATA(lo_resp) = lo_http->execute( if_web_http_client=>post ).
              DATA(lv_code) = lo_resp->get_status( ).
              DATA(lv_body) = lo_resp->get_text( ).

              IF lv_code-code >= 300.
                APPEND VALUE #(
                  %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = |HTTP { lv_code-code }: { lv_code-reason }|
                  )
                ) TO reported-ExpenseHeader.
                RETURN.
              ENDIF.
              lv_json = lo_resp->get_text( ).


              DATA lv_response TYPE ty_expense_response.

              /ui2/cl_json=>deserialize(
                                            EXPORTING
                                                json          = lv_json
                                            CHANGING
                                                data          = lv_response
                                        ).

              IF lv_response IS NOT INITIAL.
                IF lv_response-expense_data IS NOT INITIAL.
                  DATA(tag) = 0.
                  LOOP AT lv_response-expense_data INTO DATA(ls_response_result).
                    IF ls_response_result-status IS NOT INITIAL.
                      IF ls_response_result-status = 1.
                        tag = 1.

                      ENDIF.
                    ENDIF.

                  ENDLOOP.

                  IF tag = 1.

                    UPDATE ztbldboxexphdr
                    SET payment_status = 'Paid',
                     transaction_id = @transaction_id,
                     paid_date = @journalentry-PostingDate,
                     payment_comments = 'Applied reimbursements are processed',
                     sap_accountingdocument = @journalentry-AccountingDocument,
                     sap_companycode = @journalentry-CompanyCode,
                     sap_fiscalyear = @journalentry-FiscalYear
                    WHERE applied_expense_id = @expRecord-AppliedExpenseId
                     AND reimb_code = @expRecord-ReimbCode.

                    APPEND VALUE #( %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-information
                         text     = 'Data Synced with SAP.' )
                     ) TO reported-expenseheader.

                  ENDIF.
                ENDIF.
              ENDIF.

            CATCH cx_root INTO DATA(lx_http).
              APPEND VALUE #( %msg = new_message_with_text( text = lx_http->get_text( ) ) ) TO reported-expenseheader.
              RETURN.
          ENDTRY.
        ENDIF.
        CLEAR expRecord.
        CLEAR journalEntry.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD clearTableData.

    DATA user_name TYPE string.

    TRY.
        user_name = cl_abap_context_info=>get_user_formatted_name( ).

      CATCH cx_abap_context_info_error INTO DATA(lx_ctx).
        APPEND VALUE #( %msg = new_message_with_text( text = |Some Error has been occured.| ) ) TO reported-expenseheader.
    ENDTRY.

    IF to_lower( user_name ) = 'bon btp' OR to_lower( user_name ) = 'bonn btp' OR to_lower( user_name ) = 'harinder singh'.

      DELETE FROM ztbldboxexpdtl WHERE 1 = 1.
      DELETE FROM ztbldboxexphdr WHERE 1 = 1.

      APPEND VALUE #( %msg = new_message_with_text(
                severity = if_abap_behv_message=>severity-information
                text     = 'Data cleared.' )
            ) TO reported-expenseheader.
    ELSE.
      APPEND VALUE #( %msg = new_message_with_text( text = |You are not authorised. { user_name }| ) ) TO reported-expenseheader.
    ENDIF.


  ENDMETHOD.

ENDCLASS.
