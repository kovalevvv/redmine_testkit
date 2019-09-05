module RedmineTestkit
  module ProjectsControllerPatch
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :helper, :attachments
    end

    module InstanceMethods
      def testkit_settings
        @project.update(params.require(:project).permit(testkit_setting_attributes: [:new_defect_tracker_id, :testcase_prefix]))
        @project.testkit_setting.save_templates(:test_plan => params[:test_plan], :test_report => params[:test_report])
        @project.testkit_setting.save_attachments(params[:attachments])
        @project.testkit_setting.attach_saved_attachments
        render_attachment_warning_if_needed(@project.testkit_setting)
        unless @project.testkit_setting.errors.present?
          flash[:notice] = l(:notice_successful_update)
        else
          flash[:error] = @project.testkit_setting.errors.full_messages.join(" ")
        end
        redirect_to settings_project_path(@project, :tab => 'testkit_settings')
      end

    end
  end
end
