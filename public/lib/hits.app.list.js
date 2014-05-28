/*
	HITS: App List
*/

$.fn.hits_app_list = function () {
	return this.each(function () {
		var $this = $(this);
		var $tbody = $this.find('tbody');
		console.log("Making request");
		hits_api.rest().app.read()
		.done(function(data) {
			if (data && data.app) {
				$tbody.empty();
				// XXX Quick hack table row - later add proper templates
				$.each( data.app, function(i, v) {
					$tbody.append(''
						+ '<tr>'
						// + '<td>' + v.id + '</td>'
						+ '<td><img src="/api/app/' + v.id + '/icon" /></td>'
						+ '<td>' + v.name + '</td>'
						+ '<td>' + v.title + '</td>'
						+ '<td>' + v.tags + '</td>'
						+ '<td>' + v.pub + '</td>'
						+ '<td><a href="school_scenario_step1?app_id=' + v.id + '">edit</a></td>'
						// XXX Add edit link - Page name?
						+ '</tr>'
					);
				});

				/*
				// XXX Table Sorter and Table Search ?
				$this.tablesorter(); 
				$tbody.find("tr:has(td)").each(function(){
					var t = $(this).text().toLowerCase();
					$("<td class='indexColumn'></td>").hide().text(t).appendTo(this);
				});
				*/

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

