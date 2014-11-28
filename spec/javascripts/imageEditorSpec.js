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

      describe('when sending the chronicle sheet', function() {
        var promise;
        beforeEach(function() {
          promise = new $.Deferred();
          spyOn($, 'ajax').and.returnValue(promise);
        });

        it('sends to players and GM', function() {
          editor.find('.save-btn').click();
          expect($.ajax).toHaveBeenCalledWith({
            method: 'POST',
            url: '/gm/sendChronicle',
            data: {
              gameId: game.gameId,
              imgBase64: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAAABJRU5ErkJggg=='
            }
          });
        });

        it('disables the button while sending', function() {
          //promise.resolve();
          editor.find('.save-btn').click();
          expect(editor.find('.save-btn')).toHaveProp('disabled');
          expect(editor.find('.save-btn')).toHaveText('Sending...');
        });

        it('Updated the button when sent', function() {
          editor.find('.save-btn').click();
          promise.resolve();
          expect(editor.find('.save-btn')).toHaveText('Sent!');
        });

        it('Updated the button when sent', function() {
          editor.find('.save-btn').click();
          promise.reject();
          expect(editor.find('.save-btn')).toHaveText('Failed!');
        });
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
          expect(items[4].find('.field-name').text()).toEqual('Event Code');
          expect(items[4].find('.field-value').val()).toEqual('35556');
        });

        it('Adds the event name (even if none)', function() {
          expect(items[5].find('.field-name').text()).toEqual('Event Name');
          expect(items[5].find('.field-value').val()).toEqual('');
        });

        it('Adds the Date', function() {
          expect(items[0].find('.field-name').text()).toEqual('Date');
          expect(items[0].find('.field-value').val()).toEqual('5 Nov 2014');
        });

        it('Adds GM PFS number', function() {
          expect(items[6].find('.field-name').text()).toEqual('GM PFS #');
          expect(items[6].find('.field-value').val()).toEqual('38803');
        });

        it('Adds the gold gained', function() {
          expect(items[1].find('.field-name').text()).toEqual('Gold Gained');
          expect(items[1].find('.field-value').val()).toEqual('1847');
        });

        it('Adds the prestige gained', function() {
          expect(items[2].find('.field-name').text()).toEqual('Prestige Gained');
          expect(items[2].find('.field-value').val()).toEqual('2');
        });

        it('Adds the XP gained', function() {
          expect(items[3].find('.field-name').text()).toEqual('XP Gained');
          expect(items[3].find('.field-value').val()).toEqual('1');
        });
      });
    });
  });
