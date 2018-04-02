class TestkitEnvsController < ApplicationController
  menu_item :testkit
  before_filter :find_project_by_project_id, :authorize

  def index
    @server = TestkitEnv.where(project: @project, env_type: "server")
    @client = TestkitEnv.where(project: @project, env_type: "client")
  end

  def new
    @env = TestkitEnv.new(:env_type => params.require(:env_type), :project => @project)
  end

  def create
    @env = TestkitEnv.new(params_permit)
    if @env.save
      redirect_to project_testkit_envs_path
    else
      render :new
    end
  end

  def edit
    @env = TestkitEnv.find(params[:id])
  end

  def update
    @env = TestkitEnv.find(params[:id])
    if @env.update(params_permit)
      redirect_to project_testkit_envs_path, notice: "Обновлено"
    else
      render :edit
    end
  end

  def destroy
    @env = TestkitEnv.find(params[:id]).destroy
    redirect_to project_testkit_envs_path, notice: "Удалено окружение '#{@env.name}'"
  end

  private

  def params_permit
    params.require(:testkit_env).permit(:name, :project_id, :env_type)
  end
end
