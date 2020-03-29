$(document).on( 'ready page:load turbolinks:load', function(){
  bind_deactivate();
});

function bind_deactivate(){
  //Reset all event handlers
  $('#products button').off('click');

  $('#products').find('button.activate').on('click', product.activate);
  $('#products').find('button.deactivate').on('click', product.deactivate);
}

var product = {
  deactivate : function(){
    var row = $(this).closest('tr');

    $.ajax({
      url: '/apps/products/' + row.attr( 'data-id' ) + '/flip',
      type: 'PATCH',
      data: {
        checkout_product: {
          active: false
        }

      }
    }).done(function(){
      toastr.success($(row).find('a').html() + ' is gedeactiveerd');

      $(row)
        .addClass('inactive')
        .find( 'button.deactivate' )
        .empty()
        .removeClass( 'deactivate btn-warning' )
        .addClass( 'activate btn-primary' )
        .append( '<i class="fa fa-fw fa-check"></i> Activeer' );

      //Reset all event handlers
      bind_deactivate();

    }).fail(function(error){
      toastr.error(error.statusText, error.status);
    });
  },

  activate : function(){
    var row = $(this).closest('tr');

    $.ajax({
      url: '/apps/products/' + row.attr('data-id') + '/flip',
      type: 'PATCH',
      data: {
        checkout_product: {
          active: true
        }
      }
    }).done(function(){
      toastr.success($(row).find('a').html() + ' is geactiveerd');

      $(row)
        .removeClass( 'inactive' )
        .find( 'button.activate' )
        .empty()
        .removeClass( 'activate btn-primary inactive' )
        .addClass( 'deactivate btn-warning' )
        .append( '<i class="fa fa-fw fa-times"></i> Deactiveer' );

        bind_deactivate();

    }).fail(function(error){
      toastr.error(error.statusText, error.status);
    });
  }
};
