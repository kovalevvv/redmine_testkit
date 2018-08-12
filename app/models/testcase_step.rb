class TestcaseStep < ActiveRecord::Base
  belongs_to :testcase

  acts_as_attachable
  extend OrderAsSpecified

  def index
    testcase.steps.index(self)+1
  end
  
  def attachments_editable?(user=User.current)
    true
  end

  def attachments_visible?(user=User.current)
    true
  end

  def attachments_deletable?(user=User.current)
    true
  end
end
