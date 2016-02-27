class CreateJoinTableFacebookStatusFacebookSearch < ActiveRecord::Migration
  def change
    create_join_table :facebook_statuses, :facebook_searches do |t|
      # t.index [:facebook_status_id, :facebook_search_id]
      # t.index [:facebook_search_id, :facebook_status_id]
    end
  end
end
