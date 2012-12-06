package org.wheely.game
{
	import org.cove.ape.CollisionEvent;
	import org.cove.ape.Group;
	import org.cove.ape.RectangleParticle;
	
	public class Cleaner extends Group
	{
		private var _cleaner:RectangleParticle
		private var _game:Game;
		private var _hero:Group;
		
		public function Cleaner(gameStageWidth:int,gameStageHeight:int,game:Game, hero:Group)
		{
			super(false);
			_game = game;
			_hero = hero;
			
			_cleaner = new RectangleParticle(gameStageWidth/2,gameStageHeight+gameStageHeight/2+5,gameStageWidth,10,0,false,1,0,0.1);
			_cleaner.collidable = true;
			_cleaner.sprite.name = "cleaner";
			_cleaner.alwaysRepaint = true;
			_cleaner.setFill(0xFF0000,0.8);
			_cleaner.setLine(1,0x550000,0.8);
			
			addParticle(_cleaner);
			addCollidable(hero);
			
			_cleaner.addEventListener(CollisionEvent.COLLIDE, CleanHandler);
		}
		
		private function CleanHandler(event:CollisionEvent):void
		{
			var name:String = event.collidingItem.sprite.name;
			
			if(name=="roue")
			{
				var particle:SpecialWheelParticle = SpecialWheelParticle(event.collidingItem);
				_game.removeGroup(particle.group);
				particle = null;
			}
			else if(name=="hero")
			{
				_game.removeGroup(_hero);
				_hero = null;
				_cleaner.removeEventListener(CollisionEvent.COLLIDE, CleanHandler);
			}
		}
		
		public function get cleaner():RectangleParticle
		{
			return _cleaner;
		}
		
	}
}