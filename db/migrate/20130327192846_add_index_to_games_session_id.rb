class AddIndexToGamesSessionId < ActiveRecord::Migration
  def change
  	add_index :games, :session_id, unique: true
  end
end