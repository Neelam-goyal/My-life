    CLASS lhc_GateEntryHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
      PRIVATE SECTION.
        CONSTANTS: BEGIN OF lc_cancelled,
                     yes TYPE abap_boolean VALUE 'X',
                     no  TYPE abap_boolean VALUE '',
                   END OF lc_cancelled.

        METHODS get_instance_features FOR FEATURES
          IMPORTING keys REQUEST requested_features FOR GateEntryHeader RESULT result.

        METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
          IMPORTING keys REQUEST requested_authorizations FOR GateEntryHeader RESULT result.

        METHODS cancelGateEntry FOR MODIFY
          IMPORTING keys FOR ACTION GateEntryHeader~cancelGateEntry RESULT result.
        METHODS validateMandatory FOR VALIDATE ON SAVE
          IMPORTING keys FOR GateEntryHeader~validateMandatory.
        METHODS changeValues FOR DETERMINE ON MODIFY
          IMPORTING keys FOR GateEntryHeader~changeValues.
*    METHODS ReCalcTotals FOR MODIFY
*      IMPORTING keys FOR ACTION GateEntryHeader~ReCalcTotals.
        METHODS precheck_update FOR PRECHECK
          IMPORTING entities FOR UPDATE GateEntryHeader.
        METHODS precheck_create FOR PRECHECK
          IMPORTING entities FOR CREATE GateEntryHeader.
        METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
          IMPORTING REQUEST requested_authorizations FOR GateEntryHeader RESULT result.
        METHODS cancelMultiple FOR MODIFY
          IMPORTING keys FOR ACTION GateEntryHeader~cancelMultiple.


        METHODS is_update_allowed
          RETURNING VALUE(update_allowed) TYPE abap_boolean.

        METHODS earlynumbering_gateentrylines FOR NUMBERING
          IMPORTING entities FOR CREATE GateEntryHeader\_GateEntryLines.

        METHODS earlynumbering_gateentryheader FOR NUMBERING
          IMPORTING entities FOR CREATE GateEntryHeader.


    ENDCLASS.

    CLASS lhc_GateEntryHeader IMPLEMENTATION.

      METHOD get_instance_authorizations.
        DATA: cancelled_requested TYPE abap_boolean.

        READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
        ENTITY GateEntryHeader
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(GateEntryHeaders)
        FAILED failed.

        CHECK GateEntryHeaders IS NOT INITIAL.

        cancelled_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
    "    OR requested_authorizations-
                                      THEN abap_true ELSE abap_false ).

        LOOP AT GateEntryHeaders ASSIGNING FIELD-SYMBOL(<lfs_gateheader>).
          IF cancelled_requested = abap_true.
            IF is_update_allowed(  ) = abap_false.

              "          APPEND VALUE #( %tky = <lfs_gateheader>-%tky ) to failed-gateentryheader.

              APPEND VALUE #( "%tky = <lfs_gateheader>-%tky
                              %msg = new_message_with_text(
                                    severity = if_abap_behv_message=>severity-error
                                    text = 'No authorization to cancel'
                              ) ) TO reported-gateentryheader.

            ENDIF.
          ENDIF.
        ENDLOOP.

      ENDMETHOD.

      METHOD get_instance_features.
        " Fill the response table
        READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
        ENTITY GateEntryHeader
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(GateEntryHeaders).

        result = VALUE #( FOR GateEntryHeader IN GateEntryHeaders
                            LET
                              is_cancelled = COND #( WHEN gateentryheader-Cancelled = lc_cancelled-yes
                                                     THEN if_abap_behv=>fc-o-disabled
                                                     ELSE if_abap_behv=>fc-o-enabled  )
    "                            is_not_set_as_fav = COND #( WHEN contact-PbFavourite = lc_favourite-no
    "                                                        THEN if_abap_behv=>fc-o-disabled
    "                                                        ELSE if_abap_behv=>fc-o-enabled  )
                            IN
                                ( %tky                   = gateentryheader-%tky
                                  %action-cancelGateEntry    = is_cancelled
                                   ) ).
        "                              %action-removeFavourite = is_not_set_as_fav ) ).

      ENDMETHOD.

      METHOD cancelGateEntry.

*    validate the reference entry already exists
        DATA gateEntryNo TYPE string.

        LOOP AT keys INTO DATA(key2).
          gateEntryNo  = key2-GateEntryNo.
        ENDLOOP.

        SELECT SINGLE FROM ZR_GateEntryHeader
            FIELDS ( EntryType )
            WHERE GateEntryNo = @gateentryno
            INTO @DATA(EntryType).


        SELECT SINGLE FROM ZR_GateEntryLines
        FIELDS ( GateEntryNo )
        WHERE DocumentNo = @gateentryno
        INTO @DATA(RefEntry).

        IF RefEntry IS NOT INITIAL AND EntryType = 'RGP-IN'.

          APPEND VALUE #(
                         %msg = new_message_with_text(
                           severity = if_abap_behv_message=>severity-error
                           text = | Cannot Cancel Entry RGP-IN { RefEntry } | )
                           ) TO reported-gateentryheader.
          RETURN.


        ENDIF.

*    check that grn is done or not

        SELECT SINGLE FROM I_MaterialDocumentHeader_2 AS MTHead
        JOIN I_MaterialDocumentItem_2 AS MTDOCITem
        ON MTDOCITem~MaterialDocument = MTHead~MaterialDocument AND MTDOCITem~MaterialDocumentYear = MTHead~MaterialDocumentYear
        FIELDS MTHead~MaterialDocument, mthead~MaterialDocumentYear
        WHERE MTHead~MaterialDocumentHeaderText = @gateentryno AND MTDOCITem~GoodsMovementIsCancelled = '' AND mtdocitem~GoodsMovementType = '101'
        INTO @DATA(grndoc).

        IF grndoc IS NOT INITIAL.
          APPEND VALUE #(
                         %msg = new_message_with_text(
                           severity = if_abap_behv_message=>severity-error
                           text = | GRN Already done. Cannot Cancel Entry | )
                           ) TO reported-gateentryheader.
          RETURN.

        ENDIF.


        " Set as Cancelled
        MODIFY ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
          ENTITY GateEntryHeader
             UPDATE
               FIELDS ( Cancelled )
               WITH VALUE #( FOR key IN keys
                               ( %tky      = key-%tky
                                 Cancelled = lc_cancelled-yes ) )
        FAILED failed
        REPORTED reported.

        " Fill the response table
        READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
        ENTITY GateEntryHeader
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(GateEntryHeaders).

        result = VALUE #( FOR GateEntryHeader IN GateEntryHeaders
                            ( %tky   = GateEntryHeader-%tky
                              %param = GateEntryHeader ) ).
      ENDMETHOD.

      METHOD earlynumbering_gateentrylines.
        READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
          ENTITY GateEntryHeader BY \_GateEntryLines
            FIELDS ( Gateitemno )
              WITH CORRESPONDING #( entities )
              RESULT DATA(gate_entry_lines)
            FAILED failed.


        LOOP AT entities ASSIGNING FIELD-SYMBOL(<gate_entry_header>).
          " get highest item from lines
          DATA(max_item_id) = REDUCE #( INIT max = CONV posnr( '000000' )
                                        FOR gate_entry_line IN gate_entry_lines USING KEY entity WHERE ( Gateentryno = <gate_entry_header>-Gateentryno )
                                        NEXT max = COND posnr( WHEN gate_entry_line-Gateitemno > max
                                                               THEN gate_entry_line-Gateitemno
                                                               ELSE max )
                                      ).
        ENDLOOP.

        "assign Gate Entry Item id
        LOOP AT <gate_entry_header>-%target ASSIGNING FIELD-SYMBOL(<gate_entry_line>).
          APPEND CORRESPONDING #( <gate_entry_line> ) TO mapped-gateentrylines ASSIGNING FIELD-SYMBOL(<mapped_gate_entry_line>).
          IF <gate_entry_line>-Gateitemno IS INITIAL.
            max_item_id += 10.
            <mapped_gate_entry_line>-Gateitemno = max_item_id.
          ENDIF.


        ENDLOOP.
      ENDMETHOD.

      METHOD earlynumbering_gateentryheader.


        LOOP AT entities ASSIGNING FIELD-SYMBOL(<gate_entry_header>).


          DATA: currentYear  TYPE string,
                currentMonth TYPE string,
                numYear      TYPE n LENGTH 4.


          currentYear  = <gate_entry_header>-GateInDate+0(4).
          currentMonth = <gate_entry_header>-GateInDate+4(2).
          numYear = currentYear.
          IF currentMonth >= '04'.  " April (04) to December (12)
            numYear = numYear.
          ELSE.
            numYear = numYear - 1.
          ENDIF.

          DATA: nr_number     TYPE cl_numberrange_runtime=>nr_number.
          TRY.

              DATA interval TYPE c LENGTH 2.

              IF <gate_entry_header>-EntryType = 'PUR'.
                interval = '10'.
              ELSEIF <gate_entry_header>-EntryType = 'RGP-OUT'.
                interval = '20'.
              ELSEIF <gate_entry_header>-EntryType = 'RGP-IN'.
                interval = '30'.
              ELSEIF <gate_entry_header>-EntryType = 'NRGP'.
                interval = '40'.
              ELSEIF <gate_entry_header>-EntryType = 'WREF'.
                interval = '50'.
              ENDIF.


              cl_numberrange_runtime=>number_get(
                EXPORTING
                  nr_range_nr = interval
                  toyear      = numyear
                  object      = 'ZGENO'
                IMPORTING
                  number      = DATA(nextnumber)
              ).
            CATCH cx_number_ranges INTO DATA(lx_number_ranges).
              numYear = numYear.
          ENDTRY.
          SHIFT nextnumber LEFT DELETING LEADING '0'.
        ENDLOOP.

        "assign Gate Entry no.
        APPEND CORRESPONDING #( <gate_entry_header> ) TO mapped-gateentryheader ASSIGNING FIELD-SYMBOL(<mapped_gate_entry_header>).
        IF <gate_entry_header>-Gateentryno IS INITIAL.
          "      max_item_id += 10.
          <mapped_gate_entry_header>-Gateentryno =  |{ <gate_entry_header>-Plant }-{ nextnumber }|.
        ENDIF.


      ENDMETHOD.

      METHOD validateMandatory.
        READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
          ENTITY GateEntryHeader
            FIELDS ( Vehicleno Plant Entrytype InvoiceParty InvoiceNo InvoiceDate Cancelled GateOutTime GateInTime )
              WITH CORRESPONDING #( keys )
              RESULT DATA(entryheaders).

        LOOP AT entryheaders INTO DATA(entryHeader).

          IF ( entryHeader-EntryType = 'PUR' OR entryHeader-EntryType = 'WREF' OR entryHeader-EntryType = 'NRGP' OR entryHeader-EntryType = 'RGP-IN' OR entryHeader-EntryType = 'RGP-OUT'  ) AND entryHeader-GateOutTime IS NOT INITIAL.
            CONTINUE.
          ELSEIF entryHeader-EntryType NE 'PUR' AND entryHeader-EntryType NE 'WREF' AND entryHeader-EntryType NE 'NRGP' AND entryHeader-EntryType NE 'RGP-OUT' AND entryHeader-EntryType NE 'RGP-IN'  AND entryHeader-GateInTime IS NOT INITIAL.
            CONTINUE.
          ELSEIF entryheader-Cancelled = 'X'.
            CONTINUE.
          ENDIF.

          IF entryHeader-InvoiceNo IS NOT INITIAL.
*          IF entryHeader-InvoiceDate IS NOT INITIAL.
            DATA: currentYear  TYPE string,
                  currentMonth TYPE string,
                  currentDate  TYPE string,
                  fyStart      TYPE string,
                  fyEnd        TYPE string,
                  numYear      TYPE i.

            currentYear  = entryHeader-EntryDate+0(4). "InvoiceDate
            currentMonth = entryHeader-EntryDate+4(2). "InvoiceDate
            currentDate  = entryHeader-EntryDate+6(2). "InvoiceDate
            numYear = currentYear.
            IF currentMonth >= '04'.  " April (04) to December (12)
              fyStart = currentYear && '0401'.   " YYYY-04-01
              numYear = numYear + 1.
              fyEnd   = numYear && '0331'.  " (YYYY+1)-03-31
            ELSE.  " January (01) to March (03)
              numYear = numYear - 1.
              fyStart = numYear && '0401'.  " (YYYY-1)-04-01
              fyEnd   = currentYear && '0331'.  " YYYY-03-31
            ENDIF.

*            current companycode
            SELECT SINGLE FROM I_PurchaseOrderAPI01 AS pur
            FIELDS pur~PurchasingOrganization
            WHERE pur~PurchaseOrder = @entryHeader-RefDocNo
            INTO @DATA(CompanyCode).


            SELECT SINGLE FROM I_PurchaseOrderAPI01 AS pur
            JOIN ZR_GateEntryLines AS EntryLines ON EntryLines~DocumentNo = pur~PurchaseOrder
            JOIN ZR_GateEntryHeader AS EntryHeader ON EntryLines~GateEntryNo = EntryHeader~GateEntryNo
            FIELDS pur~PurchasingOrganization
            WHERE EntryHeader~InvoiceNo = @entryHeader-InvoiceNo AND pur~PurchasingOrganization = @CompanyCode
                 AND EntryHeader~EntryDate BETWEEN @fyStart AND @fyEnd AND EntryHeader~InvoiceParty = @entryheader-InvoiceParty
*                 AND EntryHeader~InvoiceDate BETWEEN @fyStart AND @fyEnd AND EntryHeader~InvoiceParty = @entryheader-InvoiceParty
            INTO @DATA(CompanyCode2).

            IF CompanyCode2 IS NOT INITIAL.
              APPEND VALUE #( %tky = entryheader-%tky ) TO failed-gateentryheader.

              APPEND VALUE #( %tky = keys[ 1 ]-%tky
                         %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text = 'Party Bill No already used within the Organisation in a Year'
                         ) ) TO reported-gateentryheader.
            ENDIF.
            RETURN.
          ENDIF.

*
*        select from ZR_GateEntryHeader
*        fields GateEntryNo
*        where InvoiceNo = @entryHeader-InvoiceNo

          IF entryheader-Vehicleno = ''.
            APPEND VALUE #( %tky = entryheader-%tky ) TO failed-gateentryheader.

            APPEND VALUE #( %tky = keys[ 1 ]-%tky
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text = 'Vehicle No. is mandatory'
                            ) ) TO reported-gateentryheader.
            RETURN.

          ELSEIF entryheader-InvoiceParty = '' AND entryheader-EntryType = 'PUR' .
            APPEND VALUE #( %tky = entryheader-%tky ) TO failed-gateentryheader.

            APPEND VALUE #( %tky = keys[ 1 ]-%tky
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text = 'Invoicing Party is mandatory'
                            ) ) TO reported-gateentryheader.
            RETURN.
          ENDIF.

          DATA inv_party TYPE c LENGTH 10.

          inv_party = |{ entryheader-InvoiceParty ALPHA = IN }|.

          SELECT SINGLE FROM ZI_InvoiceParty_VH
          FIELDS InvoicingParty
          WHERE InvoicingParty = @inv_party
          INTO @DATA(lv_invoiceparty).

          IF entryheader-InvoiceParty NE '' AND lv_invoiceparty IS INITIAL .
            APPEND VALUE #( %tky = entryheader-%tky ) TO failed-gateentryheader.

            APPEND VALUE #( %tky = keys[ 1 ]-%tky
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text = 'Invoicing Party is not valid'
                            ) ) TO reported-gateentryheader.
            RETURN.
          ENDIF.

          SELECT SINGLE FROM I_PurchaseOrderAPI01
          FIELDS PurchaseOrderDate
          WHERE PurchaseOrder = @entryheader-RefDocNo
          INTO @DATA(lv_podate) PRIVILEGED ACCESS.

          IF entryHeader-EntryType = 'PUR' AND lv_podate IS NOT INITIAL AND entryheader-GateInDate < lv_podate.

            APPEND VALUE #( %tky = keys[ 1 ]-%tky
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text = 'Gate In Date Should not be less than PO Date.'
                              ) ) TO reported-gateentryheader.
            APPEND VALUE #( %tky = entryheader-%tky ) TO failed-gateentryheader.
            RETURN.
          ENDIF.

*      if entryheader-Plant = ''.
*        APPEND VALUE #( %tky = entryheader-%tky ) to failed-gateentryheader.
*
*        APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                        %msg = new_message_with_text(
*                                 severity = if_abap_behv_message=>severity-error
*                                 text = 'Plant field is mandatory'
*                        ) ) TO reported-gateentryheader.
*      endif.
*      if entryheader-Entrytype NE 'PUR' AND entryheader-Entrytype NE 'SRET'
*          AND entryheader-Entrytype NE 'JOB' AND entryheader-Entrytype NE 'SALES'.
*        APPEND VALUE #( %tky = entryheader-%tky ) to failed-gateentryheader.

*        APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                        %msg = new_message_with_text(
*                                 severity = if_abap_behv_message=>severity-error
*                                 text = 'Entrytype must be of Inward type (PUR, SRET, JOB)'
*                        ) ) TO reported-gateentryheader.
*      endif.

        ENDLOOP.

      ENDMETHOD.

      METHOD changeValues.
        READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
          ENTITY GateEntryHeader
            FIELDS ( Vehicleno Plant Entrytype )
              WITH CORRESPONDING #( keys )
              RESULT DATA(entryheaders).

        LOOP AT entryheaders INTO DATA(entryheader).

*    if entryheader-Grosswt is not INITIAL.
*
*       DATA(max_item_id) = '100001234'.
*
*      DATA: nr_number     TYPE cl_numberrange_runtime=>nr_number.
*      TRY.
*        cl_numberrange_runtime=>number_get(
*          EXPORTING
*            nr_range_nr = '02'
*            object      = 'ZRGATENUM'
*          IMPORTING
*            number      = DATA(nextnumber)
*        ).
*      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
*      ENDTRY.
*      SHIFT nextnumber LEFT DELETING LEADING '0'.
*      max_item_id = nextnumber.
**    ENDLOOP.
*
*      MODIFY ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
*        ENTITY GateEntryHeader
*        UPDATE
*        FIELDS ( Gateno ) WITH VALUE #( ( %tky = entryheader-%tky Gateno = nextnumber ) ).

          "assign Gate Entry no.
*    APPEND CORRESPONDING #( <entryheader> ) TO entryheaders ASSIGNING FIELD-SYMBOL(<mapped_gate_entry_header>).
*    IF <gate_entry_header>-Gateentryno IS INITIAL.
*"      max_item_id += 10.
*      <mapped_gate_entry_header>-Gateentryno = nextnumber.
*    ENDIF.
*    endif.

          DATA: gateoutwardval TYPE int1.
*      gateoutwardval = 1.
*      if entryheader-Entrytype = 'PUR' OR entryheader-Entrytype = 'SRET' OR entryheader-Entrytype = 'JOB'.
*      if entryheader-Entrytype = 'PUR' OR entryheader-Entrytype = 'RGP' OR entryheader-Entrytype = 'WREF'.
          gateoutwardval = 0.
*      else.
*        gateoutwardval = 1.
*      endif.
*      ENDIF.
          MODIFY ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
            ENTITY GateEntryHeader
            UPDATE
            FIELDS ( Gateoutward ) WITH VALUE #( ( %tky = entryheader-%tky Gateoutward = gateoutwardval ) ).

        ENDLOOP.

      ENDMETHOD.

*  METHOD ReCalcTotals.
*    READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
*      ENTITY GateEntryHeader
*      FIELDS ( Totallines )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_gateentry).
*
*    LOOP AT lt_gateentry ASSIGNING FIELD-SYMBOL(<fs_gateentry>).
*      <fs_gateentry>-Totallines = 0.
*
*      READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
*        ENTITY GateEntryHeader
*        by \_GateEntryLines
*        FIELDS ( Gateitemno )
*        WITH VALUE #( ( %tky = <fs_gateentry>-%tky ) )
*        RESULT DATA(lt_lines).
*
*      LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<fs_lines>).
*        <fs_gateentry>-Totallines = <fs_gateentry>-Totallines + 1.
*      ENDLOOP.
*
*
*      MODIFY ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
*        ENTITY GateEntryHeader
*        UPDATE
*        FIELDS ( Totallines ) WITH VALUE #( ( %tky = <fs_gateentry>-%tky Totallines = <fs_gateentry>-Totallines ) ).
*
*    ENDLOOP.
*
*    READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
*      ENTITY GateEntryHeader
*      FIELDS ( Totallines )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_gateentry1).
*
*"    MODIFY ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
*"    ENTITY GateEntryHeader
*"    UPDATE
*"    FIELDS ( Totallines )
*"    WITH VALUE #( FOR gateentry IN lt_gateentry ( %tky = gateentry-%tky Totallines = gateentry-Totallines ) ).
*
*
*  ENDMETHOD.

      METHOD precheck_update.
        LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entity>).
          CHECK <lfs_entity>-%control-Drivername EQ '01' OR <lfs_entity>-%control-Driverno EQ '01'.

          READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
          ENTITY GateEntryHeader
          FIELDS ( Drivername Driverno ) WITH VALUE #( ( %key = <lfs_entity>-%key ) )
          RESULT DATA(lt_gateheader).

          IF sy-subrc IS INITIAL.
            READ TABLE lt_gateheader ASSIGNING FIELD-SYMBOL(<lfs_driverdetail>) INDEX 1.
            IF sy-subrc IS INITIAL.
              <lfs_driverdetail>-Drivername = COND #( WHEN <lfs_entity>-%control-Drivername EQ '01' THEN
                                                        <lfs_entity>-Drivername ELSE <lfs_driverdetail>-Drivername ).

              <lfs_driverdetail>-Driverno = COND #( WHEN <lfs_entity>-%control-Driverno EQ '01' THEN
                                                        <lfs_entity>-Driverno ELSE <lfs_driverdetail>-Driverno ).

              IF ( <lfs_driverdetail>-Drivername = '' AND <lfs_driverdetail>-Driverno <> '' ) OR
                 ( <lfs_driverdetail>-Drivername <> '' AND <lfs_driverdetail>-Driverno = '' ).

                APPEND VALUE #( %tky = <lfs_driverdetail>-%tky ) TO failed-gateentryheader.

                APPEND VALUE #( %tky = <lfs_driverdetail>-%tky
                                %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text = 'Both Driver Name and Contact information must be blank or having a value.' )
                                ) TO reported-gateentryheader.

              ENDIF.

            ENDIF.
          ENDIF.

        ENDLOOP.

      ENDMETHOD.

      METHOD precheck_create.
        LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entity>).
          CHECK <lfs_entity>-%control-Drivername EQ '01' OR <lfs_entity>-%control-Driverno EQ '01'.

          IF ( <lfs_entity>-Drivername = '' AND <lfs_entity>-Driverno <> '' ) OR
             ( <lfs_entity>-Drivername <> '' AND <lfs_entity>-Driverno = '' ).

            "        APPEND VALUE #( %tky = <lfs_entity>-%key ) to failed-gateentryheader.

            APPEND VALUE #( "%tky = <lfs_entity>-%key
                            %msg = new_message_with_text(
                              severity = if_abap_behv_message=>severity-error
                              text = 'Both Driver Name and Contact information must be blank or having a value.' )
                              ) TO reported-gateentryheader.

          ENDIF.

        ENDLOOP.
      ENDMETHOD.



      METHOD get_global_authorizations.
        IF requested_authorizations-%update = if_abap_behv=>mk-on.
          "     OR requested_authorizations-%action-Edit
          IF is_update_allowed(  ) = abap_true.
            result-%update = if_abap_behv=>auth-allowed.
            "        result-%action-cancelGateEntry = if_abap_behv=>auth-allowed.
          ELSE.
            result-%update = if_abap_behv=>auth-unauthorized.
            "        result-%action-cancelGateEntry = if_abap_behv=>auth-unauthorized.
          ENDIF.
        ENDIF.
      ENDMETHOD.

      METHOD is_update_allowed.
        update_allowed = abap_true.
      ENDMETHOD.


      METHOD cancelMultiple.
        READ ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
          ENTITY GateEntryHeader
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(gateheaders)
          FAILED failed.

        SORT gateheaders BY Cancelled DESCENDING.
        LOOP AT gateheaders ASSIGNING FIELD-SYMBOL(<lfs_gateheader>).
          <lfs_gateheader>-Cancelled = lc_cancelled-yes.
        ENDLOOP.

        MODIFY ENTITIES OF ZR_GateEntryHeader IN LOCAL MODE
          ENTITY GateEntryHeader
          UPDATE FIELDS ( Cancelled ) WITH CORRESPONDING #( gateheaders ).


        APPEND VALUE #( %tky = <lfs_gateheader>-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-success
                          text = 'Gate Entries Cancelled.' )
                          ) TO reported-gateentryheader.

      ENDMETHOD.

    ENDCLASS.
