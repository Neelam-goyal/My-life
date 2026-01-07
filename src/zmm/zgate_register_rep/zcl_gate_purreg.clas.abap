CLASS zcl_gate_purreg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GATE_PURREG IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zce_gate_register,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      TYPES: BEGIN OF ty_gate,
               gateno           TYPE c LENGTH 25,
               gateindate       TYPE datn,
               entrytype        TYPE c LENGTH 10,
               invoiceno        TYPE c LENGTH 20,
               invoicedate      TYPE datn,
               invoicepartygst  TYPE c LENGTH 15,
               cancelled        TYPE c LENGTH 5,
               vehicleno        TYPE c LENGTH 15,
               invoicingparty   TYPE c LENGTH 15,
               invoicepartyname TYPE c LENGTH 81,
               gateitemno       TYPE c LENGTH 6,
               billamount       TYPE p LENGTH 15 DECIMALS 2,
               gateqty          TYPE p LENGTH 15 DECIMALS 2,
               documentno       TYPE c LENGTH 10,
               documentitemno   TYPE n LENGTH 5,
               partycode        TYPE c LENGTH 10,
               partyname        TYPE c LENGTH 50,
               productdesc      TYPE c LENGTH 40,
               plant            TYPE c LENGTH 4,
               productcode      TYPE c LENGTH 40,
               TaxNumber3       TYPE c LENGTH 18,
             END OF ty_gate.
      DATA wa_gate TYPE ty_gate.
      DATA it_gate TYPE TABLE OF ty_gate.
      DATA lv_lifnr TYPE c LENGTH 10.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lo_error).
          DATA(lv_msg) = lo_error->get_text( ).
      ENDTRY.

      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          lv_msg = lo_error->get_text( ).
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'PONUM'.
          DATA(lt_ebeln) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'GATE_ENTRY_NUM'.
          DATA(lt_gateno) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'GATEINDATE'.
          DATA(lt_gateindate) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'PRODUCT'.
          DATA(lt_matnr) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'SUPPLIER'.
          DATA(lt_supplier) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'PLANT'.
          DATA(lt_werks) = ls_filter_cond-range[].
         ELSEIF ls_filter_cond-name = 'SUPPLIERQTY'.
          DATA(lt_SUPPQTY) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT FROM zgateentryheader AS a
      LEFT JOIN zgateentrylines AS b ON a~gateentryno = b~gateentryno
      LEFT JOIN i_supplier AS c ON c~Supplier = b~partycode
      FIELDS a~gateentryno, a~gateindate, a~entrytype, a~invoiceno, a~invoicedate, a~invoicepartygst, a~cancelled,
      a~vehicleno, a~invoiceparty, a~invoicepartyname, b~gateitemno , a~billamount , b~gateqty, b~documentno, b~documentitemno, b~partycode, b~partyname, b~productdesc,
      b~plant, b~productcode, c~TaxNumber3
      WHERE a~gateentryno IN @lt_gateno AND b~productcode IN @lt_matnr AND b~partycode IN @lt_supplier
      AND a~gateindate IN @lt_gateindate AND b~documentno IN @lt_ebeln AND b~plant IN @lt_werks
      INTO TABLE @it_gate PRIVILEGED ACCESS.

      SELECT FROM ZI_PlantTable
      FIELDS CompCode, PlantCode , PlantName1, GstinNo
      WHERE PlantCode IN @lt_werks
      INTO TABLE @DATA(it_plant) PRIVILEGED ACCESS.

      DELETE it_gate WHERE documentno IS INITIAL AND documentitemno IS INITIAL.
      IF it_gate IS NOT INITIAL.

        SELECT FROM I_PurchaseOrderAPI01 AS a
        LEFT JOIN I_PurchaseOrderItemAPI01 AS b ON b~PurchaseOrder = a~PurchaseOrder
        LEFT JOIN I_ProductPlantBasic AS c ON c~Product = b~Material AND c~Plant = b~Plant
        FIELDS a~PurchaseOrder, a~PurchaseOrderDate, a~PurchaseOrderType, a~CompanyCode,
        a~PurchasingGroup, a~PurchasingOrganization,
        b~PurchaseOrderItem, b~OrderQuantity, b~BaseUnit, b~Plant, b~Material, b~ProfitCenter, b~TaxCode, b~NetPriceAmount,
        c~ConsumptionTaxCtrlCode
        FOR ALL ENTRIES IN @it_gate WHERE a~PurchaseOrder = @it_gate-documentno
        INTO TABLE @DATA(it_po) PRIVILEGED ACCESS.

        SELECT FROM I_MaterialDocumentheader_2 AS a
        LEFT JOIN I_MaterialDocumentItem_2 AS b ON b~MaterialDocument = a~MaterialDocument AND b~GoodsMovementIsCancelled NE 'X' AND b~GoodsMovementType = '101'
        LEFT JOIN I_SuplrInvcItemPurOrdRefAPI01 AS c ON c~ReferenceDocument = a~MaterialDocument
        AND c~ReferenceDocumentItem = b~MaterialDocumentItem AND c~ReferenceDocumentFiscalYear = a~MaterialDocumentYear
        LEFT JOIN I_SupplierInvoiceAPI01 AS d ON d~SupplierInvoice = c~SupplierInvoice AND d~FiscalYear = c~ReferenceDocumentFiscalYear
        LEFT JOIN c_supplierinvoicedex AS e ON e~SupplierInvoice = c~SupplierInvoice AND e~FiscalYear = c~FiscalYear AND e~CompanyCode = b~CompanyCode
        LEFT JOIN ztaxcode AS f ON f~taxcode = c~TaxCode
        FIELDS a~MaterialDocumentHeaderText, b~MaterialDocument, b~MaterialDocumentItem, b~DocumentDate, b~MaterialDocumentYear,
        b~QuantityInBaseUnit, b~PurchaseOrder, b~PurchaseOrderItem,
        c~SupplierInvoice, c~SupplierInvoiceItem, C~QuantityInPurchaseOrderUnit, c~FiscalYear, c~ReferenceDocument, c~SupplierInvoiceItemAmount, c~TaxCode,
        d~PostingDate,
        e~ReverseDocument,
        f~rate, f~description, f~transactiontypedetermination
        FOR ALL ENTRIES IN @it_gate WHERE a~MaterialDocumentHeaderText = @it_gate-gateno
        AND b~PurchaseOrder = @it_gate-documentno AND b~PurchaseOrderItem = @it_gate-documentitemno
        INTO TABLE @DATA(it_grn) PRIVILEGED ACCESS.

      ENDIF.

      SORT lt_response BY gate_entry_num gate_entryline.

      LOOP AT it_gate ASSIGNING FIELD-SYMBOL(<fs_gate>).

        CLEAR ls_response.

        ls_response-gate_entry_num   = <fs_gate>-gateno.
        ls_response-gate_entryline   = <fs_gate>-gateitemno.
        ls_response-gateindate       = <fs_gate>-gateindate.
        ls_response-gateentrytype    = <fs_gate>-entrytype.
        ls_response-gebillno         = <fs_gate>-invoiceno.
        ls_response-gebilldate       = <fs_gate>-invoicedate.
        ls_response-billamt          = <fs_gate>-billamount.
        ls_response-productname      = <fs_gate>-productdesc.
        ls_response-vehicleno        = <fs_gate>-vehicleno.
        ls_response-gatecancelled    = <fs_gate>-cancelled.
        ls_response-invoiceparty     = <fs_gate>-invoicingparty.
        ls_response-invoicepartyname     = <fs_gate>-invoicepartyname.
        ls_response-invoicepartygst     = <fs_gate>-invoicepartygst.
        ls_response-gateqty          = <fs_gate>-gateqty.
        ls_response-ponum            = <fs_gate>-documentno.
        ls_response-poitem           = <fs_gate>-documentitemno.
        ls_response-supplier         = <fs_gate>-partycode.
        ls_response-suppliername     = <fs_gate>-partyname.
        ls_response-supp_gst         = <fs_gate>-taxnumber3.
        ls_response-plant            = <fs_gate>-plant.
        ls_response-product          = <fs_gate>-productcode.

        READ TABLE it_po ASSIGNING FIELD-SYMBOL(<fs_po>)
             WITH KEY PurchaseOrder = <fs_gate>-documentno
                      PurchaseOrderItem = <fs_gate>-documentitemno.
        IF <fs_po> IS ASSIGNED.
          ls_response-podate         = <fs_po>-purchaseorderdate.
          ls_response-potype         = <fs_po>-purchaseordertype.
          ls_response-pur_group      = <fs_po>-PurchasingGroup.
          ls_response-pur_org        = <fs_po>-PurchasingOrganization.
          ls_response-pouom          = <fs_po>-BaseUnit.
          ls_response-porate         = <fs_po>-NetPriceAmount.
          ls_response-hsncode        = <fs_po>-ConsumptionTaxCtrlCode.
          ls_response-companycode    = <fs_po>-companycode.
          ls_response-profitcenter   = <fs_po>-ProfitCenter.
          UNASSIGN <fs_po>.
        ENDIF.

        READ TABLE it_plant ASSIGNING FIELD-SYMBOL(<fs_plant>)
             WITH KEY PlantCode = ls_response-plant
                      CompCode = ls_response-companycode.
        IF <fs_plant> IS ASSIGNED.
          ls_response-plantgst       = <fs_plant>-GstinNo.
          ls_response-plantname      = <fs_plant>-PlantName1.
          UNASSIGN <fs_plant>.
        ENDIF.

        READ TABLE it_grn ASSIGNING FIELD-SYMBOL(<fs_grn2>)
             WITH KEY MaterialDocumentHeaderText = <fs_gate>-gateno
                      PurchaseOrder = <fs_gate>-documentno
                      PurchaseOrderItem = <fs_gate>-documentitemno.
        IF <fs_grn2> IS ASSIGNED.
          ls_response-grnnum         = <fs_grn2>-MaterialDocument.
          ls_response-grndate        = <fs_grn2>-DocumentDate.
          ls_response-grnqty         = <fs_grn2>-QuantityInBaseUnit.
          ls_response-grnitem        = <fs_grn2>-MaterialDocumentItem.
          ls_response-grnyear        = <fs_grn2>-MaterialDocumentYear.

          IF <fs_grn2>-ReverseDocument IS NOT INITIAL.
            ls_response-isreversed   = 'X'.
            ls_response-refinvno     = <fs_grn2>-ReverseDocument.
          ENDIF.

          IF <fs_grn2>-SupplierInvoice IS NOT INITIAL AND <fs_grn2>-SupplierInvoiceItem IS NOT INITIAL.
            ls_response-taxcodename            = <fs_grn2>-description.
            ls_response-supplierinvoice        = <fs_grn2>-supplierinvoice.
            ls_response-supplierinvoiceitem    = <fs_grn2>-supplierinvoiceitem.
            LS_RESPONSE-supplierqty = <FS_GRN2>-QuantityInPurchaseOrderUnit.
            ls_response-fiscalyear             = <fs_grn2>-FiscalYear.
            ls_response-netamount              = <fs_grn2>-SupplierInvoiceItemAmount.
            ls_response-originalreferencedocument = |{ <fs_grn2>-supplierinvoice }{ <fs_grn2>-fiscalyear }|.
            ls_response-invpostingdate         = <fs_grn2>-PostingDate.
            ls_response-taxamount              = ( ls_response-netamount * <fs_grn2>-rate ) / 100 .

            IF <fs_grn2>-transactiontypedetermination = 'JII'.
              ls_response-igst     = ls_response-taxamount.
              ls_response-rateigst = <fs_grn2>-rate.
            ELSEIF <fs_grn2>-transactiontypedetermination = 'JIC' OR <fs_grn2>-transactiontypedetermination = 'JIS'.
              ls_response-sgst     = ls_response-taxamount / 2.
              ls_response-cgst     = ls_response-taxamount / 2.
              ls_response-ratecgst = <fs_grn2>-rate / 2.
              ls_response-ratesgst = <fs_grn2>-rate / 2.
            ENDIF.
            ls_response-totalamount = ls_response-netamount + ls_response-taxamount .
          ENDIF.
          UNASSIGN <fs_grn2>.
        ENDIF.

        COLLECT ls_response INTO lt_response.

      ENDLOOP.

      LOOP AT lt_sort INTO DATA(ls_sort).
        CASE ls_sort-element_name.
          WHEN 'GATE_ENTRY_NUM'.
            SORT lt_response BY gate_entry_num ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY gate_entry_num DESCENDING.
            ENDIF.
          WHEN 'GATE_ENTRYLINE'.
            SORT lt_response BY gate_entryline ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY gate_entryline DESCENDING.
            ENDIF.
          WHEN 'GATEINDATE'.
            SORT lt_response BY gateindate ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY gateindate DESCENDING.
            ENDIF.
          WHEN 'GATEENTRYTYPE'.
            SORT lt_response BY gateentrytype ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY gateentrytype DESCENDING.
            ENDIF.
          WHEN 'GEBILLNO'.
            SORT lt_response BY gebillno ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY gebillno DESCENDING.
            ENDIF.
          WHEN 'GEBILLDATE'.
            SORT lt_response BY gebilldate ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY gebilldate DESCENDING.
            ENDIF.
          WHEN 'GATECANCELLED'.
            SORT lt_response BY gatecancelled ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY gatecancelled DESCENDING.
            ENDIF.
          WHEN 'PONUM'.
            SORT lt_response BY ponum ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY ponum DESCENDING.
            ENDIF.
          WHEN 'POITEM'.
            SORT lt_response BY poitem ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY poitem DESCENDING.
            ENDIF.
          WHEN 'PODATE'.
            SORT lt_response BY podate ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY podate DESCENDING.
            ENDIF.
          WHEN 'INVOICEPARTY'.
            SORT lt_response BY invoiceparty ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY invoiceparty DESCENDING.
            ENDIF.
          WHEN 'INVOICEPARTYNAME'.
            SORT lt_response BY invoicepartyname ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY invoicepartyname DESCENDING.
            ENDIF.
          WHEN 'SUPPLIER'.
            SORT lt_response BY supplier ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY supplier DESCENDING.
            ENDIF.
          WHEN 'SUPPLIERNAME'.
            SORT lt_response BY suppliername ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY suppliername DESCENDING.
            ENDIF.
          WHEN 'SUPPLIERQTY'.
            SORT lt_response BY supplierqty ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY supplierqty DESCENDING.
            ENDIF.
          WHEN 'PLANT'.
            SORT lt_response BY plant ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY plant DESCENDING.
            ENDIF.
          WHEN 'PLANTNAME'.
            SORT lt_response BY plantname ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY plantname DESCENDING.
            ENDIF.
          WHEN 'GRNDATE'.
            SORT lt_response BY grndate ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY grndate DESCENDING.
            ENDIF.
          WHEN 'GRNNUM'.
            SORT lt_response BY grnnum ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY grnnum DESCENDING.
            ENDIF.
          WHEN 'SUPPLIERINVOICE'.
            SORT lt_response BY supplierinvoice ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY supplierinvoice DESCENDING.
            ENDIF.
          WHEN 'INVPOSTINGDATE'.
            SORT lt_response BY invpostingdate ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY invpostingdate DESCENDING.
            ENDIF.
          WHEN 'COMPANYCODE'.
            SORT lt_response BY companycode ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY companycode DESCENDING.
            ENDIF.
          WHEN 'POTYPE'.
            SORT lt_response BY potype ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY potype DESCENDING.
            ENDIF.
          WHEN 'PUR_ORG'.
            SORT lt_response BY pur_org ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY pur_org DESCENDING.
            ENDIF.
          WHEN 'PUR_GROUP'.
            SORT lt_response BY pur_group ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY pur_group DESCENDING.
            ENDIF.
          WHEN 'PRODUCT'.
            SORT lt_response BY product ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY product DESCENDING.
            ENDIF.
          WHEN 'PRODUCTNAME'.
            SORT lt_response BY productname ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY productname DESCENDING.
            ENDIF.
          WHEN 'TRANSACTIONTYPE'.
            SORT lt_response BY transactiontype ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY transactiontype DESCENDING.
            ENDIF.
        ENDCASE.
      ENDLOOP.

      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).

    ENDIF.

  ENDMETHOD.
ENDCLASS.
