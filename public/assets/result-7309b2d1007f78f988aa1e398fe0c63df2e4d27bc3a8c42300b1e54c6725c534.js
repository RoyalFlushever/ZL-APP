$(document).ready(function(){

	$(window).on("load", function(){
		set_hidden_data();
		$('#download_form input[type="submit"]').removeAttr('data-disable-with');
	});


});
