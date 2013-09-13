class BookActivity
  attr_reader	:b_id
  alias :id :b_id

  @key = 'book_activity'

  def self.setBookActivity(b_id, time)
    res = $redis.zadd(@key, time, b_id)
    return res
  end

  def self.getBookActivities
    res = $redis.zrevrange(@key, 0, -1, :withscores => true)
    return res
  end
end
