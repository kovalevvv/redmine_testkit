module RedmineTestkit
  module ProjectsControllerPatch
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def testkit_settings
        @project.update(params.require(:project).permit(testkit_settings_attributes: :new_defect_tracker_id))
        flash[:notice] = l(:notice_successful_update)
        redirect_to settings_project_path(@project, :tab => 'testkit_settings')
      end

    end
  end
end
