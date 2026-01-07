CLASS zcl_cl_http_voucherprint DEFINITION

  PUBLIC

  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_http_service_extension.


    CLASS-DATA : comp TYPE string.
  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS: get_html RETURNING VALUE(ui_html) TYPE string,

      post_html IMPORTING
                          lv_belnr       TYPE string
                          lv_companycode TYPE string
                RETURNING VALUE(html)    TYPE string.
ENDCLASS.



CLASS ZCL_CL_HTTP_VOUCHERPRINT IMPLEMENTATION.


  METHOD get_html.

    TRY.
        DATA(user_formatted_name) = cl_abap_context_info=>get_user_formatted_name( ).
      CATCH cx_abap_context_info_error INTO DATA(lv_err).
        CLEAR lv_err.
    ENDTRY.

    DATA(system_date) = cl_abap_context_info=>get_system_date( ).

    DATA formatted_date TYPE string.
    DATA document_date TYPE string.
    formatted_date = system_date(4) && '-' && system_date+4(2) && '-' && system_date+6(2).

    DATA amount TYPE string.

    " Fetch data from the database

    SELECT FROM i_operationalacctgdocitem

           FIELDS AccountingDocument,CompanyCode,FiscalYear,AccountingDocumentItem,AccountingDocumentType,DocumentDate,AmountInTransactionCurrency

           WHERE AccountingDocumentItem = '001'

           INTO TABLE @DATA(it).

    DATA count TYPE string.

    count = lines( it ).

    " Prepare HTML with input field and button

    DATA(lv) = |<table border="1" style="border-collapse: collapse; width:97%; background-color: #2E2E2E; color: #FFFFFF; margin: 39px 19px;">|.

*    CONCATENATE lv '<tr style="background-color: #29313a; padding:12px;cursor: pointer;5rem 1rem;font-size: .875rem;">' INTO lv.
*
*    CONCATENATE lv '<th style="padding:12px">SL</th>' INTO lv.
*
*    CONCATENATE lv '<th>Accounting Document</th>' INTO lv.
*
*    CONCATENATE lv '<th>Company Code</th>' INTO lv.
*
*    CONCATENATE lv '<th>Fiscal Year</th>' INTO lv.
*
*    CONCATENATE lv '<th>Accounting Document Item</th>' INTO lv.
*
*    CONCATENATE lv '<th>Accounting Document Type</th>' INTO lv.
*
*    CONCATENATE lv '<th>Document Date</th>' INTO lv.
*
*    CONCATENATE lv '<th>Amount In Transaction Currency</th>' INTO lv.

    CONCATENATE lv '</tr>' INTO lv.

    LOOP AT it INTO DATA(line).

      amount = line-AmountInTransactionCurrency.
      document_date = line-DocumentDate(4) && '-' && line-DocumentDate+4(2) && '-' && line-DocumentDate+6(2). " Ensure yyyy-mm-dd format
      CONCATENATE lv '<tr onclick="selectRow(this)">' INTO lv.

*      CONCATENATE lv '<td style="background-color:#31363b;padding:5px"><input style ="border-color:white" type="radio" name="selection" class="radio-item" value="' line-accountingdocument '"/></td>' INTO lv.
*
*      CONCATENATE lv '<td style="background-color:#31363b;padding:5px">' line-accountingdocument '</td>' INTO lv.
*
*      CONCATENATE lv '<td style="background-color:#31363b;padding:5px">' line-companycode '</td>' INTO lv.
*
*      CONCATENATE lv '<td style="background-color:#31363b;padding:5px">' line-fiscalyear '</td>' INTO lv.
*
*      CONCATENATE lv '<td style="background-color:#31363b;padding:5px">' line-AccountingDocumentItem '</td>' INTO lv.
*
*      CONCATENATE lv '<td style="background-color:#31363b;padding:5px">' line-AccountingDocumentType '</td>' INTO lv.
*
*      CONCATENATE lv '<td style="background-color:#31363b;padding:5px">' document_date '</td>' INTO lv.
*
*      CONCATENATE lv '<td style="background-color:#31363b;padding:5px">' amount '</td>' INTO lv.

      CONCATENATE lv '</tr>' INTO lv.

    ENDLOOP.

    CONCATENATE lv '</table>' INTO lv.

    " Combine everything into the HTML output
    ui_html = |<html><head><title>General Information</title></head><body style="margin:0 ;background-color:#495767;">|.

    CONCATENATE ui_html
*                '<h1 style="font-size: 28px; margin: 0; font-weight: 300; text-align: center; background-color: #232f3e; color: white; padding: 15px; display: flex; align-items: center; justify-content: center;">'
*                '<img src="https://images.jdmagicbox.com/comp/kolkata/a6/033pxx33.xx33.110705140942.t1a6/catalogue/gtz-india-pvt-ltd-head-office-kolkata-gpo-kolkata-corporate-companies-k31ro1vvv5-250.jpg"'
*                ' alt="Logo" style="height: 50px; margin-right: 15px; position: absolute; left: 24px;width: 71px" />Accounting Document Print</h1>'
*                 '<div style="display:flex;justify-content: space-around;align-items: baseline;">'
*                 '<p style = "color:white ;font-size:17px">Today&#39;s Date : ' formatted_date '</p>'
*
*
**                 '<form action="/sap/bc/http/sap/ZHTTP_VOUCHER_PRINT" method="POST" target = _blank>'
*
*                 '<form action="/sap/bc/http/sap/ZCL_HTTP_VOUCHERPRINT" method="POST">'
*                 '<label style = "color:white;font-size:17px" for="belnr">Print Document Number</label>'
*                 '<input style="font-size:17px;padding:2px 3px;background:transparent;border:1px solid white;margin:4px;color: white;" type="text" id="belnr" name="belnr" required>'
*                 '<input style="font-size:14px;background-color:#1b8dec;padding:5px 17px;border-radius: 6px;cursor:pointer;border:none;color:white;font-weight:700;" type="submit" value="Print">'
*                 '</form>'
*                 '</div>'
*                 '<div style="display: flex;align-items: center;justify-content:space-around;">'
*                 '<div style="margin: 26px 0px">'
*                 '<label style = "color:white">Accounting Document : </label>'
*                 '<input style="padding:2px 3px;background:transparent;border:1px solid white;margin:4px;color: white;" type="text" id="accountingDocInput" />'
*                 '</div>'
*                 '<div style="margin: 2px 0px">'
*                 '<label style = "color:white">Document Date : </label>'
*                 '<input style="cursor:pointer;padding:3px 15px;background:transparent;border:1px solid white;margin:4px;color: white;" type="date" id="documentDateInput" />'
*                 '</div>'
*                 '<div style="margin: 2px 0px">'
*                 '<label style = "color:white">Accounting Document Type : </label>'
*                 '<select style="padding:2px 3px;background:transparent;border:1px solid white;margin:4px;color:white;" id="accountingDocTypeDropdown">'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="">Select</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="CV">CV - Cash Voucher</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="DG">DG - Customer Credit Note</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="DD">DD - Customer Debit Note</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="DZ">DZ - Money Receipt Voucher</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="SB">SB - Journal Voucher</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="RE">RE - Invoice - Gross</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="KR">KR - Vendor Invoice</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="KZ">KZ - Payment Voucher/Advice</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="KG">KG - Vendor Debit Note</option>'
*                 '<option style="background-color:#232f3e;color:white;cursor:pointer;" value="KC">KC - Vendor Credit Note</option>'
*                 '</select>'
*                 '</div>'
*                 '<button style="background-color:#1b8dec;padding:5px 17px;border-radius: 6px;cursor:pointer;border:none;color:white;font-weight:700;position: relative;" onclick="filterTable()">GO</button>'
*                 '</div>'
*                 '<h3 style="color: white;position: absolute;margin: 11px 24px;font-family: system-ui;"> Number of Lines : (&nbsp;' count ')</h3>'
*                 lv
*                 '<script>'
*                   'function selectRow(row) {'
*                   '    var radios = document.getElementsByClassName("radio-item");'
*                   '    for (var i = 0; i < radios.length; i++) {'
*                   '        radios[i].checked = false;'
*                   '    }'
*                   '    var selected = row.getElementsByTagName("input")[0];'
*                   '    if (selected) {'
*                   '        selected.checked = true;'
*                   '        document.getElementById("belnr").value = selected.value;'
*                   '    }'
*                   '}'
*                   'function filterTable() {'
*                   '    var docInput = document.getElementById("accountingDocInput").value.toLowerCase();'
*                   '    var typeDropdown = document.getElementById("accountingDocTypeDropdown").value.toLowerCase();'
*                   '    var docDateInput = document.getElementById("documentDateInput").value;'
*                   '    var rows = document.getElementsByTagName("tr");'
*                   '    var visibleRowCount = 0;'
*                   '    for (var i = 1; i < rows.length; i++) {'
*                   '        var cells = rows[i].getElementsByTagName("td");'
*                   '        if (cells.length > 0) {'
*                   '            var accDoc = cells[1].innerText.toLowerCase();'
*                   '            var accType = cells[5].innerText.toLowerCase();'
*                   '            var docDate = cells[6].innerText;'
*                   '            var matchesDocInput = !docInput || accDoc.indexOf(docInput) !== -1;'
*                   '            var matchesTypeDropdown = !typeDropdown || accType === typeDropdown;'
*                   '            var matchesDocDate = !docDateInput || docDate === docDateInput;'
*                   '            if (matchesDocInput && matchesTypeDropdown && matchesDocDate) {'
*                   '                rows[i].style.display = "";'
*                   '                visibleRowCount++;'
*                   '            } else {'
*                   '                rows[i].style.display = "none";'
*                   '            }'
*                   '        }'
*                   '    }'
*                   '    var lineCountElement = document.querySelector("h3");'
*                   '    if (lineCountElement) {'
*                   '        lineCountElement.innerHTML = Number of Lines : (&nbsp;${visibleRowCount}&nbsp;);'
*                   '    }'
*                   '}'
*                 '</script>'
               '</body></html>' INTO ui_html.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    DATA(req_method) = request->get_method( ).

    CASE req_method.


      WHEN CONV string( if_web_http_client=>get ).

        " Handle GET request

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        " Handle POST request

        DATA(lv_belnr) = request->get_form_field( `belnr` ).
        comp = request->get_form_field( `lv_companycode` ).


        response->set_text( post_html( lv_belnr = lv_belnr lv_companycode = comp ) ).
*         response->set_text( post_html( lv_belnr ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    DATA lv_belnr2 TYPE string.

    SELECT SINGLE FROM i_operationalacctgdocitem

      FIELDS AccountingDocument

      WHERE AccountingDocument = @lv_belnr AND CompanyCode = @comp

      INTO @lv_belnr2.

*    IF lv_belnr2 IS NOT INITIAL.

    TRY.

        " Construct HTML response with embedded PDF view

        DATA(pdf_content) = zcl_voucher_print=>read_posts( lv_belnr2 = lv_belnr lv_companycode = comp ).

        html = |{ pdf_content }|.
*           html = |<html><body><iframe src="data:application/pdf;base64,{ pdf_content }" width="100%" height="600px"></iframe></body></html>|.

*              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
*              response->set_text( pdf ).
      CATCH cx_static_check INTO DATA(er).
        CLEAR er.
*
*          html = |Accounting Document does not exist: { er->get_longtext( ) }|.
*
    ENDTRY.

*    ELSE.
*
*      html = |Accounting Document not found|.

*    ENDIF.

  ENDMETHOD.
ENDCLASS.
