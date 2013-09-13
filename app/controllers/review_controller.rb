class ReviewController < ApplicationController
  before_action	:set_review, only: [:show, :get]
  protect_from_forgery :only => [:create, :update]

  def index
    reviews = Review.all(params[:b_id])
    render json: reviews, status: :ok
  end

  def show
    @review["b_id"] = params[:b_id]
  end

  def get
    render json: @review, status: :ok
  end

  def getReview b_id, r_id
    review = Review.find(b_id, r_id)
    return review.hgetReview
  end

  def addCm_idToReview(b_id, r_id, cm_id)
    review = Review.find(b_id, r_id)
    review.saddToCm_id(cm_id)
  end

  def update
    Log.debug(self, params, 'begin')
    review = Review.find(params[:b_id], params[:r_id])
    params['r_time'] = Time.now
    hash_args = CommonMethods.makeArgs(params, *Review.fields)
    review_hash = review.hmset(*hash_args)
    render json: nil ,status: :ok
    Log.debug(self, params, 'end')
  end
   
  def create
    Log.debug(self, params, 'begin')
    params['r_time'] = Time.now
    b_id = params['b_id']
    review = Review.new(b_id)
    hash_args = CommonMethods.makeArgs(params, *Review.fields)
    review_hash = review.hmset(*hash_args)
    if review.save
      render json: review_hash, status: :created
    end
    review_hash["b_id"] = b_id
    review_hash["type"] = 'review'
    review_hash["f_time"] = review_hash["r_time"]
    book = BooksController.new
    book.review b_id, review_hash["r_id"]
    feed = FeedController.new
    feed.createFeedWithHash review_hash
    Log.debug(self, params, 'end')
  end

  private
    def set_review
      b_id = params[:b_id]
      r_id = params[:r_id]
      review = Review.find(b_id, r_id)
      @review = review.hgetall
    end
end
