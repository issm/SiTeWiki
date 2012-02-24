(function() {
  var SiTeWiki;

  SiTeWiki = (function() {

    function SiTeWiki() {
      var _this = this;
      this.html_view = new SiTeWiki.HTMLView({
        parent: this
      });
      this.edit_view = new SiTeWiki.EditView({
        parent: this
      });
      this.html_view.$button_edit.click(function() {
        _this.switch_view();
        return false;
      });
      this.edit_view.$button_cancel.click(function() {
        _this.switch_view();
        _this.edit_view.$textarea_data.val(_this.edit_view.$data_orig.text());
        return false;
      });
    }

    SiTeWiki.prototype.load_data = function(path) {
      var ajax_params,
        _this = this;
      ajax_params = {
        url: "" + SITEWIKI_URI_BASE + "api/load",
        type: 'get',
        dataType: 'json',
        data: {
          path: path
        },
        success: function(res, status, xhr) {
          _this.html_view.update(res.data_html);
          return _this.edit_view.update(res.data);
        },
        error: function(xhr, status) {
          return _this.switch_view();
        }
      };
      return $.ajax(ajax_params);
    };

    SiTeWiki.prototype.switch_view = function() {
      if (this.html_view.showed) {
        this.html_view.hide();
        return this.edit_view.show();
      } else {
        this.edit_view.hide();
        return this.html_view.show();
      }
    };

    return SiTeWiki;

  })();

  SiTeWiki.HTMLView = (function() {

    function HTMLView(params) {
      this.$ = $('#htmlview');
      this.$button_edit = this.$.find('.button-edit');
      this.$view = this.$.find('.view');
      this.parent = params.parent;
      this.showed = true;
    }

    HTMLView.prototype.update = function(data) {
      return this.$view.html(data);
    };

    HTMLView.prototype.show = function() {
      this.$.show();
      return this.showed = true;
    };

    HTMLView.prototype.hide = function() {
      this.$.hide();
      return this.showed = false;
    };

    return HTMLView;

  })();

  SiTeWiki.EditView = (function() {

    function EditView(params) {
      var self,
        _this = this;
      self = this;
      this.parent = params.parent;
      this.$ = $('#editview');
      this.$editor = this.$.find('.editor');
      this.$previewer = this.$.find('.previewer');
      this.$data_orig = this.$.find('.data_orig');
      this.$textarea_data = this.$.find('form .editor [name="data"]');
      this.$button_cancel = this.$.find('form .buttons [name="cancel"]');
      this.$button_edit = this.$.find('form .buttons [name="edit"]');
      this.$button_preview = this.$.find('form .buttons [name="preview"]');
      this.$button_save = this.$.find('form .buttons [name="save"]');
      this.$csrf_token = this.$.find('form [name="csrf_token"]');
      this.showed = false;
      this.editing = true;
      this.previewing = false;
      this.$.find('form').submit(function() {
        return false;
      });
      this.$button_preview.click(function() {
        _this.switch_preview();
        return false;
      });
      this.$button_edit.click(function() {
        _this.switch_edit();
        return false;
      });
      this.$button_save.click(function() {
        _this.save();
        return false;
      });
    }

    EditView.prototype.update = function(data) {
      return this.$textarea_data.val(data);
    };

    EditView.prototype.show = function() {
      this.switch_edit();
      this.$.show();
      this.$data_orig.text(this.$textarea_data.val());
      this.$textarea_data.focus();
      return this.showed = true;
    };

    EditView.prototype.hide = function() {
      this.$.hide();
      return this.showed = false;
    };

    EditView.prototype.switch_preview = function() {
      var ajax_params,
        _this = this;
      ajax_params = {
        url: "" + SITEWIKI_URI_BASE + "api/textile",
        type: 'get',
        dataType: 'json',
        data: {
          data: this.$textarea_data.val()
        },
        success: function(res, status, xhr) {
          _this.$editor.hide();
          _this.$previewer.html(res.data_html).show();
          _this.$button_edit.show();
          _this.$button_preview.hide();
          _this.editing = false;
          return _this.previewing = true;
        },
        error: function(xhr, status) {}
      };
      return $.ajax(ajax_params);
    };

    EditView.prototype.switch_edit = function() {
      this.$previewer.hide().empty();
      this.$editor.show();
      this.$button_preview.show();
      this.$button_edit.hide();
      this.$textarea_data.focus();
      this.previewing = false;
      return this.editing = true;
    };

    EditView.prototype.save = function() {
      var ajax_params,
        _this = this;
      ajax_params = {
        url: "" + SITEWIKI_URI_BASE + "api/save",
        type: 'post',
        dataType: 'json',
        data: {
          path: SITEWIKI_PATH,
          data: this.$textarea_data.val(),
          csrf_token: this.$csrf_token.val()
        },
        success: function(res, status, xhr) {
          _this.update(res.data);
          _this.parent.html_view.update(res.data_html);
          return _this.parent.switch_view();
        },
        error: function(xhr, status) {}
      };
      return $.ajax(ajax_params);
    };

    return EditView;

  })();

  $(function() {
    window.sitewiki = new SiTeWiki();
    return sitewiki.load_data(SITEWIKI_PATH);
  });

}).call(this);
