class TestkitEnv < ActiveRecord::Base
  belongs_to :project
  validates :name, :project_id, :env_type, presence: true
end
