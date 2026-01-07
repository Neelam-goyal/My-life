CLASS zcl_job_controlsheet DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_apj_dt_exec_object .
  INTERFACES if_apj_rt_exec_object .


  INTERFACES if_oo_adt_classrun.
  CLASS-METHODS runJob
    IMPORTING paramgateentryno TYPE C.

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JOB_CONTROLSHEET IMPLEMENTATION.


    METHOD getCID.
        TRY.
            cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.
    ENDMETHOD.


    METHOD if_apj_dt_exec_object~get_parameters.
        " Return the supported selection parameters here
        et_parameter_def = VALUE #(
          ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Gate Entry No'   lowercase_ind = abap_true changeable_ind = abap_true )
        ).

        " Return the default parameters values here
        et_parameter_val = VALUE #(
          ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Gate Entry No' )
        ).

    ENDMETHOD.


    METHOD if_apj_rt_exec_object~execute.
      DATA p_descr TYPE c LENGTH 80.

      " Getting the actual parameter values
      LOOP AT it_parameters INTO DATA(ls_parameter).
        CASE ls_parameter-selname.
          WHEN 'P_DESCR'. p_descr = ls_parameter-low.
        ENDCASE.
      ENDLOOP.
      runJob( p_descr ).
    ENDMETHOD.


    METHOD if_oo_adt_classrun~main .
        runJob( '' ).
    ENDMETHOD.


    METHOD runJob.
      DATA totalSalesPExp TYPE p DECIMALS 3.
      DATA total880Exp TYPE p DECIMALS 3.
      DATA totalCngExp TYPE p DECIMALS 3.
      DATA totalDieselExp TYPE p DECIMALS 3.
      DATA totalrepair TYPE p DECIMALS 3.
      DATA amtdeposit TYPE p DECIMALS 3.
      DATA amtdealer TYPE p DECIMALS 3.
      DATA plantno TYPE c LENGTH 5.
      DATA companycode TYPE c LENGTH 5.
      DATA fnyr TYPE c LENGTH 4.
      DATA gateentryno TYPE c LENGTH 20.
      DATA costcenter TYPE c LENGTH 10.
      DATA customercode TYPE c LENGTH 20.
      DATA customername TYPE string.
      DATA  expnaming  TYPE string.
      DATA glaccount TYPE c LENGTH 10.
      DATA vehiclenum TYPE c LENGTH 10.
      DATA dealercode TYPE c LENGTH 10.
      DATA salespersoncode TYPE c LENGTH 20.
      DATA differamt TYPE p DECIMALS 2.
      DATA custamount TYPE p DECIMALS 2.
      DATA : lv_date TYPE d.
      DATA lv_count TYPE i.
      DATA: lv_cust_result TYPE char256.
      DATA: jeno TYPE char72.
      DATA localgateentryno TYPE c LENGTH 20.
      DATA : strcuserror TYPE c LENGTH  100.

*    ***         SJ 01-04-25 Start to Get GLs ************
      TYPES: BEGIN OF ls_glExpDtls,
               expname  TYPE char72,
               glnumber TYPE char72,
               expAmt   TYPE decan,
             END OF ls_glExpDtls.


      DATA: gt_glExpDtls TYPE STANDARD TABLE OF ls_glExpDtls WITH KEY expname.
      DATA: ls_ls_glExpDtls_struct TYPE ls_glExpDtls.


      SELECT intgmodule,intgpath FROM zintegration_tab WITH PRIVILEGED ACCESS
         WHERE intgmodule = `Controlsheet-TollExpGL`
         INTO  @DATA(wa_cstollGL).      "SJ 01-04-25 - GL of Toll"


        SELECT SINGLE FROM zintegration_tab WITH PRIVILEGED ACCESS
           FIELDS intgmodule,intgpath
           WHERE intgmodule = `Controlsheet-RouteExpGL`
           INTO  @DATA(wa_csrouteGL).      "SJ 01-04-25 - GL of Route Exp"

        SELECT SINGLE FROM zintegration_tab WITH PRIVILEGED ACCESS
           FIELDS intgmodule,intgpath
           WHERE intgmodule = `Controlsheet-OtherExpGL`
           INTO  @DATA(wa_csothGL).      "SJ 01-04-25 - GL of Other Exp"

        SELECT SINGLE FROM zintegration_tab WITH PRIVILEGED ACCESS
           FIELDS intgmodule,intgpath
           WHERE intgmodule = `Controlsheet-CNGExpGL`
           INTO  @DATA(wa_cscngGL).      "SJ 01-04-25 - GL of CNG Exp"

        SELECT SINGLE FROM zintegration_tab WITH PRIVILEGED ACCESS
           FIELDS intgmodule,intgpath
           WHERE intgmodule = `Controlsheet-DieselExpGL`
           INTO  @DATA(wa_csdieselGL).      "SJ 01-04-25 - GL of Diesel Exp"

        SELECT SINGLE FROM zintegration_tab WITH PRIVILEGED ACCESS
           FIELDS intgmodule,intgpath
           WHERE intgmodule = `Controlsheet-RepairExpGL`
           INTO  @DATA(wa_csrepairGL).      "SJ 01-04-25 - GL of Repair Exp"

      ENDSELECT.

****         SJ 01-04-25 end to Get GLs ************


      DATA : ltcontrolsheet TYPE TABLE OF zcontrolsheet.
      localgateentryno = paramgateentryno.
      IF localgateentryno = '' .
        SELECT * FROM zcontrolsheet AS cs
            WHERE cs~glposted = 0
        INTO TABLE @ltcontrolsheet.
      ELSE.
        SELECT * FROM zcontrolsheet AS cs
            WHERE cs~glposted = 0 AND cs~gate_entry_no = @localgateentryno
        INTO TABLE @ltcontrolsheet.
      ENDIF.

*        lv_date = cl_abap_context_info=>get_system_date(  ).




      LOOP AT ltcontrolsheet ASSIGNING FIELD-SYMBOL(<ls_controlsheet>).
***************************************************accountingdocumentheadertext check
        DATA : acctdoct TYPE c LENGTH 25.
        jeno = <ls_controlsheet>-comp_code && <ls_controlsheet>-plant
            && <ls_controlsheet>-imfyear && <ls_controlsheet>-gate_entry_no.
        SELECT SINGLE FROM I_JournalEntry AS ije
        FIELDS ije~AccountingDocument
        WHERE ije~AccountingDocumentHeaderText = @jeno
        INTO  @DATA(ltDE).

        IF ltDE IS NOT INITIAL.
          acctdoct = ltDE.

          UPDATE zcontrolsheet
           SET glposted = 1,
           error_log = ``,
           reference_doc = @acctdoct
           WHERE comp_code = @<ls_controlsheet>-comp_code AND plant = @<ls_controlsheet>-plant AND gate_entry_no = @<ls_controlsheet>-gate_entry_no
           AND imfyear = @<ls_controlsheet>-imfyear AND glposted = 0.
          CLEAR: ltde.
          CONTINUE.
        ENDIF.



        SELECT FROM zcontrolsheet AS cs
            INNER JOIN I_BusinessPartner AS ibpsalesperson ON ibpsalesperson~BusinessPartnerIDByExtSystem = cs~sales_person

            FIELDS ibpsalesperson~BusinessPartner AS EmployeCode
            WHERE cs~gate_entry_no = @<ls_controlsheet>-gate_entry_no AND cs~plant = @<ls_controlsheet>-plant
        INTO TABLE @DATA(ltsalesPerson).
        IF ltsalesperson IS NOT INITIAL.
*          lv_date = <ls_controlsheet>-gpdate.
          lv_date = <ls_controlsheet>-cdate.

          total880exp = <ls_controlsheet>-toll + <ls_controlsheet>-routeexp + <ls_controlsheet>-other .
          totalCngExp = <ls_controlsheet>-cngexp.
          totalDieselExp = <ls_controlsheet>-dieselexp.
          totalrepair = <ls_controlsheet>-repair.
          totalSalesPExp = total880exp + totalCngExp + totalDieselExp + totalrepair.


          plantno = <ls_controlsheet>-plant.
          companycode = <ls_controlsheet>-comp_code.
          fnyr = <ls_controlsheet>-imfyear.
          gateentryno = <ls_controlsheet>-gate_entry_no.


          IF totalSalesPExp = 0.
            UPDATE zcontrolsheet
                         SET glposted = 1,
                         error_log = ``
                         WHERE comp_code = @companycode AND plant = @plantno AND gate_entry_no = @gateentryno
                         AND imfyear = @fnyr AND glposted = 0.
            CONTINUE. " Skip processing if total Sales and Purchase Expense is zero
          ENDIF.

          SELECT FROM I_BusinessPartner AS ibp
                  INNER JOIN I_CustomerCompany AS icc ON ibp~BusinessPartner = icc~Customer
                     FIELDS BusinessPartner , ibp~BusinessPartnerFullName
                     WHERE ibp~BusinessPartnerIDByExtSystem = @<ls_controlsheet>-sales_person AND icc~CompanyCode = @companycode
                 INTO TABLE @DATA(lt_customer).

          IF lt_customer IS NOT INITIAL .
            LOOP AT lt_customer INTO DATA(wa_customer).
              customercode = wa_customer-BusinessPartner.
              customername = wa_customer-BusinessPartnerFullName.
            ENDLOOP.


*        ***         SJ 01-04-25 Start Append GLs and amount in internal table ************


            DELETE gt_glExpDtls WHERE NOT expname = `aaaa`.

            ls_ls_glExpDtls_struct-expname = wa_cstollGL-intgmodule.
            ls_ls_glExpDtls_struct-glnumber = wa_cstollGL-intgpath.
            ls_ls_glExpDtls_struct-expamt = <ls_controlsheet>-toll.
            APPEND ls_ls_glExpDtls_struct TO gt_glexpdtls.

            ls_ls_glExpDtls_struct-expname = wa_csrouteGL-intgmodule.
            ls_ls_glExpDtls_struct-glnumber = wa_csrouteGL-intgpath.
            ls_ls_glExpDtls_struct-expamt = <ls_controlsheet>-routeexp.
            APPEND ls_ls_glExpDtls_struct TO gt_glexpdtls.

            ls_ls_glExpDtls_struct-expname = wa_csothGL-intgmodule.
            ls_ls_glExpDtls_struct-glnumber = wa_csothGL-intgpath.
            ls_ls_glExpDtls_struct-expamt = <ls_controlsheet>-other.
            APPEND ls_ls_glExpDtls_struct TO gt_glexpdtls.

            ls_ls_glExpDtls_struct-expname = wa_cscngGL-intgmodule.
            ls_ls_glExpDtls_struct-glnumber = wa_cscngGL-intgpath.
            ls_ls_glExpDtls_struct-expamt = <ls_controlsheet>-cngexp.
            APPEND ls_ls_glExpDtls_struct TO gt_glexpdtls.

            ls_ls_glExpDtls_struct-expname = wa_csdieselGL-intgmodule.
            ls_ls_glExpDtls_struct-glnumber = wa_csdieselGL-intgpath.
            ls_ls_glExpDtls_struct-expamt = <ls_controlsheet>-dieselexp.
            APPEND ls_ls_glExpDtls_struct TO gt_glexpdtls.

            ls_ls_glExpDtls_struct-expname = wa_csrepairGL-intgmodule.
            ls_ls_glExpDtls_struct-glnumber = wa_csrepairGL-intgpath.
            ls_ls_glExpDtls_struct-expamt = <ls_controlsheet>-repair.
            APPEND ls_ls_glExpDtls_struct TO gt_glexpdtls.


*                    SELECT a~glnumber , sum( a~expAmt ) as expAmt from @gt_glexpdtls as a
*                        where a~expamt > 0
*                        group by  a~glnumber
*                        into table @data(waglexp).
            DATA: waglexp    TYPE TABLE OF ls_glExpDtls,
                  ls_waglexp TYPE ls_glExpDtls.

            CLEAR : waglexp.

            LOOP AT gt_glexpdtls INTO DATA(ls_glexpdtls) WHERE expamt > 0.
              READ TABLE waglexp INTO ls_waglexp WITH KEY glnumber = ls_glexpdtls-glnumber.
              IF sy-subrc = 0.
                ls_waglexp-expamt = ls_waglexp-expamt + ls_glexpdtls-expamt.
                MODIFY TABLE waglexp FROM ls_waglexp.
              ELSE.
                ls_waglexp = ls_glexpdtls.
                APPEND ls_waglexp TO waglexp.
              ENDIF.
              CLEAR : ls_glexpdtls,ls_waglexp.
            ENDLOOP.

*************************** added by VKS
            LOOP AT waglexp ASSIGNING FIELD-SYMBOL(<waglexp1>).
              CASE <waglexp1>-glnumber.
                WHEN '80000980'.   "example GL
                  expnaming = 'CNGFuel'.  "mapped GL
                WHEN '80000950'.
                  expnaming = 'FuelOutside'.
                WHEN '80000900'.
                  expnaming = 'OtherRouteExp'.
                WHEN '65301040'.
                  expnaming = 'VehicleR&M'.
                WHEN '80000880'.
                  expnaming = 'FOC'.
              ENDCASE.
            ENDLOOP.



*        ***         SJ 01-04-25 end Append GLs and amount in internal table ************

            SELECT FROM ztable_plant AS pt
                FIELDS pt~costcenter
                WHERE pt~comp_code = @companycode
                AND pt~plant_code = @plantno
            INTO TABLE @DATA(ltPlant).


            IF ltPlant IS NOT INITIAL.
              LOOP AT ltPlant INTO DATA(waplant).
                costcenter = waplant-costcenter.
              ENDLOOP.
              IF costcenter <> ''.
                DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
                      lv_cid     TYPE abp_behv_cid.

                TRY.
                    lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
                  CATCH cx_uuid_error.
                    ASSERT 1 = 0.
                ENDTRY.

                APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
                <je_deep>-%cid = lv_cid.

                <je_deep>-%param = VALUE #(
                companycode = <ls_controlsheet>-comp_code
                businesstransactiontype = 'RFBU'
                accountingdocumenttype = 'DG'

                CreatedByUser = sy-uname
                documentdate = lv_date
                postingdate = lv_date

                accountingdocumentheadertext = <ls_controlsheet>-comp_code && <ls_controlsheet>-plant
                                            && <ls_controlsheet>-imfyear && <ls_controlsheet>-gate_entry_no


                _aritems = VALUE #(
                                    ( glaccountlineitem = |001|
*                                                  glaccount = '12213000'
                                        Customer = customercode
                                        BusinessPlace = <ls_controlsheet>-plant
                                        DocumentItemText = |{ expnaming } amt ({ <ls_controlsheet>-gate_entry_no }) paid to { customercode }-{ customername }|
                                        _currencyamount = VALUE #( (
                                                        currencyrole = '00'
                                                        journalentryitemamount = -1 * totalSalesPExp
                                                        currency = 'INR' ) ) )
                                   )

                 _glitems = VALUE #(

                                      FOR waglexp2 IN waglexp INDEX INTO j
                                        ( glaccountlineitem = |{ j + 1 WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                                            glaccount =  waglexp2-glnumber
                                             CostCenter = costcenter
                                             DocumentItemText = |Amt paid ({ <ls_controlsheet>-gate_entry_no }) to { customercode }-{ customername }|
                                              _currencyamount = VALUE #( (
                                                                currencyrole = '00'
                                                                journalentryitemamount =  waglexp2-expamt
                                                                currency = 'INR' ) ) )

                                    )
                ).


                MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
                ENTITY journalentry
                EXECUTE post FROM lt_je_deep
                FAILED DATA(ls_failed_deep)
                REPORTED DATA(ls_reported_deep)
                MAPPED DATA(ls_mapped_deep).
                IF ls_failed_deep IS NOT INITIAL.

                  LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
                    lv_cust_result = lv_cust_result &&  <ls_reported_deep>-%msg->if_message~get_text( ).
                    ...
                  ENDLOOP.
                  UPDATE zcontrolsheet
                      SET error_log = @lv_cust_result
                      WHERE comp_code = @companycode AND plant = @plantno AND gate_entry_no = @gateentryno
                      AND imfyear = @fnyr AND glposted = 0.
                  CLEAR lv_cust_result .
                ELSE.

                  COMMIT ENTITIES BEGIN
                  RESPONSE OF i_journalentrytp
                  FAILED DATA(lt_commit_failed)
                  REPORTED DATA(lt_commit_reported).
                  ...
                  COMMIT ENTITIES END.

                  IF lt_commit_failed IS INITIAL.
                    DATA : acctdoc TYPE c LENGTH 25.
                    jeno = <ls_controlsheet>-comp_code && <ls_controlsheet>-plant
                        && <ls_controlsheet>-imfyear && <ls_controlsheet>-gate_entry_no.
                    SELECT FROM I_JournalEntry AS ije
                    FIELDS ije~AccountingDocument
                    WHERE ije~AccountingDocumentHeaderText = @jeno
                    INTO TABLE @DATA(ltJE).
                    IF ltJE IS NOT INITIAL.
                      LOOP AT ltJE INTO DATA(wa_ltje).
                        acctdoc = wa_ltje-AccountingDocument.
                      ENDLOOP.
                    ENDIF.

                    UPDATE zcontrolsheet
                        SET glposted = 1,
                        error_log = ``,
                        reference_doc = @acctdoc
                        WHERE comp_code = @companycode AND plant = @plantno AND gate_entry_no = @gateentryno
                        AND imfyear = @fnyr AND glposted = 0.
                  ENDIF.
                  CLEAR : lt_commit_failed, lt_commit_reported,acctdoc,acctdoct.
                  CLEAR : lt_je_deep.
                ENDIF.
              ENDIF.
            ENDIF.
            CLEAR : ltplant.
          ELSE.

            strcuserror =  <ls_controlsheet>-sales_person && ' customer does not exist'.
            UPDATE zcontrolsheet
            SET error_log = @strcuserror
            WHERE comp_code = @<ls_controlsheet>-comp_code AND plant = @<ls_controlsheet>-plant AND gate_entry_no = @<ls_controlsheet>-gate_entry_no
            AND imfyear = @<ls_controlsheet>-imfyear AND glposted = 0.

          ENDIF.

         ELSE.
            strcuserror =  <ls_controlsheet>-sales_person && ' sales person does not exist'.
            UPDATE zcontrolsheet
            SET error_log = @strcuserror
            WHERE comp_code = @<ls_controlsheet>-comp_code AND plant = @<ls_controlsheet>-plant AND gate_entry_no = @<ls_controlsheet>-gate_entry_no
            AND imfyear = @<ls_controlsheet>-imfyear AND glposted = 0.
        ENDIF.
        CLEAR : customername,customercode,expnaming.
      ENDLOOP.

    ENDMETHOD.
ENDCLASS.
