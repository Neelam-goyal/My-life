class ZCL_HTTP_EWBBYIRNJSON definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_EWBBYIRNJSON IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
   CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).

        DATA: lv_bukrs TYPE ztable_irn-bukrs.
        DATA: lv_invoice TYPE ztable_irn-billingdocno.
        lv_bukrs = request->get_form_field( `companycode` ).
        lv_invoice = request->get_form_field( `document` ).
        DATA(payload) = zcl_http_ewaybillbyirn=>getpayload( companycode = lv_bukrs invoice = lv_invoice ).
        IF payload EQ '1'.
          response->set_text( 'IRN Not found' ).
          return.
        ENDIF.
        response->set_text( payload ).

    ENDCASE.
  endmethod.
ENDCLASS.
