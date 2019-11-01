class TestkitExportController < ApplicationController
  menu_item :testkit
  before_filter :find_project_by_project_id

  def make
    @report = Testkit.find(params[:testkit_id])
    begin
      docx_template = @project.testkit_setting.get_template(type)
      template = Sablon.template(File.expand_path(docx_template[:file]))
    rescue StandardError => e
      return render :not_found
    end
    context = @report.context
    begin
      send_data template.render_to_string(context), filename: '%s-%s-%s-%s.docx' % [@project.name, docx_template[:title], @report.name, Date.current]
    rescue StandardError => e
      render_error :message => e.message
    end
  end

  private

  def type
    params.require(:type)
  end

end
