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
$('.hdd-dashboard-back').click(function() {
	$('.hdd-body').hide();
	$('#hdd-body-apps').show();
});
$('#hdd-button-create').click(function() {
	$('.hdd-body').hide();
	$('#hdd-body-create').show();
	var $this = $('#create-results');
	$this.html("Loading...");
	$this.mask("Loading...");
	hits_api.rest().sif.read($.url().attr('fragment'))
	.done(function(data) {
		$this.unmask();
		if (data.success) {
			$this.html("<h1>Success</h1><p>" + data.note + "</p>");
		}
		else {
			$this.html("<h1>ERROR</h1><p>" + data.error + "</p><p>" + data.database + "</p>");
		}
	});
});

