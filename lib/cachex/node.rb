module Cachex

  class Node
    attr_reader :key

    def initialize(key, tags=[])
      @children = []
      @key = key
      @tags = tags
    end

    def add_child(node)
      @children ||= []
      @children << node
    end

    def add_tags(additional_tags)
      @tags += additional_tags
    end

    def all_tags
      [@tags, @children.map(&:key), @children.map(&:all_tags)].flatten.compact.uniq
    end

  end

end
