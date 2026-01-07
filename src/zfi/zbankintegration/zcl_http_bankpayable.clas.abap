class ZCL_HTTP_BANKPAYABLE definition
  public
  create public .

PUBLIC SECTION.

  INTERFACES if_http_service_extension .

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
  CLASS-METHODS getLastUniq
    RETURNING
      VALUE(max_num) TYPE string.
  CLASS-METHODS saveData
    IMPORTING
      VALUE(request) TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string .

  CLASS-METHODS  checkDateFormat
    IMPORTING
      date           TYPE string
    RETURNING
      VALUE(message) TYPE string.

  CLASS-METHODS convertDate
    IMPORTING
      VALUE(excel_value)  TYPE I
    RETURNING
      VALUE(lv_formatted) TYPE string.
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_BANKPAYABLE IMPLEMENTATION.


    METHOD checkDateFormat.

    DATA: lv_date_parts TYPE TABLE OF string.
    TRY.
        SPLIT date AT '/' INTO  DATA(lv_date_parts1) DATA(lv_date_parts2) DATA(lv_date_parts3) .
        message = lv_date_parts3 && lv_date_parts2 && lv_date_parts1.
      CATCH cx_sy_itab_line_not_found.
        message = |Invalid Document date format: { date }|.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD getLastUniq.


    SELECT FROM zr_bankpayable
      FIELDS instructionrefnum
      WHERE instructionrefnum IS NOT INITIAL
      INTO TABLE @DATA(last_record).

    max_num = REDUCE #( INIT max = CONV posnr( '000000' )
                FOR line IN last_record
                    NEXT max = COND posnr( WHEN line-InstructionRefNum > max
                                           THEN line-InstructionRefNum
                                           ELSE max )
              ).

    IF max_num EQ '000000'.
      max_num = '100001'.
    ELSE.
      max_num += 1.
    ENDIF.
  ENDMETHOD.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
  CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( saveData( request ) ).
    ENDCASE.
  ENDMETHOD.


  METHOD saveData.

*  DATA(filename) = request->get_form_field( i_name = 'uploadName' ).
    TYPES: BEGIN OF ty_bank_receipt,
             vutdate    TYPE c LENGTH 10,
             unit       TYPE c LENGTH 20,
             vutacode   TYPE c LENGTH 10,
             vutatag    TYPE c LENGTH 1,
             vutaacode  TYPE c LENGTH 10,
             vutamt     TYPE p LENGTH 15 DECIMALS 2,
             custref    TYPE c LENGTH 80,
             vutref     TYPE c LENGTH 50,
             vutnart    TYPE c LENGTH 80,
             vutcostcd  TYPE c LENGTH 20,
             vutbgtcd   TYPE c LENGTH 20,
             vutloccd   TYPE c LENGTH 20,
             vutemail   TYPE c LENGTH 255,
             uploadName TYPE c LENGTH 100,
           END OF ty_bank_receipt.

    DATA tt_json_structure TYPE TABLE OF ty_bank_receipt WITH EMPTY KEY.

    TRY.

        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

        IF tt_json_structure IS NOT INITIAL.

          DATA(file_name) = tt_json_structure[ 1 ]-uploadname.
          SELECT SINGLE FROM zr_bankpayable
          FIELDS UploadFileName
          WHERE UploadFileName = @file_name AND IsPosted = '' AND IsDeleted = ''
          INTO @DATA(uploaded_file).

          IF uploaded_file IS NOT INITIAL.
            message = 'File is already uploaded.'.
            RETURN.
          ENDIF.

        ENDIF.

        LOOP AT tt_json_structure INTO DATA(wa).
          DATA code TYPE c LENGTH 1.
          DATA lv_max_refnum TYPE i.
          DATA(cid) = getcid( ).
          DATA(Vutaacode) = |{ wa-vutaacode ALPHA = IN }|.


          SELECT SINGLE FROM I_businesspartnerbank
          FIELDS BankNumber
          WHERE BusinessPartner = @Vutaacode
          INTO @DATA(bank).

*          IF bank IS INITIAL.
*            message = |Bank code not found for Vutacode: { wa-vutacode }| .
*            RETURN.
*          ELSE
          IF bank+0(4) = 'HDFC'.
            code = 'I'.
          ELSEIF wa-vutamt < 200000.
            code = 'N'.
          ELSE.
            code = 'R'.
          ENDIF.


          DATA(unique_ref) = getlastuniq( ).
          CONDENSE unique_ref NO-GAPS.
          DATA(concater) = |{ code }{ unique_ref }DT{ wa-vutdate }A{ wa-vutacode }{ wa-vutatag }{ wa-vutaacode }|.


          MODIFY ENTITIES OF zr_bankpayable
          ENTITY ZrBankpayable
          CREATE FIELDS (
                Vutdate
                Unit
                Vutacode
                Createdtime
                Vutatag
                Vutaacode
                Vutamt
                Custref
                Vutref
                Vutnart
                Vutcostcd
                Vutbgtcd
                Vutloccd
                Vutemail
                UploadFileName
                TransType
                InstructionRefNum
                UniqTracCode
               )
          WITH VALUE #( (
                 %cid = cid
                 Vutdate = convertDate( CONV I( wa-vutdate ) )
                 Unit = wa-unit
                 Vutacode = wa-vutacode
                 Createdtime = cl_abap_context_info=>get_system_time( )
                 Vutatag = wa-vutatag
                 Vutaacode = wa-vutaacode
                 Vutamt = wa-vutamt
                 Custref = wa-custref
                 Vutref = wa-vutref
                 Vutnart = wa-vutnart
                 Vutcostcd = wa-vutcostcd
                 Vutbgtcd = wa-vutbgtcd
                 Vutloccd = wa-vutloccd
                 Vutemail = wa-vutemail
                 UploadFileName = wa-uploadName
                 TransType = code
                 InstructionRefNum = unique_ref
                 UniqTracCode = |{ code }{ unique_ref }DT{ checkDateFormat( CONV string( wa-vutdate ) ) }A{ wa-vutacode }{ wa-vutatag }{ wa-vutaacode }|
               ) )
           REPORTED DATA(ls_po_reported)
           FAILED   DATA(ls_po_failed)
           MAPPED   DATA(ls_po_mapped).

          COMMIT ENTITIES BEGIN
             RESPONSE OF zr_bankpayable
             FAILED DATA(ls_save_failed)
             REPORTED DATA(ls_save_reported).

          IF ls_po_failed IS NOT INITIAL OR ls_save_failed IS NOT INITIAL.
            message = 'Failed to save data'.
          ELSE.
            message = 'Data saved successfully'.
          ENDIF.

          COMMIT ENTITIES END.
        ENDLOOP.

      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.


  ENDMETHOD.


  METHOD convertDate.


    DATA total_seconds TYPE i.
    DATA lv_tstmp      TYPE string.
    DATA value       TYPE p LENGTH 15 DECIMALS 5.

    total_seconds = ( excel_value - 25569 ) * 86400 .
    lv_tstmp      = CONV string( cl_abap_tstmp=>add( tstmp = 19700101000000 secs = total_seconds ) ).


    lv_formatted = |{ lv_tstmp+6(2) }/{ lv_tstmp+4(2) }/{ lv_tstmp+0(4) }|.

  ENDMETHOD.
ENDCLASS.
