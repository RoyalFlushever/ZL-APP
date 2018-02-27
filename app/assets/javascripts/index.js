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

    
    var filename;

    // Dropzone option config. myDropzone - id: my-dropzone
    Dropzone.options.myDropzone = {
      uploadMultiple: false,  // only upload one file
      maxFiles: 1,            // max file upload file : 1  
      acceptedFiles: ".csv",  // accept .csv file only 
      dictInvalidFileType: "You can't upload files of this type. Only Accept CSV.",
      success: function(file, result){
            filename = result.filename;
      }             
    }

    // progress bar elements
    // 
    var percent = $('.done');
    var message = $('.to-amazon h5');
    var bar = $('.progress-bar');
    // update progressbar every pingTime
    var pingTime = 1000

    // ajax Function for update progress bar
    var ajaxFn = function(){
      $.ajax({
        url: '/start',
        data: { filename: filename },
        dataType: 'json',
        success: function (data) {
          var percentHtml = data.percent + "%";
          bar.css('width', percentHtml);
          $('.tradein-value').html(data.tradein);
          $('.buyback-value').html(data.buyback);
          console.log(percentHtml);
          if ( parseInt(data.percent) < 100 ) {
            message.html(data.message + ": <span class='done'>" + data.percent + "</span> Done");
            setTimeout(ajaxFn, pingTime);
          } else {
            message.html("Finished");
          }
        }
      });
    }

    // multi step handle
    $('.show-profit').click( function( event ){
      $('.sync-amz').fadeOut('fast', function(){
        $('.scan-inventory').fadeIn('fast');
        ajaxFn();
        $.get('/create', {filename: filename});
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

  });

})(window, document, window.jQuery);