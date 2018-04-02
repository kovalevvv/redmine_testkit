class TestcasesController < ApplicationController
  menu_item :testkit
  before_filter :find_project_by_project_id, :authorize
  before_filter :find_testcase, :only => [:show, :edit, :update, :destroy]
  helper :attachments

  def index
  end

  def new
    @testcase = Testcase.new(params_permit)
    @testcase.steps.new
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
