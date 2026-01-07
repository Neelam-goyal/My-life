CLASS zsalescycle_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
     INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
  DATA: lv_imno TYPE zinv_mst-imno VALUE ''.
   DATA: lv_imno1 TYPE zinv_mst-imno VALUE ''.
   DATA: lv_idno TYPE zdt_usdatamst1-imno VALUE ''.
      DATA: lv_idno1 TYPE zdt_usdatamst1-imno VALUE ''.
   data: check type i value '0'.

ENDCLASS.



CLASS ZSALESCYCLE_DELETE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*
*data: lv_VariableDelete type string.
*  lv_variabledelete = 'reference_doc_del'.


if check = 1.
    UPDATE zinv_mst
    set processed = '',
    reference_doc = '',
    reference_doc_del = '',
    status = '',
    datavalidated = 0,
    error_log = ''
    where imno ge @lv_imno and imno le @lv_imno1.

elseif check = 2 .
    UPDATE zdt_usdatamst1
    set processed = '',
    reference_doc = '',
    reference_doc_del = '',
    status = '',
    datavalidated = 0,
    error_log = ''
    where imno ge @lv_idno and imno le @lv_idno1 .

elseif check = 3.

    UPDATE zinvoicedatatab1
    set processed = '',
    error_log = ''
    where idno ge @lv_imno and idno le @lv_imno1.

elseif check = 4.

    UPDATE zdt_usdatadata1
    set processed = '',
    error_log = ''
    where idno ge @lv_idno and idno le @lv_idno1.

elseif check = 5.
     delete from zinvoicedatatab1 where idno ge @lv_imno and idno le @lv_imno1 and idprdcode = '000000001400000030'.


elseif check = 6.
      delete from zdt_usdatadata1 where idno ge @lv_idno and idno le @lv_idno1  and idprdcode = '000000001400000030'.


elseif check = 7.
      delete from zinv_mst where imno ge @lv_imno and imno le @lv_imno1.

elseif check = 8.
      delete from  zinvoicedatatab1 where idno ge @lv_imno and idno le @lv_imno1.

elseif check = 9.
      delete from zinv_mst where imno eq @lv_imno.

elseif check = 11.
   UPDATE zinv_mst
SET
    reference_doc_invoice = '',
    invoiceamount = ''
where imno eq @lv_imno.

elseif check = 13.
   UPDATE zinv_mst
SET
    reference_doc_del  = ''
where imno eq @lv_imno.

elseif check = 12.
delete from zinvoicedatatab1 where idno eq @lv_imno and idprdcode = '000000001400000023'.


elseif check = 10.
      delete from  zinvoicedatatab1 where idno eq @lv_imno.

endif.

  ENDMETHOD.
ENDCLASS.
