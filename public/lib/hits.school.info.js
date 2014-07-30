/*
	HITS: School Info
*/

$.fn.hits_school_info = function () {
        return this.each(function () {
                var school_id = $.url().param('school_id');
                if (! school_id) {
                        return;
                }
                var $this = $(this);
                hits_api.rest().school.read(school_id)
                .done(function(data) {
			if (data.school) {
				// Map any fields
				$this.find('.field').each(function() {
					var fieldstr = $(this).attr("dataField");
					$(this).html( data.school[fieldstr] );
				});
				// $this.find('.image').html( '<img src="/api/app/' + app_id + '/icon" />');
			}
		})
		.fail(function(x) { 
			var error = JSON.parse(x.responseText);
			console.log("ERROR: " + error.message);
		});
	});
};

$( document ).ready(function() {
	$('.hits-school-info').hits_school_info();
});

