class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.string :role
      t.text :content
      t.string :msg_type

      t.timestamps
    end
  end
end
