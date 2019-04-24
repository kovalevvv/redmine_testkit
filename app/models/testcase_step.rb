class TestcaseStep < ActiveRecord::Base
  belongs_to :testcase

  acts_as_attachable
  extend OrderAsSpecified

  def if_doc
    Sablon.content(:html, Testcase.clear_hidden(self.if))
  end

  def then_doc
    Sablon.content(:html, Testcase.clear_hidden(self.then))
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
