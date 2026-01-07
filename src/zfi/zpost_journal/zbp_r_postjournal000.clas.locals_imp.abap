CLASS LHC_ZR_POSTJOURNAL000 DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrPostjournal000
        RESULT result.

      METHODS generateData FOR MODIFY
      IMPORTING keys FOR ACTION ZrPostjournal000~generateData RESULT result.

      METHODS post FOR MODIFY
      IMPORTING keys FOR ACTION ZrPostjournal000~post RESULT result.

     METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

ENDCLASS.

CLASS LHC_ZR_POSTJOURNAL000 IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD post.

  ENDMETHOD.

  METHOD generateData.

    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    DATA(Company) = ls_key-%param-comp_code.
    DATA(Plant) = ls_key-%param-plant.
    DATA(FromDate) = ls_key-%param-from_date.
    DATA(ToDate) = ls_key-%param-to_date.
    DATA(Percent) = ls_key-%param-percent.

    SELECT SINGLE FROM ztable_plant
      FIELDS ( gstin_no )
      WHERE plant_code = @plant
      AND comp_code = @company
      INTO @DATA(ls_plantgst).

   DATA: lv_postjournal TYPE TABLE OF zr_postjournal000.


    SELECT FROM zpurchinvlines AS main
      FIELDS  main~companycode, main~fiscalyearvalue, main~supplierinvoice, main~supplierinvoiceitem, main~postingdate,  main~plantname, main~product, main~productname,
        main~purchaseorder, main~purchaseorderitem, main~vendor_invoice_no, main~vendor_invoice_date, main~vendor_type,
        main~baseunit, main~profitcenter, main~purchaseordertype, main~purchaseorderdate,
        main~purchasingorganization, main~purchasinggroup, main~hsncode,
        main~taxcodename,  main~igst, main~sgst, main~cgst,
        main~rateigst, main~ratecgst, main~ratesgst,
        main~isreversed, main~netamount, main~taxamount, main~roundoff
      WHERE main~companycode = @company
        AND main~plantgst = @ls_plantgst
        AND main~postingdate BETWEEN @fromdate AND @todate
        AND NOT EXISTS (
          SELECT 1
            FROM zpostjournal AS sub
            WHERE sub~companycode = main~companycode
              AND sub~fiscalyear = main~fiscalyearvalue
              AND sub~postingdate BETWEEN @fromdate AND @todate
              AND sub~supplierinvoice = main~supplierinvoice
              AND sub~supplierinvoiceitem = main~supplierinvoiceitem
        )
      INTO TABLE @DATA(lv_purchInv).
    LOOP AT lv_purchInv INTO DATA(wa_purchInv).

        DATA(cid) = getCID( ).

        MODIFY ENTITIES OF zr_postjournal000 IN LOCAL MODE
            ENTITY ZrPostjournal000
            CREATE FIELDS (
                companycode
              fiscalyear
              supplierinvoice
              supplierinvoiceitem
              postingdate
              plantname
              Material
              productname
              purchaseorder
              purchaseorderitem
              VendorInvoiceNo
              VendorInvoiceDate
              VendorType
              baseunit
              profitcenter
              purchaseordertype
              purchaseorderdate
              purchasingorganization
              purchasinggroup
              hsncode
              taxcodename
              igst
              sgst
              cgst
              rateigst
              ratecgst
              ratesgst
              isreversed
              netamount
              taxamount
              roundoff )
            WITH VALUE #( ( %cid = cid
                            companycode = wa_purchInv-companycode
                            fiscalyear = wa_purchInv-fiscalyearvalue
                            supplierinvoice = wa_purchInv-supplierinvoice
                            supplierinvoiceitem = wa_purchInv-supplierinvoiceitem
                            postingdate = wa_purchInv-postingdate
                            Plant = plant
                            Percent = Percent
                            plantname = wa_purchInv-plantname
                            Material = wa_purchInv-product
                            productname = wa_purchInv-productname
                            purchaseorder = wa_purchInv-purchaseorder
                            purchaseorderitem = wa_purchInv-purchaseorderitem
                            VendorInvoiceNo = wa_purchInv-vendor_invoice_no
                            VendorInvoiceDate = wa_purchInv-vendor_invoice_date
                            VendorType = wa_purchInv-vendor_type
                            baseunit = wa_purchInv-baseunit
                            profitcenter = wa_purchInv-profitcenter
                            purchaseordertype = wa_purchInv-purchaseordertype
                            purchaseorderdate = wa_purchInv-purchaseorderdate
                            purchasingorganization = wa_purchInv-purchasingorganization
                            purchasinggroup = wa_purchInv-purchasinggroup
                            hsncode = wa_purchInv-hsncode
                            taxcodename = wa_purchInv-taxcodename
                            igst = wa_purchInv-igst
                            sgst = wa_purchInv-sgst
                            cgst = wa_purchInv-cgst
                            rateigst = wa_purchInv-rateigst
                            ratecgst = wa_purchInv-ratecgst
                            ratesgst = wa_purchInv-ratesgst
                            isreversed = wa_purchInv-isreversed
                            netamount = wa_purchInv-netamount
                            taxamount = wa_purchInv-taxamount
                            roundoff = wa_purchInv-roundoff
                          ) )
              MAPPED mapped
            FAILED   failed
            REPORTED reported.
    ENDLOOP.

     APPEND VALUE #( %cid = ls_key-%cid
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = 'Data Generated.' )
                      ) TO reported-zrpostjournal000.
    RETURN.


  ENDMETHOD.

  METHOD getCID.
            TRY.
                cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
            CATCH cx_uuid_error.
                ASSERT 1 = 0.
            ENDTRY.
  ENDMETHOD.

ENDCLASS.
