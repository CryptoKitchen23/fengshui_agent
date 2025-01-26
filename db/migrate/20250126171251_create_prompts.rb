class CreatePrompts < ActiveRecord::Migration[7.1]
  def change
    create_table :prompts do |t|
      t.string :role
      t.text :content
      t.integer :version

      t.timestamps
    end
  end
end
