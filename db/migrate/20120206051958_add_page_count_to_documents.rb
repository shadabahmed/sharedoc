class AddPageCountToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :page_count, :integer

  end
end
