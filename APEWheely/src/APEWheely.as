package
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	
	import org.wheely.game.Game;
	import org.wheely.ui.ViewManager;
	import org.wheely.utils.FPSMonitor;
	import org.wheely.utils.ImageImporter;
	
	[SWF(frameRate="30")]
	
	public class APEWheely extends MovieClip
	{	
		private var splash:ImageImporter;
		private var time:Timer;
		
		public function APEWheely()
		{	
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			var playerName:SharedObject = SharedObject.getLocal("playerName");
			if(playerName.data.name == undefined)
				playerName.data.name = "Entrez un nom";
			
			splash = new ImageImporter("org/wheely/assets/image/splash.png",480,800);
			addChild(splash);
			
			time = new Timer(3000);
			time.addEventListener(TimerEvent.TIMER, startx);
			time.start();
		}
		
		protected function startx (event:TimerEvent):void
		{
			time.removeEventListener(TimerEvent.TIMER, startx);
			time = null;
			
			removeChild(splash);
			splash = null;
			
			var viewManager:ViewManager = new ViewManager(this.stage);
			addChild(viewManager);
		}
	}
}