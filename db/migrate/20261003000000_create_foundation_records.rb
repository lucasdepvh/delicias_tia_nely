class CreateFoundationRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :admins do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.timestamps
    end
    add_index :admins, :email, unique: true
    add_index :admins, :reset_password_token, unique: true

    create_table :store_settings do |t|
      t.string :singleton_key, null: false, default: "current"
      t.string :store_name, null: false, default: "Delícias da Tia Nely"
      t.string :whatsapp_number
      t.string :pix_key
      t.text :address
      t.text :business_hours
      t.text :order_message
      t.decimal :minimum_order_value, precision: 10, scale: 2, null: false, default: 0
      t.decimal :default_delivery_fee, precision: 10, scale: 2, null: false, default: 10
      t.text :pickup_policy
      t.string :instagram_url
      t.string :facebook_url
      t.boolean :accepting_orders, null: false, default: false
      t.text :pause_message, null: false, default: "No momento não estamos recebendo pedidos. Voltamos em breve."
      t.timestamps
    end
    add_index :store_settings, :singleton_key, unique: true
  end
end
