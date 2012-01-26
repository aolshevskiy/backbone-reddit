var Reddits = Backbone.Collection.extend({	
	parse: function(response) {
		var result = [];
		$(response.data.children).each(function(i, it){			
			result.push(it.data);			
		});		
		return result;		
	}
});

var BodyView = Backbone.View.extend({
	el: "#reddits",	
	render: function() {		
		this.collection.each(function(model){
			var view = new RedditView({model: model, id: "reddit-"+model.id, tagName: "li", className: "row"});
			$(this.el).append(view.render());						
		}, this);	
	}
});

var RedditView = Backbone.View.extend({	
	render: function() {					
		$(this.el).html(this.template(this.model.toJSON()));
		return this.el;
	}
});