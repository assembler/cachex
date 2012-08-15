module Cachex
  module ViewHelpers
    def cachex(key, *tags, &block)
      Cachex.cache self, key, tags, &block
    end
  end
end
