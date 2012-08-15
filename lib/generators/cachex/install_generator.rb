module Cachex

  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../templates", __FILE__)

    desc "Copies initializer script"
    def copy_initializer
      copy_file "cachex.rb", "config/initializers/cachex.rb"
    end
  end

end
