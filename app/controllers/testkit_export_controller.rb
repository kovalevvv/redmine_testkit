class TestkitExportController < ApplicationController
  menu_item :testkit
  before_filter :find_project_by_project_id

  def make
    @report = Testkit.find(params[:testkit_id])
    begin
      docx_template = find_template(params[:type].to_sym)
    rescue Exception => error
      return render :not_found
    end

    template = Sablon.template(File.expand_path(docx_template))

    context = {
      project: @project.name,
      report: @report.as_json
    }
    context.merge!(:testcases => @report.testcases.as_json({:include => {:steps => {:methods => [:index, :if_doc, :then_doc], :except => [:if, :then]}}, :methods => :duration_text}))    
    send_data template.render_to_string(context), filename: '%s-%s-%s-%s.docx' % [@project.name, avaliable_types[params[:type].to_sym][:name], @report.name, Date.current]
  end

  private 

  def avaliable_types
    {
      :ps => {filename: 'ps.docx', name: 'Протокол тестирования'},
      :pmi => {filename: 'pmi.docx', name: 'ПМИ'}
    }
  end

  def find_template(type)
    lookup_context.find_template("#{controller_path}/#{avaliable_types[type][:filename]}").identifier
  end

end
