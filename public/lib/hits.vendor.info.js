/*
	HITS: App Vendor
*/

$.fn.hits_vendor_info = function () {
	return this.each(function () {
		var $this = $(this);
		var $form = $this.find('form');

		// Find list of fields
		var fields = [];
		$form.find('input').each(function(index,element) {
			fields.push(element);
		});
		$form.hide();

		// Load existing data
		console.log("Hello world... about to load");
		hits_api.rest().vendor.info.read('currentVendor')
		.done(function(data) {
			$form.show();
			if (data && data.info) {
				$.each(fields, function(index,element) {
					$(element).val(data.info[$(element).attr('name')]);
				});
			}

			$form.find('button').click(function() {
				var data = {};
				$.each(fields, function(index,element) {
					var name = $(element).attr('name');
					data[name] = $(element).val();
				});
				
				hits_api.rest().vendor.info.create('currentVendor', {
					info: data
				}).done(function(data) {
					console.log(data);
					alert("Saved");
				});
				return false;
			});
		});
	});
};

// CREATE vs UPDATE
$( document ).ready(function() {
	$('.hits-vendor-info').hits_vendor_info();
});

