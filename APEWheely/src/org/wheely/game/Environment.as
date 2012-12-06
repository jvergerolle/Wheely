package org.wheely.game
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import org.cove.ape.CollisionEvent;
	import org.cove.ape.Group;
	import org.cove.ape.RectangleParticle;
	import org.cove.ape.SpringConstraint;
	import org.cove.ape.VectorAPE;
	import org.wheely.game.Wheely;
	import org.wheely.utils.ImageImporter;
	import org.wheely.utils.Tools;
	
	public class Environment extends MovieClip
	{
		private var _game:Game;
		private var _wallgroup:Group;
		private var _wheelsArray:Array;
		private var _hero:Wheely;
		private var _cleaner:Cleaner;
		private var _acidPool:Group;

		
		private var _leftWall:RectangleParticle;
		private var _rightWall:RectangleParticle;
		private var _acid:RectangleParticle;

		
		//min speed = 0.05 / max speed = 0.3
		private const MIN_WHEEL_SIZE:Number = 25;
		private const MAX_WHEEL_SIZE:Number = 100;
		private const MIN_WHEEL_SPEED:Number = 5;
		private const MAX_WHEEL_SPEED:Number = 8;
		private const WHEELY_SIZE:Number = 30;
		private const WHEELY_RANGE:Number = 100;
		
		public function Environment(gameStage:Stage,gameInstance:Game,hero:Wheely,cleaner:Cleaner)
		{
			_game = gameInstance;
			_hero = hero;
			_cleaner = cleaner;
			
			CreateAcid(gameStage.stageWidth,gameStage.stageHeight);
			CreateWalls(gameStage.stageWidth,gameStage.stageHeight);
			CreateWheels(gameStage.stageWidth,gameStage.stageHeight,gameStage);
		}
		
		private function CreateAcid(gameStageWidth:int, gameStageHeight:int):void
		{	
			_acid = new RectangleParticle(gameStageWidth/2,gameStageHeight,gameStageWidth,gameStageHeight,0,true,1,0,0.1);
			_acid.collidable = true;
			_acid.solid = false;
			_acid.sprite.name = "acid";
			_acid.alwaysRepaint = true;
			_acid.setFill(0xBEFF3B,0.6);
			_acid.setLine(1,0x6FFF3B,0.8);
			
			_acidPool = new Group();
			_acidPool.addParticle(_acid);
			_acidPool.addCollidable(_hero);
			
			var constraint:SpringConstraint = new SpringConstraint(_acid,_cleaner.cleaner,1);
				constraint.visible = false;
			_acidPool.addConstraint(constraint);
			
			_acid.addEventListener(CollisionEvent.FIRST_COLLIDE, CollisionHandler);
		}
		
		private function CollisionHandler(event:CollisionEvent):void
		{
			_hero.jump();
			_hero.listenCollision(false);
			_game.waterDiving();
			_game.worldMobile = false;
			_game.endGame();
		}
		
		private function CreateWalls(gameStageWidth:int,gameStageHeight:int):void
		{
			_leftWall = new RectangleParticle(-5,gameStageHeight/2,10,gameStageHeight,0,true,1,0,0.1);
			_rightWall = new RectangleParticle(gameStageWidth+5,gameStageHeight/2,10,gameStageHeight,0,true,1,0,0.1);
			
			_leftWall.visible = false;
			_rightWall.visible = false;
			
			_leftWall.sprite.name = "mur gauche";
			_rightWall.sprite.name = "mur droite";
			
			_wallgroup = new Group(false);
			_wallgroup.addParticle(_rightWall);
			_wallgroup.addParticle(_leftWall);
			_wallgroup.addCollidable(_hero);
		}
		
		private function CreateWheels(gameStageWidth:int,gameStageHeight:int,gameStage:Stage):void 
		{	
			var speed:Number = Tools.random(MIN_WHEEL_SPEED,MAX_WHEEL_SPEED);
				speed = Number("0.0"+speed);
			var size:Number = Tools.random(MIN_WHEEL_SIZE,MAX_WHEEL_SIZE);
			var pmin:Number = size+WHEELY_SIZE;
			var pmax:Number = gameStageWidth-WHEELY_SIZE-size;
			
			_wheelsArray = new Array();	
			_wheelsArray[0] = new Wheel(Tools.random(pmin,pmax),gameStageHeight-WHEELY_SIZE-size,size,speed,gameStage);

			var UIwheel:WheelsFace = new WheelsFace();
				UIwheel.cacheAsBitmapMatrix = new Matrix();
				UIwheel.width = UIwheel.height = size*2;
				
			_wheelsArray[0].face.setDisplay(UIwheel);
			_wheelsArray[0].particle.sprite.name = "roue";
			_wheelsArray[0].addCollidable(_hero);
			_wheelsArray[0].addCollidable(_cleaner);
			_game.updateWheel(_wheelsArray[0]);
			
			for (var i:int=0;i<=30;i++)
				addaWheel(gameStageWidth,gameStage);
			
			var xpos:Number = _wheelsArray[15].position.x;
			var ypos:Number = _wheelsArray[15].position.y-(_wheelsArray[15].radius+_hero.radius);
			_hero.setHighestWheel(_wheelsArray[15].position.y);
			_hero.body.position = new VectorAPE(xpos,ypos);
		}
		
		public function addaWheel(gameStageWidth:int,gameStage:Stage):void
		{	
			var speed:Number = Tools.random(MIN_WHEEL_SPEED,MAX_WHEEL_SPEED);
				speed = Number("0.0"+speed);
			var size:Number = Tools.random(MIN_WHEEL_SIZE,MAX_WHEEL_SIZE);
			
			var dmin:Number = _wheelsArray[_wheelsArray.length-1].radius+size+WHEELY_SIZE; 	//minimum pour laisser passer le hero
			var dmax:Number = _wheelsArray[_wheelsArray.length-1].radius+size+WHEELY_RANGE;	//portée supposée du hero - a testé
			var dmoy:Number = Tools.random(dmin,dmax);
			
			var nextX:Number = 0;
			var nextY:Number = 0;
			
			while(nextX<size+WHEELY_SIZE || nextX>gameStageWidth-size-WHEELY_SIZE)
			{
				var angle:Number = Math.random()*(-Math.PI);
				nextX = _wheelsArray[_wheelsArray.length-1].particle.px + Math.cos(angle)*(dmoy);
				nextY = _wheelsArray[_wheelsArray.length-1].particle.py + Math.sin(angle)*(dmoy);
				
				if(_wheelsArray.length>2)
				{
					var nxDist:Number = _wheelsArray[_wheelsArray.length-2].particle.px-nextX;
					var nyDist:Number = _wheelsArray[_wheelsArray.length-2].particle.py-nextY;
					var minDist:Number = _wheelsArray[_wheelsArray.length-2].radius+size+WHEELY_SIZE;
					
					if(nxDist < minDist && nyDist < minDist) //HANDLE WHEEL OVERFLOW - !! to improve
					{
						angle = Math.random()*(-Math.PI);
						nextX = _wheelsArray[_wheelsArray.length-1].particle.px + Math.cos(angle)*(dmoy);
						nextY = _wheelsArray[_wheelsArray.length-1].particle.py + Math.sin(angle)*(dmoy);
					}
				}
			}
			
			var face:WheelsFace = new WheelsFace();
				face.cacheAsBitmapMatrix = new Matrix();
				face.width = face.height = size*2;
			
			var w:Wheel = new Wheel(nextX,nextY,size,speed,gameStage);
				w.face.setDisplay(face);
				w.particle.sprite.name = "roue";
				w.addCollidable(_hero);
				w.addCollidable(_cleaner);
				
			_wheelsArray.push(w);
			w.particle.sprite.parent.swapChildren(_acid.sprite,w.particle.sprite);
			_game.updateWheel(_wheelsArray[_wheelsArray.length-1]);
		}
		
		public function moveWalls(position:Number):void
		{
			_leftWall.py = position;
			_rightWall.py = position;
		}
		
		public function moveAcid():void
		{
			_acid.py-=2.5;
		}
		
		public function get walls():Group
		{
			return _wallgroup;
		}
		
		public function get acid():Group
		{
			return _acidPool;
		}
		
		public function get wheels():Array
		{
			return _wheelsArray;
		}
	}
}