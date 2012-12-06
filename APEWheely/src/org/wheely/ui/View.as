package org.wheely.ui
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	public class View extends Sprite
	{
		protected var _manager:ViewManager;
		protected var _sub:Boolean = false;
		protected var _currentSub:Subview;
		
		/**Abstract class describing a customizable view*/
		public function View(manager:ViewManager)
		{
			if (getQualifiedClassName(this) == "org.wheely.ui::View") {
				throw new ArgumentError("View can't be instantiated directly");
			}
			_manager = manager;
		}
		
		protected function getStage():Stage
		{
			return _manager.getStage();
		}
		
		protected function openSubView(subview:Subview):void
		{
			if(!_sub)
			{
				addChild(subview);
				_sub = true;
				_currentSub = subview;
			}
		}
		
		protected function closeSubView():void
		{
			if(_sub)
			{
				removeChild(_currentSub);
				_sub = false;
			}
		}
		
		public function menuHandler():void 
		{trace("Key MENU Pressed");}
	}
}