describe('GM Detail View', function() {
  var view, gameObj;

  beforeEach(function() {
    gameObj = fakeGame();
    var gmPrep = {
      "PZOPSS0413E": {
        "name": "4-13 The Fortress of the Nail",
        "title": "PZOPSS0413E"
      },
      "PZOPSS0414E": {
        "name": "4-14 My Enemy's Enemy",
        "title": "PZOPSS0414E"
      }
    };
    fakeRoutes['http://assets.windycitypathfinder.com/gm_prep.json'] = [gmPrep]
    fakeRoutes["/games/detail?id=95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa"] = [gameObj],
    spyOn(window, 'imageEditor');
    spyOn(window, 'store');
  });

  describe('when a scenario has been selected', function() {
    beforeEach(function() {
      gameObj.chronicle = {
        scenarioId: 'PZOPSS0414E'
      };
      view = gmDetailView(game.id);
    });

    it('adds chronicle sheet editor', function() {
      expect(view.find('.chronicle-sheet h2').text()).toEqual('Chronicle Sheet');
    });
  });

  describe('with no selected scenario', function() {
    beforeEach(function() {
      spyOn($, 'ajax');
      view = gmDetailView(game.id);
    });

    it('does not add the chronicle sheet editor', function() {
      expect(view.find('.chronicle-sheet')).not.toBeVisible();
    });

    it('adds the chronicle sheet selector, with no selection', function() {
      expect(view.find('.scenario-selector select').val()).toEqual(null)
    });

    it('can cancel the game', function() {
      view.find('.cancel-game-btn').click();
      expect($.ajax).toHaveBeenCalledWith({
        url: '/games/detail',
        type: 'DELETE',
        data: {gameId: gameObj.id},
        success: jasmine.any(Function)
      });
    });

    describe('when a scenario is selected', function() {
      beforeEach(function() {
        view.find('.scenario-selector select').val('PZOPSS0414E').change();
      });
      
      it('includes adds the chronicle sheet editor', function() {
        expect(view.find('.chronicle-sheet h2').text()).toEqual('Chronicle Sheet');
      });

      it('saves the game', function() {
        expect(window.store).toHaveBeenCalledWith('/gm/game', gameObj);
      });
    });

    it('Adds the date for the game', function() {
      expect(view.find('.when').text()).toEqual('Wednesday, November 5th');
    });

    it('Adds the notes and other fields', function() {
      expect(view.find('.notes').text()).toEqual(game.notes);
    });
  });
});
