var contextMenuObserving;
var contextMenuUrl;

function contextMenuRightClick(event) {
  var target = $(event.target);
  if (target.is('a')) {return;}
  var span = target.parents('span').first();
  if (!span.hasClass('fancytree-node')) {return;}
  event.preventDefault();
  contextMenuShow(event);
}

function contextMenuCreate() {
  if ($('#context-menu').length < 1) {
    var menu = document.createElement("div");
    menu.setAttribute("id", "context-menu");
    menu.setAttribute("style", "display:none;");
    document.getElementById("wrapper").appendChild(menu);
  }
}

function contextMenuClick(event) {
  var target = $(event.target);
  var lastSelected;

  if (target.is('a') && target.hasClass('submenu')) {
    event.preventDefault();
    return;
  }
  contextMenuHide();
}

function contextMenuHide() {
  $('#context-menu').hide();
}

function contextMenuInit(url) {
  contextMenuUrl = url;
  contextMenuCreate();
  
  if (!contextMenuObserving) {
    $(document).click(contextMenuClick);
    $(document).contextmenu(contextMenuRightClick);
    contextMenuObserving = true;
  }
}

function contextMenuShow(event) {

  var node = $.ui.fancytree.getNode(event)
  var mouse_x = event.pageX;
  var mouse_y = event.pageY;
  var render_x = mouse_x;
  var render_y = mouse_y;
  var dims;
  var menu_width;
  var menu_height;
  var window_width;
  var window_height;
  var max_width;
  var max_height;

  $('#context-menu').css('left', (render_x + 'px'));
  $('#context-menu').css('top', (render_y + 'px'));
  $('#context-menu').html('');

  $.ajax({
    url: contextMenuUrl,
    data: $(event.target).parents('form').first().serialize() + "&" + $.param({ node: {key: node.key, type: node.data.type} }),
    success: function(data, textStatus, jqXHR) {
      $('#context-menu').html(data);
      menu_width = $('#context-menu').width();
      menu_height = $('#context-menu').height();
      max_width = mouse_x + 2*menu_width;
      max_height = mouse_y + menu_height;

      var ws = window_size();
      window_width = ws.width;
      window_height = ws.height;

      /* display the menu above and/or to the left of the click if needed */
      if (max_width > window_width) {
       render_x -= menu_width;
       $('#context-menu').addClass('reverse-x');
      } else {
       $('#context-menu').removeClass('reverse-x');
      }
      if (max_height > window_height) {
       render_y -= menu_height;
       $('#context-menu').addClass('reverse-y');
      } else {
       $('#context-menu').removeClass('reverse-y');
      }
      if (render_x <= 0) render_x = 1;
      if (render_y <= 0) render_y = 1;
      $('#context-menu').css('left', (render_x + 'px'));
      $('#context-menu').css('top', (render_y + 'px'));
      $('#context-menu').show();

    }
  });
}

function window_size() {
  var w;
  var h;
  if (window.innerWidth) {
    w = window.innerWidth;
    h = window.innerHeight;
  } else if (document.documentElement) {
    w = document.documentElement.clientWidth;
    h = document.documentElement.clientHeight;
  } else {
    w = document.body.clientWidth;
    h = document.body.clientHeight;
  }
  return {width: w, height: h};
}