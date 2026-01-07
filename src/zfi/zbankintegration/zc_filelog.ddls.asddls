@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection View for file log'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zc_filelog as projection on zr_filelog
{
    key DownDate,
    key Versionnm,
    key Filename,
    ExportFilename,
    ExportedBy,
    ExportedTimestamp,
    CreatedBy,
    CreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt
}
