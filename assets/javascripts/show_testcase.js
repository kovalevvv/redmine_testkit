function dblclickShowTestcase(event) {
  var target = $(event.target);
  if (target.is('a')) {return;}
  if (!target.is('.fancytree-title, .fancytree-custom-icon')) {return;}
  event.preventDefault();
  var node = $.ui.fancytree.getNode(event)
  if (node.data.type == "Testcase") {
    var request = {
      url: node.data.path,
      type: 'get',
      dataType: 'script'
    }
    if (event.data.buttons) {
      var buttons = {
        data: {
          buttons: "yes"
        }
      }
      request = $.extend(request, buttons)
    }
    $.ajax(request)
  }
}