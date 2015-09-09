class AddAttachmentsImage1Image2Image3AndImage4ToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :image_1_file_name, :string
    add_column :products, :image_1_content_type, :string
    add_column :products, :image_1_file_size, :integer
    add_column :products, :image_1_updated_at, :datetime
    add_column :products, :image_1_alt, :string
    add_column :products, :image_2_file_name, :string
    add_column :products, :image_2_content_type, :string
    add_column :products, :image_2_file_size, :integer
    add_column :products, :image_2_updated_at, :datetime
    add_column :products, :image_2_alt, :string
    add_column :products, :image_3_file_name, :string
    add_column :products, :image_3_content_type, :string
    add_column :products, :image_3_file_size, :integer
    add_column :products, :image_3_updated_at, :datetime
    add_column :products, :image_3_alt, :string
    add_column :products, :image_4_file_name, :string
    add_column :products, :image_4_content_type, :string
    add_column :products, :image_4_file_size, :integer
    add_column :products, :image_4_updated_at, :datetime
    add_column :products, :image_4_alt, :string
  end

  def self.down
    remove_column :products, :image_1_file_name
    remove_column :products, :image_1_content_type
    remove_column :products, :image_1_file_size
    remove_column :products, :image_1_updated_at
    remove_column :products, :image_1_alt
    remove_column :products, :image_2_file_name
    remove_column :products, :image_2_content_type
    remove_column :products, :image_2_file_size
    remove_column :products, :image_2_updated_at
    remove_column :products, :image_2_alt
    remove_column :products, :image_3_file_name
    remove_column :products, :image_3_content_type
    remove_column :products, :image_3_file_size
    remove_column :products, :image_3_updated_at
    remove_column :products, :image_3_alt
    remove_column :products, :image_4_file_name
    remove_column :products, :image_4_content_type
    remove_column :products, :image_4_file_size
    remove_column :products, :image_4_updated_at
    remove_column :products, :image_4_alt
  end
end
