class TestcasesController < ApplicationController
  menu_item :testkit
  before_filter :find_project_by_project_id, :authorize
  before_filter :find_testcase, :only => [:show, :edit, :update, :destroy]
  before_filter :find_attachments, :only => [:preview, :edit, :show]
  helper :attachments

  def index
  end

  def new
    if params[:copy_from]
      begin
        @copy_from = Testcase.find(params[:copy_from])
        @testcase = Testcase.new(@copy_from.attributes.except('id', 'created_at', 'updated_at', 'author_id', 'name'))
        @testcase.name = "#{@copy_from.name} (#{l(:label_copied)}: #{@copy_from.name_with_id})"
        @copy_from.steps.each do |step|
          @testcase.steps << step.dup
        end
      rescue ActiveRecord::RecordNotFound
        render_404
        return
      end
    else
      @testcase = Testcase.new(params_permit)
      @testcase.steps.new
    end
  end

  def create
    @testcase = Testcase.new(params_permit)
    @testcase.author = User.current
    @testcase.project = @project
    @copy_from = Testcase.find(params[:copy_from]) if params[:copy_from]
    if @copy_from && params[:copy_attachments].present?
      @testcase.attachments = @copy_from.attachments.map do |attachement|
        attachement.copy(:container => @testcase)
      end
    end
    @testcase.save_attachments(params[:attachments])
    if @testcase.save
      notice = "Создан новый тесткейс '#{link_to_testcase}' в '#{view_context.make_folders_legend(@testcase.folder)}'"
      if params[:continue]
        redirect_to new_project_testcase_path(:testcase => 
          {
            :folder_id => @testcase.folder_id,
            :run_in_production => @testcase.run_in_production,
            :priority => @testcase.priority,
            :tag_list => @testcase.tag_list 
          }), :notice => notice
      else
        redirect_to project_testcases_path, :notice => notice
      end
    else
      render :new
    end
  end

  def preview
    @testcase = Testcase.find(params[:testcase_id]) if params[:testcase_id].present?
    @text = params[:content]
    render :layout => false
  end

  def new_import
  end

  def import
    if params[:import_file].present?
      @testcase = Testcase.new(:name => params[:import_file].original_filename, :folder_id => params[:current_folder])
      
      begin
        csv = CSV.read(params[:import_file].path)
      rescue StandardError => e
          @testcase.errors.add(:base, e.message)
          render :new and return
      end

      csv.each do |row|
        @testcase.steps.new(
            :if => row[0].to_s,
            :then => row[1].to_s,
            :info => row[2].to_s
          )
      end
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    @testcase.save_attachments(params[:attachments])
    if @testcase.update(params_permit)
      redirect_to project_testcases_path, notice: "Тесткейс '#{link_to_testcase}' обновлен"
    else
      render :edit
    end
  end

  def destroy
    if Testcase.where(parent_id: @testcase.id).present?
      redirect_to project_testcases_path, notice: "Этот тесткейс удалить нельзя"
    else
      @testcase.destroy
      redirect_to project_testcases_path, notice: "Тесткейс '#{@testcase.name}' удален"
    end
  end

  private

  def link_to_testcase
    view_context.link_to @testcase.name_with_id, project_testcase_path(id: @testcase.id, buttons: true), :remote => true
  end

  def find_testcase
    @testcase = Testcase.find(params[:id])
  end

  def params_permit
    params.require(:testcase).permit!
  end
end
