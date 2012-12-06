package org.wheely.ui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	import org.wheely.utils.DatabaseManager;

	public class OptionView extends View
	{
		private var optionClip:OptionScreen;
		private var playerName:SharedObject;
		
		public function OptionView(manager:ViewManager)
		{
			super(manager);
			name = "OPTION_VIEW";
			
			var bckg:Sprite = new Sprite();
				bckg.graphics.beginFill(0xffffff);
				bckg.graphics.drawRect(0,0,_manager.getStage().stageWidth,_manager.getStage().stageHeight);
				bckg.graphics.endFill();
			addChild(bckg);
			
			optionClip = new OptionScreen();
			optionClip.home.addEventListener(MouseEvent.CLICK, returnHome);
			optionClip.restart.addEventListener(MouseEvent.CLICK, resetData);
			optionClip.register.addEventListener(MouseEvent.CLICK, registerName);
			addChild(optionClip);
		}
		
		protected function registerName(event:MouseEvent):void
		{
			playerName = SharedObject.getLocal("playerName");
			playerName.data.name = optionClip.input_name.text;
		}
		
		protected function resetData(event:MouseEvent):void
		{
			var dbm:DatabaseManager = new DatabaseManager();
			dbm.open("update");
			dbm.resetDatabase();
		}
		
		private function returnHome(event:Object):void
		{
			_manager.replaceView(ViewManager.HOME);
		}
	}
}