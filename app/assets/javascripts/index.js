// Place all the behaviors and hooks related to the matching controller here.

(function(window, document, $, undefined){

  if ( !$.fn.dataTable ) return;

  $(function(){
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
      init: function() {
        this.on("addedfile", function(file) {

          // Create the remove button
          var removeButton = Dropzone.createElement("<button class='btn btn-danger delete'>Remove file</button>");

          // Capture the Dropzone instance as closure.
          var _this = this;

          // Listen to the click event
          removeButton.addEventListener("click", function(e) {
            // Make sure the button click doesn't submit the form:
            e.preventDefault();
            e.stopPropagation();

            // Remove the file preview.
            _this.removeFile(file);
            $('.complete').hide();
            // If you want to the delete the file on the server as well,
            // you can do the AJAX request here.
          });

          // Add the button to the file preview element.
          file.previewElement.appendChild(removeButton);
        });
      },

      uploadMultiple: false,  // only upload one file
      maxFiles: 1,            // max file upload file : 1  
      acceptedFiles: ".txt",  // accept .txt file only 
      dictDefaultMessage: "Drop Your \"All Inventory File\" Here,<br> Or Click To Upload",
      dictInvalidFileType: "You can't upload files of this type. Only Accept TXT.",
      success: function(file, result){
        if (result.filename) {
          filename = result.filename;
          $(".upload-container").after("<span class='complete'>Complete !</span>");           
        } else {
          alert("Check your TXT file Columns!");          
        }
      }             
    }

    // progress bar elements
    // 
    var percent = $('.done');
    var message = $('.to-amazon h4');
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
          
          $('.tradein-value').html(parseFloat(data.tradein).toFixed(2));
          $('.buyback-value').html(parseFloat(data.buyback).toFixed(2));

          if ( parseInt(data.percent) < 100 ) {
            message.html(data.message + ": <span class='done'>" + data.percent + "</span> Done");
            setTimeout(ajaxFn, pingTime);
          } else {
              message.html("Finished");
              if (data.profit > 0.5)
                $('#get-access').html("Yes! <br/> Get access for $<span class='profit'>" + data.profit +"</span>").attr('data-available', 'true');
              else if(data.profit == 0.0) {
                $('div.buyback').after('<p class="alert">No instant profit found:</p>');
                $('.tradein-value').html('0.00');
                $('.buyback-value').html('0.00');
              } 
              else {
                $('#get-access').html("Yes! <br/> Get access for free").attr('data-available', 'true');
                $('#get-access').html("Yes! <br/> Get access for free").attr('data-charge', 'false');
              }
          }
        }
      });
    }

    // multi step handle
    $('.show-profit').click( function( event ){
      if (!filename) {
        alert("Choose your inventory file first");
      } 
      else if (filename == "Check your TXT file Columns!") {
        alert("Please Check your TXT file Columns! ");
      } 
      else {
        $('.sync-amz').fadeOut('fast', function(){
          $('.scan-inventory').fadeIn('fast');
          ajaxFn();
          $.get('/create', {filename: filename});
        });
      }

    });

    $('#get-access').on('click', function(){
      if ($(this).attr('data-available') == 'false')
      {
        location.href = $(this).attr('data-url2');
      }else{
        if ($(this).attr('data-charge') == 'true')
          next_url = $(this).attr('data-url1') + '?filename=' + filename;   // go to result page if profit > 50 cents
        else
          next_url = $(this).attr('data-url3') + '?filename=' + filename;   // go to result page if profit < 50 cents
        location.href = next_url;
      }

    });
    
  });

})(window, document, window.jQuery);