var shinyTree = function(){

  // copied from https://github.com/vakata/jstree/blob/ebf2112c62f24843c8b0322169ae9696373f5c09/src/misc.js#L407  
  $.jstree.defaults.node_customize = {
  		"key": "type",
  		"switch": {},
  		"default": null
  	};
  
  $.jstree.plugins.node_customize = function (options, parent) {
  	this.redraw_node = function (obj, deep, callback, force_draw) {
  		var node_id = obj;
  		var el = parent.redraw_node.apply(this, arguments);
  		if (el) {
  			var node = this._model.data[node_id];
  			var cfg = this.settings.node_customize;
  			var key = cfg.key;
  			var type =  (node && node.original && node.original[key]);
  			var customizer = (type && cfg.switch[type]) || cfg.default;
  			if(customizer)
  				customizer(el, node);
  		}
  		return el;
  	};
  }

  var treeOutput = new Shiny.OutputBinding();
  $.extend(treeOutput, {
    find: function(scope) {
      return $(scope).find('.shiny-tree');
    },
    renderValue: function(el, data) {
      // ********************* htmlwidgets code to support htmlwidget jsevals ********
      // Attempt eval() both with and without enclosing in parentheses.
      // Note that enclosing coerces a function declaration into
      // an expression that eval() can parse
      // (otherwise, a SyntaxError is thrown)
      function tryEval(code) {
        var result = null;
        try {
          result = eval("(" + code + ")");
        } catch(error) {
          if (!error instanceof SyntaxError) {
            throw error;
          }
          try {
            result = eval(code);
          } catch(e) {
            if (e instanceof SyntaxError) {
              throw error;
            } else {
              throw e;
            }
          }
        }
        return result;
      }
      
      // Wipe the existing tree and create a new one.
      $elem = $('#' + el.id)
      
      $elem.jstree('destroy');
      
      $elem.html(data);
      var plugins = [];
      if ($elem.data('st-checkbox') === 'TRUE'){
        plugins.push('checkbox');
      }
      if ($elem.data('st-search') === 'TRUE'){
        plugins.push('search');
      }  
      if ($elem.data('st-dnd') === 'TRUE'){
        plugins.push('dnd');
      }
      
      var config = {
        'core' : {
          "check_callback" : ($elem.data('st-dnd') === 'TRUE'),
          'themes': {
            'name': $elem.data('st-theme'),
            'url': true, // guess path by theme name
            'responsive': true,
            'icons': ($elem.data('st-theme-icons') === 'TRUE'),
            'dots': ($elem.data('st-theme-dots') === 'TRUE')
          }
        },
        plugins: plugins
      };
      
      config = $.extend(config, $elem.data('st-config'));
      
      if(config.hasOwnProperty('node_customize') && config.node_customize.hasOwnProperty('default')) {
        config.node_customize.default = tryEval(config.node_customize.default);
      }
      
      var tree = $(el).jstree(config);
      
      if ($elem.data('st-search') === 'TRUE'){
        $elem.siblings().find('.search-remove').click(function () {
          $(this).parent().find('.input').val('');
          $.jstree.reference($elem).search('');
        });
      }
    }
  });
  Shiny.outputBindings.register(treeOutput, 'shinyTree.treeOutput');
  
  var treeInput = new Shiny.InputBinding();
  $.extend(treeInput, {
    find: function(scope) {
      return $(scope).find(".shiny-tree");
    },
    getType: function(){
      return "shinyTree"
    },
    getValue: function(el, keys) {
      /**
       * Prune an object recursively to only include the specified keys.
       * 'li_attr' is a special key that will actually map to 'li_attrs.class' and
       * will be called 'class' in the output.
       **/
      var prune = function(arr, keys){
        var arrToObj = function(ar){
          var obj = {};
          $.each(ar, function(i, el){
            obj['' + i] = el;
          })
          return obj;
        }
        
        var toReturn = [];
        // Ensure 'children' property is retained.
        keys.push('children');
        
        $.each(arr, function(i, obj){
          if (obj.children && obj.children.length > 0){
            obj.children = arrToObj(prune(obj.children, keys));
          }
          var clean = {};
          
          $.each(obj, function(key, val){
            if (keys.indexOf(key) >= 0) {
              //console.log(key + ": " + val)
              
              if (key === 'li_attr') { // We don't really want, just the stid and class attr
                if (val.stid){
                  //console.log("stid (li_attr): " + val.stid)
                  if (typeof val.stid === 'string'){
                    // TODO: We don't really want to trim but have to b/c of Shiny's pretty-printing
                    clean["stid"] = val.stid.trim();
                  } else {
                    clean["stid"] = val.stid; 
                  }
                }
                
                if (val.class) {
                  //console.log("stclass (li_attr): " + val.class)
                  if (typeof val.class === 'string'){
                    // TODO: We don't really want to trim but have to b/c of Shiny's pretty-printing
                    clean["stclass"] = val.class.trim();
                  } else {
                    clean["stclass"] = val.class; 
                  }
                }
                
                //if (!val.class){
                //  console.log(key + ": " + val)
                //  // Skip without adding element.
                //  return;
                //}
                
                //if (val.class){
                //  val = val.class;
                //  key = 'class';
                //}
              } else {
              
                if (typeof val === 'string'){
                  // TODO: We don't really want to trim but have to b/c of Shiny's pretty-printing.
                  clean[key] = val.trim();
                } else {
                  clean[key] = val; 
                }
              }
            }
          });
          
          toReturn.push(clean);
        });
        return arrToObj(toReturn);
      }
      
      var tree = $.jstree.reference(el);
      if (tree) { // May not be loaded yet.
        if(tree.get_container().find("li").length>0) { // The tree may be initialized but empty
          var js = tree.get_json();
          //var pruned =  prune(js, ['id', 'state', 'text', 'li_attr']);
          if(js.length > 0) {
            return js;
          } else {
            return null;
          }
        }
      }
    },
    setValue: function(el, value) {},
    subscribe: function(el, callback) {
      $(el).on("open_node.jstree", function(e) {
        callback();
      });
      
      $(el).on("close_node.jstree", function(e) {
        callback();
      });
      
      $(el).on("changed.jstree", function(e) {
        callback();
      });
      
      $(el).on("model.jstree", function(e) {
        callback();
      });
      
      $(el).on("ready.jstree", function(e){
        // Initialize the data.
        callback();
      });
      
      $(el).on("move_node.jstree", function(e){
        callback();
      });
    },
    unsubscribe: function(el) {
      $(el).off(".jstree");
    },
    receiveMessage: function(el, message) {
      // This receives messages of type "updateTree" from the server.
      if(message.type == 'updateTree' && typeof message.data !== 'undefined') {
        // make sure that jstree has been rendered
        //  surely there is a better way to do this
        if( $(el).jstree(true) === false ) {
          Shiny.outputBindings.bindingNames["shinyTree.treeOutput"]
            .binding.renderValue(el);
        }
        
        // make sure that jstree rendered and ready
        if($(el).jstree(true)) {
          $(el).jstree(true).settings.core.data = JSON.parse(message.data);
          $(el).jstree(true).refresh(true, true);
        }
      }
    }
  });
  
  Shiny.inputBindings.register(treeInput); 
  
  var exports = {};
  
  exports.initSearch = function(treeId, searchId){
    $(function(){
      var to = false;
      $('#' + searchId).keyup(function () {
        if(to) { clearTimeout(to); }
        to = setTimeout(function () {
          var v = $('#' + searchId).val();
          $.jstree.reference('#' + treeId).search(v);
        }, 250);
      });
    });    
  }
  
  return exports;
}()