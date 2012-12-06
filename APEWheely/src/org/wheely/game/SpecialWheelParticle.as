package org.wheely.game
{
	import org.cove.ape.WheelParticle;
	
	public class SpecialWheelParticle extends WheelParticle
	{
		public var group:Wheel;
		
		public function SpecialWheelParticle(x:Number, y:Number, radius:Number,g:Wheel, fixed:Boolean=false, mass:Number=1, elasticity:Number=0.3, friction:Number=0, traction:Number=1)
		{
			super(x, y, radius, fixed, mass, elasticity, friction, traction);
			group = g;
		}
	}
}