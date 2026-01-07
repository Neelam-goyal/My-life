class ZCL_HTTP_SALARY definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .


   CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
   CLASS-METHODS saveData
    IMPORTING
      VALUE(request)  TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message)  TYPE STRING .


protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_SALARY IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  Method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
  CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( saveData( request ) ).
    ENDCASE.


  ENDMETHOD.


  METHOD saveData.
    TYPES: BEGIN OF ty_json_structure,
            EmployeeCode TYPE C LENGTH 10,
            DueDate TYPE C LENGTH 10,
            EmployeeType TYPE C LENGTH 1,
            PostingDate TYPE C LENGTH 10,
            GrossSalary TYPE P LENGTH 15 DECIMALS 2,
            TdsAmount TYPE P LENGTH 15 DECIMALS 2,
            LoanInstallmentAmount TYPE P LENGTH 15 DECIMALS 2,
            AdvanceInstallmentAmount TYPE P LENGTH 15 DECIMALS 2,
            NetPayable TYPE P LENGTH 15 DECIMALS 2,
            CompanyCode TYPE C LENGTH 4,
            Plant TYPE C LENGTH 4,
           END OF ty_json_structure.

    DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

    TRY.

        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

        LOOP AT tt_json_structure INTO DATA(wa).

          DATA(cid) = getcid( ).
          MODIFY ENTITIES OF ZR_Salary
         ENTITY ZrSalary
         CREATE FIELDS (
                EmployeeCode
                DueDate
                PostingDate
                EmployeeType
                GrossSalary
                TdsAmount
                LoanInstallmentAmount
                AdvanceInstallmentAmount
                NetPayable
                CompanyCode
                Plant
              )
         WITH VALUE #( (
                %cid = cid
                EmployeeCode = wa-EmployeeCode
                DueDate = wa-DueDate
                PostingDate = wa-PostingDate
                EmployeeType = wa-EmployeeType
                GrossSalary = wa-GrossSalary
                TdsAmount = wa-TdsAmount
                LoanInstallmentAmount = wa-LoanInstallmentAmount
                AdvanceInstallmentAmount = wa-AdvanceInstallmentAmount
                NetPayable = wa-NetPayable
                CompanyCode = wa-CompanyCode
                Plant = wa-Plant
              ) )
          REPORTED DATA(ls_po_reported)
          FAILED   DATA(ls_po_failed)
          MAPPED   DATA(ls_po_mapped).

          COMMIT ENTITIES BEGIN
             RESPONSE OF ZR_Salary
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
ENDCLASS.
