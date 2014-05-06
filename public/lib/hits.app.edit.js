/*
	HITS: App Edit
*/

$.fn.hits_app_edit = function () {
	return this.each(function () {
		var $this = $(this);

		var $form = $this.find('form');
		if (! $form.length) {
			$this.append('<form></form>');
			$form = $this.find('form');

			// Experimental form - add a new entry
			$form.append("<h2>Javascript FORM Added</h2>");
			$form.append('Example Date Picker: <input id="datepicker"> <br />');
			$form.find('#datepicker').datepicker();

			// var $tbody = $this.find('tbody');
			$form.append('Name: <input name="name"> <br />');
			$form.append('Title: <input name="title"> <br />');
			$form.append('Description: <input name="description"> <br />');
			$form.append('Site URL: <input name="site_url"> <br />');
			$form.append('About URL: <input name="about"> <br />');
			$form.append('Tags: <input name="tags"> <br />');
			$form.append('Icon URL: <input name="icon_url"> <br />');
			$form.append('Public: <input name="public"> <br />');

			$form.append('<br>');
			$form.append('<input type="submit" name="clear" value="Clear">');
			$form.append('<button type="submit" name="submit" value="submit">Save</button>');
		}

		$form.find('input[name="clear"]').click(function() {
			alert("Clearing");
			return false;
		});

		console.log("Adding submit");
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
	$('.hits-appedit').hits_app_edit();
});

