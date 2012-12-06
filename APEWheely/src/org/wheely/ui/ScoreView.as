package org.wheely.ui
{
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	import org.wheely.ui.touchlist.controls.TouchList;
	import org.wheely.ui.touchlist.events.ListItemEvent;
	import org.wheely.ui.touchlist.renderers.TouchListItemRenderer;
	import org.wheely.utils.DatabaseManager;

	public class ScoreView extends View
	{
		private var homeReturn:RetourMenu;
		private var touchList:TouchList;
		private var scoreArray:Array = new Array();
		
		public function ScoreView(manager:ViewManager)
		{
			super(manager);
			name = "SCORE_VIEW";
			addEventListener(Event.ADDED_TO_STAGE,refreshData);
		}
		
		private function refreshData(event:Event):void
		{
			addGUI();
		}
		
		private function addGUI():void
		{
			var _stage:Stage = _manager.getStage();
			
			//create top button
			homeReturn = new RetourMenu();
			homeReturn.addEventListener(MouseEvent.CLICK,returnHome);
			addChild(homeReturn);
			
			//create List
			touchList = new TouchList(_stage.stageWidth, _stage.stageHeight-homeReturn.height);
			touchList.addEventListener("LIST_READY",fillList);
			touchList.y = homeReturn.height;
			addChild(touchList);
		}
		
		private function fillList(event:Event=null):void
		{
			var _highestScore:SharedObject = SharedObject.getLocal("highscore");

			if (_highestScore.data.value != undefined)
			{
				var dbm:DatabaseManager = new DatabaseManager();
				dbm.open("read");
				scoreArray = dbm.getLocalScoreList();
				
				var j:int = 0;
				for each(var sc:Object in scoreArray) 
				{
					var item:TouchListItemRenderer = new TouchListItemRenderer();
					item.index = j;
					item.data = sc.name+" - "+ sc.score;
					item.itemHeight = 80;
					
					touchList.addListItem(item);
					j++;
				}
			}
		}
		
		private function returnHome(event:Object):void
		{
			_manager.replaceView(ViewManager.HOME);
		}
	}
}