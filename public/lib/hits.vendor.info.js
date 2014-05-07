/*
	HITS: App Vendor
*/

$.fn.hits_vendor_info = function () {
	return this.each(function () {
		var $this = $(this);

		var $form = $this.find('form');

		// Find list of fields
		$form.find('input').each(function(e) {
		});

		// Load existing data
		hits_api.rest().vendor.info.read('currentVendor')
		.done(function(data) {
			if (data && data.info) {
				console.log(data);
			}
		});

		// Bind to save (only after loaded)
		$form.find('button[value="submit"]').click(function() {
			hits_api.rest().app.create({
				name: $form.find('input[name="name"]').val() + '',
				title: $form.find('input[name="title"]').val() + '',
				description: $form.find('input[name="description"]').val() + '',
				site_url: $form.find('input[name="site_url"]').val() + '',
				about: $form.find('input[name="about"]').val() + '',
				tags: $form.find('input[name="tags"]').val() + '',
			}).done(function(data) {
				console.log(data);
				alert("Created, new ID = " + data.id);
			});
			return false;
		});
	});
};

// CREATE vs UPDATE
$( document ).ready(function() {
	$('.hits-vendor-info').hits_vendor_info();
});

