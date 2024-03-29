class User < ActiveRecord::Base
  attr_accessible :screen_name, :twitter_user_id
  validates :screen_name, :presence => true, :uniqueness => true
  validates :twitter_user_id, :presence => true, :uniqueness => true

  has_many(
    :statuses,
    :class_name => "Status",
    :foreign_key => :twitter_user_id,
    :primary_key => :twitter_user_id
  )

  def self.fetch_by_screen_name(screen_name)
    fetch_url = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/users/show.json",
      :query_values => {:screen_name => screen_name}
    ).to_s
    TwitterSession.get(fetch_url)
  end

  def self.parse_twitter_params(screen_name_json)
    user_info = JSON.parse(screen_name_json)
    user = User.new({:screen_name => user_info["screen_name"],
              :twitter_user_id =>user_info["id_str"].to_i})
    user.save!
  end

  def sync_statuses
    statuses = Status.fetch_statuses_for_user(self)

    twitter_status_ids = self.statuses
    twitter_status_ids = twitter_status_ids.map(&:twitter_status_id)

    statuses.each do |status|
      puts status.persisted?
      unless twitter_status_ids.include?(status.twitter_status_id)
        status.save!
      end
    end
  end
end
