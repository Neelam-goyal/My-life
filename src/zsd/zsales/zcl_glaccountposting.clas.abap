CLASS zcl_glaccountposting DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_apj_dt_exec_object .
  INTERFACES if_apj_rt_exec_object .


  INTERFACES if_oo_adt_classrun.
  CLASS-METHODS runJob
    IMPORTING paramgateentryno TYPE C.
  CLASS-METHODS updateDocument.

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GLACCOUNTPOSTING IMPLEMENTATION.


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
      updateDocument( ).
      runJob( p_descr ).
    ENDMETHOD.


    METHOD if_oo_adt_classrun~main .
        updateDocument( ).
        runJob( '03638' ).
    ENDMETHOD.


    METHOD updateDocument.
      SELECT ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno, ccsg~camt, ccsg~cdate
           FROM zcashroomcrtable AS ccsg
           WHERE glposted = 0
           ORDER BY ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno
           INTO TABLE @DATA(lt_cashSheet).

      LOOP AT lt_cashSheet INTO DATA(ls_cashSheet).

        DATA(refno) = ls_cashSheet-ccmpcode && ls_cashSheet-plant && ls_cashSheet-cfyear
                                                         && ls_cashSheet-cgpno && ls_cashSheet-cno.

        SELECT SINGLE FROM I_JournalEntry
        FIELDS AccountingDocument
        WHERE AccountingDocumentHeaderText = @refno
        INTO @DATA(acctdoc).

        IF acctdoc IS NOT INITIAL.
           UPDATE zcashroomcrtable
              SET glposted = 1,
              error_log = ``,
              reference_doc = @acctdoc
              WHERE ccmpcode = @ls_cashSheet-ccmpcode AND plant = @ls_cashSheet-plant AND cgpno = @ls_cashSheet-cgpno
              AND glposted = 0.
        ENDIF.

        CLEAR acctdoc.

      ENDLOOP.
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
******************************************************accountingdocumentheadertext check
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
           clear: ltde.
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
            DATA : strcuserror TYPE c LENGTH 25.
            strcuserror =  <ls_controlsheet>-sales_person && ' sales person doesnot exist'.
            UPDATE zcontrolsheet
            SET error_log = @strcuserror
            WHERE comp_code = @<ls_controlsheet>-comp_code AND plant = @<ls_controlsheet>-plant AND gate_entry_no = @<ls_controlsheet>-gate_entry_no
            AND imfyear = @<ls_controlsheet>-imfyear AND glposted = 0.

          ENDIF.

        ENDIF.
        CLEAR : customername,customercode,expnaming.
      ENDLOOP.


****         Post Collection
      TYPES: BEGIN OF lt_CRCTable,
               ccmpcode TYPE c LENGTH 10,
               plant    TYPE c LENGTH 4,
               cfyear   TYPE c LENGTH 4,
               cgpno    TYPE c LENGTH 7,
               cno      TYPE c LENGTH 6,
               camt     TYPE p LENGTH 12 DECIMALS 2,
               cdate    TYPE d,
             END OF lt_CRCTable.

      DATA : lt_cashSheet TYPE TABLE OF lt_CRCTable.
      IF localgateentryno = ''.
        SELECT ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno, ccsg~camt, ccsg~cdate
            FROM zcashroomcrtable AS ccsg
            WHERE glposted = 0
            ORDER BY ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno
            INTO TABLE @lt_cashSheet.
      ELSE.
        SELECT ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno, ccsg~camt, ccsg~cdate
        FROM zcashroomcrtable AS ccsg
        WHERE glposted = 0
        AND cgpno = @localgateentryno   "temp added to check a particular gate pass no"
        ORDER BY ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno
        INTO TABLE @lt_cashSheet.

      ENDIF.
      DATA: salesPerson TYPE string.
      CLEAR costcenter.
      LOOP AT lt_cashSheet INTO DATA(wa_cashSheet).
        SELECT FROM zcustcontrolsht AS ccs
            INNER JOIN I_BusinessPartner AS ibpsalesperson ON ibpsalesperson~BusinessPartnerIDByExtSystem = ccs~sales_person
            INNER JOIN I_CustomerCompany AS icc ON ibpsalesperson~BusinessPartner = icc~Customer
            FIELDS ibpsalesperson~BusinessPartner AS EmployeCode
            WHERE ccs~gate_entry_no = @wa_cashSheet-cgpno AND icc~CompanyCode = @wa_cashSheet-ccmpcode
            AND ccs~dealer_wise_cash > 0 AND ccs~plant = @wa_cashsheet-plant
        INTO TABLE @DATA(lt_salesPerson).

        LOOP AT lt_salesperson INTO DATA(wa_salesperson).
          salesPerson = wa_salesperson-EmployeCode.
        ENDLOOP.

************************************************************BY VINAY on 13-11-2025
        SELECT SINGLE FROM i_businesspartner AS a
        FIELDS a~BusinessPartnerName
               WHERE a~businesspartner = @salesperson
               INTO @DATA(ltsalespersonname).
****************************************************************

        IF lt_salesperson IS NOT INITIAL.
          SELECT SINGLE FROM ztable_plant AS zpt
              FIELDS zpt~glaccount
              WHERE zpt~comp_code = @wa_cashsheet-ccmpcode
              AND zpt~plant_code = @wa_cashsheet-plant
          INTO @DATA(ltcashaccount).


          lv_date = wa_cashSheet-cdate.  "         cl_abap_context_info=>get_system_date(  )."

          TYPES: BEGIN OF deductions,
                   CustCode         TYPE string,
                   DeductionCash    TYPE p LENGTH 12 DECIMALS 3,
                   GlAccount        TYPE string,
                   custcode_name    TYPE string,
                   documentitemtext TYPE string,
                 END OF deductions.

          SELECT SINGLE dealer  FROM zcustcontrolsht AS zccs
          WHERE zccs~gate_entry_no = @wa_cashSheet-cgpno AND zccs~dealer_wise_cash > 0 AND zccs~plant = @wa_cashsheet-plant
          AND NOT EXISTS ( SELECT BusinessPartner FROM I_BusinessPartner AS ibp
                          WHERE zccs~dealer = ibp~BusinessPartnerIDByExtSystem )
          INTO @DATA(wa_custdata).
          IF wa_custdata IS INITIAL.

            DATA CustomerDeductions TYPE TABLE OF deductions.
            DATA SalesPersonDeductions TYPE deductions.
            companycode = wa_cashsheet-ccmpcode.
            plantno = wa_cashsheet-plant.
            gateentryno = wa_cashsheet-cgpno.
            SELECT SINGLE FROM zcontrolsheet
            FIELDS controlsheet
            WHERE  plant = @wa_cashSheet-plant AND imfyear = @wa_cashSheet-cfyear AND gate_entry_no = @wa_cashSheet-cgpno AND comp_code = @wa_cashSheet-ccmpcode
            INTO @DATA(ControlSheet).

            SELECT SINGLE FROM zcustcontrolsht
            FIELDS SUM( dealer_wise_cash )
            WHERE  plant = @wa_cashSheet-plant AND imfyear = @wa_cashSheet-cfyear AND gate_entry_no = @wa_cashSheet-cgpno
            INTO @CustAmount.
            IF CustAmount IS NOT INITIAL.
              DifferAmt = wa_cashSheet-camt - CustAmount.
              SELECT FROM zcustcontrolsht AS ccs
              INNER JOIN I_BusinessPartner AS ibpcust ON ibpcust~BusinessPartnerIDByExtSystem = ccs~dealer
              INNER JOIN ztable_plant AS pt ON pt~comp_code = ccs~comp_code AND pt~plant_code = ccs~plant
              FIELDS ibpcust~BusinessPartner AS CustCode, ccs~dealer_wise_cash AS DeductionCash, pt~glaccount AS GlAccount , ibpcust~BusinessPartnerFullName AS custcode_name
              WHERE ccs~gate_entry_no = @wa_cashSheet-cgpno AND ccs~dealer_wise_cash > 0 AND ccs~plant = @wa_cashSheet-plant
              INTO TABLE @CustomerDeductions.
              LOOP AT CustomerDeductions ASSIGNING FIELD-SYMBOL(<fs_cust>).
                <fs_cust>-documentitemtext = |Cash rcvd from { <fs_cust>-custcode }-{ <fs_cust>-custcode_name }|.
              ENDLOOP.

              IF NOT DifferAmt = 0.

                SELECT SINGLE FROM zcustcontrolsht AS ccs
                   INNER JOIN I_BusinessPartner AS ibpsalesperson ON ibpsalesperson~BusinessPartnerIDByExtSystem = ccs~sales_person
                   INNER JOIN I_CustSalesPartnerFunc AS icust ON ibpsalesperson~BusinessPartner = icust~Customer AND icust~PartnerFunction = 'RG'
                   INNER JOIN I_CustomerCompany AS icc ON ibpsalesperson~BusinessPartner = icc~Customer
                   INNER JOIN ztable_plant AS pt ON pt~comp_code = ccs~comp_code AND pt~plant_code = ccs~plant
                   FIELDS icust~BPCustomerNumber AS CustCode, ccs~dealer_wise_cash AS DeductionCash, pt~glaccount AS GlAccount
                   WHERE ccs~gate_entry_no = @wa_cashSheet-cgpno AND icc~CompanyCode = @wa_cashSheet-ccmpcode AND ccs~dealer_wise_cash > 0
                   AND ccs~plant = @wa_cashSheet-plant
                   INTO  @SalesPersonDeductions.

                IF salespersondeductions IS INITIAL.
                  SELECT SINGLE FROM zcustcontrolsht AS ccs
                  INNER JOIN I_BusinessPartner AS ibpsalesperson ON ibpsalesperson~BusinessPartnerIDByExtSystem = ccs~sales_person
                  INNER JOIN I_CustomerCompany AS icc ON ibpsalesperson~BusinessPartner = icc~Customer
                  INNER JOIN ztable_plant AS pt ON pt~comp_code = ccs~comp_code AND pt~plant_code = ccs~plant
                  FIELDS ibpsalesperson~BusinessPartner AS CustCode, ccs~dealer_wise_cash AS DeductionCash, pt~glaccount AS GlAccount , ibpsalesperson~BusinessPartnerFullName AS custcode_name
                  WHERE ccs~gate_entry_no = @wa_cashSheet-cgpno AND icc~CompanyCode = @wa_cashSheet-ccmpcode AND ccs~dealer_wise_cash > 0
                  AND ccs~plant = @wa_cashSheet-plant
                  INTO  @SalesPersonDeductions.
                ENDIF.

                SalesPersonDeductions-deductioncash = DifferAmt.
                IF differamt < 0 .
                  salespersondeductions-documentitemtext = |Cash short deposited by { salespersondeductions-custcode }-{ salespersondeductions-custcode_name }|.
                ELSE.
                  salespersondeductions-documentitemtext = |Cash excess deposited by { salespersondeductions-custcode }-{ salespersondeductions-custcode_name }|.
                ENDIF.

                APPEND SalesPersonDeductions TO CustomerDeductions.
                CLEAR: SalesPersonDeductions.
              ENDIF.

              lv_count = lines( CustomerDeductions ).
              DATA: lt_cust_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
                    lv_cust_cid     TYPE abp_behv_cid.
              TRY.
                  lv_cust_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
                CATCH cx_uuid_error.
                  ASSERT 1 = 0.
              ENDTRY.


              APPEND INITIAL LINE TO lt_cust_je_deep ASSIGNING FIELD-SYMBOL(<cust_je_deep>).

              <cust_je_deep>-%cid = lv_cust_cid.
              <cust_je_deep>-%param = VALUE #(
                  businesstransactiontype = 'RFBU'
                  accountingdocumenttype = 'DZ'
                  CompanyCode = wa_cashSheet-ccmpcode
                  CreatedByUser = sy-uname
                  documentdate = lv_date
                  postingdate = lv_date
                  accountingdocumentheadertext = wa_cashSheet-ccmpcode && wa_cashSheet-plant && wa_cashSheet-cfyear
                                                 && wa_cashSheet-cgpno && wa_cashSheet-cno
                  _aritems = VALUE #( FOR wa_deduction IN CustomerDeductions INDEX INTO j
                                      ( glaccountlineitem = |{ j WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                                          Customer = wa_deduction-custcode
                                         DocumentItemText = wa_deduction-documentitemtext
                                          BusinessPlace = wa_cashSheet-plant
                                            _currencyamount = VALUE #( (
                                                              currencyrole = '00'
                                                              journalentryitemamount = -1 * wa_deduction-deductioncash
                                                              currency = 'INR' ) ) )
                                          )

                  _glitems = VALUE #(
                                          ( glaccountlineitem = |{ lv_count + 1 WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
                                          glaccount = ltcashaccount
                                          CostCenter = costcenter
                                             DocumentItemText    = |Cash rcvd from { salesperson }-{ ltsalespersonname }|
                                          _currencyamount = VALUE #( (
                                                              currencyrole = '00'
                                                              journalentryitemamount = wa_cashSheet-camt
                                                              currency = 'INR' ) ) )
                                           )
              ).
              MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
              ENTITY journalentry
              EXECUTE post FROM lt_cust_je_deep
              FAILED DATA(ls_failed_deep_cus)
              REPORTED DATA(ls_reported_deep_cus)
              MAPPED DATA(ls_mapped_deep_cus).

              IF ls_failed_deep_cus IS NOT INITIAL.

                LOOP AT ls_reported_deep_cus-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep_cus>).
                  lv_cust_result = lv_cust_result &&  <ls_reported_deep_cus>-%msg->if_message~get_text( ).
                  ...
                ENDLOOP.
                UPDATE zcashroomcrtable
                            SET error_log = @lv_cust_result
                            WHERE ccmpcode = @companycode AND plant = @plantno AND cgpno = @gateentryno
*                                    AND cfyear =  AND dealer = @dealercode
                            AND glposted = 0.

              ELSE.

                COMMIT ENTITIES BEGIN
                RESPONSE OF i_journalentrytp
                FAILED DATA(lt_cust_commit_failed)
                REPORTED DATA(lt_cust_commit_reported).
                ...
                COMMIT ENTITIES END.

                IF lt_cust_commit_failed IS INITIAL.
                  DATA : acctdoc1 TYPE c LENGTH 30.
                  jeno = wa_cashSheet-ccmpcode && wa_cashSheet-plant && wa_cashSheet-cfyear
                      && wa_cashSheet-cgpno && wa_cashSheet-cno.

                  SELECT FROM I_JournalEntry AS ij
                      FIELDS AccountingDocument, AccountingDocumentType
                      WHERE ij~AccountingDocumentHeaderText = @jeno
                  INTO TABLE @DATA(ltJE1).
                  IF ltje1 IS NOT INITIAL.
                    LOOP AT ltje1 INTO DATA(wa_ltje1).
                      acctdoc1 = wa_ltje1-AccountingDocument.
                    ENDLOOP.
                  ENDIF.

                  UPDATE zcashroomcrtable
                      SET glposted = 1,
                      error_log = ``,
                      reference_doc = @acctdoc1
                      WHERE ccmpcode = @companycode AND plant = @plantno AND cgpno = @gateentryno
                      AND glposted = 0.
                ENDIF.
                CLEAR : lt_cust_commit_failed, lt_cust_commit_reported.
                CLEAR : lt_cust_je_deep.
              ENDIF.
            ENDIF.

            CLEAR : ltplant.
          ELSE.
            DATA strcustError TYPE c LENGTH 40.
            strcustError = wa_custdata && ' customer not mapped'.
            UPDATE zcashroomcrtable
            SET error_log = @strcustError
            WHERE ccmpcode = @wa_cashSheet-ccmpcode AND plant = @wa_cashSheet-plant AND cgpno = @wa_cashSheet-cgpno
            AND glposted = 0.
          ENDIF.
        ELSE.
          DATA strError TYPE c LENGTH 40.
          strError = 'Gate No ' &&  wa_cashSheet-cgpno && ' Sales Person not mapped'.
          UPDATE zcashroomcrtable
          SET error_log = @strerror
          WHERE ccmpcode = @wa_cashSheet-ccmpcode AND plant = @wa_cashSheet-plant AND cgpno = @wa_cashSheet-cgpno
          AND glposted = 0.

        ENDIF.
        CLEAR : gt_glexpdtls,waglexp,ls_ls_glExpDtls_struct,wa_custdata,wa_cashSheet,ltcashaccount,ControlSheet,CustAmount,
        SalesPersonDeductions,strcustError , ltsalespersonname .
      ENDLOOP.

    ENDMETHOD.
ENDCLASS.
