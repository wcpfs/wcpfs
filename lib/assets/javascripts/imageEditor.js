function imageEditor(game) {
  var editor = $('#templates .image-editor').clone();
  var canvasElem = editor.find('canvas').get(0);
  var canvas;

  function getSheetUrl() {
    return "http://assets.windycitypathfinder.com/gm_prep/" + game.chronicle.scenarioId + "/chronicle.png";
  }

  function buildCanvas(oImg) {
    function addImage(url, positions) {
      fabric.Image.fromURL(url, function(oImg) {
        _.each(positions, function(pos) {  
          img = fabric.util.object.clone(oImg);
          img.set({
            top: pos.top,
            hasControls: false,
            hasRotatingPoint: false,
            left: pos.left
          });
          canvas.add(img);
        });
      });
    }

    function addEntry(name, value, left, top) {
      if (value === undefined) { value = ''; }
      var text = new fabric.Text(value.toString(), {
        fontFamily: "Permanent Marker",
        hasControls: false,
        hasRotatingPoint: false,
        fontSize: 14,
        fontWeight: 'normal',
        left: left,
        top: top
      });
      canvas.add(text);
      var item = $('#templates .chronicle-item').clone();
      item.find('.field-name').text(name);
      item.find('.field-value').val(value).change(function() {  
        text.set({text: $(this).val()});
        canvas.renderAll();
      });
      editor.find('.chronicle-form').append(item);
    }

    var canvas = new fabric.Canvas(canvasElem, {
      backgroundImage: oImg,
      width: oImg.width,
      height: oImg.height
    });
    addEntry('Date', new Date(game.datetime).format('{d} {Mon} {yyyy}'), 235, 748);
    addEntry('Gold Gained', game.chronicle.goldGained, 510, 580);
    addEntry('Prestige Gained', game.chronicle.prestigeGained, 510, 428);
    addEntry('XP Gained', game.chronicle.xpGained, 510, 315);

    userInfoPromise().done(function(userInfo) {  
      addEntry('Event Code', game.chronicle.eventCode, 172, 748);
      addEntry('Event Name', game.chronicle.eventName, 68, 748);
      addEntry('GM PFS #', userInfo.pfsNumber, 500, 748);
      addImage('/user/signature', [{top: 745, left: 332}]);
      addImage('/user/initials', [ 
        {top: 315, left: 560},
        {top: 427, left: 560},
        {top: 580, left: 560}
      ]);
    })

    editor.find('.save-btn').click(function() {  
      var button = $(this);
      $.ajax({
        method: 'POST',
        url: '/gm/sendChronicle',
        data: {
          gameId: game.gameId,
          imgBase64: canvas.toDataURL()
        }
      })
      .done(function() {  button.text('Sent!'); })
      .fail(function() {  button.text('Failed!'); });
      button.prop('disabled', true);
      button.text('Sending...');
    });

    canvas.renderAll();
  }

  fabric.Image.fromURL(getSheetUrl(), buildCanvas, {crossOrigin: 'anonymous'});
  return editor;
}
