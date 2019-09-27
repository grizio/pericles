class AddAdditionalSwaggerDescription < ActiveRecord::Migration[5.1]
  def up
    add_column :routes, :additional_swagger_description, :jsonb, default: {}
  end

  def down
    remove_column :routes, :additional_swagger_description, :jsonb
  end
end
