CLASS LHC_ZR_SALARY DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrSalary
        RESULT result.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR ACTION ZrSalary~delete.

    METHODS validate FOR MODIFY
      IMPORTING keys FOR ACTION ZrSalary~validate.



  ENDCLASS.

CLASS LHC_ZR_SALARY IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD delete.
  MODIFY ENTITIES OF Zr_Salary IN LOCAL MODE
            ENTITY ZrSalary
            UPDATE FIELDS ( Isdeleted )
            WITH VALUE #( FOR key in keys INDEX INTO i (
                %tky       = key-%tky
                Isdeleted = abap_true
              ) )
            FAILED DATA(lt_failed)
            REPORTED DATA(lt_reported).
  ENDMETHOD.

  METHOD validate.

    READ ENTITIES OF Zr_Salary IN LOCAL MODE
            ENTITY ZrSalary
            ALL FIELDS
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_entities).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

*        check employee exists
      SELECT SINGLE FROM I_BusinessPartner
          FIELDS BusinessPartner
            WHERE BusinessPartner = @<fs_entity>-EmployeeCode
            INTO @DATA(lv_business_partner).

      IF lv_business_partner IS INITIAL.
        APPEND VALUE #(
                     %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text = 'Employee does not exist' )
                       ) TO reported-zrsalary.
        CONTINUE.
      ENDIF.

      SELECT SINGLE FROM I_CustomerCompany
            FIELDS Customer
                WHERE Customer = @<fs_entity>-EmployeeCode AND CompanyCode = @<fs_entity>-CompanyCode
                INTO @DATA(lv_customer_company).

      IF lv_customer_company IS INITIAL.
        SELECT SINGLE FROM I_SupplierCompany
         FIELDS Supplier
             WHERE Supplier = @<fs_entity>-EmployeeCode AND CompanyCode = @<fs_entity>-CompanyCode
             INTO @DATA(lv_vendor_company).
        IF lv_vendor_company IS INITIAL.
          APPEND VALUE #(
               %msg = new_message_with_text(
               severity = if_abap_behv_message=>severity-error
               text = 'Employee does not exist in Company' )
               ) TO reported-zrsalary.
          CONTINUE.
        ENDIF.
      ENDIF.

      MODIFY ENTITIES OF Zr_Salary IN LOCAL MODE
            ENTITY ZrSalary
            UPDATE FIELDS ( Isvalidate Errorlog )
            WITH VALUE #( (
                Isvalidate = abap_true
                Errorlog = ''
                %tky       = <fs_entity>-%tky
            ) )
            FAILED DATA(lt_failed)
            REPORTED DATA(lt_reported).


    ENDLOOP.
  ENDMETHOD.




ENDCLASS.
