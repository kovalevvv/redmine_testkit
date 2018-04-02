module RedmineTestkit
  class HookListener < Redmine::Hook::ViewListener
    render_on :view_projects_roadmap_version_bottom, :partial => 'hooks/view_projects_roadmap_version_bottom'
    render_on :view_issues_show_description_bottom, :partial => 'hooks/view_issues_show_description_bottom'
    render_on :view_versions_show_bottom, :partial => 'hooks/view_projects_roadmap_version_bottom'
  end
end