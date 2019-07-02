module RedmineTestkit
  module IssuePatch
    def self.included(base)
      base.class_eval do
        has_and_belongs_to_many :testkits
        belongs_to :found_in_testcase, class_name: "Testcase"
      end
    end
  end
end