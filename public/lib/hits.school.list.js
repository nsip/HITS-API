/*
	HITS: App List
*/

$.fn.hits_school_list = function () {
	return this.each(function () {
		var $this = $(this);
		var $tbody = $this.find('tbody');
		console.log("Making request");
		hits_api.rest().school.read()
		.done(function(data) {
			if (data && data.school) {
				$tbody.empty();
				$.each( data.school, function(i, v) {
					$tbody.append(''
						+ '<tr>'
						// + '<td>' + v.id + '</td>'
						+ '<td>&nbsp;</td>'
						+ '<td>' + v.name + '</td>'
						+ '<td><a href="school-apps?school_id=' + v.id + '">Login</a></td>'
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
	$('.hits-school-list').hits_school_list();
});

