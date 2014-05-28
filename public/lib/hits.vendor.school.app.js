/*
	HITS: School App for vendor

*/

$.fn.hits_vendor_school_app_list = function () {
        return this.each(function () {
		var vendor_id = $.url().param('vendor_id');
		if (!vendor_id) vendor_id = 'currentVendor';
                var $this = $(this);
                var $tbody = $this.find('tbody');
		hits_api.rest().vendor.app.read(vendor_id)
		.done(function(data) {
			$.each( data.app, function(i, v) {
				$tbody.append(''
					+ '<tr>'
					// + '<td>' + v.id + '</td>'
					+ '<td><img src="/api/app/' + v.id + '/icon" /></td>'
					+ '<td>' + v.vendor_name + '</td>'
					+ '<td>' + v.name + '</td>'
					+ '<td>' + v.title + '</td>'
					+ '<td>' + v.school_name + '</td>'
					+ '<td>'
						+ '<a href="school-apps-view?school_id=' + v.school_id + '&app_id=' + v.id + '">View</a>'
						+ '&nbsp;'
						+ '<a href="' + v.href + '">(json)</a>'
					+ '</td>'
					+ '</tr>'
				);
			});
		})
		.fail(function() {
			alert("Failed");
		});
	});
};
                
$.fn.hits_vendor_school_app_view = function () {
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
			alert("Loaded single app");
			$.each(data.app, function (i,e) {
			})
		})
		.fail(function() {
			alert("Failed");
		});
	});
};

$( document ).ready(function() {
	$('.hits-vendor-school-app-list').hits_vendor_school_app_list();
	$('.hits-vendor-school-app-view').hits_vendor_school_app_view();
});
