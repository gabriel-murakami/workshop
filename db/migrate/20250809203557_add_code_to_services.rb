class AddCodeToServices < ActiveRecord::Migration[7.2]
  def change
    add_column :services, :code, :string, null: false
    add_index :services, :code, unique: true
  end
end
