/*
	HITS: App List
*/

$.fn.hits_app_list = function () {
	return this.each(function () {
		var $this = $(this);
		var $tbody = $this.find('tbody');
		hits_api.rest().app.read()
		.done(function(data) {
			if (data && data.app) {
				$tbody.empty();
				$.each( data.app, function(i, v) {
					$tbody.append(''
						+ '<tr>'
						+ '<td>' + v.id + '</td>'
						+ '<td>' + v.title + '</td>'
						+ '</tr>'
					);
				});

				/*
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

$('.hits-applist').hits_app_list();

