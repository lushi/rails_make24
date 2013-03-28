class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :session_id
      t.string :deck
      t.integer :score

      t.timestamps
    end
  end
end
