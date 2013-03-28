class AddHandToGames < ActiveRecord::Migration
  def change
    add_column :games, :hand, :string
  end
end
