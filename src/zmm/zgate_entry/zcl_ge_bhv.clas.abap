CLASS zcl_ge_bhv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GE_BHV IMPLEMENTATION.


 METHOD if_sadl_exit_calc_element_read~calculate.
   DATA: lt_GateEntryHeader TYPE STANDARD TABLE OF ZC_GateEntryHeader WITH DEFAULT KEY.
   lt_GateEntryHeader = CORRESPONDING #( it_original_data ).

   LOOP AT lt_GateEntryHeader ASSIGNING FIELD-SYMBOL(<lfs_progressors>).

     IF <lfs_progressors>-EntryType = 'PUR'.

       SELECT SINGLE FROM I_MaterialDocumentHeader_2 AS MTHead
       JOIN I_MaterialDocumentItem_2 AS MTDOCITem
       ON MTDOCITem~MaterialDocument = MTHead~MaterialDocument AND MTDOCITem~MaterialDocumentYear = MTHead~MaterialDocumentYear
       FIELDS MTHead~MaterialDocument, mthead~MaterialDocumentYear
       WHERE MTHead~MaterialDocumentHeaderText = @<lfs_progressors>-GateEntryNo AND MTDOCITem~GoodsMovementIsCancelled = '' AND MTDOCITem~GoodsMovementType = '101'
       INTO @DATA(grndoc).

       IF grndoc IS NOT INITIAL.
         <lfs_progressors>-UpdateAllowed = abap_false.
       ELSE.
         <lfs_progressors>-UpdateAllowed = abap_true.
       ENDIF.

     ELSEIF <lfs_progressors>-EntryType = 'RGP-IN'.
       SELECT SINGLE FROM ZR_GateEntryLines AS Lines
       JOIN ZR_GateEntryHeader AS Header ON Lines~DocumentNo = Header~GateEntryNo
       FIELDS Header~GateEntryNo
       WHERE Header~GateEntryNo = @<lfs_progressors>-GateEntryNo
       INTO @DATA(RGPEntry).

       IF RGPEntry IS NOT INITIAL.
         <lfs_progressors>-UpdateAllowed = abap_false.
       ELSE.
         <lfs_progressors>-UpdateAllowed = abap_true.
       ENDIF.
     ELSEIF <lfs_progressors>-EntryType = 'RGP-OUT' OR <lfs_progressors>-EntryType = 'NRGP'.
       IF <lfs_progressors>-GateOutDate IS NOT INITIAL .
         <lfs_progressors>-UpdateAllowed = abap_false.
       ELSE.
         <lfs_progressors>-UpdateAllowed = abap_true.

       ENDIF.
     ENDIF.

     ENDLOOP.
     ct_calculated_data = CORRESPONDING #( lt_gateentryheader ).

   ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
