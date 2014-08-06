hljs.initHighlightingOnLoad();

var entify = function(data) {
		return document.createElement( 'a' ).appendChild( 
				document.createTextNode( data ) ).parentNode.innerHTML;
};

// ----------------------------------------------------------------------
// Navigation
$('.hdd-nav').click(function() {
	$('.hdd-nav').removeClass('active');
	$(this).addClass('active');
	$('.hdd-body').hide();
	$($(this).find('a').attr('href')).show(); // href contains ID
});
$('#hdd-dashboard-back').click(function() {
	$('.hdd-body').hide();
	$('#hdd-body-dashboard').show();
});
$('#hdd-view-back').click(function() {
	$('.hdd-body').hide();
	$('#hdd-body-view').show();
});

// ----------------------------------------------------------------------
// Table / Database view (XXX move to external resource)
hits_api.rest().view.read().done(function(data) {
	var ul = $('#hdd-body-view-list');
	// TODO - Add row counts etc in here
	$.each(data.table, function(key, val) {
		ul.append('<li><a class="table-view" href="#' + key + '">' + key + '</a></li>');
	});

	$('.table-view').click(function() {
		var table = $(this).attr('href').substring(1);
		hits_api.rest().view.read(table).done(function(data) {
			$('.hdd-body').hide();
			$('#hdd-body-view-table').show();

			$('#hbv-tablename').html(table);
			var tbl = $('#hbv-data');
			var head = tbl.find('thead tr');
			var body = tbl.find('tbody');
			head.empty();
			body.empty();

			var fields = [];
			$.each(data.data[0], function(key, val) {
				fields.push(key);
			});
			// fields.sort();
			$.each(fields, function(x, k) {
				head.append('<th>' + k + '</th>');
			});

			$.each(data.data, function(i, d) {
				body.append('<tr></tr>');
				var tr = body.find('tr').last();
				$.each(fields, function(x, k) {
					tr.append('<td>' + d[k] + '</td>');
				});
			});

			tbl.tablesorter(); 
		});
	});
});

