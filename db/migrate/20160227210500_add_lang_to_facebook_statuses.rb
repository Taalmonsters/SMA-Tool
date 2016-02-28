class AddLangToFacebookStatuses < ActiveRecord::Migration
  def change
    add_column :facebook_statuses, :lang, :string
  end
end
