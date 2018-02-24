// Place all the behaviors and hooks related to the matching controller here.


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
      'pageLength': 10,
      // Text translation options
      // Note the required keywords between underscores (e.g _MENU_)
      oLanguage: {
        sSearch:      'Search all columns:',
        sLengthMenu:  '_MENU_ records per page',
        info:         'Showing page _PAGE_ of _PAGES_',
        zeroRecords:  'Nothing found - sorry',
        infoEmpty:    'No records available',
        infoFiltered: '(filtered from _MAX_ total records)',
        pageLength: '10'
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
      $('.sync-amz').fadeOut('fast', function() {
        $('.scan-inventory').fadeIn('fast');
      });
    });

    $('.get-access').click( function( event ){
      $('.scan-inventory').fadeOut('fast', function() {
        $('.payment-step').fadeIn('fast');
      });
    });

    $('.pay-btn').click( function() {
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