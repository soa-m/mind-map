class AddCards < ActiveRecord::Migration[6.1]
  def change
    create_table "cards", force: :cascade do |t|
    t.string "content"
    t.integer "tag", default: 0
    t.integer "x", default: 0
    t.integer "y", default: 0
    t.boolean "generated", default: false
    t.boolean "base", default: false
    t.timestamps null: false
  end
  end
end
