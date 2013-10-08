class Status < ActiveRecord::Base
  attr_accessible :body, :twitter_status_id, :twitter_user_id
  validates :body, :presence => true
  validates :twitter_status_id, :presence => true, :uniqueness => true
  validates :twitter_status_id, :presence => true

  belongs_to(
    :user,
    :class_name => "User",
    :foreign_key => :twitter_user_id,
    :primary_key => :twitter_user_id
  )

  def self.parse_twitter_params(status_json)
    status_info = JSON.parse(status_json)
    body = status_info["status"]["text"]
    status_id = status_info["status"]["id"]
    user_id = status_info["id_str"]
    status = Status.new({ :body => body,
                          :twitter_status_id => status_id,
                          :twitter_user_id => user_id
                        })
    status.save!
  end
end
