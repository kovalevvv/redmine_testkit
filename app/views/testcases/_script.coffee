$(document).on 'click', 'form .remove_steps', (event) ->
  $(this).prev('input[type=hidden]').val(1)
  $(this).closest('fieldset').hide()
  event.preventDefault()
 
$(document).on 'click', 'form .add_steps', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).before($(this).data('fields').replace(regexp, time))
  event.preventDefault()