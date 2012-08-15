module Cachex

  def self.config
    if !@config
      @config = Config.new
      yield @config
    end
    @config
  end

  class Config
    attr_reader :adapter

    def adapter=(adapter)
      case adapter.to_sym
      when :redis
        @adapter = Adapters::RedisStore.new
      else
        raise ArgumentError, "Specified Cachex adapter is not supported!"
      end
    end

  end
end
