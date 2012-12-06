package org.wheely.game
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.cove.ape.CircleParticle;
	import org.cove.ape.CollisionEvent;
	import org.cove.ape.Group;
	import org.cove.ape.SpringConstraint;
	import org.cove.ape.VectorForce;
	import org.cove.ape.WheelParticle;

	public class Wheely extends Group
	{	
		private var _body:WheelParticle;
		private var _connector:SpringConstraint;
		private var _lastWheelCollided:SpecialWheelParticle;
		private var _highWheelCollided:Number;
		private var _stage:Stage;
		private var _game:Game;
		private var _platform:String;
		private var _phantomParticle:CircleParticle;
		private var _rotationAngle:Number = 0;
		private var _inAir:Boolean = true; 
		
		public function Wheely(x:Number,y:Number,s:Stage,g:Game):void
		{
			super(false);
			_stage = s;
			_game = g;
			_body = new WheelParticle(x,y,8,false, 1, 0, 0);
			_body.multisample = 5;
			_body.addEventListener(CollisionEvent.COLLIDE, CollisionHandler);
			var face:HeroFace = new HeroFace();
			face.cacheAsBitmap = true;
			_body.setDisplay(face);
			_body.sprite.name = "hero";
			addParticle(_body);
			
			_phantomParticle = new CircleParticle(0,0,8,false, 1, 0, 0);
			_phantomParticle.collidable = false;
			_phantomParticle.visible = false;
			addParticle(_phantomParticle);
		}
		
		private function CollisionHandler(event:CollisionEvent):void
		{
			_platform = event.collidingItem.sprite.name;
			
			if(_platform == "roue")
			{
				_inAir = false;
				_lastWheelCollided = SpecialWheelParticle(event.collidingItem);
				bindTo(_lastWheelCollided);
			}
			else if(_platform == "bomb")
			{
				jump(); 
				
				for each(var w:Wheel in _game.wheels)
				{
					w.particle.solid = false;
				}
				
				listenCollision(false);
				var bombinette:SpecialWheelParticle = SpecialWheelParticle(event.collidingItem);
				bombinette.sprite.visible = false;
				_game.addExplosion(bombinette.px, bombinette.py);
				_game.worldMobile = false;
				_game.endGame();
			}
			else{_inAir = false;}
			
			if(_lastWheelCollided.py < _highWheelCollided)
			{
				setHighestWheel(_lastWheelCollided.py);
				_game.createWheel();
			}	
		}
		
		private function bindTo(wheelCollided:SpecialWheelParticle):void
		{
			//Bind and get angle
			var connector:SpringConstraint = new SpringConstraint(_body,wheelCollided,1,false);
			connector.restLength = wheelCollided.radius+_body.radius;
			connector.visible = false;
			addConstraint(connector);
			
			_rotationAngle = connector.radian;
			removeConstraint(connector);
			
			//Let's move!
			_phantomParticle.fixed = false;
			_stage.addEventListener(Event.ENTER_FRAME,moveWheely);
		}
		
		private function moveWheely(event:Event):void
		{
			var group:Wheel = _lastWheelCollided.group;
			_rotationAngle += group.rotation*2.05;
			
			_body.px = _lastWheelCollided.px + Math.cos(_rotationAngle)*(_lastWheelCollided.radius+_body.radius); 
			_body.py = _lastWheelCollided.py + Math.sin(_rotationAngle)*(_lastWheelCollided.radius+_body.radius);
			
			//Move target
			_phantomParticle.px = _lastWheelCollided.px + Math.cos(_rotationAngle)*(_lastWheelCollided.radius+_phantomParticle.radius+100);
			_phantomParticle.py = _lastWheelCollided.py + Math.sin(_rotationAngle)*(_lastWheelCollided.radius+_phantomParticle.radius+100);
		}
		
		public function jump():void
		{
			if(!_inAir && _platform=="roue")
			{
				//find new position using target position
				var newPosX:Number = _phantomParticle.px - _body.px;
				var newPosY:Number = _phantomParticle.py - _body.py;
				
				_phantomParticle.fixed = true;
				_stage.removeEventListener(Event.ENTER_FRAME,moveWheely);
				
				_body.addForce(new VectorForce(false,newPosX,newPosY));

				_lastWheelCollided.collidable = true;

				_inAir = true;
			}
			else if(!_inAir && _platform == "mur droite")
			{
				_body.addForce(new VectorForce(false,-100,-110));
				_inAir = true;
			}
			else if(!_inAir && _platform == "mur gauche")
			{
				_body.addForce(new VectorForce(false,100,-110));
				_inAir = true;
			}
		}
		
		public function listenCollision(status:Boolean):void
		{
			if(status)
				_body.addEventListener(CollisionEvent.COLLIDE, CollisionHandler);
			else
				_body.removeEventListener(CollisionEvent.COLLIDE, CollisionHandler);
		}
		
		public function toggleMove(b:Boolean):void
		{
			if(b)
			{
				_stage.addEventListener(Event.ENTER_FRAME,moveWheely);
			}
			else
			{
				_stage.removeEventListener(Event.ENTER_FRAME,moveWheely);
			}
		}
		
		public function get body():WheelParticle
		{
			return _body;
		}
		
		public function get radius():Number
		{
			return _body.radius;
		}
		
		public function get dynamicState():Boolean
		{
			return _inAir;
		}
		
		public function setHighestWheel(wheelposition:Number):void
		{
			_highWheelCollided = wheelposition;
			
			//update score
			if(wheelposition < 0)
				_game.updateScore(int((wheelposition*-1)/10));
			else
				_game.updateScore(int((wheelposition)/10));
		}
	}
}