package org.wheely.ui
{
	import flash.desktop.NativeApplication;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class HomeView extends View
	{
		private var gui:MovieClip;
		
		public function HomeView(manager:ViewManager)
		{
			super(manager);
			name = "HOME_VIEW";
			addGUI();
		}
		
		private function addGUI():void
		{
			gui = new HomeScreen();
			logicGUI();
			addChild(gui);
		}
		
		private function logicGUI():void
		{
			gui.jouer.addEventListener(MouseEvent.CLICK,jouerHandler);
			gui.scores.addEventListener(MouseEvent.CLICK,displayScoreHandler);
			gui.eteindre.addEventListener(MouseEvent.CLICK,function():void{NativeApplication.nativeApplication.exit();});
			gui.aide.addEventListener(MouseEvent.CLICK,displayHelpHandler);
			gui.options.addEventListener(MouseEvent.CLICK,displayOptionHandler);
		}
		
		private function displayOptionHandler(event:Object):void
		{
			_manager.replaceView(ViewManager.OPTION);
		}
		
		private function displayHelpHandler(event:Object):void
		{
			_manager.replaceView(ViewManager.HELP);
		}
		
		private function jouerHandler(event:Object):void
		{
			_manager.replaceView(ViewManager.GAME);
			var gameV:GameView = GameView(_manager.getView(ViewManager.GAME));
				gameV.startGame();
		}
		
		private function displayScoreHandler(event:Object):void
		{
			_manager.replaceView(ViewManager.SCORE);
		}
		
		//Override
		override public function menuHandler():void{}
	}
}