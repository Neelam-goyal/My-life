CLASS ztest_class_pr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_CLASS_PR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lv_SUPPLIER TYPE I_SupplierInvoiceAPI01-SupplierInvoice.
*    DATA: lv_COMP TYPE zpurchinvproc-companycode.
**  data: lv_line type zbillinglines-lineitemno.
    lv_SUPPLIER = '5105600315'.

*    lv_COMP = '0000'.
**      lv_line = '0000'.
    DELETE FROM zpurchinvlines WHERE supplierinvoice = @lv_supplier.
    DELETE FROM zpurchinvproc WHERE supplierinvoice = @lv_supplier.

    DELETE FROM zpurchinvlines WHERE supplierinvoice IS NOT INITIAL.
    DELETE FROM zpurchinvproc WHERE supplierinvoice IS NOT INITIAL.



***    DELETE FROM zpurchinvlines WHERE purchaseordertype = 'ZRET'.
***    DELETE FROM zpurchinvlines WHERE isreversed = 'X'.
***
***
***    SELECT FROM zpurchinvlines FIELDS companycode, fiscalyearvalue, supplierinvoice
***    WHERE deliverycost IS NOT INITIAL
***    INTO TABLE @DATA(it_dlrvycost) PRIVILEGED ACCESS.
***
***    LOOP AT it_dlrvycost INTO DATA(wa_dlvry).
***
***      DELETE FROM zpurchinvlines
***      WHERE companycode = @wa_dlvry-companycode
***      AND fiscalyearvalue = @wa_dlvry-fiscalyearvalue
***      AND supplierinvoice = @wa_dlvry-supplierinvoice.
***      COMMIT WORK.
***    ENDLOOP.
***
***
***    SELECT FROM zpurchinvproc AS a
***    LEFT JOIN zpurchinvlines AS b ON a~companycode = b~companycode AND a~fiscalyearvalue = b~fiscalyearvalue
***    AND a~supplierinvoice = b~supplierinvoice
***    FIELDS a~supplierinvoice, a~companycode, a~fiscalyearvalue, b~supplierinvoice AS suppinv2
****    WHERE b~supplierinvoice IS INITIAL
***    INTO TABLE @DATA(it_prhdr) PRIVILEGED ACCESS.
***
***    DELETE it_prhdr WHERE suppinv2 IS NOT INITIAL.
***
***    LOOP AT it_prhdr INTO DATA(wahdr).
***
***      SELECT SINGLE FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
***      FIELDS *
***      WHERE  a~FiscalYear = @wahdr-fiscalyearvalue
***      AND a~supplierinvoice = @wahdr-supplierinvoice
***      INTO @DATA(wa_supinvitem) PRIVILEGED ACCESS.
***
***      IF wa_supinvitem IS NOT INITIAL.
***        DELETE FROM zpurchinvproc
***        WHERE companycode = @wahdr-companycode
***        AND fiscalyearvalue = @wahdr-fiscalyearvalue
***        AND supplierinvoice = @wahdr-supplierinvoice.
***        COMMIT WORK.
***      ENDIF.
***
***    ENDLOOP.

    DATA lv_msg TYPE c LENGTH 20.
    lv_msg = 'jcbsk'.
    lv_msg = 'jcjkbsk'.

  ENDMETHOD.
ENDCLASS.
