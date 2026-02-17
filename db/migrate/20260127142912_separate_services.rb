class SeparateServices < ActiveRecord::Migration[7.2]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # --- Catalog service ---
    create_table :services, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :name, null: false
      t.text :description
      t.decimal :base_price, precision: 10, scale: 2, null: false, default: 0
      t.timestamps
    end

    create_table :products, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :sku, null: false, index: { unique: true }
      t.string :name, null: false
      t.text :description
      t.integer :stock_quantity, null: false, default: 0
      t.decimal :base_price, precision: 10, scale: 2, null: false, default: 0
      t.timestamps
    end

    create_table :metrics, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.integer :service_order_count, default: 0
      t.decimal :average_time, default: 0
      t.timestamps
    end

    # --- Service Orders service ---
    create_table :users, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :document_number, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :service_orders, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :customer_id, null: false
      t.uuid :vehicle_id, null: false

      t.datetime :service_started_at
      t.datetime :service_finished_at
      t.string :status, null: false, default: "received"
      t.text :description
      t.timestamps

      t.index :customer_id
      t.index :vehicle_id
    end

    create_table :budgets, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :service_order, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      t.date :date, null: false
      t.decimal :total_value, precision: 12, scale: 2, null: false, default: 0
      t.string :status, null: false, default: "pending"
      t.timestamps
    end

    create_table :service_order_items, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :service_order, type: :uuid, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.string :item_kind, null: false
      t.uuid :item_id, null: false
      t.string :item_name, null: false
      t.string :item_code, null: false
      t.decimal :unit_price, precision: 12, scale: 2, null: false, default: 0
      t.decimal :total_value, precision: 12, scale: 2, null: false, default: 0

      t.timestamps

      t.index [ :item_kind, :item_id ]
    end
  end
end
