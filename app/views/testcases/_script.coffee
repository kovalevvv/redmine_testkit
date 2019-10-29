$(document).on 'click', 'form .remove_steps', (event) ->
  $(this).prev('input[type=hidden]').val(1)
  $(this).closest('fieldset').hide()
  $(this).closest('fieldset').prev('div').hide()
  $('form > fieldset:visible').each (n,e) ->
    $(e).find('th').first().html('<%= l(:label_testkit_step) %> '+(n+1))
    $(e).find('.position').val(n+1)
  event.preventDefault()
 
$(document).on 'click', 'form .add_steps', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).closest('div').after($(this).closest('div').clone())
  $(this).closest('div').after($(this).data('fields').replace(regexp, time))
  textarea_if = new jsToolBar(document.getElementById('testcase_steps_attributes_' + time + '_if'))
  textarea_then = new jsToolBar(document.getElementById('testcase_steps_attributes_' + time + '_then'))
  textarea_info = new jsToolBar(document.getElementById('testcase_steps_attributes_' + time + '_info'))
  url = '<%= escape_javascript "#{Redmine::Utils.relative_url_root}/help/#{current_language.to_s.downcase}/wiki_syntax.html" %>'
  textarea_if.setHelpLink(url)
  textarea_then.setHelpLink(url)
  textarea_info.setHelpLink(url)
  textarea_if.draw()
  textarea_then.draw()
  textarea_info.draw()
  $('form > fieldset:visible').each (n,e) ->
    $(e).find('th').first().html('<%= l(:label_testkit_step) %> '+(n+1))
    $(e).find('.position').val(n+1)
  event.preventDefault()
  