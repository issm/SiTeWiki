class SiTeWiki
    constructor: () ->
        @html_view = new SiTeWiki.HTMLView
            parent: @
        @edit_view = new SiTeWiki.EditView
            parent: @

        @html_view.$button_edit.click () =>
            @switch_view()
            return false

        @edit_view.$button_cancel.click () =>
            @switch_view()
            @edit_view.$textarea_data.val( @edit_view.$data_orig.text() )
            return false

    load_data: (path) ->
        ajax_params =
            url: "#{SITEWIKI_URI_BASE}api/load"
            type: 'get'
            dataType: 'json'
            data:
                path: path
            success: (res, status, xhr) =>
                @html_view.update(res.data_html)
                @edit_view.update(res.data)

            error: (xhr, status) =>
                @switch_view()
                #@html_view.$button_edit.click()

        $.ajax(ajax_params)

    switch_view: () ->
        if @html_view.showed
            @html_view.hide()
            @edit_view.show()
        else
            @edit_view.hide()
            @html_view.show()


class SiTeWiki.HTMLView
    constructor: (params) ->
        @$            = $('#htmlview')
        @$button_edit = @$.find('.button-edit')
        @$view        = @$.find('.view')

        @parent = params.parent

        @showed = true

    update: (data) ->
        @$view.html(data)

    show: () ->
        @$.show()
        @showed = true

    hide: () ->
        @$.hide()
        @showed = false


class SiTeWiki.EditView
    constructor: (params) ->
        self = @

        @parent = params.parent

        @$          = $('#editview')
        @$editor    = @$.find('.editor')
        @$previewer = @$.find('.previewer')
        @$data_orig = @$.find('.data_orig')

        @$textarea_data  = @$.find('form .editor [name="data"]')
        @$button_cancel  = @$.find('form .buttons [name="cancel"]')
        @$button_edit    = @$.find('form .buttons [name="edit"]')
        @$button_preview = @$.find('form .buttons [name="preview"]')
        @$button_save    = @$.find('form .buttons [name="save"]')
        @$csrf_token     = @$.find('form [name="csrf_token"]')

        @showed     = false
        @editing    = true
        @previewing = false

        @$.find('form').submit () ->
            return false

        @$button_preview.click () =>
            @switch_preview()
            return false

        @$button_edit.click () =>
            @switch_edit()
            return false

        @$button_save.click () =>
            @save()
            return false

    update: (data) ->
        @$textarea_data.val(data)

    show: () ->
        @switch_edit()
        @$.show()
        @$data_orig.text( @$textarea_data.val() )
        @$textarea_data.focus()
        @showed = true

    hide: () ->
        @$.hide()
        @showed = false

    switch_preview: () ->
        ajax_params =
            url: "#{SITEWIKI_URI_BASE}api/textile"
            type: 'get'
            dataType: 'json'
            data:
                data: @$textarea_data.val()
            success: (res, status, xhr) =>
                @$editor.hide()
                @$previewer.html(res.data_html).show()
                @$button_edit.show()
                @$button_preview.hide()
                @editing    = false
                @previewing = true

            error: (xhr, status) =>

        $.ajax(ajax_params)

    switch_edit: () ->
        @$previewer.hide().empty()
        @$editor.show()
        @$button_preview.show()
        @$button_edit.hide()
        @$textarea_data.focus()
        @previewing = false
        @editing    = true

    save: () ->
        ajax_params =
            url: "#{SITEWIKI_URI_BASE}api/save"
            type: 'post'
            dataType: 'json'
            data:
                path:       SITEWIKI_PATH
                data:       @$textarea_data.val()
                csrf_token: @$csrf_token.val()
            success: (res, status, xhr) =>
                @update(res.data)
                @parent.html_view.update(res.data_html)
                @parent.switch_view()

            error: (xhr, status) =>

        $.ajax(ajax_params)


$ ->
    window.sitewiki = new SiTeWiki()
    sitewiki.load_data(SITEWIKI_PATH)