CLASS zc_purchtest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZC_PURCHTEST IMPLEMENTATION.


    METHOD if_oo_adt_classrun~main.

*      DATA(migo) = ''.
*      DATA(purchaseorder) = ''.
*      DATA(update_line) = ''.
*      IF update_line = 'X'.
*        UPDATE zinv_mst SET migo_processed = 1, migo_no = @migo, error_log = ''
*                  WHERE po_no = @purchaseorder.
*      ENDIF.

        update zinv_mst set migo_no = '', migo_processed  = '', error_log = '',gate_entry_no = '', last_changed_at = '', po_no = '', po_processed = '',
               scrapbill = 'GT', imtype = 'S', imnoseries = 'S', reference_doc = '', reference_doc_del = '', reference_doc_invoice = '', processed = ''
        where imno in ( 'LD025100', 'LD025101'  ).

    ENDMETHOD.
ENDCLASS.
