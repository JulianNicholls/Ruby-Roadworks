$(function() {
    $("select#road").change( function() {
        $("div#roadworks-info").load( '/road/' + $(this).val() );
        $("input#location").val( '' );
    });

    $("input#location").bind( 'keyup', function() {
       $("div#roadworks-info").load( 'data_access.php?location=' + $(this).val() );
    });
});
