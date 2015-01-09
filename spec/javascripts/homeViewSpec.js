  describe('Home View', function() {
    var view;
    beforeEach(function() {
      gameList[1].datetime = 1414221200000
      view = homeView();
    });

    it('Lists the available games', function() {
      expect(view.find('.game-list > li').length).toEqual(2);
    });

    describe('game items', function() {
      var item, fullGameItem;
      beforeEach(function() {
        fullGameItem = view.find('.game-list > li:first');
        item = view.find('.game-list > li:last');
      });

      it('includes the title', function() {
        expect(item.find('.title').text()).toEqual("City of Golden Death (Online)");
      });

      it('are sorted by date', function() {
        expect(fullGameItem.find('.when').text()).toEqual("Saturday, October 25th");
        expect(item.find('.when').text()).toEqual("Wednesday, November 5th");
      });

      it('includes the button to join the game', function() {
        expect(item.find('.join-button').attr('href')).toEqual("/user/joinGame?id=95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa");
      });

      it('includes the game detail button', function() {
        expect(item.find('.detail-button').attr('href')).toEqual("/#gameDetail-95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa");
      });

      it('marks the game as full when there are 6 players', function() {
        var btn = fullGameItem.find('.join-button');
        expect(btn.attr('href')).toBeUndefined();
        expect(btn.hasClass('btn-danger')).toBeTruthy();
        expect(btn.prop('disabled')).toBeTruthy();
      });

      it('include the GM', function() {
        expect(item.find('.gm_name').text()).toEqual("Ben Rady");
        expect(item.find('.gm_profile_pic').attr('src')).toEqual('/img/preloader.gif');
      });

      it('adds the list of players', function() {
        expect(item.find('.player-list li').length).toEqual(2);
        expect(item.find('.player-list li:first').text()).toEqual('adisney');
      });

      it('includes the number of available seats', function() {
        expect(item.find('.seats-available').text()).toEqual('4');
      });
    });
  });
