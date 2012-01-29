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
    settings =
    $.scrollTo $(this.at(this.selected).view.el),
      offset: {left: 0, top: -300}
  next: ->
    this.deselect()
    this.selected += 1
    this.select()
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
    <div class="info"><strong><%= score %></strong> <%= num_comments %> comments</div>
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
        success: -> reddits.select()

fetchReddits()

$(window).scroll ->
  if $(window).scrollTop() == $(document).height() - $(window).height()
    reddits.fetch add: true

shortcuts = (event) ->
  switch event.which
    when 74 then reddits.next()
    when 75 then reddits.prev()

unbindShortcuts = ->
  $(document).unbind 'keydown', shortcuts

bindShortcuts = ->
  $(document).bind 'keydown', shortcuts

bindShortcuts()

$('#subreddit').bind 'keydown', (event) ->
  return unless event.which == 13
  $(this).blur()
  bindShortcuts()
  $('#reddits').empty()
  reddits.selected = 0
  reddits.reset []
  reddits.subreddit = $('#subreddit').val()
  fetchReddits()


$('#subreddit').bind 'focus', unbindShortcuts
$('#subreddit').unbind 'blur', bindShortcuts



