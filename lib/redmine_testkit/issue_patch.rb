module RedmineTestkit
  module IssuePatch
    def self.included(base)
        base.send :include, InstanceMethods
      base.class_eval do
        has_and_belongs_to_many :testkits
        belongs_to :found_in_testcase, class_name: "Testcase"
        has_many :testcases
      end
    end

    module InstanceMethods
      def tag_list_string
        if defined?(ActsAsTaggableOn::Tag)
          self.tag_list.join(", ")
        else
          ""
        end
      end
    end
    
  end
end