CLASS ztest_salary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.

    CLASS-METHODS postData.


    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    CLASS-METHODS  postSupplierPayment
      IMPORTING
        wa_data        TYPE zr_salary
        psDate         TYPE string
        dcDate         TYPE string
      RETURNING
        VALUE(message) TYPE string .

    CLASS-METHODS get_month_year
      IMPORTING
        iv_date              TYPE string
      RETURNING
        VALUE(ev_month_year) TYPE string.


    CLASS-METHODS  checkDateFormat
      IMPORTING
        date           TYPE string
        dateType       TYPE string
      RETURNING
        VALUE(message) TYPE string.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_SALARY IMPLEMENTATION.


  METHOD checkDateFormat.

    DATA: lv_match TYPE i.

    FIND REGEX '^\d{2}-\d{2}-\d{4}$'  IN date.

    IF sy-subrc = 0.
      lv_match = 1.
    ELSE.
      lv_match = 0.
    ENDIF.

    FIND REGEX '^\d{4}\d{2}\d{2}$'  IN date.
    IF sy-subrc = 0.
      lv_match = 2.
    ENDIF.

    IF lv_match = 1.
      TRY.
          DATA: lv_date_parts TYPE TABLE OF string.
          SPLIT date AT '-' INTO  DATA(lv_date_parts1) DATA(lv_date_parts2) DATA(lv_date_parts3) .
          message = lv_date_parts3 && lv_date_parts2 && lv_date_parts1.
        CATCH cx_sy_itab_line_not_found.
          message = |Invalid { dateType } date format: { date }|.
          RETURN.
      ENDTRY.
    ELSEIF lv_match = 2.
      message = date.
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


  METHOD get_month_year.
    DATA: lv_year  TYPE string,
          lv_month TYPE string.

    lv_year = iv_date(4).
    lv_month = iv_date+4(2).


    CASE lv_month.
      WHEN '01'. lv_month = 'Jan'.
      WHEN '02'. lv_month = 'Feb'.
      WHEN '03'. lv_month = 'Mar'.
      WHEN '04'. lv_month = 'Apr'.
      WHEN '05'. lv_month = 'May'.
      WHEN '06'. lv_month = 'Jun'.
      WHEN '07'. lv_month = 'Jul'.
      WHEN '08'. lv_month = 'Aug'.
      WHEN '09'. lv_month = 'Sep'.
      WHEN '10'. lv_month = 'Oct'.
      WHEN '11'. lv_month = 'Nov'.
      WHEN '12'. lv_month = 'Dec'.
    ENDCASE.

    " Concatenate month and year
    CONCATENATE lv_month lv_year INTO ev_month_year SEPARATED BY space.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    postData(  ).

    DATA(toUpdate) = ''.

    DATA: acc_doc       TYPE zr_salary-Accountingdocument,
          employee_code TYPE zr_salary-EmployeeCode,
          due_date      TYPE zr_salary-DueDate,
          plant         TYPE zr_salary-plant.
    IF toUpdate = 'X'.
      UPDATE zsalary SET accountingdocument2 = @acc_doc
      WHERE employee_code = @employee_code
        AND due_date = @due_date
        AND Plant = @plant.
    ENDIF.


  ENDMETHOD.


  METHOD postData.

    DATA message TYPE string.
    TRY.

        DATA: employee_code TYPE zr_salary-EmployeeCode,
              due_date      TYPE zr_salary-DueDate,
              plant         TYPE zr_salary-plant.

        IF employee_code IS NOT INITIAL AND plant IS NOT INITIAL AND due_date IS NOT INITIAL.
          SELECT * FROM zr_salary
          WHERE EmployeeCode = @employee_code
            AND Plant = @Plant
            AND DueDate = @due_date
          INTO TABLE @DATA(tt_json_structure).
        ELSE.


          SELECT * FROM zr_salary
          WHERE Isposted = 'X'
                AND Accountingdocument IS NOT INITIAL
                AND Accountingdocument2 IS INITIAL
                AND (
                      TdsAmount IS NOT INITIAL OR
                      LoanInstallmentAmount IS NOT INITIAL OR
                      AdvanceInstallmentAmount IS NOT INITIAL
                    )
          INTO TABLE @tt_json_structure.

        ENDIF.


        LOOP AT tt_json_structure INTO DATA(wa_data).

          DATA(psDate) = checkDateFormat( date = CONV string( wa_data-postingdate ) datetype = 'Posting' ).
          FIND 'Invalid' IN psDate.
          IF sy-subrc = 0.
            message = psDate.
            RETURN.
          ENDIF.

          DATA(dcDate) = checkDateFormat( date = CONV string( wa_data-DueDate ) datetype = 'Document' ).
          FIND 'Invalid' IN dcDate.
          IF sy-subrc = 0.
            message = dcDate.
            RETURN.
          ENDIF.

          message = postSupplierPayment( wa_data = wa_data psdate = psDate dcdate = dcDate ).

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


  METHOD postSupplierPayment.
    DATA: lt_je_deep     TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          document       TYPE string,
          document2      TYPE string,
          lv_postingdate TYPE d.

    DATA(TypeFinder) = |EMPTYPE{ wa_data-EmployeeType }|.

    SELECT SINGLE FROM zr_integration_tab
    FIELDS Intgpath
    WHERE Intgmodule = @TypeFinder
    INTO @DATA(lv_gl).

    SELECT SINGLE FROM ztable_plant
    FIELDS costcenter, profitcenter
    WHERE plant_code = @wa_data-Plant
    INTO @DATA(lv_centers).

    SELECT SINGLE FROM I_businesspartner
    FIELDS BusinessPartnerName
    WHERE businesspartner = @wa_data-EmployeeCode
    INTO @DATA(lv_bpName).

    SELECT SINGLE FROM zr_integration_tab
    FIELDS Intgpath
    WHERE Intgmodule = 'TDS-GL'
    INTO @DATA(lv_tds_gl).

    IF wa_data-TdsAmount IS NOT INITIAL OR
       wa_data-LoanInstallmentAmount IS NOT INITIAL OR
       wa_data-AdvanceInstallmentAmount IS NOT INITIAL.


      IF wa_data-TdsAmount IS NOT INITIAL.

        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep1>).
        <je_deep1>-%cid = getCid(  ).
        <je_deep1>-%param = VALUE #(
        companycode = wa_data-Companycode
        businesstransactiontype = 'RFBU'
        accountingdocumenttype = 'EK'
        CreatedByUser = sy-uname
        documentdate = dcDate
        postingdate = COND #( WHEN psDate IS INITIAL
                      THEN cl_abap_context_info=>get_system_date( )
                      ELSE psDate )
        _apitems = VALUE #(
*                         TDS SALARY
                             ( glaccountlineitem = |001|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    DocumentItemText = |Salary TDS for m/o { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-TdsAmount
                                                    currency = 'INR' ) ) )

*                               Loan
                                ( glaccountlineitem = |003|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    DocumentItemText = |Installment recovered for { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-LoanInstallmentAmount
                                                    currency = 'INR' ) ) )

                                ( glaccountlineitem = |004|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    DocumentItemText = |Installment recovered for { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    SpecialGLCode = 'L'
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-LoanInstallmentAmount * -1
                                                    currency = 'INR' ) ) )

*                               Advance
                                ( glaccountlineitem = |005|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    DocumentItemText = |Advance recovered for { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-AdvanceInstallmentAmount
                                                    currency = 'INR' ) ) )

                                   ( glaccountlineitem = |006|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    DocumentItemText = |Advance recovered for { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    SpecialGLCode = 'A'
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-AdvanceInstallmentAmount * -1
                                                    currency = 'INR' ) ) )
        )
        _glitems = VALUE #(
                            ( glaccountlineitem = |002|
                            glaccount = lv_tds_gl
                            CostCenter = lv_centers-costcenter
                            AssignmentReference = wa_data-EmployeeCode
                            DocumentItemText = |Salary TDS for m/o { get_month_year( dcDate ) } ({ lv_bpName })|
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-TdsAmount * -1
                                                currency = 'INR' ) ) ) )
        ).

      ELSE.
        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep2>).
        <je_deep2>-%cid = getCid(  ).
        <je_deep2>-%param = VALUE #(
        companycode = wa_data-Companycode
        businesstransactiontype = 'RFBU'
        accountingdocumenttype = 'EK'
        CreatedByUser = sy-uname
        documentdate = dcDate
        postingdate = COND #( WHEN psDate IS INITIAL
                      THEN cl_abap_context_info=>get_system_date( )
                      ELSE psDate )
        _apitems = VALUE #(
*                         TDS SALARY
                             ( glaccountlineitem = |001|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    DocumentItemText = |Salary TDS for m/o { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-TdsAmount
                                                    currency = 'INR' ) ) )

*                               Loan
                                ( glaccountlineitem = |003|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    DocumentItemText = |Installment recovered for { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-LoanInstallmentAmount
                                                    currency = 'INR' ) ) )

                                ( glaccountlineitem = |004|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    SpecialGLCode = 'L'
                                    ProfitCenter = lv_centers-profitcenter
                                    DocumentItemText = |Installment recovered for { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-LoanInstallmentAmount * -1
                                                    currency = 'INR' ) ) )

*                               Advance
                                ( glaccountlineitem = |005|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    DocumentItemText = |Advance recovered for { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-AdvanceInstallmentAmount
                                                    currency = 'INR' ) ) )

                                   ( glaccountlineitem = |006|
                                    Supplier = wa_data-EmployeeCode
                                    BusinessPlace = wa_data-Plant
                                    SpecialGLCode = 'A'
                                    DocumentItemText = |Advance recovered for { get_month_year( dcDate ) } ({ lv_bpName })|
                                    AssignmentReference = wa_data-EmployeeCode
                                    ProfitCenter = lv_centers-profitcenter
                                    _currencyamount = VALUE #( (
                                                    currencyrole = '00'
                                                    journalentryitemamount = wa_data-AdvanceInstallmentAmount * -1
                                                    currency = 'INR' ) ) )
        )
        _glitems = VALUE #(
                            ( glaccountlineitem = |002|
                            glaccount = lv_tds_gl
                            CostCenter = lv_centers-costcenter
                            DocumentItemText = |Salary TDS for m/o { get_month_year( dcDate ) } ({ lv_bpName })|
                            AssignmentReference = wa_data-EmployeeCode
                            _currencyamount = VALUE #( (
                                                currencyrole = '00'
                                                journalentryitemamount = wa_data-TdsAmount * -1
                                                currency = 'INR' ) ) ) )
        ).


      ENDIF.

    ENDIF.
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
      UPDATE zsalary SET Errorlog = @message
       WHERE employee_code = @wa_data-EmployeeCode
         AND due_date = @wa_data-DueDate
         AND Plant = @wa_data-Plant.
      RETURN.
    ELSE.

      COMMIT ENTITIES BEGIN
      RESPONSE OF i_journalentrytp
      FAILED DATA(lt_commit_failed)
      REPORTED DATA(lt_commit_reported).

      IF lt_commit_reported IS NOT INITIAL.
        LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
            document2 = <ls_reported>-AccountingDocument.
        ENDLOOP.
      ELSE.
        LOOP AT lt_commit_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed>).
          message = <ls_failed>-%fail-cause.
        ENDLOOP.
        UPDATE zsalary SET Errorlog = @message
        WHERE employee_code = @wa_data-EmployeeCode
          AND due_date = @wa_data-DueDate
          AND Plant = @wa_data-Plant.
        RETURN.
      ENDIF.

      COMMIT ENTITIES END.

      IF document2 IS NOT INITIAL.
        message = |Document Created Successfully: { document2 }|.
        MODIFY ENTITIES OF zr_salary
        ENTITY ZrSalary
        UPDATE FIELDS ( Accountingdocument2 Isposted Errorlog )
        WITH VALUE #(  (
            Accountingdocument2 = document2
            Isposted = abap_true
            Errorlog = ''
            EmployeeCode = wa_data-EmployeeCode
            DueDate = wa_data-DueDate
            Plant = wa_data-Plant
            )  )
        FAILED DATA(lt_failed2)
        REPORTED DATA(lt_reported2).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_salary
        FAILED DATA(lt_commit_failed22)
        REPORTED DATA(lt_commit_reported22).

        ...
        COMMIT ENTITIES END.
      ELSE.
        message = |Document Creation Failed: { message }|.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
