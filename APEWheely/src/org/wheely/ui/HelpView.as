package org.wheely.ui
{
	import flash.events.MouseEvent;

	public class HelpView extends View
	{
		private var helpClip:HelpScreen;
		
		public function HelpView(manager:ViewManager)
		{
			super(manager);
			name = "HELP_VIEW";
			helpClip = new HelpScreen();
			helpClip.home.addEventListener(MouseEvent.CLICK, returnHome);
			addChild(helpClip);
		}
		
		private function returnHome(event:Object):void
		{
			_manager.replaceView(ViewManager.HOME);
		}
	}
}