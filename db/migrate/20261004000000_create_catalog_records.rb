class CreateCatalogRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :categories, :slug, unique: true
    add_index :categories, [:active, :position]

    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.boolean :featured, null: false, default: false
      t.boolean :track_inventory, null: false, default: false
      t.integer :quantity, null: false, default: 0
      t.integer :low_stock_threshold, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, [:category_id, :active, :position]

    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2
      t.boolean :active, null: false, default: true
      t.integer :quantity, null: false, default: 0
      t.integer :low_stock_threshold, null: false, default: 0
      t.timestamps
    end
    add_index :product_variants, [:product_id, :active]
  end
end
