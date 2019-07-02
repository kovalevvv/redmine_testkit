module RedmineTestkit
  module ProjectPatch
    def self.included(base)
      base.class_eval do
        has_one :testkit_settings
        accepts_nested_attributes_for :testkit_settings, update_only: true
      end
    end
  end
end