class TestcaseStep < ActiveRecord::Base
  acts_as_attachable
  extend OrderAsSpecified
  
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
