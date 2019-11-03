class CorrectSecurityScheme < ActiveRecord::Migration[5.0]
  def up
    add_column :security_schemes, :description, :string
    add_column :security_schemes, :scheme, :string
    add_column :security_schemes, :bearer_format, :string
    add_column :security_schemes, :flows, :jsonb, default: {}
    add_column :security_schemes, :open_id_connect_url, :string
    rename_column :security_schemes, :parameters, :specification_extensions

    create_table :security_scheme_assignments
    add_reference :security_scheme_assignments, :security_scheme, references: :security_schemes
    add_reference :security_scheme_assignments, :route, references: :routes

    execute(
      "INSERT INTO security_scheme_assignments (route_id, security_scheme_id) " +
      "SELECT id, security_scheme_id FROM routes WHERE security_scheme_id IS NOT NULL;"
    )

    remove_reference :routes, :security_scheme
  end

  def down
    add_reference :routes, :security_scheme, references: :security_schemes

    drop_table :security_scheme_assignments

    rename_column :security_schemes, :specification_extensions, :parameters
    remove_column :security_schemes, :open_id_connect_url
    remove_column :security_schemes, :flows
    remove_column :security_schemes, :bearer_format
    remove_column :security_schemes, :scheme
    remove_column :security_schemes, :description
  end
end
