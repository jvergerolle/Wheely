package org.wheely.ui
{
	import flash.desktop.NativeApplication;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.wheely.game.Game;
	
	public class ViewManager extends Sprite
	{
		private var _viewer:MovieClip;
		private var _currentView:View;
		private var _stage:Stage;
		private var _homeView:View;
		private var _gameView:GameView;
		private var _optionView:View;
		private var _scoreView:View;
		private var _helpView:View;
		
		public static const HOME:String = "HOME";
		public static const GAME:String = "GAME";
		public static const OPTION:String = "OPTION";
		public static const SCORE:String = "SCORE";
		public static const HELP:String = "HELP";
		
		public function ViewManager(stage:Stage):void
		{
			_stage = stage;
			_viewer = new MovieClip();
			addChild(_viewer);
			
			_homeView = new HomeView(this);
			_gameView = new GameView(this);
			_scoreView = new ScoreView(this);
			_helpView = new HelpView(this);
			_optionView = new OptionView(this);
			
			pushView(ViewManager.HOME);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,sleep);
		}
		
		//Control View
		private function pushView(viewName:String):void
		{
			_currentView = getView(viewName);
			_viewer.addChild(_currentView);
		}
		
		public function replaceView(viewName:String):void
		{
			_viewer.removeChild(_currentView);
			pushView(viewName);
		}
		
		//Access to View
		/**
		 * Get a specific view from the ViewManager
		 * you can any constant provided by the ViewManager
		 **/
		public function getView(viewName:String=null):View
		{
			switch(viewName)
			{
				case "HOME":
				{
					return _homeView;
					break;
				}
				
				case "GAME":
				{
					return _gameView;
					break;
				}	
				
				case "OPTION":
				{
					return _optionView;
					break;
				}	
				
				case "SCORE":
				{
					return _scoreView;
					break;
				}
					
				case "HELP":
				{
					return _helpView;
					break;
				}	
					
				default:
				{
					return _currentView;
					break;
				}
			}
		}
		
		//Access to Stage
		public function getStage():Stage
		{
			return _stage;
		}
		
		//Button Events
		private function keyHandler(event:KeyboardEvent):void
		{
			// Mise en pause à l'appui sur les bouton MENU ou BACK
			if(event.keyCode == Keyboard.MENU )
			{
				_currentView.menuHandler();
			}
		}
		
		private function sleep(event:Event):void
		{
			if (_currentView == getView(GAME))
			{
				var v:GameView = GameView(_currentView);
				if(!v.paused && !v.ended)
					_currentView.menuHandler();
			}
		}
	}
}