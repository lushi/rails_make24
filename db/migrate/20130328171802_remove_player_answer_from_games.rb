class RemovePlayerAnswerFromGames < ActiveRecord::Migration
  def up
  	add_column :games, :player_answer, :string
  end

  def down
		remove_column :games, :player_answer
  end
end
