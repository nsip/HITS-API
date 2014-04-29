/*
	HITS: App Edit
*/

$.fn.hits_app_edit = function () {
	return this.each(function () {
		var $this = $(this);
		var $tbody = $this.find('tbody');
	});
};

// CREATE vs UPDATE
$( document ).ready(function() {
	$('.hits-appedit').hits_app_edit();
});

