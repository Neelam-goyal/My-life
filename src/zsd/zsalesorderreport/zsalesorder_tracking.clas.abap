CLASS zsalesorder_tracking DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSALESORDER_TRACKING IMPLEMENTATION.


   METHOD if_rap_query_provider~select.

     DATA: lv_skip     TYPE i, " Declare lv_skip as an integer
           lv_top      TYPE i,
           lv_max_rows TYPE i.

     lv_top = io_request->get_paging( )->get_page_size( ).
     lv_skip = io_request->get_paging( )->get_offset( ).
     lv_max_rows = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).


*      DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
     DATA(lt_parameters)  = io_request->get_parameters( ).
     DATA(lt_fileds)  = io_request->get_requested_elements( ).
     DATA(lt_sort)  = io_request->get_sort_elements( ).

     TRY.
         DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
       CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
         CLEAR lt_Filter_cond.  " Ignore error and continue
     ENDTRY.

     LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
       IF ls_filter_cond-name = to_upper( 'Plant' ).
         DATA(lt_plant) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'Customer' ).
         DATA(lt_customer) = ls_FILTER_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'CreationDate' ).
         DATA(lt_date) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'SalesDocument' ).
         DATA(lt_salesorder) = ls_filter_cond-range[].
       ELSEIF ls_filter_cond-name = to_upper( 'DistributionChannel' ).
         DATA(lt_DistributionChannel) = ls_FILTER_cond-range[].
       ENDIF.
     ENDLOOP.

     DATA: lt_result      TYPE STANDARD TABLE OF zsalesrp_tracking,
           ls_line        TYPE zsalesrp_tracking,
           la_line        TYPE zsalesrp_tracking,
           lt_responseout LIKE lt_result,
           ls_responseout LIKE LINE OF lt_responseout.


     SELECT FROM I_SalesDocument AS a
     JOIN I_SalesDocumentItem AS b ON a~SalesDocument = b~SalesDocument
     LEFT JOIN I_DeliveryDocumentItem AS c ON c~ReferenceSDDocument = b~SalesDocument
*      LEFT JOIN I_MaterialDocumentItem_2 AS d ON d~DeliveryDocument = c~DeliveryDocument AND d~ReversedMaterialDocument EQ ''
*            AND NOT EXISTS IN ( SELECT * FROM I_MaterialDocumentItem_2 AS g WHERE eg~ReversedMaterialDocument = d~MaterialDocument )
     LEFT JOIN I_BILlingDocumentITEM AS e ON e~ReferenceSDDocument = c~DeliveryDocument AND e~SalesDocument = b~SalesDocument AND e~BillingDocumentType NE 'F8'
     FIELDS a~SalesDocument, a~CreationDate, a~CreationTime, a~PurchaseOrderByCustomer,  a~ControllingAreaCurrency,
           b~DistributionChannel, b~Plant, c~DeliveryDocument AS obd,e~BillingDocument AS Bill, a~OVERALLSDPROCESSSTATUS",d~MaterialDocument
     WHERE a~CreationDate IN @lt_date AND b~BillToParty IN @lt_customer
          AND b~Plant IN @lt_plant AND b~DistributionChannel IN @lt_distributionchannel AND b~SalesDocument IN @lt_salesorder
*           AND d~MaterialDocument NOT IN ( SELECT MaterialDocument FROM I_MaterialDocumentItem_2 AS g WHERE g~ReversedMaterialDocument = d~MaterialDocument )
     GROUP BY a~SalesDocument, a~CreationDate, a~CreationTime, a~PurchaseOrderByCustomer,  a~ControllingAreaCurrency,
               b~DistributionChannel, b~Plant, c~DeliveryDocument, e~BillingDocument,a~OVERALLSDPROCESSSTATUS", d~MaterialDocument
     ORDER BY a~CreationDate, a~CreationTime
     INTO TABLE @DATA(la_invoice).
*      UP TO lv_max_rows ROWS
*      OFFSET lv_skip.

     DATA(count) = 0.

     LOOP AT la_invoice INTO DATA(wa_invoice) FROM lv_skip + 1.

       IF count >= lv_max_rows.
         EXIT.
       ENDIF.

       CLEAR ls_line.
       ls_line-CreationDate            =           wa_invoice-CreationDate.
       ls_line-CreationTime            =           wa_invoice-CreationTime.
       ls_line-CustomerRef             =           wa_invoice-PurchaseOrderByCustomer.
       ls_line-SalesDocument           =           wa_invoice-SalesDocument.
       ls_line-ControllingAreaCurrency =           wa_invoice-ControllingAreaCurrency.
       ls_line-DistributionChannel     =           wa_invoice-DistributionChannel.
       ls_line-Plant                   =           wa_invoice-Plant.
       ls_line-odd                     =           wa_invoice-obd.
       ls_line-Invoice                 =           wa_invoice-bill.

       IF wa_invoice-OverallSDProcessStatus = 'A'.
            ls_line-Status       =           'Pending'.
       ELSEIF wa_invoice-OverallSDProcessStatus = 'C'.
             select single from I_DeliveryDocumentitem as a
             inner join I_DeliveryDocument as b on a~DeliveryDocument = b~DeliveryDocument
             fields b~OverallSDProcessStatus
             where a~ReferenceSDDocument = @wa_invoice-SalesDocument and b~DeliveryDocument = @wa_invoice-obd
             into @data(status).
            IF status = 'C'.
              ls_line-Status  = 'Closed'.
            ELSE.
              ls_line-Status  =  'Open'.
            ENDIF.
       ELSEIF wa_invoice-OverallSDProcessStatus = 'B'.
            ls_line-Status       =            'Short Supply'.
       ENDIF.



*      Taxable Amount
       SELECT SINGLE FROM I_SalesDocumentItem AS a
       FIELDS SUM( a~NetAmount ) AS TaxableAmount
       WHERE a~SalesDocument = @wa_invoice-SalesDocument
       INTO @DATA(TaxableAmount).

       ls_line-OrderAmount             =           TaxableAmount.


*       Customer
       SELECT SINGLE FROM I_SalesDocumentItem AS a
       JOIN I_Customer AS b ON b~Customer = a~BillToParty
       FIELDS b~Customer, b~CustomerName
       WHERE a~SalesDocument = @wa_invoice-SalesDocument
       INTO @DATA(Customer).


       ls_line-Customer                =           Customer-Customer.
       ls_line-CustomerName            =           Customer-CustomerName.



*       Order Quantity
       SELECT SINGLE FROM I_SalesDocumentItem AS a
        FIELDS SUM( a~OrderQuantity ) AS OrderQty, SUM( a~ItemNetWeight ) AS ItemNetWeight
       WHERE a~SalesDocument = @wa_invoice-SalesDocument
       INTO @DATA(OrderQty).

       ls_line-OrderQty                =           OrderQty-OrderQty.
       ls_line-OrderQtyPerKG           =           OrderQty-ItemNetWeight.

       IF ls_line-OrderQtyPerKG NE 0.
         ls_line-RatePerKG             =           ls_line-OrderAmount / ls_line-OrderQtyPerKG .
       ENDIF.


*       Credit Blocked
       SELECT SINGLE FROM I_CreditBlockedSalesDocument AS a
       FIELDS SalesDocument
       WHERE a~SalesDocument = @wa_invoice-SalesDocument
       INTO @DATA(SalesDoc).

       IF SalesDoc IS INITIAL.
         ls_line-FinApp           =           'RO-Approved/NA'.
       ELSE.
         ls_line-FinApp           =           'RO-Pending'.
       ENDIF.

       SELECT SINGLE FROM I_MaterialDocumentItem_2 AS a
       FIELDS a~MaterialDocument
          WHERE a~DeliveryDocument = @wa_invoice-obd
            AND a~ReversedMaterialDocument = ''
            AND NOT EXISTS (
              SELECT *
                FROM I_MaterialDocumentItem_2 AS g
                WHERE g~ReversedMaterialDocument = a~MaterialDocument
            )
          INTO @DATA(MaterialDocument).
       IF MaterialDocument IS NOT INITIAL AND wa_invoice-obd IS NOT INITIAL.
         ls_line-pgi       =           MaterialDocument.
       ENDIF.


       SELECT SINGLE FROM I_BillingDocumentItem AS a
       FIELDS SUM( a~BillingQuantity ) AS BillQty, SUM( a~NetAmount ) AS TaxableInvoice
       WHERE a~BillingDocument = @wa_invoice-bill
       INTO @DATA(BillQty).
       ls_line-InvoiceQty              =           BillQty-BillQty.
       ls_line-InvoiceAmount           =           BillQty-TaxableInvoice.

       SELECT SINGLE FROM I_BillingDocument AS a
       FIELDS DocumentReferenceID, BillingDocumentIsCancelled, BillingDocumentType ",OverallSDProcessStatus
       WHERE a~BillingDocument = @wa_invoice-bill
       INTO @DATA(InvoiceAmount).
       ls_line-ODNNo                      =           InvoiceAmount-DocumentReferenceID.

       IF InvoiceAmount-BillingDocumentIsCancelled EQ abap_true.
         ls_line-Cancelled                  =           'Yes'.
       ENDIF..

*       IF InvoiceAmount-OverallSDProcessStatus IS NOT INITIAL AND InvoiceAmount-OverallSDProcessStatus EQ 'C'.
*         ls_line-Status       =           'Closed'.
*       ELSEIF ls_line-Cancelled = 'Yes'.
*         ls_line-Status       =           'Closed'.
*       ELSEIF InvoiceAmount-BillingDocumentType = 'S1'.
*         ls_line-Status       =           'Closed'.
*       ELSE.
*         ls_line-Status       =           'Open'.
*       ENDIF.



*           Eway Bill
       SELECT SINGLE FROM zr_zirntp AS a
       FIELDS a~Ewaybillno
       WHERE a~Bookingno = @wa_invoice-bill
       INTO @DATA(Ewaybillno).


       IF Ewaybillno IS INITIAL.
         ls_line-Eway                =           'No'.
       ELSE.
         ls_line-Eway                =           'Yes'.
       ENDIF.


*            PGI Reference
       SELECT SINGLE FROM I_DeliveryDocumentItem AS a
       FIELDS SUM( a~ActualDeliveryQuantity ) AS ActualDeliveryQuantity
       WHERE a~DeliveryDocument = @wa_invoice-obd
       INTO @DATA(ActualDeliveryQuantity).
       ls_line-ODDQty          =           ActualDeliveryQuantity.


       ls_line-AmtDiff                 =           ls_line-OrderAmount - ls_line-InvoiceAmount.
       ls_line-QtyDiff                 =           ls_line-OrderQty - ls_line-InvoiceQty.

       APPEND ls_line TO lt_result.
       count = count + 1.
       CLEAR:
               InvoiceAmount,
               BillQty,
               ActualDeliveryQuantity,
               MaterialDocument,
               Ewaybillno,
               status.

     ENDLOOP.



     CLEAR lt_responseout.
     LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>)." FROM lv_skip TO lv_max_rows.
       ls_responseout = <lfs_out_line_item>.
       APPEND ls_responseout TO lt_responseout.
     ENDLOOP.

     io_response->set_total_number_of_records( lines( lt_responseout ) ).
     io_response->set_data( lt_responseout ).

   ENDMETHOD.
ENDCLASS.
