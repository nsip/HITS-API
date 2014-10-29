/*
	HITS: App Edit
*/

var hits_app_view = function(el, existing_id) {
		// XXX ? el or $(el)
		var $this = el;

		console.log(existing_id);
		if (existing_id) {
			// XXX Mask ?
			$this.mask("Loading...");
		}

		if (existing_id) {
			// Loading...
			hits_api.rest().app.read(existing_id)
			.done(function(data) {
				if (!data || !data.app) {
					alert("No data for app_id");
				}
				else {
					console.log(data);
					$.each(data.app, function(name, val) {
						var el = $this.find('[field="' + name + '"]');
						if (el) 
							el.html(val);
					});
					$this.unmask();
				}
			})
			.fail(function() {
				alert("Failed to load app_id");
			});
		}
};

