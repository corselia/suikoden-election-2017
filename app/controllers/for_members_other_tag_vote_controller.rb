class ForMembersOtherTagVoteController < ApplicationController
  protect_from_forgery with: :null_session # HACK: よく勉強しないと危険
  include TweetsJoinUsers
  include SelectTweetsByHashtag
  include ForGetMethodAtMembers
  include ForPostMethodAtMembers
  layout 'application_members'

  def index
    authenticate_or_request_with_http_basic("Hello, gensosenkyo staff!") do |username, password|
      username == Rails.application.secrets.members_page_auth_username && password == Rails.application.secrets.members_page_auth_password
    end

    for_get_method if request.get?
    for_post_method(params[:search_word]) if request.post?
  end

  def for_get_method
    # ex. https://twitter.com/nyaka_y/status/874979736308416512
    all_records = Hashtag.all.map { |rec| rec.attributes }
    @all_rec_tweet_ids = []
    all_records.each do |record|
      @all_rec_tweet_ids << record["tweet_id"]
    end

    tag_records = Hashtag.where(tagname: "幻水総選挙2017").map { |rec| rec.attributes }
    @tag_rec_tweet_ids = []
    tag_records.each do |record|
      @tag_rec_tweet_ids << record["tweet_id"]
    end

    @result_ids = []
    @tag_rec_tweet_ids.each do |tweet_id|
      if @all_rec_tweet_ids.count(tweet_id) == 1
        @result_ids << tweet_id
      end
    end

    tomochin = without_retweets_and_gensosenkyo_loose_limited_period # Array
    # tomochin[0].tweet_id

    # @result_ids の tweet_id の Tweetクラス を採用したい
    result_tweets = tomochin.select do |element|
      @result_ids.include?(element.tweet_id)
    end

    # TODO: コントローラに詰め込みすぎだし NOT DRY
    unreadable_tweet_ids = IsReadableTweet.where(is_readable: false)
    @removed_tweet_ids = []
    unreadable_tweet_ids.each do |tweet|
      @removed_tweet_ids << tweet.tweet_id
    end

    # 削除済みツイートを取り除く
    last_result_tweets = result_tweets.reject do |element|
      @removed_tweet_ids.include?(element.tweet_id)
    end

    @kaminari_page_per = 20
    @kaminaried_tweets = Kaminari.paginate_array(last_result_tweets.reverse).page(params[:page]).per(@kaminari_page_per) # HACK: 個別に設定を決めないようにする
  end

  def for_post_method(search_word)
    # ex. https://twitter.com/nyaka_y/status/874979736308416512
    all_records = Hashtag.all.map { |rec| rec.attributes }
    @all_rec_tweet_ids = []
    all_records.each do |record|
      @all_rec_tweet_ids << record["tweet_id"]
    end

    tag_records = Hashtag.where(tagname: "幻水総選挙2017").map { |rec| rec.attributes }
    @tag_rec_tweet_ids = []
    tag_records.each do |record|
      @tag_rec_tweet_ids << record["tweet_id"]
    end

    @result_ids = []
    @tag_rec_tweet_ids.each do |tweet_id|
      if @all_rec_tweet_ids.count(tweet_id) == 1
        @result_ids << tweet_id
      end
    end

    tomochin = without_retweets_and_gensosenkyo_loose_limited_period # Array
    # tomochin[0].tweet_id

    # @result_ids の tweet_id の Tweetクラス を採用したい
    result_tweets = tomochin.select do |element|
      @result_ids.include?(element.tweet_id)
    end

    # TODO: コントローラに詰め込みすぎだし NOT DRY
    unreadable_tweet_ids = IsReadableTweet.where(is_readable: false)
    @removed_tweet_ids = []
    unreadable_tweet_ids.each do |tweet|
      @removed_tweet_ids << tweet.tweet_id
    end

    # 削除済みツイートを取り除く
    last_result_tweets = result_tweets.reject do |element|
      @removed_tweet_ids.include?(element.tweet_id)
    end

    # この時点で last_result_tweets は Array（Tweet であり ActiveRecord ではない）
    @lastest_result_tweets = []
    last_result_tweets.select do |element|
      @lastest_result_tweets << element if element.text =~ /.*#{search_word}.*/
    end

    @kaminari_page_per = 20
    @kaminaried_tweets = Kaminari.paginate_array(@lastest_result_tweets.reverse).page(params[:page]).per(@kaminari_page_per) # HACK: 個別に設定を決めないようにする
  end
end
