// Place all the behaviors and hooks related to the matching controller here.

//--- jqGrid
//= require jqgrid/js/jquery.jqGrid.min.js
//= require jqgrid/js/i18n/grid.locale-en.js

//--- Datatables
//= require datatables/media/js/jquery.dataTables.min
//= require datatables-colvis/js/dataTables.colVis
//= require datatables/media/js/dataTables.bootstrap

//--- Datatables Buttons
//= require datatables-buttons/js/dataTables.buttons
//= require datatables-buttons/js/buttons.bootstrap
//= require datatables-buttons/js/buttons.colVis
//= require datatables-buttons/js/buttons.flash
//= require datatables-buttons/js/buttons.html5
//= require datatables-buttons/js/buttons.print
//= require datatables-responsive/js/dataTables.responsive
//= require datatables-responsive/js/responsive.bootstrap

(function(window, document, $, undefined){

  if ( !$.fn.dataTable ) return;

  $(function(){
    //
    // Initial DataTable
    //
    $('#datatable1').dataTable({
      'paging':   true,  // Table pagination
      'ordering': true,  // Column ordering
      'info':     true,  // Bottom left status text
      'responsive': true, // https://datatables.net/extensions/responsive/examples/
      // Text translation options
      // Note the required keywords between underscores (e.g _MENU_)
      oLanguage: {
        sSearch:      'Search all columns:',
        sLengthMenu:  '_MENU_ records per page',
        info:         'Showing page _PAGE_ of _PAGES_',
        zeroRecords:  'Nothing found - sorry',
        infoEmpty:    'No records available',
        infoFiltered: '(filtered from _MAX_ total records)'
      },
      // Datatable Buttons setup
      dom: '<"html5buttons"B>lTfgitp',
      buttons: [
      {extend: 'copy',  className: 'btn-sm' },
      {extend: 'csv',   className: 'btn-sm' },
      {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
      {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
      {extend: 'print', className: 'btn-sm' }
      ]
    });

    // multi step handle
    $('.show-profit').click( function( event ){
        event.preventDefault();
        $('.sync-amz').fadeOut('fast', function() {
          $('.scan-inventory').fadeIn('fast');
        });
      });

      $('.get-access').click( function( event ){
        event.preventDefault();
        $('.scan-inventory').fadeOut('fast', function() {
          $('.payment-step').fadeIn('fast');
        });
      });

      $('.pay-btn').click( function() {
        event.preventDefault();
        $('.payment-step').fadeOut('400');
        $('.table-wrapper').removeClass('blur-teaser');
      });

  });

})(window, document, window.jQuery);