CLASS zcl_salarybatchpost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.

    METHODS: run,
            validate,
            post.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SALARYBATCHPOST IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Post EMployee Salary'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Post EMployee Salary' )

    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    run(  ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    run(  ).
  ENDMETHOD.


  METHOD post.

    SELECT * FROM zr_salary
      WHERE Isdeleted = ''
        AND Isposted = ''
        AND Isvalidate = 'X'
      INTO TABLE @DATA(tt_json_structure).

    LOOP AT tt_json_structure INTO DATA(wa).

      DATA(psDate) = ZCL_salarypost=>checkdateformat( date = CONV string( wa-postingdate ) datetype = 'Posting' ).
      FIND 'Invalid' IN psDate.
      IF sy-subrc = 0.
        MODIFY ENTITIES OF Zr_Salary
          ENTITY ZrSalary
          UPDATE FIELDS ( Isvalidate Errorlog )
          WITH VALUE #( (
              Errorlog = psDate
              EmployeeCode = wa-EmployeeCode
              DueDate = wa-DueDate
              Plant = wa-Plant
          ) )
          FAILED DATA(lt_failed)
          REPORTED DATA(lt_reported).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_salary
        FAILED DATA(lt_commit_failed22)
        REPORTED DATA(lt_commit_reported22).
        COMMIT ENTITIES END.

        RETURN.
      ENDIF.

      DATA(dcDate) = ZCL_salarypost=>checkDateFormat( date = CONV string( wa-DueDate ) datetype = 'Document' ).
      FIND 'Invalid' IN dcDate.
      IF sy-subrc = 0.
        MODIFY ENTITIES OF Zr_Salary
          ENTITY ZrSalary
          UPDATE FIELDS ( Isvalidate Errorlog )
          WITH VALUE #( (
              Errorlog = dcDate
              EmployeeCode = wa-EmployeeCode
              DueDate = wa-DueDate
              Plant = wa-Plant
          ) )
        FAILED lt_failed
        REPORTED lt_reported.

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_salary
        FAILED lt_commit_failed22
        REPORTED lt_commit_reported22.
        COMMIT ENTITIES END.

        RETURN.
      ENDIF.

      DATA(message) = ZCL_salarypost=>postSupplierPayment( wa_data = wa psdate = psDate dcdate = dcDate ).

    ENDLOOP.

  ENDMETHOD.


  METHOD run.
    validate(  ).
    post(  ).
  ENDMETHOD.


  METHOD validate.

    SELECT FROM zr_salary
      FIELDS EmployeeCode, DueDate, Plant, Isvalidate, Errorlog,CompanyCode
      WHERE Isdeleted = ''
        AND Isposted = ''
        AND Isvalidate = ''
      INTO TABLE @DATA(lt_entities).


    LOOP AT lt_entities INTO DATA(fs_entity).

*        check employee exists
      SELECT SINGLE FROM I_BusinessPartner
          FIELDS BusinessPartner
            WHERE BusinessPartner = @fs_entity-EmployeeCode
            INTO @DATA(lv_business_partner).

      IF lv_business_partner IS INITIAL.
        MODIFY ENTITIES OF Zr_Salary
             ENTITY ZrSalary
             UPDATE FIELDS ( Isvalidate Errorlog )
             WITH VALUE #( (
                 Isvalidate = abap_false
                 Errorlog = 'Employee does not exist'
                 EmployeeCode = fs_entity-EmployeeCode
                 DueDate = fs_entity-DueDate
                 Plant = fs_entity-Plant
             ) )
             FAILED DATA(lt_failed)
             REPORTED DATA(lt_reported).

        COMMIT ENTITIES BEGIN
        RESPONSE OF zr_salary
        FAILED DATA(lt_commit_failed22)
        REPORTED DATA(lt_commit_reported22).

        ...
        COMMIT ENTITIES END.

        CONTINUE.
      ENDIF.

      SELECT SINGLE FROM I_CustomerCompany
            FIELDS Customer
                WHERE Customer = @fs_entity-EmployeeCode AND CompanyCode = @fs_entity-CompanyCode
                INTO @DATA(lv_customer_company).

      IF lv_customer_company IS INITIAL.
        SELECT SINGLE FROM I_SupplierCompany
         FIELDS Supplier
             WHERE Supplier = @fs_entity-EmployeeCode AND CompanyCode = @fs_entity-CompanyCode
             INTO @DATA(lv_vendor_company).
        IF lv_vendor_company IS INITIAL.
          MODIFY ENTITIES OF Zr_Salary
            ENTITY ZrSalary
            UPDATE FIELDS ( Isvalidate Errorlog )
            WITH VALUE #( (
                Isvalidate = abap_false
                Errorlog = 'Employee does not exist in Company Code'
                EmployeeCode = fs_entity-EmployeeCode
                DueDate = fs_entity-DueDate
                Plant = fs_entity-Plant
            ) )
            FAILED lt_failed
            REPORTED lt_reported.

          COMMIT ENTITIES BEGIN
          RESPONSE OF zr_salary
          FAILED lt_commit_failed22
          REPORTED lt_commit_reported22.

          COMMIT ENTITIES END.
          CONTINUE.
        ENDIF.
      ENDIF.

      MODIFY ENTITIES OF Zr_Salary
            ENTITY ZrSalary
            UPDATE FIELDS ( Isvalidate Errorlog )
            WITH VALUE #( (
                Isvalidate = abap_true
                Errorlog = ''
                EmployeeCode = fs_entity-EmployeeCode
                DueDate = fs_entity-DueDate
                Plant = fs_entity-Plant
            ) )
            FAILED lt_failed
            REPORTED lt_reported.

      COMMIT ENTITIES BEGIN
      RESPONSE OF zr_salary
      FAILED lt_commit_failed22
      REPORTED lt_commit_reported22.

      COMMIT ENTITIES END.


    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
