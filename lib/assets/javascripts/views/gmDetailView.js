function gmDetailView(gameId) {
  var view = $('#templates .gm-detail-view').clone();

  function assetItem(link, text) {
    var item = $('#templates .well-item-sm').clone();
    item.find('a').attr('href', link).text(text);
    return item;
  }

  function showGame(game, gmPrepData) {
    var select = $('<select class="form-control">');
    _.each(gmPrepData, function(mod, id) {  
      select.append($("<option>").attr('value', id).text(mod.name));
    })
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
  }

  $.when(fetch('/games/detail?gameId=' + gameId),
         fetch('http://assets.windycitypathfinder.com/gm_prep.json')).done(showGame);
  view.find('.gm-option').show();
  view.find('.player-option').hide();
  return view;
}
