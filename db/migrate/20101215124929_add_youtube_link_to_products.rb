class AddYoutubeLinkToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :youtube_link, :text
  end

  def self.down
    remove_column :products, :youtube_link
  end
end
