class AddTweetIdIndexToTweets < ActiveRecord::Migration[5.1]
  def change
    # add_index :tweets, :tweet_id, unique: true # 既に付いてた……この場合は db:migrate が失敗してハマるので、何もない migrate をして migrate を確定させる
  end
end
