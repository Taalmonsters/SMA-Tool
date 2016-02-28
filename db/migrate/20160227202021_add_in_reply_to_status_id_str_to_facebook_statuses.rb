class AddInReplyToStatusIdStrToFacebookStatuses < ActiveRecord::Migration
  def change
    add_column :facebook_statuses, :in_reply_to_status_id_str, :string
  end
end
