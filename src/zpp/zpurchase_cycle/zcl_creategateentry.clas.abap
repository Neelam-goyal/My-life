CLASS zcl_creategateentry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.

    CLASS-METHODS createGateEntry.

    CLASS-METHODS convertISTSeparate
      IMPORTING
        sdate        TYPE d
        stime        TYPE t
      EXPORTING
        VALUE(idate) TYPE d
        VALUE(itime) TYPE t.

PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CREATEGATEENTRY IMPLEMENTATION.


 METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 80
        param_text = 'Create Interbranch PO' lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ'
        low = 'Create Interbranch PO' )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    createGateEntry( ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    createGateEntry( ).
  ENDMETHOD.


  METHOD createGateEntry.

    " Get integration path for sales filter
    SELECT SINGLE FROM zintegration_tab
    FIELDS intgpath
    WHERE intgmodule = 'SALESFILTER'
    INTO @DATA(it_integration).

    " Get PO list based on filter condition
    IF it_integration IS NOT INITIAL AND it_integration NE ''.
      SELECT a~imno, a~comp_code, a~plant, a~imfyear, a~imtype, a~po_no,
             a~cust_code, a~imdate, a~error_log, a~vehicleno
        FROM zinv_mst AS a
        INNER JOIN zinv_mst_filter AS b
        ON a~comp_code = b~comp_code
        AND a~plant = b~plant
        AND a~imfyear = b~imfyear
        AND a~imtype = b~imtype
        AND a~imno = b~imno
        INNER JOIN ztable_plant AS c ON a~plant = c~plant_code
        WHERE a~po_tobe_created = 1 AND a~po_processed = 1 AND a~datavalidated = 1 AND c~stpocreationenabled = 'X'
              AND a~gate_entry_no IS INITIAL
        ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
        INTO TABLE @DATA(polist).
    ELSE.
      SELECT a~imno, a~comp_code, a~plant, a~imfyear, a~imtype, a~po_no,
             a~cust_code, a~imdate, a~error_log, a~vehicleno
        FROM zinv_mst AS a
         INNER JOIN ztable_plant AS c ON a~plant = c~plant_code
        WHERE a~po_tobe_created = 1 AND a~po_processed = 1 AND a~datavalidated = 1 AND c~stpocreationenabled = 'X'
                AND a~gate_entry_no IS INITIAL
        ORDER BY a~comp_code, a~plant, a~imfyear, a~imtype, a~imno
        INTO TABLE @polist.
    ENDIF.


    LOOP AT polist INTO DATA(podetails).


*    get IST date and time for insertion
      CALL METHOD convertISTSeparate
        EXPORTING
          sdate = cl_abap_context_info=>get_system_date( )
          stime = cl_abap_context_info=>get_system_time( )
        IMPORTING
          idate = DATA(date_ist)
          itime = DATA(time_ist).


      SELECT SINGLE FROM I_PurchaseOrderAPI01 AS a
      INNER JOIN I_Supplier AS b ON a~Supplier = b~Supplier
      FIELDS b~Supplier, b~SupplierName, b~TaxNumber3
      WHERE PurchaseOrder = @podetails-po_no
      INTO @DATA(ls_po).

      SELECT FROM I_purchaseOrderItemAPI01 AS a
      INNER JOIN I_ProductText AS b ON a~Material = b~Product
      FIELDS Material,Plant,StorageLocation, a~BaseUnit, PurchaseOrderItem, PurchaseOrder, NetAmount,
             b~ProductName, a~OrderQuantity
      WHERE PurchaseOrder = @podetails-po_no
      INTO TABLE @DATA(lt_poitem).

      IF lt_poitem IS INITIAL.
        RETURN.
      ENDIF.

      DATA(lv_netamt) = 0.
      LOOP AT lt_poitem INTO DATA(ls_item0).
        lv_netamt = lv_netamt + ls_item0-NetAmount.
      ENDLOOP.

      DATA(custref) = |{ podetails-imfyear+0(2) }{ podetails-imtype }{ podetails-imno }|.

      DATA(my_cid) = getCID( ).
      MODIFY ENTITIES OF ZR_GateEntryHeader
      ENTITY GateEntryHeader
      CREATE FIELDS (
          EntryType
          GateOutward
          EntryDate
          RefDocNo
          BillAmount
          VehicleNo
          InvoiceParty
          InvoicePartyGST
          InvoicePartyName
          Plant
          Purpose
          GateInTime
          GateInDate
      )
      WITH VALUE #( (
        %cid = my_cid
        EntryType = 'PUR'
        GateOutward = '0'
        EntryDate = date_ist
        RefDocNo = podetails-po_no
        BillAmount = lv_netamt
        VehicleNo = COND #(
                              WHEN podetails-vehicleno IS INITIAL THEN 'Own vehicle'
                              ELSE podetails-vehicleno
                          )
        InvoiceParty = ls_po-Supplier
        InvoicePartyGST = ls_po-TaxNumber3
        InvoicePartyName = ls_po-SupplierName
        Plant = lt_poitem[ 1 ]-Plant
        Purpose = custref
        GateInDate = podetails-imdate
        GateInTime = time_ist
      ) )

      CREATE BY \_GateEntryLines
      FIELDS (
          Plant
          SLoc
          ProductCode
          ProductDesc
          PartyCode
          PartyName
          OrderQty
          GateQty
          uom
          DocumentNo
          DocumentItemNo
          DocumentQty
          GateValue
          Rate
      )
      WITH VALUE #( (
          %cid_ref = my_cid
          GateEntryNo = space
          %target = VALUE #( FOR ls_item IN lt_poitem INDEX INTO i
            (
              %cid =  |{ my_cid }{ i WIDTH = 3 ALIGN = RIGHT PAD = '0' }|
              Plant = ls_item-Plant
              SLoc = ls_item-StorageLocation
              ProductCode = ls_item-Material
              ProductDesc = ls_item-ProductName
              PartyCode = ls_po-Supplier
              PartyName = ls_po-SupplierName
              OrderQty = ls_item-OrderQuantity
              GateQty = ls_item-OrderQuantity
              uom = ls_item-BaseUnit
              DocumentNo = ls_item-PurchaseOrder
              DocumentItemNo = ls_item-PurchaseOrderItem
              DocumentQty = ls_item-OrderQuantity
              GateValue = ls_item-NetAmount
              Rate = ls_item-NetAmount / ls_item-OrderQuantity
            )
          ) )
       )
      REPORTED DATA(ls_po_reported)
        FAILED DATA(ls_po_failed)
        MAPPED DATA(ls_po_mapped).

      COMMIT ENTITIES BEGIN
         RESPONSE OF ZR_GateEntryHeader
         FAILED DATA(ls_save_failed)
         REPORTED DATA(ls_save_reported).

      IF ls_po_failed IS INITIAL AND ls_save_failed IS INITIAL.
        LOOP AT ls_po_mapped-gateentryheader INTO DATA(ls_reported).
          DATA(gate_entry) = ls_reported-GateEntryNo.
        ENDLOOP.
      ELSE.
        LOOP AT ls_save_reported-gateentryheader INTO DATA(ls_reported1).
          DATA(message) = ls_reported1-%msg->if_message~get_text( )..
        ENDLOOP.

      ENDIF.

      IF gate_entry IS INITIAL.
        UPDATE zinv_mst SET error_log = @message
               WHERE imno = @podetails-imno
               AND comp_code = @podetails-comp_code
               AND plant = @podetails-plant
               AND imfyear = @podetails-imfyear
               AND imtype = @podetails-imtype.
      ELSE.
        UPDATE zinv_mst SET gate_entry_no = @gate_entry, error_log = ''
                WHERE imno = @podetails-imno
                AND comp_code = @podetails-comp_code
                AND plant = @podetails-plant
                AND imfyear = @podetails-imfyear
                AND imtype = @podetails-imtype.
      ENDIF.



      COMMIT ENTITIES END.



    ENDLOOP.


  ENDMETHOD.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


    METHOD convertISTSeparate.

    DATA: timestamp   TYPE timestampl,
          timestp_str TYPE string.
    timestamp = sdate && stime.

    CALL METHOD cl_abap_tstmp=>add
      EXPORTING
        tstmp   = timestamp
        secs    = 19800 " 5 hours 30 minutes in seconds
      RECEIVING
        r_tstmp = timestamp.

    timestp_str = timestamp.

    idate = timestp_str+0(8). " Extracting date part
    itime = timestp_str+8(6). " Extracting time part
  ENDMETHOD.
ENDCLASS.
