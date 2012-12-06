package org.wheely.game
{	
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.cove.ape.Group;
	import org.cove.ape.SpringConstraint;
	import org.cove.ape.VectorAPE;
	import org.wheely.utils.Tools;

	public class Wheel extends Group
	{
		private var _fixedWheel:SpecialWheelParticle;
		private var _wheel:SpecialWheelParticle;
		private var _connector:SpringConstraint;
		private var _rotation:Number;
		private var _stage:Stage;
		
		private var _bombArray:Array = new Array();
		private var _rotationAngle:Number = 0;
		
		public function Wheel(x:Number,y:Number,radius:Number,rotation:Number,stage:Stage)
		{
			super(false);
			_rotation = rotation;
			_stage = stage;
			
			_fixedWheel = new SpecialWheelParticle(x,y,radius,this,true,1,0,0);
			_fixedWheel.collidable = true;
			_fixedWheel.visible = false;
			
			_wheel = new SpecialWheelParticle(x,y,radius,this,false,10,0,0,1);
			_wheel.collidable = false;
			_wheel.speed = _rotation;
			
			_connector = new SpringConstraint(_fixedWheel,_wheel,1,false);
			_connector.visible = false;
			_connector.restLength = 0.1;
			
			for(var i:int=0; i<4; i++)
				_bombArray[i] = new SpecialWheelParticle(x+radius,y,8,this,false,10,1,0,1);
			
			var temp:uint;

			switch(true)
			{
				case (y<-5000 && y>-10000) :
				{
					temp = Tools.random(1,4);
					if(temp == 1)
						addBombs(1);
					break;
				}
					
				case (y<-10000 && y>-15000) :
				{
					temp = Tools.random(1,4);
					if(temp == 1)
					{
						temp = Tools.random(1,2);
						addBombs(temp);
					}	
					break;
				}
				
				case (y<-15000 && y>-20000) :
				{
					temp = Tools.random(1,4);
					if(temp == 1)
					{
						temp = Tools.random(1,3);
						addBombs(temp);
					}	
					break;
				}
					
				case (y<-20000 && y>-25000) :
				{
					temp = Tools.random(1,2);
					if(temp == 1)
					{
						temp = Tools.random(1,2);
						addBombs(temp);
					}	
					break;
				}
					
				case (y<-25000 && y>-30000) :
				{
					temp = Tools.random(1,2);
					if(temp == 1)
					{
						temp = Tools.random(1,3);
						addBombs(temp);
					}	
					break;
				}
					
				case (y<-30000) :
				{
					temp = Tools.random(1,2);
					if(temp == 1)
					{
						temp = Tools.random(1,4);
						addBombs(temp);
					}	
					break;
				}
					
				default:
				{
					break;
				}
			}
			
			addParticle(_fixedWheel);
			addParticle(_wheel);
			addConstraint(_connector);
		}
		
		private function addBombs(num:int):void
		{	
			for(var i:int=0; i<num; i++)
			{
				_bombArray[i].sprite.name = "bomb";
				_bombArray[i].collidable = true;
				_bombArray[i].setDisplay(new BombFace);
				addParticle(_bombArray[i]);
			}
			
			_stage.addEventListener(Event.ENTER_FRAME,moveBomb);
		}
		
		private function moveBomb(event:Event):void
		{
				_rotationAngle += _rotation*2.05;
				_bombArray[0].px = _fixedWheel.px + Math.cos(_rotationAngle)*(_fixedWheel.radius); 
				_bombArray[0].py = _fixedWheel.py + Math.sin(_rotationAngle)*(_fixedWheel.radius);
				
				_bombArray[1].px = _fixedWheel.px + Math.cos(_rotationAngle)*(-1*_fixedWheel.radius); 
				_bombArray[1].py = _fixedWheel.py + Math.sin(_rotationAngle)*(-1*_fixedWheel.radius);
				
				_bombArray[2].px = _fixedWheel.px + Math.sin(_rotationAngle)*(_fixedWheel.radius); 
				_bombArray[2].py = _fixedWheel.py + Math.cos(_rotationAngle)*(-1*_fixedWheel.radius);
				
				_bombArray[3].px = _fixedWheel.px + Math.sin(_rotationAngle)*(-1*_fixedWheel.radius); 
				_bombArray[3].py = _fixedWheel.py + Math.cos(_rotationAngle)*(_fixedWheel.radius);
				
		}
		
		//GETTERS
		public function get particle():SpecialWheelParticle
		{
			return _fixedWheel;
		}
		
		public function get face():SpecialWheelParticle
		{
			return _wheel;
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}
		
		public function get position():VectorAPE
		{
			return _fixedWheel.position;
		}
		
		public function get radius():Number
		{
			return _wheel.radius;
		}
		
		//SETTERS
		public function set position(vector:VectorAPE):void
		{
			_fixedWheel.position = vector;
		}
		
			
	}
}