CLASS ZCL_HTTP_ACCOUNTPOSTSALARYEXP DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.


    INTERFACES if_http_service_extension .
    CLASS-METHODS postData
      IMPORTING
        request        TYPE REF TO if_web_http_request
      RETURNING
        VALUE(message) TYPE string .


    CLASS-METHODS  checkDateFormat
      IMPORTING
        date           TYPE string
        dateType       TYPE string
      RETURNING
        VALUE(message) TYPE string.

   CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    CLASS-METHODS  postSalaryExpenseAccount
      IMPORTING
        wa_data        TYPE zsalaryexpenses
        psDate         TYPE string
        dcDate         TYPE string
      RETURNING
        VALUE(message) TYPE string .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_ACCOUNTPOSTSALARYEXP IMPLEMENTATION.


  METHOD checkDateFormat.

    DATA: lv_match TYPE i.
    DATA: lv_date_parts TYPE TABLE OF string.

    FIND REGEX '^\d{2}-\d{2}-\d{4}$'  IN date.

    IF sy-subrc = 0.
      lv_match = 1.
    ELSE.
      lv_match = 0.
    ENDIF.

    FIND REGEX '^\d{4}-\d{2}-\d{2}$'  IN date.
    IF sy-subrc = 0.
      lv_match = 2.
    ENDIF.

    IF lv_match = 1.
      TRY.
          SPLIT date AT '-' INTO  DATA(lv_date_parts1) DATA(lv_date_parts2) DATA(lv_date_parts3) .
          message = lv_date_parts3 && lv_date_parts2 && lv_date_parts1.
        CATCH cx_sy_itab_line_not_found.
          message = |Invalid { dateType } date format: { date }|.
          RETURN.
      ENDTRY.
    ELSEIF lv_match = 2.
      TRY.
          DATA(lv_date_parts4) = date.
          REPLACE ALL OCCURRENCES OF '-' IN lv_date_parts4 WITH ''.
          message = lv_date_parts4.
        CATCH cx_sy_itab_line_not_found.
          message = |Invalid { dateType } date format: { date }|.
          RETURN.
      ENDTRY.
    ELSE.
      message = |Invalid { dateType } date format: { date }|.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( postData( request ) ).
    ENDCASE.
  ENDMETHOD.


  METHOD postData.

    TYPES: BEGIN OF ty_json_structure,
             employetype TYPE i,
             salarydate  TYPE c length 10,
             plantcode type werks_d,
           END OF ty_json_structure.

    DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

    TRY.

        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

        LOOP AT tt_json_structure INTO DATA(wa).

          SELECT SINGLE * FROM zsalaryexpenses
          WHERE employetype  = @wa-employetype
               AND salarydate   = @wa-salarydate
               AND salarydate = @wa-salarydate
*               AND companycode  = @wa-companycode
               and isposted is initial
             INTO @DATA(wa_data).

          wa_data-salarydate = wa_data-salarydate+0(10).

          DATA(psDate) = checkDateFormat( date = CONV string( wa_data-salarydate ) datetype = 'Posting' ).
          FIND 'Invalid' IN psDate.
          IF sy-subrc = 0.
            message = psDate.
            UPDATE zsalaryexpenses
               SET errorlog = @message
               WHERE employetype = @wa_data-employetype
               and salarydate = @wa_data-salarydate
               and salarydate = @wa_data-salarydate
*               and companycode = @wa_data-companycode
               and isposted is initial.
            RETURN.
          ENDIF.

          DATA(dcDate) = checkDateFormat( date = CONV string( wa_data-salarydate ) datetype = 'Document' ).
          FIND 'Invalid' IN dcDate.
          IF sy-subrc = 0.
            message = dcDate.
            UPDATE zsalaryexpenses
               SET errorlog = @message
               WHERE employetype = @wa_data-employetype
               and salarydate = @wa_data-salarydate
               and salarydate = @wa_data-salarydate
*               and companycode = @wa_data-companycode
               and isposted is initial.
            RETURN.
          ENDIF.

          message = postSalaryExpenseAccount( wa_data = wa_data psdate = psDate dcdate = dcDate ).

        ENDLOOP.

      CATCH cx_sy_conversion_no_date INTO DATA(lx_date).
        message = |Error in Date Conversion: { lx_date->get_text( ) }|.

      CATCH cx_sy_conversion_no_time INTO DATA(lx_time).
        message = |Error in Time Conversion: { lx_time->get_text( ) }|.

      CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
        message = |SQL Error: { lx_sql->get_text( ) }|.

      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.


  ENDMETHOD.


 METHOD postSalaryExpenseAccount.
   DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
         document   TYPE string.

   SELECT SINGLE FROM ztable_plant
    FIELDS  profitcenter , costcenter ,comp_code
    WHERE plant_code = @wa_data-plantcode
    INTO @DATA(lv_centers).

   DATA(TypeFinder) = |EMPTYPE{ wa_data-employetype }|.

   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = @TypeFinder
   INTO @DATA(lv_gl).

   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = 'VPFPayable'
   INTO @DATA(VPFPayable).

   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = 'SalaryExpenses'
   INTO @DATA(Salary).


   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = 'PTDeduction'
   INTO @DATA(PTDeduction).

   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = 'PLWFPayable'
   INTO @DATA(PLWFPayable).

   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = 'PFPayable'
   INTO @DATA(PFPayable).

   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = 'GHIDeduction'
   INTO @DATA(GHIDeduction).

   SELECT SINGLE FROM zr_integration_tab
   FIELDS Intgpath
   WHERE Intgmodule = 'ESIPayable'
   INTO @DATA(ESIPayable).


   APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
   <je_deep>-%cid = getCid(  ).
   <je_deep>-%param = VALUE #(
   companycode = lv_centers-comp_code
   businesstransactiontype = 'RFBU'
   accountingdocumenttype = 'SA'
   CreatedByUser = sy-uname
   documentdate = dcDate
   postingdate = COND #( WHEN psDate IS INITIAL
                 THEN cl_abap_context_info=>get_system_date( )
                 ELSE psDate )
        _glitems = VALUE #(
                            ( glaccountlineitem = |001|
                            glaccount = Salary
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-salarypayable
                                                currency = 'INR' ) ) )

                          ( glaccountlineitem = |002|
                            glaccount = lv_gl
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-salarypayable * -1
                                                currency = 'INR' ) ) )

                          ( glaccountlineitem = |003|
                            glaccount = lv_gl
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-pfpayable
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |004|
                            glaccount = plwfpayable
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-pfpayable * -1
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |005|
                            glaccount = lv_gl
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-ghideduction
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |006|
                            glaccount = ghideduction
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-ghideduction  * -1
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |007|
                            glaccount = lv_gl
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-pfpayable
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |008|
                            glaccount = pfpayable
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-pfpayable * -1
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |009|
                            glaccount = lv_gl
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-esipayable
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |010|
                            glaccount = esipayable
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-esipayable  * -1
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |011|
                            glaccount = lv_gl
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-ptdeduction
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |012|
                            glaccount = ptdeduction
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-ptdeduction * -1
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |013|
                            glaccount = lv_gl
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-vpfpayable
                                                currency = 'INR' ) ) )

                            ( glaccountlineitem = |014|
                            glaccount = vpfpayable
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-vpfpayable * -1
                                                currency = 'INR' ) ) )

                          ( glaccountlineitem = |015|
                            glaccount = vpfpayable
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-vpfpayable
                                                currency = 'INR' ) ) )

                           ( glaccountlineitem = |016|
                            glaccount = pfpayable
                            BusinessPlace = wa_data-plantcode
                            DocumentItemText = |salary expence  for month of 09062025|
*                            ProfitCenter = lv_centers-profitcenter
                            CostCenter = lv_centers-costcenter
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-vpfpayable * -1
                                                currency = 'INR' ) ) ) )
        )
   .

   MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
   ENTITY journalentry
   EXECUTE post FROM lt_je_deep
   FAILED DATA(ls_failed_deep)
   REPORTED DATA(ls_reported_deep)
   MAPPED DATA(ls_mapped_deep).

   IF ls_failed_deep IS NOT INITIAL.

     LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
       message = <ls_reported_deep>-%msg->if_message~get_text( ).
     ENDLOOP.
     UPDATE zsalaryexpenses
       SET errorlog = @message
       WHERE  employetype = @wa_data-employetype
               and salarydate = @wa_data-salarydate
               and salarydate = @wa_data-salarydate.
*               and companycode = @wa_data-companycode
     RETURN.
   ELSE.

     COMMIT ENTITIES BEGIN
     RESPONSE OF i_journalentrytp
     FAILED DATA(lt_commit_failed)
     REPORTED DATA(lt_commit_reported).

     IF lt_commit_reported IS NOT INITIAL.
       LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
         document = <ls_reported>-AccountingDocument.
       ENDLOOP.
     ELSE.
       LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
         message = <ls_failed>-%fail-cause.
       ENDLOOP.
       UPDATE zsalaryexpenses
       SET errorlog = @message
       WHERE    employetype = @wa_data-employetype
               and salarydate = @wa_data-salarydate
               and salarydate = @wa_data-salarydate.
*               and companycode = @wa_data-companycode .
       RETURN.
     ENDIF.

     COMMIT ENTITIES END.

     IF document IS NOT INITIAL.
       message = |Document Created Successfully: { document }|.
       MODIFY ENTITIES OF zcds_salesexpenses
       ENTITY ZrSalesExpenses
       UPDATE FIELDS ( Accountingdocument Isposted )
       WITH VALUE #(  (
           Accountingdocument = document
           Isposted = abap_true
           employetype = wa_data-employetype
           salarydate = wa_data-salarydate
           Plantcode = wa_data-plantcode
         )  )
       FAILED DATA(lt_failed)
       REPORTED DATA(lt_reported).
       COMMIT ENTITIES BEGIN
          RESPONSE OF zr_oipayments
          FAILED DATA(lt_commit_failed2)
          REPORTED DATA(lt_commit_reported2).
       ...
       COMMIT ENTITIES END.
     ELSE.
       message = |Document Creation Failed: { message }|.
     ENDIF.

   ENDIF.

 ENDMETHOD.
ENDCLASS.
