class TestcaseStepsController < ApplicationController
  before_filter :find_project_by_project_id, :authorize
  before_filter :load_step
  helper :attachments

  def upload_form
  end

  def upload
    @step.save_attachments(params[:attachments])
    @step.save
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    if @step.attachments.include?(@attachment)
      @attachment.destroy
    else
      render js: "alert('Error!')"
    end
  end

  private

  def load_step
    @step = TestcaseStep.find(params[:testcase_step_id])
  end
end
