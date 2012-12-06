package org.wheely.utils
{
	public class Tools
	{
		public function Tools()
		{
		}
		
		public static function random(min:Number=0,max:Number=1):Number
		{
			return Math.floor(Math.random() * (1+max-min)) + min;
		}
	}
}