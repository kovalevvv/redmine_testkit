module RedmineTestkit
  module ProjectsHelperPatch

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :project_settings_tabs, :redmine_testkit
      end
    end

    module InstanceMethods
      def project_settings_tabs_with_redmine_testkit
        tabs = project_settings_tabs_without_redmine_testkit
        tabs << {:name => 'testkit_settings', :action => :manage_project_testkit_settings, :partial => 'projects/settings/testkit_settings',
                 :label => :label_testkit_settings} if User.current.allowed_to?(:manage_testkit_settings, @project)
        tabs
      end
    end
  end
end