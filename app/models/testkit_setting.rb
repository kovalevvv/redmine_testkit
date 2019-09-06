class TestkitSetting < ActiveRecord::Base
  belongs_to :project
  belongs_to :new_defect_tracker, class_name: 'Tracker'
  has_one :test_plan, -> { where container_type: TestkitSetting.avaliable_types[:test_plan][:class_name] },
      class_name: 'Attachment', foreign_key: :container_id, foreign_type: :container_type, dependent: :destroy
  has_one :test_report, -> { where container_type: TestkitSetting.avaliable_types[:test_report][:class_name] },
      class_name: 'Attachment', foreign_key: :container_id, foreign_type: :container_type, dependent: :destroy
  acts_as_attachable

  def get_template(type)
    file = case type.to_s
    when *self.class::avaliable_types.keys.collect(&:to_s)
      title = template_name(type)
      if self.send(type).present? && attachment = self.send(type)
        attachment.diskfile
      else
        self.class::default_template(type)
      end
    else
      attachment = Attachment.find(type)
      title = template_name(attachment)
      attachment.diskfile
    end
    { file: file, title: title }
  end

  def self.default_template(type)
    TestkitExportController.new.lookup_context.find_template("#{TestkitExportController.controller_path}/#{self::avaliable_types[type.to_sym][:filename]}").identifier
  end

  def template_name(obj)
    case obj
    when Attachment
      obj.description.present? ? obj.description : File.basename(obj.filename, '.docx')
    when Symbol, String
      I18n.t("word_template_#{obj}")
    end
  end

  def save_templates(files)
    files.each do |type, file|
      save_attachments(file)
      if saved_attachments.present?
        attachment = saved_attachments.first
        attachment.container_type = self.class::avaliable_types[type][:class_name]
        if validate_template(attachment)
          self.send("#{type}=", attachment)
        else
          attachment.destroy
        end
        @saved_attachments = []
      end
    end
  end

  def attach_saved_attachments
    saved_attachments.each do |attachment|
      self.attachments << attachment if validate_template(attachment)
    end
  end

  def validate_template(attachment)
    unless attachment.content_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      errors.add(:base, :only_docx_allowed) unless errors.added?(:base, :only_docx_allowed)
      return false
    end
    true
  end

  def attachments_visible?(user=User.current)
    user.allowed_to?(:manage_testkit_settings, self.project)
  end

  def attachments_editable?(user=User.current)
    user.allowed_to?(:manage_testkit_settings, self.project)
  end

  def attachments_deletable?(user=User.current)
    user.allowed_to?(:manage_testkit_settings, self.project)
  end

  def self.avaliable_types
    {
      test_plan: { class_name: 'TestkitPlanTemplate', filename: 'test_plan.docx' },
      test_report: { class_name: 'TestkitReportTemplate', filename: 'test_report.docx' }
    }
  end

end

class TestkitPlanTemplate < TestkitSetting; end
class TestkitReportTemplate < TestkitSetting; end