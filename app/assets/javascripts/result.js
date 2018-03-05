$(document).ready(function(){
	alert('Payment Done');
  var table =  $('#result-datatable').DataTable({
      'paging':   true,  // Table pagination
      'ordering': true,  // Column ordering
      'info':     true,  // Bottom left status text
      'responsive': true, // https://datatables.net/extensions/responsive/examples/
      "iDisplayLength" : 10,
      "processing": false,
      "serverSide": false,
      "scrollX": true,
			sAjaxSource: '/renderjson',      
			aoColumns: [
        { mData: 'msku' },
        { mData: 'name' },
        { mData: 'rank' },
        { mData: 'days' },
        { mData: 'ltsf' },
        { mData: 'price' },
        { mData: 'tradein' },
        { mData: 'cash' }
	    ],
			// Text translation options
      // Note the required keywords between underscores (e.g _MENU_)
      oLanguage: {
        sSearch:      'Search all columns:',
        sLengthMenu:  '_MENU_',
        info:         'Showing page _PAGE_ of _PAGES_',
        zeroRecords:  'Nothing found - sorry',
        infoEmpty:    'No records available',
        infoFiltered: '(filtered from _MAX_ total records)',
        pageLength: '10'
      },
      // Datatable Buttons setup
      dom: '<"html5buttons"B>lTfgitp',
      buttons: [
      {extend: 'csv',   className: 'btn-sm' },
      {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
      {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
      ]
    });


	var value_regex =     "^(0*[1-9][0-9]*(\.[0-9]+)?|0+\.[0-9]*[1-9][0-9]*)$";
  
	$('#value-option').change(function(){
		value = $( "#value-option option:selected").text();
		alert(value);
		if (value == "Buy Back") {
			table
				.column(7)
				.search(value_regex, true)
				.draw();
			table
				.column(6)
				.search("")
				.draw();
		}	else if(value == "Trade-in") {
			table
				.column(6)
				.search(value_regex, true)
				.draw();
			table
				.column(7)
				.search("")
				.draw();
		}	else {
			table
				.column(6)
				.search("")
				.draw();
			table
			.column(7)
			.search("")
			.draw();
		} 
	});

	$('#ltsf-option').change(function() {
		value = $( "#ltsf-option option:selected").text();
		if (value == "Show All") {
			value = "";
			table
				.column(4)
				.search(value)
				.draw();
		}	else {
			value = "true";
			table
				.column(4)
				.search(value)
				.draw();
		} 
	});


});