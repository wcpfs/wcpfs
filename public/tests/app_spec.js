var game = {
  gameId: "95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa",
  notes: "Tier 4-5. Playing online using Skype and MapTools.",
  gm_name: "Ben Rady",
  gm_pic: "/img/preloader.gif",
  datetime: 1415221200000,
  title: "City of Golden Death (Online)",
  seats: [{name: 'adisney'}, {name: 'renedq'}],
  chronicle: {
    sheetUrl: "/game/95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa/chronicle.png",
    goldGained: 1847,
    prestigeGained: 2,
    xpGained: 1,
    eventCode: 35556,
    gmPfsNumber: 38803
  }
};

var gameList = [
  game, 
  _.extend({}, game, {
    "seats": [{name: 'adisney'}, {name: 'renedq'}, {name: 'renedq'}, {name: 'foo'}, {name: 'xyz'}, {name: 'abc'}]
  })
];

var fakeRoutes = {
  "/games": [gameList],
  "/user/info": [{pic: '/img/preloader.gif'}],
  "/games/detail?gameId=95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa": gameList,
  "/user/games": [{playing: [game], running: gameList}]
}

describe('WCPFS', function() {
  beforeEach(function() {
    spyOn($, 'getJSON').and.callFake(function(url, callback) {  
      if (callback) {
        callback.apply(this, fakeRoutes[url])
      }
    })
  });

  it('Can use profile information in a view', function() {
    expect(1).toEqual(2);
  });

  it('can serve static views', function() {
    spyOn(window, 'currentView').and.returnValue('about');
    var view = staticView();
    expect(view.find('h2').text()).toEqual("About Windy City Pathfinder");
  });

  describe('Home View', function() {
    var view;
    beforeEach(function() {
      view = homeView();
    });

    it('Lists the available games', function() {
      expect(view.find('.game-list > li').length).toEqual(2);
    });

    describe('game items', function() {
      var item, fullGameItem;
      beforeEach(function() {
        item = view.find('.game-list > li:first');
        fullGameItem = view.find('.game-list > li:last');
      });

      it('includes the title', function() {
        expect(item.find('.title').text()).toEqual("City of Golden Death (Online)");
      });

      it('includes the date', function() {
        expect(item.find('.when').text()).toEqual("Wednesday, November 5th");
      });

      it('includes the button to join the game', function() {
        expect(item.find('.join-button').attr('href')).toEqual("/user/joinGame?gameId=95c3ff0b-ae7d-4a9f-9a82-ab5b3f6f57fa");
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

  describe("New Game View", function() {
    var view;
    beforeEach(function() {
      view = newGame();
    });

    it('disables the submit button until the fields are filled in', function() {
      expect(view.find('button.new-game-submit').prop('disabled')).toBeTruthy();
    });

    it('Enables the submit button when all fields are entered', function() {
      view.find('input.game-title').val('My Title').change();
      view.find('input.datetime').val('5pm February 13th, 2009').change();
      expect(view.find('button.new-game-submit').prop('disabled')).toBeFalsy();
    });

    it('parses the date and places the timestamp in a hidden field', function() {
      view.find('input.datetime').val('5pm February 13th, 2009').change();
      expect(view.find('input.datetime-hidden').val()).toEqual('1234566000000');
    });
  });

  describe('Message View', function() {
    it('shows a message', function() {
      var view = messageView("Hello World");
      expect(view.find('.message').text()).toEqual("Hello World");
    });
  });

  describe('GM Detail View', function() {
    var view;
    beforeEach(function() {
      spyOn(window, 'imageEditor');
      view = gmDetailView(game.gameId);
    });

    it('Adds chronicle sheet to assets', function() {
      var item = view.find('.asset-list li:first a');
      expect(item.text()).toEqual("Chronicle Sheet");
      expect(item.attr('href')).toEqual(game.chronicle.sheetUrl);
    });
  });

  describe('Game Detail View', function() {
    var view;
    beforeEach(function() {
      view = gameDetailView(game.gameId);
    });

    it('Adds the date for the game', function() {
      expect(view.find('.when').text()).toEqual('Wednesday, November 5th');
    });

    it('Adds the notes and other fields', function() {
      expect(view.find('.notes').text()).toEqual(game.notes);
    });

    it('Adds the join button', function() {
      expect(view.find('.join-button').text()).toEqual('Join Now!');
    });
    
  });

  describe('profile view', function() {
    var view;
    beforeEach(function() {
      view = profileView();
    });

    it('fetches the list of games playing', function() {
      expect(view.find('.games-playing li').length).toEqual(1);
      expect(view.find('.games-playing li:first a').text()).toEqual('City of Golden Death (Online)');
    });

    it('fetches the list of games running', function() {
      expect(view.find('.games-running li').length).toEqual(2);
      expect(view.find('.games-running li:first a').text()).toEqual('City of Golden Death (Online)');
    });

    it('Links to the GM view for games youre running', function() {
      expect(view.find('.games-running li:first a').attr('href')).toEqual('#gmDetail-' + game.gameId);
    });
  });

  describe('Image Editor', function() {
    var editor;

    beforeEach(function() {
      spyOn(fabric.Image, 'fromURL');
      editor = imageEditor(game);
    });

    describe('when the chronicle image is loaded', function() {
      var dataUrl = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAAABJRU5ErkJggg==';
      var img, canvas;

      beforeEach(function() {
        canvas = jasmine.createSpyObj('canvas', ['toDataURL', 'add', 'renderAll']);
        canvas.toDataURL.and.returnValue(dataUrl);
        img = {width: 628, height: 816};
        spyOn(fabric, 'Canvas').and.returnValue(canvas);
        spyOn(fabric, 'Text');
        fabric.Image.fromURL.calls.argsFor(0)[1](img);
      });

      it('creates a canvas', function() {
        expect(fabric.Canvas).toHaveBeenCalledWith(editor.find('canvas').get(0), {
          backgroundImage: img,
          width: 628,
          height: 816
        });
      });

      it('creates a download link', function() {
        expect(editor.find('.save-btn').click().attr('href')).toEqual(dataUrl);
      });

      describe('filling in form values', function() {
        var items;

        beforeEach(function() {
          items = _.map(editor.find('.chronicle-item'), $);
        });

        it('creates Text objects for each field', function() {
          expect(fabric.Text.calls.count()).toEqual(7);
        });

        it('Adds the event code', function() {
          expect(items[0].find('.field-name').text()).toEqual('Event Code');
          expect(items[0].find('.field-value').val()).toEqual('35556');
        });

        it('Adds the event name (even if none)', function() {
          expect(items[1].find('.field-name').text()).toEqual('Event Name');
          expect(items[1].find('.field-value').val()).toEqual('');
        });

        it('Adds the Date', function() {
          expect(items[2].find('.field-name').text()).toEqual('Date');
          expect(items[2].find('.field-value').val()).toEqual('5 Nov 2014');
        });

        it('Adds GM PFS number', function() {
          expect(items[3].find('.field-name').text()).toEqual('GM PFS #');
          expect(items[3].find('.field-value').val()).toEqual('38803');
        });

        it('Adds the gold gained', function() {
          expect(items[4].find('.field-name').text()).toEqual('Gold Gained');
          expect(items[4].find('.field-value').val()).toEqual('1847');
        });

        it('Adds the prestige gained', function() {
          expect(items[5].find('.field-name').text()).toEqual('Prestige Gained');
          expect(items[5].find('.field-value').val()).toEqual('2');
        });

        it('Adds the XP gained', function() {
          expect(items[6].find('.field-name').text()).toEqual('XP Gained');
          expect(items[6].find('.field-value').val()).toEqual('1');
        });
      });
    });
  });
});
