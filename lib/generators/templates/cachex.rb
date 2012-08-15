Cachex.config do |c|
  c.adapter = :redis
  c.adapter.redis = Redis.new(host: '127.0.0.1', port: '6379')
end
