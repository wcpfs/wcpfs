function gmDetailView(id) {
  var view = $('#templates .gm-detail-view').clone();

  function assetItem(link, text) {
    var item = $('#templates .well-item-sm').clone();
    item.find('a').attr('href', link).text(text);
    return item;
  }

  function parseChronicles(text) {
    var chronicles = text.trimRight().split('\n').map(function(line) {  
      return JSON.parse(line);
    });
    return _.sortBy(chronicles, 'name');
  }

  function showGame(game, gmPrepData) {
    var select = $('<select class="form-control">');
    select.append($("<option>").
        attr('value', '').
        prop('disabled', true).
        prop('selected', true).
        text("Select a Scenario or Module"));
    var chronicles = gmPrepData.trimRight().split('\n');
    _.each(parseChronicles(gmPrepData), function(entry) {  
      select.append($("<option>").attr('value', entry.id).text(entry.name));
    });

    function updateGMPrep() {
      if (game.chronicle && game.chronicle.scenarioId) {
        select.val(game.chronicle.scenarioId);
        var chronicleSheetElem = $('#templates .chronicle-sheet').clone();
        chronicleSheetElem.append(imageEditor(game));
        view.find('.chronicle-sheet').remove();
        view.append(chronicleSheetElem);
      }
    }
    view.find('.scenario-selector').append(select);
    select.change(function() {  
      var id = $(this).val();
      game.chronicle = {
        scenarioId: id
      };
      updateGMPrep();
      store('/gm/game', game);
    })
    populateGameTemplate(game, view);
    updateGMPrep();
    view.find('.cancel-game-btn').click(function() {  
      $.ajax({
        url: '/games/detail',
        type: 'DELETE',
        data: {gameId: game.id},
        success: function() { 
          changeToView('message', "This game has been canceled");
        }
      });
    })
    view.find('.detail-link').text("http://" + window.location.host + "/#gameDetail-" + game.id)
  }

  $.when(fetch('/games/detail?id=' + id),
         $.get('http://assets.windycitypathfinder.com/chronicles.lson').pipe(_.identity)).done(showGame);
  return view;
}
