module Cachex
  class Railtie < Rails::Railtie
    initializer 'cachex.view_helpers' do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
