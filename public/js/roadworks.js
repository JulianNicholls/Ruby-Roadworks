$(function() {
    $("div#roadworks-info").load('/road/' + $("select#road").val())

    $("select#road").change(function() {
        $("div#roadworks-info").load('/road/' + this.value);
        $("input#location").val('');
    });

    $("#select-form").submit(function(e) {
        return false;
    });

    $("input#location").bind('keyup', function() {
        // The string is escaped here, and automagically unescaped on receipt

        $("div#roadworks-info").load('/location/' + escape(this.value));
    });
});
