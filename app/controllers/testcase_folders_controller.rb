class TestcaseFoldersController < ApplicationController
  menu_item :testkit
  helper :context_menus
  before_filter :find_project_by_project_id, :authorize

  def tree
    json = []
    TestcaseFolder.where(parent_id: nil, project: @project).each do |folder|
      if params[:q].present? and params[:q].is_a? Array
        json << folder.make_tree(tags: params[:q])
      else
        json << folder.make_tree
      end
    end
    render json: json.flatten
  end

  def node_menu
    @node = params[:node][:type].constantize.find(params[:node][:key])
    render :layout => false
  end

  def new
    @folder = TestcaseFolder.new(params.permit(:parent_id, :project_id))
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @folder = TestcaseFolder.new(params_permit)
    if @folder.save
      redirect_to project_testcases_path, notice: "Папка '#{@folder.name}' создана"
    else
      render :new
    end
  end

  def edit
    @folder = TestcaseFolder.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @folder = TestcaseFolder.find(params[:id])
    if @folder.update(params_permit)
      redirect_to project_testcases_path, notice: "Папка '#{@folder.name}' обновлена"
    else
      render :edit
    end
  end

  def destroy
    @folder = TestcaseFolder.find(params[:id])
    @folder.destroy
    redirect_to project_testcases_path, notice: "Папка '#{@folder.name}' удалена"
  end

  private

  def params_permit 
    params.require(:testcase_folder).permit(:name, :parent_id, :project_id)
  end
end
