class CreateInitialTables < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :document_number, null: false, index: { unique: true }
      t.string :email
      t.string :phone

      t.timestamps
    end

    create_table :vehicles do |t|
      t.references :customer, foreign_key: true
      t.string :license_plate, null: false, index: { unique: true }
      t.string :brand
      t.string :model
      t.integer :year

      t.timestamps
    end

    create_table :service_orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.datetime :service_started_at
      t.datetime :service_finished_at
      t.string :status, null: false, default: "open"
      t.text :description

      t.timestamps
    end

    create_table :budgets do |t|
      t.references :service_order, null: false, foreign_key: true, index: { unique: true }
      t.date :date, null: false
      t.decimal :total_value, precision: 12, scale: 2, null: false, default: 0
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    create_table :services do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :base_price, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end

    create_table :auto_parts do |t|
      t.string :name, null: false
      t.text :description
      t.integer :stock_quantity, null: false, default: 0
      t.decimal :base_price, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end

    create_table :service_order_items do |t|
      t.references :service_order, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.references :item, polymorphic: true, null: false

      t.timestamps
    end
  end
end
