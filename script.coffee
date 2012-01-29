getUrl = (subreddit, after) ->
  url = 'http://www.reddit.com/'
  url += "r/#{subreddit}" if subreddit
  url += '.json?jsonp=?'
  url += "&count=25&after=#{after}" if after
  url

urlFunc = ->
  name = this.last().toJSON().name if this.last()
  getUrl(this.subreddit, name)

Reddits = Backbone.Collection.extend
  subreddit: null
  url: -> getUrl()
  selected: 0
  deselect: -> $(this.at(this.selected).view.el).removeClass('active')
  select: ->
    $(this.at(this.selected).view.el).addClass('active')
    $.scrollTo $(this.at(this.selected).view.el),
      offset: {left: 0, top: -300}
  next: ->
    this.deselect()
    this.selected += 1
    this.select()
  open: ->
    window.open(this.at(this.selected).toJSON().url)
  comments: ->
    window.open("http://www.reddit.com/#{this.at(this.selected).toJSON().permalink}")
  prev: ->
    return if this.selected == 0
    this.deselect()
    this.selected -= 1
    this.select()
  parse: (response) ->
    it.data for it in response.data.children

RedditView = Backbone.View.extend
  tagName: "li",
  template: _.template """
  <% if(thumbnail) { %>
    <a class="thumbnail-link" href="<%= url %>">
      <img src="<%= thumbnail %>" />
    </a>
  <% } %>
  <div class="caption">
    <div class="link">
      <a href="<%= url %>"><%= _.escape(title) %></a>
    </div>
    <div class="info"><strong><%= score %></strong> <a href="http://www.reddit.com/<%= permalink %>"><%= num_comments %> comments</a></div>
  </div>
  """
  className: 'row'
  render: ->
    $(this.el).html(this.template(this.model.toJSON()))
    this

reddits = new Reddits

reddits.bind 'add', (reddit) ->
  view = new RedditView
    model: reddit,
    id: reddit.id
  $('#reddits').append(view.el);
  view.render()
  reddit.view = view

reddits.bind 'remove', (reddit) ->
  reddit.view.remove()

fetchReddits = ->
  reddits.fetch
    add: true
    success: ->
      reddits.url = urlFunc
      reddits.fetch
        add: true
        success: ->
          $('.spinner').hide()
          reddits.select()

fetchReddits()

$(window).scroll ->
  if $(window).scrollTop() == $(document).height() - $(window).height()
    $('.spinner').show()
    reddits.fetch
      add: true
      success: -> $('.spinner').hide()

shortcuts = (event) ->
  switch event.which
    when 74 then reddits.next()
    when 79 then reddits.open()
    when 67 then reddits.comments()
    when 75 then reddits.prev()

unbindShortcuts = ->
  $(document).unbind 'keydown', shortcuts

bindShortcuts = ->
  $(document).bind 'keydown', shortcuts

bindShortcuts()

$('#subreddit').bind 'keydown', (event) ->
  return unless event.which == 13
  $(this).blur()
  $('#reddits').empty()
  reddits.selected = 0
  reddits.reset []
  reddits.subreddit = $('#subreddit').val()
  $('.spinner').show()
  fetchReddits()

$('#subreddit').bind 'focus', unbindShortcuts
$('#subreddit').bind 'blur', bindShortcuts



