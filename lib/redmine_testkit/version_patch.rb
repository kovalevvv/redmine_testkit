module RedmineTestkit
  module VersionPatch
    def self.included(base)
    	base.send :include, InstanceMethods
      base.class_eval do
        has_and_belongs_to_many :testkits
      end
    end

    module InstanceMethods
    	def due_date_localize
    		I18n.l due_date
    	end
    end

  end
end