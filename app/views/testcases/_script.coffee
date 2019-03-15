$(document).on 'click', 'form .remove_steps', (event) ->
  $(this).prev('input[type=hidden]').val(1)
  $(this).closest('fieldset').hide()
  $(this).closest('fieldset').prev('.add_steps').hide()
  $('form > div > fieldset:visible').each (n,e) ->
    $(e).find('th').first().html('Шаг '+(n+1))
  $('.position').each (n) ->
    $(this).val(n+1)
  event.preventDefault()
 
$(document).on 'click', 'form .add_steps', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).after($(this).clone())
  $(this).after($(this).data('fields').replace(regexp, time))
  $('form > div > fieldset:visible').each (n,e) ->
    $(e).find('th').first().html('Шаг '+(n+1))
  $('.position').each (n) ->
    $(this).val(n+1)
  TinyMCEinit();
  event.preventDefault()
  