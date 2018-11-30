# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :testkits do
    get 'tree', to: 'testkits#tree'
    get 'new_run', to: 'testkits#new_run'
    get 'edit_run', to: 'testkits#edit_run'
    get 'report', to: 'testkits#show_report'
    get 'move_from_archive', to: 'testkits#move_from_archive'
    get 'new_from_archive', to: 'testkits#new_from_archive'
    get ':type/export', to: 'testkit_export#make', as: 'export'
    match 'create_run', to: 'testkits#create_run', via: [:patch, :post]
    match 'update_run', to: 'testkits#update_run', via: [:patch, :post]
    match 'pass_run', to: 'testkits#pass_run', via: [:get, :patch]
  end

  get 'testkit_reports', to: 'testkits#index_reports'
  get 'testkit_archive', to: 'testkits#index_archive'
  
  get 'upload_file_to_step/:testcase_step_id', to: 'testcase_steps#upload_form', as: 'upload_file_to_step'
  match 'upload_file_to_step/:testcase_step_id', to: 'testcase_steps#upload', via: [:patch]
  delete 'destroy_step_attachment/:testcase_step_id/:id', to: 'testcase_steps#destroy', as: 'destroy_step_attachment'

  resources :testcases
  resources :testkit_envs
  resources :testcase_folders do
    collection do
      get 'tree', to: 'testcase_folders#tree'
      get 'node_menu', to: 'testcase_folders#node_menu'
    end
  end
end

get '/testcase_tags/auto_complete/:project_id', to: 'auto_completes#testcase_tags', as: 'auto_complete_testcase_tags'