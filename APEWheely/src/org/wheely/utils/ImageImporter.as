package org.wheely.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.sampler.NewObjectSample;
	import flash.text.TextField;
	
	public class ImageImporter extends Bitmap {
		private var imageURL:String;
		private var imageRequest:URLRequest;
		private var imageLoader:Loader;

		public function ImageImporter(imgURL:String,width:Number,height:Number)
		{		
			super(new BitmapData(width,height,true,0xff),"auto",true);			
			imageURL = imgURL;
			imageRequest = new URLRequest(imageURL);
			imageLoader = new Loader();
			
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadFail);
			imageLoader.load(imageRequest);
		}
		
		private function imageLoaded(event:Event):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo(event.target);
				loaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
			//draw image	
			bitmapData.draw(loaderInfo.loader);
		}
		
		private function loadFail(event:IOErrorEvent):void
		{
			var messageError:String = "Impossible de charger l'image : "+imageURL;
			
			var textError:TextField = new TextField();
				textError.text = messageError;
				textError.textColor = 0xff0000;
				textError.width = 400;
			 
			// draw error
			bitmapData.draw(textError);
		}
		
		public function get url():String
		{
			return imageURL;
		}
	}
	
}
