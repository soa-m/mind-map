class CreateList < ActiveRecord::Migration[6.1]
  def change
    create_table "lists" do |t|
      t.string :name
      t.string :detail
      t.references :user
      t.integer :list_id
      t.timestamps null: false
    end
  end
end
