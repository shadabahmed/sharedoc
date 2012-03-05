class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name
      t.string :path
      t.boolean :migrated
      t.boolean :processed
      t.boolean :uploaded_to_s3

      t.timestamps
    end
  end
end
