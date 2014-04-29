/*
	HITS: App Edit
*/

$.fn.hits_app_edit = function () {
	return this.each(function () {
		var $this = $(this);
		$this.append("<h2>Javascript FORM Added</h2>");
		$this.append('Example Date Picker: <input id="datepicker">');
		$this.find('#datepicker').datepicker();

		// var $tbody = $this.find('tbody');
		$this.append('Name: <input id="name"> <br />');
		$this.append('Title: <input id="title"> <br />');
		$this.append('Description: <input id="description"> <br />');
		$this.append('Site URL: <input id="site_url"> <br />');
		$this.append('About URL: <input id="about"> <br />');
		$this.append('Tags: <input id="tags"> <br />');
		$this.append('Icon URL: <input id="icon_url"> <br />');
		$this.append('Public: <input id="public"> <br />');

		$this.append('<br>');
		$this.append('<input type="submit" name="clear" value="Clear">');
		$this.append('<input type="submit" name="submit" value="Save">');

		$this.find('input[name="clear"]').click(function() {
			alert("Clearing");
			return false;
		});
		$this.find('input[name="submit"]').click(function() {
			hits_api.rest().app.create({
				name: $this.find('input[name="name"]').val(),
				title: $this.find('input[name="title"]').val(),
				description: $this.find('input[name="description"]').val(),
				site_url: $this.find('input[name="site_url"]').val(),
				about: $this.find('input[name="about"]').val(),
				tags: $this.find('input[name="tags"]').val(),
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

