class ZCL_HTTP_BANKPAYABLEDNLD definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .

  METHODS getDataForCSV
    IMPORTING
      VALUE(request) TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message) TYPE string .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_BANKPAYABLEDNLD IMPLEMENTATION.


  METHOD getDataForCSV.


    DATA(file_name) = request->get_form_field( i_name = 'filename' ).
    DATA: file_exists      TYPE zfilelog-filename,
          curr_version     TYPE zfilelog-versionnm,
          curr_version_num TYPE i,
          new_version_str  TYPE zfilelog-versionnm,
          newFileName      TYPE zfilelog-export_filename.

    SELECT * FROM zr_bankpayable
      WHERE UploadFileName = @file_name
            AND IsDeleted = ''
            AND IsPosted = ''
      INTO TABLE @DATA(lt_bankpayable).

      if ( lt_bankpayable is INITIAL  ) .


          message = |ERROR: No bank payable records found for the given file name { file_name }|.
            RETURN.

      ENDIF.

    SPLIT file_name AT '.' INTO DATA(lv_name2) DATA(lv_ext2).

    DATA(today) = cl_abap_context_info=>get_system_date( ).
*
*
    SELECT SINGLE FROM zfilelog AS a
    FIELDS a~filename
    WHERE a~filename =  @lv_name2 AND a~down_date = @today
    INTO @file_exists .
*
    IF ( file_exists IS INITIAL ) .

      SELECT SINGLE FROM zfilelog
      FIELDS MAX( versionnm )
      WHERE down_date = @today
      INTO @curr_version.
*
      IF ( curr_version IS INITIAL ) .
        curr_version_num = 1 .
      ELSE .
        curr_version_num =  curr_version.
        curr_version_num =  curr_version_num + 1.
      ENDIF.
*
      DATA :  exportedfile TYPE zfilelog-export_filename.
*
      new_version_str = |{ curr_version_num WIDTH = 3 ALIGN = RIGHT PAD = '0' }|.
*
*
      SPLIT file_name AT '.' INTO DATA(lv_name) DATA(lv_ext).
*
*
      DATA(newlower_name) = to_lower( lv_name ).
*
*
      exportedfile = |{ newlower_name }.{ new_version_str }|.
*
      DATA(timestamp) = cl_abap_context_info=>get_system_time( ).
*
      DATA(new_log_entry) = VALUE zfilelog(
                                        filename           = newlower_name
                                        versionnm          = new_version_str
                                        down_date          = today
                                        exported_by        = sy-uname
                                        exported_timestamp = timestamp
                                        export_filename    = exportedfile
                            ).

      INSERT zfilelog FROM @new_log_entry.
      newFileName = exportedfile .
*
    ELSE .

      SELECT SINGLE FROM zfilelog
      FIELDS export_filename
      WHERE filename = @lv_name2 AND down_date = @today
      INTO @newFileName  .

    ENDIF.


    LOOP AT lt_bankpayable INTO DATA(ls_bankpayable).

      ls_bankpayable-Vutaacode = |{ ls_bankpayable-Vutaacode ALPHA = IN }|.

      SELECT SINGLE FROM I_BusinessPartnerBank AS a
          INNER JOIN I_Bank_2 AS b ON a~BankNumber = b~BankInternalID AND a~BankCountryKey = b~BankCountry
          FIELDS a~BankName, a~BankAccount AS BeneficiaryAccount, a~BankNumber AS IFSCCode, a~BankAccountHolderName AS BeneficiaryName,
                 b~BankBranch
          WHERE BusinessPartner = @ls_bankpayable-Vutaacode
          INTO @DATA(ls_businesspartnerbank).

      DATA benficiary TYPE string.
      IF ls_bankpayable-TransType = 'I'.
        benficiary = ls_businesspartnerbank-beneficiaryaccount.
      ELSE.
        benficiary = ''.
      ENDIF.

      DATA custref TYPE c LENGTH 20.
      custref = ls_bankpayable-Custref.

      DATA(message2) = |{ ls_bankpayable-TransType },{ benficiary },{ ls_businesspartnerbank-beneficiaryaccount },{ ls_bankpayable-Vutamt },| &&
                  |{ ls_businesspartnerbank-beneficiaryname },,,,,,,,{ ls_bankpayable-InstructionRefNum },{ custref },{ ls_bankpayable-Vutref },{ ls_bankpayable-UniqTracCode },,,,,,,{ ls_bankpayable-Vutdate },,| &&
                  |{ ls_businesspartnerbank-ifsccode },{ ls_businesspartnerbank-BankName },{ ls_businesspartnerbank-BankBranch },"{ ls_bankpayable-Vutemail }"\n|.

      DATA(message3) = newfilename .

      CONCATENATE message message2 INTO message.

      CONCATENATE message message3 INTO message .



    ENDLOOP.
  ENDMETHOD.


  METHOD IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
   CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
      data(lv_message) =  getdataforcsv( request ).
      if lv_message CS 'ERROR:'.
        response->set_status( i_code = 400 i_reason = 'Not Found' ).
        response->set_text( lv_message ).
      ELSE.
        response->set_status( i_code = 200 i_reason = 'OK' ).
        response->set_text( lv_message ).

      ENDIF.
*        response->set_text( getDataForCSV( request ) ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
