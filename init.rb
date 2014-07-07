require 'redmine'

Rails.configuration.to_prepare do
  Dir.glob File.expand_path('../lib/rdb/patches/**/*.rb', __FILE__) do |patch|
    require_dependency patch
  end

  ActiveSupport::Dependencies
    .autoload_paths << File.expand_path('../', __FILE__)

  require 'rdb/sprockets/helpers'
  require 'rdb/assets'

  RDB_ASSET_ENVIRONMENT = ::Sprockets::Environment.new(File.dirname(__FILE__))
  Rdb::Assets.setup(RDB_ASSET_ENVIRONMENT)

  ActiveSupport.on_load(:action_view) do
    include Rdb::Sprockets::Helpers::TagHelper
    include Rdb::Sprockets::Helpers::ViewHelper
  end
end

Redmine::Plugin.register :redmine_dashboard do
  name 'Redmine Dashboard plugin'
  author 'Jan Graichen'
  description 'Add a task board and a planning board to Redmine'
  version '3.0.dev1'
  url 'https://github.com/jgraichen/redmine_dashboard'
  author_url 'mailto:jg@altimos.de'

  requires_redmine version_or_higher: '2.1'

  project_module :dashboard do
    permission :view_dashboards,
      rdb_boards: [:index, :show, :update],
      rdb_user_boards: [:index],
      rdb_project_boards: [:index]

    permission :configure_dashboards,
      rdb_boards: [:create]
  end

  menu :project_menu, :rdb_project_dashboards,
    {controller: 'rdb_project_boards', action: 'index'},
    caption: :'rdb.menu.dashboards', after: :new_issue
  # menu :account_menu, :rdb_my_dashboards,
  #   {controller: 'rdb_user_boards', action: 'index'},
  #   caption: :'rdb.menu.my_dashboards', after: :my_account

end
