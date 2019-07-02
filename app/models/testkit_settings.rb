class TestkitSettings < ActiveRecord::Base
  belongs_to :project
  belongs_to :new_defect_tracker, class_name: 'Tracker'
end
