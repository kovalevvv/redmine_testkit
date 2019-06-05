class TestcasesController < ApplicationController
  menu_item :testkit
  before_filter :find_project_by_project_id, :authorize
  before_filter :find_testcase, :only => [:show, :edit, :update, :destroy]
  before_filter :find_attachments, :only => [:preview, :edit, :show]
  helper :attachments

  def index
  end

  def new
    @testcase = Testcase.new(params_permit)
    @testcase.steps.new
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
      @testcase = Testcase.new(:name => params[:import_file].original_filename)
      
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

  def create
    @testcase = Testcase.new(params_permit)
    @testcase.author = User.current
    @testcase.project = @project
    @testcase.save_attachments(params[:attachments])
    if @testcase.save
      redirect_to project_testcases_path, notice: "Создан новый тесткейс '#{@testcase.name}' в '#{view_context.make_folders_legend(@testcase.folder)}'"
    else
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
      redirect_to project_testcases_path, notice: "Тесткейс '#{@testcase.name}' обновлен"
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

  def find_testcase
    @testcase = Testcase.find(params[:id])
  end

  def params_permit
    params.require(:testcase).permit!
  end
end
