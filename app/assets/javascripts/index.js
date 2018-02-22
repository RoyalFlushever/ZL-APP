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
//
//--- Upload
//= require jquery-ui/ui/widget
//= require blueimp-tmpl/js/tmpl
//= require blueimp-load-image/js/load-image.all.min
//= require blueimp-canvas-to-blob/js/canvas-to-blob
//= require blueimp-file-upload/js/jquery.iframe-transport
//= require blueimp-file-upload/js/jquery.fileupload
//= require blueimp-file-upload/js/jquery.fileupload-process
//= require blueimp-file-upload/js/jquery.fileupload-image
//= require blueimp-file-upload/js/jquery.fileupload-audio
//= require blueimp-file-upload/js/jquery.fileupload-video
//= require blueimp-file-upload/js/jquery.fileupload-validate
//= require blueimp-file-upload/js/jquery.fileupload-ui

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
      'pageLength': 50,
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

    // .blur-teaser mouseevent prevent
    $('.blur-teaser').click(function(e){
        e.preventDefault();    
    });

    $('.blur-teaser').keypress(function(e){
        e.preventDefault();
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

    //  // Initialize the jQuery File Upload widget:
    // $('#fileupload').fileupload({
    //     // Uncomment the following to send cross-domain cookies:
    //     //xhrFields: {withCredentials: true},
    //     // url: 'server/upload'
    //   });

    // // Enable iframe cross-domain access via redirect option:
    // $('#fileupload').fileupload(
    //   'option',
    //   'redirect',
    //   window.location.href.replace(
    //     /\/[^\/]*$/,
    //     '/cors/result.html?%s'
    //     )
    //   );

    // // Load existing files:
    // $('#fileupload').addClass('fileupload-processing');
    // $.ajax({
    //     // Uncomment the following to send cross-domain cookies:
    //     //xhrFields: {withCredentials: true},
    //     url: $('#fileupload').fileupload('option', 'url'),
    //     dataType: 'json',
    //     context: $('#fileupload')[0]
    //   }).always(function () {
    //     $(this).removeClass('fileupload-processing');
    //   }).done(function (result) {
    //     $(this).fileupload('option', 'done')
    //     .call(this, $.Event('done'), {result: result});
    //   });
    
    // Basic UI
    // Change this to the location of your server-side upload handler:
    // var url = window.location.hostname === 'blueimp.github.io' ?
    //             '//jquery-file-upload.appspot.com/' : 'server/php/';
    // $('#fileupload').fileupload({
    //     url: url,
    //     dataType: 'json',
    //     done: function (e, data) {
    //         $.each(data.result.files, function (index, file) {
    //             $('<p/>').text(file.name).appendTo('#files');
    //         });
    //     },
    //     progressall: function (e, data) {
    //         var progress = parseInt(data.loaded / data.total * 100, 10);
    //         $('#progress .progress-bar').css(
    //             'width',
    //             progress + '%'
    //         );
    //     }
    // }).prop('disabled', !$.support.fileInput)
    //     .parent().addClass($.support.fileInput ? undefined : 'disabled');  

  });

})(window, document, window.jQuery);