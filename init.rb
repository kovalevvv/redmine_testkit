require_dependency 'hook'

Rails.application.config.to_prepare do
  unless Issue.include?(RedmineTestkit::IssuePatch)
    Issue.send(:include, RedmineTestkit::IssuePatch)
    Version.send(:include, RedmineTestkit::VersionPatch)
    AutoCompletesController.send(:include, RedmineTestkit::AutoCompletesControllerPatch)
  end
end

Redmine::Plugin.register :redmine_testkit do
  name 'Redmine Testkit plugin'
  author 'Vladimir Kovalev'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  project_module :testkit do
    permission :view_testkits, :testkits => :index
    permission :create_and_edit_testkits, :testkits => [:tree, :new, :create, :edit, :update]
    permission :create_and_edit_runs, :testkits => [:new_run, :create_run, :edit_run, :update_run]
    permission :pass_runs, {:testkits => [:pass_run], :testcase_steps => [:upload_form, :upload, :destroy]}
    permission :view_testcases, {:testcases => [:index, :show], :testcase_folders => [:tree, :node_menu]}
    permission :add_and_edit_testcases, {:testcases => [:new, :create, :edit, :update], :testcase_folders => [:new, :create, :edit, :update, :destroy]}
    permission :view_testkit_envs, :testkit_envs => :index
    permission :manage_testkit_envs, :testkit_envs => [:new, :create, :edit, :update, :destroy]
    permission :view_reports, :testkits => [:index_reports, :show_report]
    permission :testkits_archive, :testkits => :index_archive
    permission :delete_testcases, :testcases => :destroy
    permission :delete_templates, :testkits => :destroy
    permission :delete_runs, :testkits => :destroy
  end

  menu :project_menu, :testkit, { :controller => 'testkits', :action => 'index' }, :caption => :label_testkit, :after => :board, :param => :project_id
end
