class AddSkuToAutoParts < ActiveRecord::Migration[7.2]
  def change
    add_column :auto_parts, :sku, :string, null: false
    add_index :auto_parts, :sku, unique: true
  end
end
