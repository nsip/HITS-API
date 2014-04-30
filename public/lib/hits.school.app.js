/*
	HITS: School App

	list available = List Apps (? might use app.list)
	list added apps
	
	NOTE: List Apps - maybe should be together?
		* All apps - even if not selected
		* Only my selected apps
		* Only not selected apps for adding

*/

/*
$.fn.hits_app_edit = function () {
	return this.each(function () {
		var $this = $(this);
		var $tbody = $this.find('tbody');
	});
};

// CREATE vs UPDATE
$('.hits-appedit').hits_app_edit();

*/

hits_school = {
	list: function(school_id, el) {
	},

	add: function(school_id, app_id) {
		hits_api.rest().school.app.create(school_id, { app_id: app_id })
		.done(function() {
			alert("Added");
		})
		.fail(function() {
			alert("Failed");
		});
	}
};


$( document ).ready(function() {
	hits_school.list($('.hits-school-app-list');
});


