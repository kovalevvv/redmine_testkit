module RedmineTestkit
  module IssuePatch
    def self.included(base)
      base.class_eval do
        has_and_belongs_to_many :testkits
      end
    end
  end
end