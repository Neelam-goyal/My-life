CLASS zcl_job_cashsheet DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_apj_dt_exec_object .
  INTERFACES if_apj_rt_exec_object .


  INTERFACES if_oo_adt_classrun.
  CLASS-METHODS runJob
    IMPORTING paramgateentryno TYPE zcashroomcrtable-cgpno.
  CLASS-METHODS updateDocument
    IMPORTING paramgateentryno TYPE zcashroomcrtable-cgpno.

  CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JOB_CASHSHEET IMPLEMENTATION.


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
      DATA p_descr TYPE c LENGTH 6.

      " Getting the actual parameter values
      LOOP AT it_parameters INTO DATA(ls_parameter).
        CASE ls_parameter-selname.
          WHEN 'P_DESCR'. p_descr = ls_parameter-low.
        ENDCASE.
      ENDLOOP.
      updateDocument( p_descr ).
      runJob( p_descr ).
    ENDMETHOD.


    METHOD if_oo_adt_classrun~main .

        DATA entry_no TYPE C LENGTH 6.
        entry_no = '28078'.
        updateDocument( entry_no ).
        runJob( entry_no ).
    ENDMETHOD.


    METHOD updateDocument.

      DATA main_entry TYPE C LENGTH 6.

      main_entry = paramgateentryno.

      SELECT ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno, ccsg~camt, ccsg~cdate
           FROM zcashroomcrtable AS ccsg
           WHERE glposted = 0
           AND ( cgpno = @main_entry OR @main_entry = '' )
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
****         Post Collection


      DATA differamt TYPE p DECIMALS 2.
      DATA custamount TYPE p DECIMALS 2.
      DATA : lv_date TYPE d.
      DATA lv_count TYPE i.
      DATA: lv_cust_result TYPE char256.
      DATA: jeno TYPE char72.
      DATA localgateentryno TYPE c LENGTH 20.

      localgateentryno = paramgateentryno.
      IF localgateentryno = ''.
        SELECT ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno, ccsg~camt, ccsg~cdate
            FROM zcashroomcrtable AS ccsg
            WHERE glposted = 0
            ORDER BY ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno
            INTO TABLE @DATA(lt_cashSheet).
      ELSE.
        SELECT ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno, ccsg~camt, ccsg~cdate
        FROM zcashroomcrtable AS ccsg
        WHERE glposted = 0
        AND cgpno = @localgateentryno  "temp added to check a particular gate pass no"
        ORDER BY ccsg~ccmpcode, ccsg~plant,ccsg~cfyear, ccsg~cgpno, ccsg~cno
        INTO TABLE @lt_cashSheet.

      ENDIF.

      LOOP AT lt_cashSheet INTO DATA(wa_cashSheet).
        SELECT SINGLE FROM zcustcontrolsht AS ccs
            INNER JOIN I_BusinessPartner AS ibpsalesperson ON ibpsalesperson~BusinessPartnerIDByExtSystem = ccs~sales_person
            INNER JOIN I_CustomerCompany AS icc ON ibpsalesperson~BusinessPartner = icc~Customer
            FIELDS ibpsalesperson~BusinessPartner AS EmployeCode
            WHERE ccs~gate_entry_no = @wa_cashSheet-cgpno AND icc~CompanyCode = @wa_cashSheet-ccmpcode
            AND ccs~dealer_wise_cash > 0 AND ccs~plant = @wa_cashsheet-plant
        INTO @DATA(salesPerson).

************************************************************BY VINAY on 13-11-2025
        SELECT SINGLE FROM i_businesspartner AS a
        FIELDS a~BusinessPartnerName
               WHERE a~businesspartner = @salesperson
               INTO @DATA(ltsalespersonname).
****************************************************************

        IF salesPerson IS INITIAL.

          DATA strError TYPE c LENGTH 40.
          strError = 'Gate No ' &&  wa_cashSheet-cgpno && ' Sales Person not mapped'.
          UPDATE zcashroomcrtable
          SET error_log = @strerror
          WHERE ccmpcode = @wa_cashSheet-ccmpcode AND plant = @wa_cashSheet-plant AND cgpno = @wa_cashSheet-cgpno
          AND glposted = 0.
          CONTINUE.

        ENDIF.

        IF salesPerson IS NOT INITIAL.
          SELECT SINGLE FROM ztable_plant AS zpt
              FIELDS zpt~glaccount , costcenter
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

          IF wa_custdata IS NOT INITIAL.

            DATA strcustError TYPE c LENGTH 40.
            strcustError = wa_custdata && ' customer not mapped'.
            UPDATE zcashroomcrtable
            SET error_log = @strcustError
            WHERE ccmpcode = @wa_cashSheet-ccmpcode AND plant = @wa_cashSheet-plant AND cgpno = @wa_cashSheet-cgpno
            AND glposted = 0.
            CONTINUE.

          ENDIF.

          IF wa_custdata IS INITIAL.

            DATA CustomerDeductions TYPE TABLE OF deductions.
            DATA SalesPersonDeductions TYPE deductions.

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

              DATA(refno) = wa_cashSheet-ccmpcode && wa_cashSheet-plant && wa_cashSheet-cfyear
                                                 && wa_cashSheet-cgpno && wa_cashSheet-cno.

              APPEND INITIAL LINE TO lt_cust_je_deep ASSIGNING FIELD-SYMBOL(<cust_je_deep>).

              <cust_je_deep>-%cid = lv_cust_cid.
              <cust_je_deep>-%param = VALUE #(
                  businesstransactiontype = 'RFBU'
                  accountingdocumenttype = 'DZ'
                  CompanyCode = wa_cashSheet-ccmpcode
                  CreatedByUser = sy-uname
                  documentdate = lv_date
                  postingdate = lv_date
                  accountingdocumentheadertext = refno
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
                                          glaccount = ltcashaccount-glaccount
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
                            WHERE ccmpcode = @wa_cashsheet-ccmpcode AND plant = @wa_cashsheet-plant AND cgpno = @wa_cashsheet-cgpno
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

                  SELECT SINGLE FROM I_JournalEntry AS ij
                      FIELDS AccountingDocument, AccountingDocumentType
                      WHERE ij~AccountingDocumentHeaderText = @jeno
                  INTO @DATA(wa_ltJE1).
                  IF wa_ltje1 IS NOT INITIAL.
                    acctdoc1 = wa_ltje1-AccountingDocument.
                  ENDIF.

                  UPDATE zcashroomcrtable
                      SET glposted = 1,
                      error_log = ``,
                      reference_doc = @acctdoc1
                      WHERE ccmpcode = @wa_cashsheet-ccmpcode AND plant = @wa_cashsheet-plant AND cgpno = @wa_cashsheet-cgpno
                      AND glposted = 0.
                ENDIF.
                CLEAR : lt_cust_commit_failed, lt_cust_commit_reported.
                CLEAR : lt_cust_je_deep.
              ENDIF.
            ENDIF.
*            CLEAR : ltplant.
          ENDIF.
        ENDIF.
        CLEAR : wa_custdata,wa_cashSheet,ltcashaccount,CustAmount,SalesPersonDeductions,strcustError , ltsalespersonname .
      ENDLOOP.

    ENDMETHOD.
ENDCLASS.
