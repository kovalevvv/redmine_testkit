class TestkitsController < ApplicationController
  menu_item :testkit
  before_filter :find_project_by_project_id, :authorize
  before_filter :project_versions, :only => [:new, :create, :edit, :new_from_archive]
  before_filter :load_testkit, :make_envs, :only => [:new_run, :create_run, :edit_run, :update_run, :move_from_archive]
  helper :attachments

  def index
    @runs = Testkit.where(done: false, run: true, project: @project).order(:created_at => :desc)
    @last_reports = Testkit.where(done: true, project: @project).order(:done_date => :desc).first(5)
    @reports_count = Testkit.where(done: true, project: @project).count
    @templates = Testkit.where(active: true, run: false, project: @project).order(:updated_at => :desc)
  end

  def show_report
    @report = Testkit.find(params[:testkit_id])
    @vars = Testkit::entities_clean_context(@report.context)
  end

  def index_reports
    @reports = Testkit.where(done: true, project: @project).order(:done_date => :desc)
  end

  def index_archive
    @archive = Testkit.where(active: false, run: false, project: @project).order(:name)
  end

  def tree 
    @testkit = Testkit.find(params[:testkit_id])
    render json: @testkit.tree.flatten
  end

  def new
    @testkit = Testkit.new
  end

  def create
    @testkit = Testkit.new(params_permit)
    @testkit.author = User.current
    @testkit.project = @project
    if @testkit.save
      redirect_to project_testkits_path, notice: "Создан новый тестовый набор '#{@testkit.name}'"
    else
      render :new
    end
  end

  def new_run
  end

  def create_run
    @testkit = @testkit.make_new_run(run_params_permit)
    if @testkit.save
      @testkit.copy_testcases
      redirect_to project_testkits_path, notice: "Создано тестирование '#{@testkit.name}'"
    else
      render :new_run
    end
  end

  def edit_run
  end

  def pass_run
    @run = Testkit.find(params[:testkit_id])
    redirect_to project_testkits_path, notice: "Тестирование '#{@run.name}' завершено" and return if @run.done?
    unless @run.start_date
      @run.start_date = DateTime.now
      @run.user_start = User.current
      @run.save
    end
    if request.patch?
      @run.update_attributes(params_permit)
      @run.touch
    end
    if (@run.check_done? and params[:commit].present? and not @run.done?) or params[:force_save]
      @run.set_not_run_to_testcases
      @run.done = true
      @run.done_date = DateTime.now
      @run.user_end = User.current
      @run.save
      redirect_to project_testkits_path, notice: "Тестирование '#{@run.name}' завершено" and return
    end
    respond_to do |format|
      format.html
      format.js { render :text => "$('#timer').data('updated-at','#{@run.updated_at.localtime}');" }
    end
  end

  def update_run
    @testkit = Testkit.find(params[:testkit_id])
    if @testkit.update(run_params_permit)
      redirect_to project_testkits_path, notice: "Тестовый набор '#{@testkit.name}' обновлен"
    else
      render :edit_run
    end
  end

  def edit
    @testkit = Testkit.find(params[:id])
  end

  def update
    @testkit = Testkit.find(params[:id])
    if @testkit.update(params_permit)
      redirect_to project_testkits_path, notice: "Тестовый набор '#{@testkit.name}' обновлен"
    else
      render :edit
    end
  end

  def destroy
    @testkit = Testkit.find(params[:id])
    if @testkit.template? and @testkit.have_runs?
      @testkit.active = false
      @testkit.save(validate: false)
      redirect_to project_testkits_path, notice: "Тестовый набор '#{@testkit.name}' перемещен в архив" and return
    elsif @testkit.template? and not @testkit.have_runs?
      @testkit.destroy
      redirect_to project_testkits_path, notice: "Тестовый набор '#{@testkit.name}' удален" and return
    elsif @testkit.run? and not @testkit.done?
      @testkit.testcases.each do |testcase|
        testcase.destroy
      end
      @testkit.destroy
      redirect_to project_testkits_path, notice: "План тестирования '#{@testkit.name}' удален" and return
    else
      redirect_to project_testkits_path, notice: "Тут какая-то ошибка!"
    end
  end

  def new_from_archive
    @testkit_from = Testkit.find(params[:testkit_id])
    @testkit = @testkit_from.dup
    @testkit.name = 'По шаблону: ' + @testkit_from.name
  end

  def move_from_archive
    @testkit.active = true
    @testkit.save(validate: false)
    redirect_to project_testkits_path, notice: "План тестирования '#{@testkit.name}' перемещен из архива"
  end

  private

  def make_envs
    @client_envs = TestkitEnv.where(project: @project, env_type: "client").collect { |env| [env.name] }
    if @testkit.client_env
      @client_envs << [@testkit.client_env]
      @client_envs.uniq!
    end
    @server_envs = TestkitEnv.where(project: @project, env_type: "server").collect { |env| [env.name] }
    if @testkit.env
      @server_envs << [@testkit.env]
      @server_envs.uniq!
    end
  end

  def load_testkit
    @testkit = Testkit.find(params[:testkit_id])
  end

  def project_versions
    @versions = @project.shared_versions.where.not(status: "closed")
  end

  def run_params_permit
    params.require(:testkit).permit(:name, :description, :client_env, :env, :assigned_to_id, {:issue_ids => []}, :version_ids)
  end

  def params_permit
    params.require(:testkit).permit!
  end
end
