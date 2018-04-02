module RedmineTestkit
  module VersionPatch
    def self.included(base)
      base.class_eval do
        has_and_belongs_to_many :testkits
      end
    end
  end
end