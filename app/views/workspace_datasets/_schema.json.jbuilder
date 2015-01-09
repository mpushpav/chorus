json.set! title do
  json.id schema.id
  json.name schema.name
  json.dataset_count schema.active_tables_and_views_count
  json.refreshed_at schema.refreshed_at
  json.entity_type schema.entity_type_name
  json.is_deleted schema.deleted?
  json.stale schema.stale?
  db_partial = schema.database.class.name.underscore
  json.partial! db_partial, database: schema.database , options: options
  json.complete_json true
end
