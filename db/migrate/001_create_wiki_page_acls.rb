class CreateWikiPageAcls < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_page_acls do |t|
      t.references :wiki_page, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true
      t.string :access_level, null: false, default: 'view'
      t.timestamps
    end

    add_index :wiki_page_acls, [:wiki_page_id, :user_id], unique: true
  end
end
