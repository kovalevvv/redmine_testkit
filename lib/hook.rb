module RedmineTestkit
  class HookListener < Redmine::Hook::ViewListener
    render_on :view_projects_roadmap_version_bottom, :partial => 'hooks/view_projects_roadmap_version_bottom'
    render_on :view_issues_show_description_bottom, :partial => 'hooks/view_issues_show_description_bottom'
    render_on :view_versions_show_bottom, :partial => 'hooks/view_projects_roadmap_version_bottom'
    render_on :view_issues_new_top, :partial => 'hooks/view_issues_new_top'
    render_on :view_issues_form_details_top, :partial => 'hooks/view_issues_form_details_top'
    def controller_issues_new_before_save(context={})
      if context[:params][:testcase_id].present? && (testcase = Testcase.find(context[:params][:testcase_id]))
        context[:issue].found_in_testcase = testcase
      end
    end
  end
end