@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'view entity for file log'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zr_filelog as select from zfilelog

{
    key down_date as DownDate,
    key versionnm as Versionnm,
    key filename as Filename,
    export_filename as ExportFilename,
    exported_by as ExportedBy,
    exported_timestamp as ExportedTimestamp,
    created_by as CreatedBy,
    created_at as CreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt
    
}
