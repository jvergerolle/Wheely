package org.wheely.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	import org.wheely.game.Game;
	import org.wheely.utils.DatabaseManager;
	import org.wheely.utils.ImageImporter;
	import org.wheely.utils.Tools;

	public class GameView extends View
	{
		private var _container:Sprite;
		private var _game:Game;
		private var _scoreHandler:ScoreZone;
		private var _pauseSubView:Subview = new Subview();
		private var _endSubView:Subview = new Subview();
		private var _registeredSubView:Subview = new Subview();
		private var _endClip:Fin;
		private var _endClip2:Fin2;
		private var _highestScore:SharedObject = SharedObject.getLocal("highscore");
		
		public var paused:Boolean = false;
		public var ended:Boolean = false;
		
		public function GameView(manager:ViewManager)
		{
			super(manager);
			name = "GAME_VIEW";
			createSubviews();
		}
		
		public function startGame():void
		{
			_container = new Sprite();
			_container.addEventListener("END_GAME",endGame);
			_scoreHandler  = new ScoreZone;
			_scoreHandler.scaleX = _scoreHandler.scaleY = 0.5;
			_scoreHandler.addEventListener(MouseEvent.CLICK,openMenuOnPause);
			_game = new Game(getStage(),_container,_scoreHandler);
			
			createBackground();  // TO IMPROVE -> ADD DYNAMIC BACKGROUND
			
			addChild(_container);
			addChild(_scoreHandler);
			
			_game.initNewGame(_container);
			ended = false;
		}
		
		private function createBackground():void
		{
			var bckgbloc:BackgroundBloc = new BackgroundBloc();
			var bmpBloc:BitmapData = new BitmapData(bckgbloc.width,bckgbloc.height, true);
				bmpBloc.draw(bckgbloc);
				
			for(var i:int=-300; i<600; i++)
			{
				var bmp:Bitmap = new Bitmap(bmpBloc);
				bmp.y = -1*i*55;
				bmp.alpha = .5;
				_container.addChild(bmp);
			}
			
		}
		
		private function restartGame(event:Object):void
		{
			event.stopPropagation();
			resetGame();
			startGame();
		}
		
		public function resetGame():void
		{
			removeChild(_container);
			removeChild(_scoreHandler);
			_game = null;
			closeSubView();
		}
		
		public function closeGame(event:Object):void
		{
			resetGame();
			_manager.replaceView(ViewManager.HOME);
		}
		
		private function resumeGame(event:Object):void
		{
			event.stopPropagation();
			_game.pauseGame();
			closeSubView();
		}
		
		private function endGame(event:Event):void
		{
			event.stopPropagation();
			ended = true;
			
			_highestScore = SharedObject.getLocal("highscore");
			
			if (_highestScore.data.value == undefined || _highestScore.data.value<_game.score)
			{
				_highestScore.data.value = _game.score;
			}
			else
			{
				_endClip.best_score.visible = false;
			}
			
			_endClip.score.text = _game.score+"m";
			
			openSubView(_endSubView);
		}
		
		private function registerScore(event:Object):void
		{
			var dbm:DatabaseManager = new DatabaseManager();
				dbm.open("create");
				dbm.setLocalScoreList(_endClip.input_name.text,_game.score);
				dbm.open("read");
			closeSubView();
			openSubView(_registeredSubView);	
			
			var arr:Array = dbm.getLocalScoreList();
			var limit:int = arr.length;
			
			if(limit>5)limit = 5;
			for(var i:int=0;i<limit;i++)
			{
				var j:int = i+1;
				_endClip2["nm"+j].text = arr[i].name;
				_endClip2["sc"+j].text = arr[i].score;
			}
			
		}
		
		private function createSubviews():void
		{
			var pauseClip:Pause = new Pause();
				pauseClip.resume.addEventListener(MouseEvent.CLICK,resumeGame);
				pauseClip.restart.addEventListener(MouseEvent.CLICK,restartGame);
				pauseClip.main_menu.addEventListener(MouseEvent.CLICK,closeGame);
				pauseClip.y = _manager.getStage().stageHeight/2-pauseClip.height/2;
			
			var endClip:Fin = new Fin();
				endClip.register.addEventListener(MouseEvent.CLICK,registerScore);
				endClip.restart.addEventListener(MouseEvent.CLICK,restartGame);
				endClip.main_menu.addEventListener(MouseEvent.CLICK,closeGame);
				endClip.y = _manager.getStage().stageHeight/2-endClip.height/2;
				_endClip = endClip;
				_endClip.addEventListener(Event.ADDED_TO_STAGE,refreshName);
			
			var endClip2:Fin2 = new Fin2();
				endClip2.restart.addEventListener(MouseEvent.CLICK,restartGame);
				endClip2.main_menu.addEventListener(MouseEvent.CLICK,closeGame);
				endClip2.y = _manager.getStage().stageHeight/2-endClip2.height/2;
				_endClip2 = endClip2;
				
			var bckg:Sprite = new Sprite();
				bckg.graphics.beginFill(0xffffff,0.8);
				bckg.graphics.drawRect(0,0,_manager.getStage().stageWidth,_manager.getStage().stageHeight);
				bckg.graphics.endFill();	
				
			var bckg2:Sprite = new Sprite();
				bckg2.graphics.beginFill(0xffffff,0.8);
				bckg2.graphics.drawRect(0,0,_manager.getStage().stageWidth,_manager.getStage().stageHeight);
				bckg2.graphics.endFill();
			
			_endSubView.addChild(bckg);
			_registeredSubView.addChild(bckg2);
			_pauseSubView.addChild(pauseClip);
			_endSubView.addChild(endClip);
			_registeredSubView.addChild(endClip2);
		}		
		
		protected function refreshName(event:Event):void
		{
			var playerName:SharedObject = SharedObject.getLocal("playerName");
			_endClip.input_name.text = playerName.data.name;
		}
		
		private function openMenuOnPause(event:Object):void{ menuHandler(); }
		
		override public function menuHandler():void
		{
			if(!ended)
			{
				_game.pauseGame();
				if(_sub)
				{
					closeSubView();
					paused = false;
				}
				else
				{
					openSubView(_pauseSubView);
					paused = true;
				}
			}
		}
	}
}