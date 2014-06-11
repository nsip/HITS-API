/*
	HITS: School App

	list available = List Apps (? might use app.list)
	list added apps
	
	NOTE: List Apps - maybe should be together?
		* All apps - even if not selected
		* Only my selected apps
		* Only not selected apps for adding

*/

hits_school_app_icon_render = function($this, school_id, data) {
	$.each( data.app, function(i, v) {
		$this.append('<div class="hits-app-icon">'
				// style="float: left; padding: 5px; border: 1px solid black;">'
			+ '<a href="school-apps-view?school_id=' + school_id + '&app_id=' + v.id + '">'
			+ '<img src="/api/app/' + v.id + '/icon" />'
			+ '<br />'
			+ '<span>' + v.title + '</span>'
			+ '</a>'
			+ '</div>'
			// + '<td><a href="school-app-view?school_id=' + school_id + '&app_id=' + v.id + '">View</a></td>'
		);
	});
	$this.append('<div class="hits-app-icon-end">&nbsp;</div>');
};

$.fn.hits_school_app_icon_active = function () {
        return this.each(function () {
		var school_id = $.url().param('school_id');
		if (! school_id) {
			alert("Must select a school ID first");
			return;
		}
                var $this = $(this);
		hits_api.rest().school.app.read(school_id)
		.done(function(data) {
			hits_school_app_icon_render($this, school_id, data);
		})
		.fail(function() {
			alert("Failed");
		});
	});
};

$.fn.hits_school_app_icon_available = function () {
        return this.each(function () {
		var school_id = $.url().param('school_id');
		if (! school_id) {
			alert("Must select a school ID first");
			return;
		}
                var $this = $(this);
		hits_api.rest().app.read()
		.done(function(data) {
			hits_school_app_icon_render($this, school_id, data);
		})
		.fail(function() {
			alert("Failed");
		});
	});
};

$.fn.hits_school_app_list = function () {
        return this.each(function () {
		var school_id = $.url().param('school_id');
		if (! school_id) {
			alert("Must select a school ID first");
			return;
		}
                var $this = $(this);
                var $tbody = $this.find('tbody');
		hits_api.rest().school.app.read(school_id)
		.done(function(data) {
			$.each( data.app, function(i, v) {
				$tbody.append(''
					+ '<tr>'
					+ '<td>' + v.id + '</td>'
					+ '<td>' + v.name + '</td>'
					+ '<td><a href="school-apps-view?school_id=' + school_id + '&app_id=' + v.id + '">View</a></td>'
					+ '</tr>'
				);
			});
		})
		.fail(function() {
			alert("Failed");
		});
	});
};
                
var hits_school_app_add = function(school_id, app_id) {
	hits_api.rest().school.app.create(school_id, { app_id: app_id })
	.done(function() {
		alert("Added - reloading list");
		location.reload();
	})
	.fail(function() {
		alert("Failed to add application");
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
                var $selectapp = $this.find('select[name="app"]');
		hits_api.rest().app.read()
		.done(function(data) {
			$.each(data.app, function (i,e) {
				$selectapp.append('<option value="' 
					+ e.id + '">' 
					+ e.name + ": " + e.title + " (" + e.vendor_name 
					+ ")</option>"
				);
			});
		})
		.fail(function() {
			alert("Failed");
		});

		$this.submit(function(event) {
			event.preventDefault();
			hits_school_app_add(school_id, $selectapp.val());
		});
	});
};

$.fn.hits_school_app_view = function () {
        return this.each(function () {
		var school_id = $.url().param('school_id');
		var app_id = $.url().param('app_id');
		if (! school_id || ! app_id) {
			alert("Must select a APP ID and school ID first");
			return;
		}
                var $this = $(this);
		hits_api.rest().school.app.read(school_id, app_id)
		.done(function(data) {
			console.log(data);
			// Map any fields
			$this.find('.field').each(function() {
				var fieldstr = $(this).attr("dataField");
				$(this).html( data[fieldstr] );
			});

			// Add icon
			$this.find('.image').html( '<img src="/api/app/' + app_id + '/icon" />');

			// ACTIVE / DEACTIVATE Buttons
			if (data.status == 'active') {
				$this.find('.button').html("De-Activate");
			}
			else {
				$this.find('.button').html("Activate");
			}
			$this.find('.button').click(function() {
				if (data.status == 'active') {
					alert("Sorry de-activation not yet supported");
				}
				else {
					hits_school_app_add(school_id, app_id);
				}
			});

			$this.find('.back').click(function(event) {
				event.preventDefault();
				var url = $(this).attr('href');
				window.location = url + '?school_id=' + school_id;
			});
			
			$this.find('.testlink').click(function(event) {
				event.preventDefault();
				window.location = "/client/Simple/?school_id=" + school_id
			});

			$this.find('.studentlink').click(function(event) {
				event.preventDefault();
				window.location = data.test.url + '/object/student';
			});

			$this.find('.stafflink').click(function(event) {
				event.preventDefault();
				window.location = data.test.url + '/object/teacher';
			});

			$this.find('.classeslink').click(function(event) {
				event.preventDefault();
				window.location = data.test.url + '/object/class';
			});

			$this.find('.applink').click(function(event) {
				event.preventDefault();
				if (data.app_url) {
					window.location = data.app_url + data.token;
				}
				else {
					alert("Sorry. This application does not have an applink");
				}
				return;
			});

			var perm = $this.find('.perm_template');
			if (perm) {
				if (data.perm_template) {
					perm.html('<a target="_blank" href="profile-' + data.perm_template + '">' + data.perm_template + '</a>');
				}
				else {
					perm.html('(none)');
				}
			}
		})
		.fail(function() {
			alert("Failed");
		});
	});
};

$( document ).ready(function() {
	$('.hits-school-app-list').hits_school_app_list();
	$('.hits-school-app-add').hits_school_app_add();
	$('.hits-school-app-view').hits_school_app_view();
	$('.hits-school-app-icon-active').hits_school_app_icon_active();
	$('.hits-school-app-icon-available').hits_school_app_icon_available();
});
