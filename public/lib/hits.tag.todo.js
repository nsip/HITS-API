/*
	HITS: App List
*/

$.fn.hits_tag_todo = function () {
	return this.each(function () {
		var $this = $(this);
		hits_api.rest().tag.read('todo')
		.done(function(data) {
			if (data && data.app) {
				console.log(data);
			}
		//})
		//.fail(function(x) { 
		//	var error = JSON.parse(x.responseText);
		//	alertify.alert("ERROR: " + error.message);
		});

		console.log("Finding");
		$this.find('.glyphicon-ok').hide();
		console.log("Done");
	});
};

$( document ).ready(function() {
	$('.hits-tag-todo').hits_tag_todo();
});

