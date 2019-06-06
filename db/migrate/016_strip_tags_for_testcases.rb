class StripTagsForTestcases < ActiveRecord::Migration
  include ActionView::Helpers::TextHelper
  def change
    Testcase.all.each do |testcase|
      testcase.description = strip_tags(testcase.description)
      testcase.steps.each do |step|
        step.if = strip_tags(step.if)
        step.then = strip_tags(step.then)
        step.info = strip_tags(step.info)
      end
      testcase.save(validate: false)
      puts testcase.id
    end
  end
end
