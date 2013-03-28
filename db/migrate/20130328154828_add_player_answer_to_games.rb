class AddPlayerAnswerToGames < ActiveRecord::Migration
  def change
    add_column :games, :player_answer, :string
  end
end
