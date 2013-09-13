class DisplaynewsfeedController < ApplicationController
  before_action	:set_feed, only: [:show, :get]
  protect_from_forgery :only => [:setDisplayNewsfeed]

  def index
    @feeds = DisplayNewsfeed.all
  end

  def show
  end

  def copyFeedsFromFollower hash
    Log.debug(self, hash, 'begin')
    u_id = hash['u_id']
    fr_id = hash['fr_id']
    own = OwnnewsfeedController.new
    u_feed = own.getOwnNewsfeed fr_id
    display = DisplayNewsfeed.find u_id
    if u_feed.size > 0
      display.sadd(u_feed)
    end
    Log.debug(self, hash, 'end')
  end

  def removeFeedsFromFollower hash
    Log.debug(self, hash, 'begin')
    u_id = hash['u_id']
    fr_id = hash['fr_id']
    own = OwnnewsfeedController.new
    u_feed = own.getOwnNewsfeed fr_id
    display = DisplayNewsfeed.find u_id
    if u_feed.size > 0
      display.srem(u_feed)
    end
    Log.debug(self, hash, 'end')
  end

  def setDisplayNewsfeed hash
    Log.debug(self, hash, 'begin')
    followings = UserDetail.find(hash['u_id']).u_followings
    fr_id = hash['fr_id']
    f_id = hash['f_id']

    followings.each do |following|
      if following != fr_id
        display = DisplayNewsfeed.find following
        display.sadd(f_id)
      end
    end
    Log.debug(self, hash, 'end')
  end

  def get
    feeds = @feed["feeds"]
    feedController = FeedController.new
    reviewController = ReviewController.new
    commentController = CommentController.new
    userController = UsersController.new
    feed_array = feedController.getFeeds *feeds
    return_array = Array.new
    feed_array.each do |feed_hash|
      type = feed_hash["type"]
      if (type == 'comment' or type == 'enroll' or type == 'review')
        hash = Hash.new
        hash['f_id'] = feed_hash['f_id']
        hash["type"] = type
        user = Hash.new
        user_info = userController.userview2 feed_hash['u_id']
        #user_info = User.find(feed_hash['u_id'])
        hash["user"] = user_info
        #book_detail_info = BookDetail.find('522358a16569516009000125')
        book_detail_info = BookDetail.find(feed_hash['b_id'])
        book_info = Book.find(feed_hash['b_id'])
        book_info['b_category'] = book_detail_info['b_category']
        book_info['b_author'] = book_detail_info['b_author']
        book_info['b_translator'] = book_detail_info['b_translator']
        book_info['b_publisher'] = book_detail_info['b_publisher']
        book_info['b_publishData'] = book_detail_info['b_publishData']
        hash["book"] = book_info
        if (type == 'review' or type == 'comment')
          review = Hash.new
          review["id"] = feed_hash["r_id"]
          review_array = reviewController.getReview feed_hash["b_id"], feed_hash["r_id"]
          review_user = userController.userview2 review_array[0]
          review["r_review"] = review_array[1]
          review["r_time"] = review_array[2]
          hash["review"] = review
          hash["review_user"] = review_user
        end
        if (type == 'comment')
          comment = Hash.new
          comment["id"] = feed_hash["cm_id"]
          comment_array = commentController.getComment feed_hash["b_id"], feed_hash["r_id"], feed_hash["cm_id"]
          comment_user = userController.userview2 comment_array[0]
          comment["cm_comment"] = comment_array[1]
          comment["cm_time"] = comment_array[2]
          hash["comment"] = comment
          hash["comment_user"] = comment_user
        end
        return_array << hash
      end
    end 
    render json: return_array, status: :ok
  end

  private
    def set_feed
      u_id = params[:id]
      display = DisplayNewsfeed.find(u_id)
      @feed = display.smembers
    end
end
