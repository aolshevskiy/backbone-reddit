(function() {
  var RedditView, Reddits, bindShortcuts, fetchReddits, getUrl, reddits, shortcuts, unbindShortcuts, urlFunc;

  getUrl = function(subreddit, after) {
    var url;
    url = 'http://www.reddit.com/';
    if (subreddit) url += "r/" + subreddit;
    url += '.json?jsonp=?';
    if (after) url += "&count=25&after=" + after;
    return url;
  };

  urlFunc = function() {
    var name;
    if (this.last()) name = this.last().toJSON().name;
    return getUrl(this.subreddit, name);
  };

  Reddits = Backbone.Collection.extend({
    subreddit: null,
    url: function() {
      return getUrl();
    },
    selected: 0,
    deselect: function() {
      return $(this.at(this.selected).view.el).removeClass('active');
    },
    select: function() {
      $(this.at(this.selected).view.el).addClass('active');
      return $.scrollTo($(this.at(this.selected).view.el), {
        offset: {
          left: 0,
          top: -300
        }
      });
    },
    next: function() {
      this.deselect();
      this.selected += 1;
      return this.select();
    },
    open: function() {
      return window.open(this.at(this.selected).toJSON().url);
    },
    comments: function() {
      return window.open("http://www.reddit.com/" + (this.at(this.selected).toJSON().permalink));
    },
    prev: function() {
      if (this.selected === 0) return;
      this.deselect();
      this.selected -= 1;
      return this.select();
    },
    parse: function(response) {
      var it, _i, _len, _ref, _results;
      _ref = response.data.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        it = _ref[_i];
        _results.push(it.data);
      }
      return _results;
    }
  });

  RedditView = Backbone.View.extend({
    tagName: "li",
    template: _.template("<% if(thumbnail) { %>\n  <a class=\"thumbnail-link\" href=\"<%= url %>\">\n    <img src=\"<%= thumbnail %>\" />\n  </a>\n<% } %>\n<div class=\"caption\">\n  <div class=\"link\">\n    <a href=\"<%= url %>\"><%= _.escape(title) %></a>\n  </div>\n  <div class=\"info\"><strong><%= score %></strong> <a href=\"http://www.reddit.com/<%= permalink %>\"><%= num_comments %> comments</a></div>\n</div>"),
    className: 'row',
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    }
  });

  reddits = new Reddits;

  reddits.bind('add', function(reddit) {
    var view;
    view = new RedditView({
      model: reddit,
      id: reddit.id
    });
    $('#reddits').append(view.el);
    view.render();
    return reddit.view = view;
  });

  reddits.bind('remove', function(reddit) {
    return reddit.view.remove();
  });

  fetchReddits = function() {
    return reddits.fetch({
      add: true,
      success: function() {
        reddits.url = urlFunc;
        return reddits.fetch({
          add: true,
          success: function() {
            $('.spinner').hide();
            return reddits.select();
          }
        });
      }
    });
  };

  fetchReddits();

  $(window).scroll(function() {
    if ($(window).scrollTop() === $(document).height() - $(window).height()) {
      $('.spinner').show();
      return reddits.fetch({
        add: true,
        success: function() {
          return $('.spinner').hide();
        }
      });
    }
  });

  shortcuts = function(event) {
    switch (event.which) {
      case 74:
        return reddits.next();
      case 79:
        return reddits.open();
      case 67:
        return reddits.comments();
      case 75:
        return reddits.prev();
    }
  };

  unbindShortcuts = function() {
    return $(document).unbind('keydown', shortcuts);
  };

  bindShortcuts = function() {
    return $(document).bind('keydown', shortcuts);
  };

  bindShortcuts();

  $('#subreddit').bind('keydown', function(event) {
    if (event.which !== 13) return;
    $(this).blur();
    $('#reddits').empty();
    reddits.selected = 0;
    reddits.reset([]);
    reddits.subreddit = $('#subreddit').val();
    $('.spinner').show();
    return fetchReddits();
  });

  $('#subreddit').bind('focus', unbindShortcuts);

  $('#subreddit').bind('blur', bindShortcuts);

}).call(this);
