class CreateMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :metrics, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.integer :service_order_count, default: 0
      t.decimal :average_time, default: 0

      t.timestamps
    end
  end
end
