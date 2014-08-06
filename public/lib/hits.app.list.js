/*
	HITS: App List
*/

$.fn.hits_app_list = function () {
	return this.each(function () {
		var $this = $(this);
		var $tbody = $this.find('tbody');
		console.log("Making request");

		var clean = function(din) {
			if (!din | (typeof din === 'undefined') || (din == 'undefined') || (din == 'null')) {
				return '';
			}
			return din;
		};

		hits_api.rest().app.read()
		.done(function(data) {
			if (data && data.app) {
				$tbody.empty();
				// XXX Quick hack table row - later add proper templates
				$.each( data.app, function(i, v) {
					if (v.vendor_id != v.current) 
						return;
					$tbody.append(''
						+ '<tr>'
						// + '<td>' + v.id + '</td>'
						// XXX Images + '<td><img src="/api/app/' + v.id + '/icon" /></td>'
						+ '<td>' + v.id + '</td>'
						+ '<td>' + clean(v.name) + '</td>'
						+ '<td>' + clean(v.title) + '</td>'
						+ '<td>' + clean(v.tags) + '</td>'
						+ '<td>' + clean(v.pub) + '</td>'
						+ '<td>' + clean(v.perm_template) + '</td>'
						+ '<td><a class="hits-appedit" href="#' + v.id + '">edit</a></td>'
						+ '</tr>'
					);
				});

				$this.tablesorter(); 

				// EDIT: Ideally move this out of here
				$this.find('.hits-appedit').click(function(event) {
					$('.hdd-body').hide();
					$('#hdd-body-apps-edit').show();
					var id = $(this).attr('href').substring(1);
					hits_app_edit($('#hdd-body-apps-edit'), id);
				});
			}
		})
		.fail(function(x) { 
			var error = JSON.parse(x.responseText);
			alertify.alert("ERROR: " + error.message);
		});
	});
};

$( document ).ready(function() {
	$('.hits-applist').hits_app_list();
});

