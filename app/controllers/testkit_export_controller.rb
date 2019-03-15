class TestkitExportController < ApplicationController
  menu_item :testkit
  before_filter :find_project_by_project_id

  def make
    @report = Testkit.find(params[:testkit_id])
    begin
      docx_template = @report.get_word_template(type.to_sym)
      template = Sablon.template(File.expand_path(docx_template))
    rescue StandardError => e
      return render :not_found
    end

    context = {
      project: @project.name,
      report: @report.as_json
    }.merge!(:testcases => @report.testcases.as_json({:include => {:steps => {:methods => [:if_doc, :then_doc], :except => [:if, :then]}}, :methods => [:duration_text, :description_doc]}))

    begin    
      send_data template.render_to_string(context), filename: '%s-%s-%s-%s.docx' % [@project.name, I18n.t('word_template_'+type), @report.name, Date.current]
    rescue StandardError => e
      render_error :message => e.message
    end
  end

  private

  def type
    params.require(:type)
  end

end
