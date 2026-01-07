@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VH for User'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.resultSet.sizeCategory: #XS
define view entity zr_user_vh
  as select from I_User
  //composition of target_data_source_name as _association_name
{
      @ObjectModel.text.element: [ 'UserDescription' ]
      @UI.textArrangement: #TEXT_FIRST
  key UserID,
      UserDescription
}
