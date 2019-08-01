class TestcaseStep < ActiveRecord::Base
  belongs_to :testcase

  acts_as_attachable
  extend OrderAsSpecified

  def if_doc
    Sablon.content(:html, testcase.clear_text(self.if))
  end

  def then_doc
    Sablon.content(:html, testcase.clear_text(self.then))
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
