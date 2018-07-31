module RedmineTestkit
  module AutoCompletesControllerPatch
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def testcase_tags
        @name = params[:q].to_s
        @tags = Testcase.available_tags project: @project, name_like: @name
        render layout: false, partial: 'testcase_tag_list'
      end

    end
  end
end
