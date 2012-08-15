require 'cachex/adapters/redis_store'
require 'cachex/config'
require 'cachex/node'
require 'cachex/version'
require 'cachex/view_helpers'
require 'cachex/railtie'

module Cachex
  extend self

  def cache(context, key, tags=[], &block)
    if !@parent || @parent.key == 'root'
      @parent = Node.new('root') # avoiding to reuse same root
    end

    node = Node.new(key, tags)
    @parent.add_child node

    if !Rails.cache.exist?(key) || !adapter.redis.exists(fqkey(key))
      grandparent = @parent
      @parent = node
      content = context.capture(&block)
      Rails.cache.write(key, content)
      @parent = grandparent

      # two-way dependency binding
      adapter.redis.del fqkey(key)
      if (all_tags = node.all_tags).length > 0
        adapter.redis.sadd fqkey(key), all_tags
        all_tags.each do |tag|
          adapter.redis.sadd fqtag(tag), key
        end
      end

    else
      content = Rails.cache.read(key)
      node.add_tags adapter.redis.smembers(fqkey(key))
    end

    # Rails.logger.info "--- #{key} depends on #{node.all_tags.inspect}"

    content
  end


  def expire(*tags)
    tags.each do |tag|
      Rails.cache.delete tag

      adapter.redis.smembers(fqtag(tag)).each do |key|
        Rails.cache.delete key
      end
      adapter.redis.del fqtag(tag)
    end
  end


  def fqkey(key)
    "cachex_key_dependencies_#{key}"
  end

  def fqtag(tag)
    "cachex_tag_dependencies_#{tag}"
  end

  def adapter
    config.adapter
  end

end
