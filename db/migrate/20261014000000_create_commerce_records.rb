class CreateCommerceRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.string :title
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :product_images, [ :product_id, :position ]

    create_table :customers do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email
      t.string :zip_code
      t.string :street
      t.string :number
      t.string :neighborhood
      t.string :city
      t.string :state, limit: 2
      t.string :complement
      t.string :reference
      t.text :notes
      t.timestamps
    end
    add_index :customers, :phone, unique: true
    add_index :customers, :name

    create_table :delivery_areas do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.decimal :fee, precision: 10, scale: 2, null: false, default: 0
      t.string :estimated_time
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :delivery_areas, :slug, unique: true
    add_index :delivery_areas, :active

    create_table :discounts do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :discount_type, null: false
      t.decimal :value, precision: 10, scale: 2, null: false, default: 0
      t.decimal :minimum_order_value, precision: 10, scale: 2, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :usage_limit
      t.integer :uses_count, null: false, default: 0
      t.timestamps
    end
    add_index :discounts, :code, unique: true
    add_index :discounts, [ :active, :starts_at, :ends_at ]

    create_table :promotions do |t|
      t.string :name, null: false
      t.integer :required_quantity, null: false
      t.integer :gift_quantity, null: false, default: 0
      t.boolean :surprise_gift, null: false, default: false
      t.boolean :free_shipping, null: false, default: false
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :promotions, [ :active, :position ]

    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :delivery_area, foreign_key: true
      t.references :discount, foreign_key: true
      t.references :promotion, foreign_key: true
      t.string :number, null: false
      t.string :status, null: false, default: "pending"
      t.string :fulfillment_method, null: false, default: "pickup"
      t.string :payment_method, null: false, default: "pix"
      t.decimal :change_for, precision: 10, scale: 2
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :delivery_fee, precision: 10, scale: 2, null: false, default: 0
      t.decimal :discount_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.text :delivery_address
      t.text :notes
      t.boolean :stock_deducted, null: false, default: false
      t.timestamps
    end
    add_index :orders, :number, unique: true
    add_index :orders, [ :status, :created_at ]

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, foreign_key: true
      t.references :product_variant, foreign_key: true
      t.string :product_name, null: false
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.boolean :promotion_gift, null: false, default: false
      t.boolean :surprise_gift, null: false, default: false
      t.timestamps
    end

    create_table :stock_movements do |t|
      t.references :product, foreign_key: true
      t.references :product_variant, foreign_key: true
      t.references :order, foreign_key: true
      t.integer :quantity, null: false
      t.string :movement_type, null: false
      t.string :reason, null: false
      t.text :notes
      t.timestamps
    end
    add_index :stock_movements, [ :product_id, :created_at ]
    add_index :stock_movements, [ :product_variant_id, :created_at ]

    create_table :financial_entries do |t|
      t.references :order, foreign_key: true
      t.string :entry_type, null: false
      t.string :status, null: false, default: "pending"
      t.string :description, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :due_date
      t.date :paid_at
      t.boolean :automatic, null: false, default: false
      t.text :notes
      t.timestamps
    end
    add_index :financial_entries, [ :entry_type, :status, :due_date ]

    create_table :financial_entry_items do |t|
      t.references :financial_entry, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :product_variant, foreign_key: true
      t.string :product_name, null: false
      t.integer :quantity, null: false
      t.timestamps
    end

    create_table :personal_financial_entries do |t|
      t.string :description, null: false
      t.string :entry_type, null: false
      t.string :responsible, null: false
      t.string :category
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :due_date, null: false
      t.date :paid_at
      t.string :status, null: false, default: "pending"
      t.text :notes
      t.timestamps
    end
    add_index :personal_financial_entries, [ :status, :due_date ]
  end
end
