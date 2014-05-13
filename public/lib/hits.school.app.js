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


$.fn.hits_school_app_list = function () {
        return this.each(function () {
		var school_id = $.url().param('school_id');
		if (! school_id) {
			alert("Must select a school ID first");
			return;
		}
                var $this = $(this);
                var $tbody = $this.find('tbody');
		alert("Found school list for " + school_id);
	});
};
                
$.fn.hits_school_app_add = function () {
        return this.each(function () {
		var school_id = $.url().param('school_id');
		if (! school_id) {
			alert("Must select a school ID first");
			return;
		}
                var $this = $(this);
                var $tbody = $this.find('tbody');
		hits_api.rest().app.read()
		.done(function(data) {
			alert("List apps");
			console.log(data);
		})
		.fail(function() {
			alert("Failed");
		});
	});

	/*
		hits_api.rest().school.app.create(school_id, { app_id: app_id })
		.done(function() {
			alert("Added");
		})
		.fail(function() {
			alert("Failed");
		});
	}
*/
};

$( document ).ready(function() {
	$('.hits-school-app-list').hits_school_app_list();
	$('.hits-school-app-add').hits_school_app_add();
});
