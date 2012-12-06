package org.wheely.game
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	
	import org.cove.ape.APEngine;
	import org.cove.ape.Group;
	import org.cove.ape.VectorForce;
	import org.wheely.utils.Tools;

	public class Game extends Sprite
	{
		public var worldMobile:Boolean = true;
		public var score:int = 100;
		
		private var _stage:Stage;
		private var _container:Sprite;
		private var _score:ScoreZone;
		private var _hero:Wheely;
		private var _cleaner:Cleaner;
		private var _gameEnvironement:Environment;
		private var _time:Timer;
		public var paused:Boolean = false;

		//Create a new Game
		public function Game(theStage:Stage,container:Sprite,score:ScoreZone):void
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;	
			_stage = theStage;
			_container = container;
			_score = score;
		}
		
		public function initNewGame(c:Sprite):void
		{
			APEngine.init();
			APEngine.container = c;
			APEngine.addForce(new VectorForce(false,0,3));
			createLevel();
		}
		
		private function createLevel():void
		{
			_hero = new Wheely(0,0,_stage,this);
			_cleaner = new Cleaner(_stage.stageWidth,_stage.stageHeight,this,_hero);
			_gameEnvironement = new Environment(_stage,this,_hero,_cleaner);
			
			APEngine.addGroup(_hero);
			APEngine.addGroup(_cleaner);
			APEngine.addGroup(_gameEnvironement.walls);
			APEngine.addGroup(_gameEnvironement.acid);
			
			_container.addEventListener(TouchEvent.TOUCH_BEGIN, touchHandler); // à placer sur _container
			_container.addEventListener(MouseEvent.MOUSE_DOWN, touchHandler);// à placer sur _container
			_container.y = (_hero.body.py - _stage.stageHeight/2)*-1; 
			addEventListener(Event.ENTER_FRAME, runEngine);
		}	
		
		private function touchHandler (event:Object):void
		{
			if(!paused)_hero.jump();
		}
		
		public function updateWheel(wheel:Wheel):void
		{
			APEngine.addGroup(wheel);
		}
		
		public function createWheel():void
		{
			_gameEnvironement.addaWheel(_stage.stageWidth,_stage);
		}
		
		public function moveWorld():void
		{
			if(worldMobile)
			{
				_container.y = (_hero.body.py - _stage.stageHeight/2)*-1;
				_gameEnvironement.moveWalls(_container.y*-1+_stage.stageHeight/2);
				_gameEnvironement.moveAcid();
			}
		}
		
		public function pauseGame():void
		{
			if(paused)
			{
				if(!_hero.dynamicState)
					_hero.toggleMove(true);
				
				addEventListener(Event.ENTER_FRAME, runEngine);
				_stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchHandler);
				paused = false;
			}
			else
			{
				if(!_hero.dynamicState)
					_hero.toggleMove(false);
				removeEventListener(Event.ENTER_FRAME, runEngine);
				_stage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchHandler);
				paused = true;
			}
		}
		
		public function endGame():void
		{
			var mc:MovieClip = MovieClip(_hero.body.getDisplay());
			mc.addChild(new HeroDead());
			_time = new Timer(1500);
			_time.addEventListener(TimerEvent.TIMER,killGame);
			_time.start();
			
			for each(var w:Wheel in _gameEnvironement.wheels)
			{
				w.particle.solid = false;
			}
		}
		
		private function killGame(event:TimerEvent):void
		{
			pauseGame();
			_time.stop();
			_time.removeEventListener(TimerEvent.TIMER,killGame);
			_container.dispatchEvent(new Event("END_GAME",true));
		}
		
		public function addExplosion(posX:Number, posY:Number):void
		{
			var explosionParticleAmount:Number = 30;
			var distance:Number = 30;
			var explosionSize:Number = 10;
			var explosionAlpha:Number = 75;
			
			//run a for loop based on the amount of explosion particles
			for(var i:int=0; i<explosionParticleAmount; i++)
			{
				var tempClip2:Explosion2 = new Explosion2();
				var tempClip:Explosion = new Explosion();
				
				tempClip.x = posX+Tools.random(distance/2,distance);
				tempClip.y = posY+Tools.random(distance/2,distance);		
				tempClip2.x = posX+Tools.random(distance/2,distance);
				tempClip2.y = posY+Tools.random(distance/2,distance);
				
				var tempRandomSize:Number = Tools.random(explosionSize/2,explosionSize);
				tempClip.scaleX = tempRandomSize;
				tempClip.scaleY = tempRandomSize;
				tempRandomSize = Tools.random(explosionSize/2,explosionSize);
				tempClip2.scaleX = tempRandomSize;
				tempClip2.scaleY = tempRandomSize;
				tempClip2.rotation = Tools.random(0,359);
				tempClip.alpha = Tools.random();
				tempClip2.alpha = Tools.random();
				_container.addChild(tempClip);
				_container.addChild(tempClip2);
			}
		}
		
		public function waterDiving():void
		{
			APEngine.removeAllForce();
			APEngine.addForce(new VectorForce(false,0,.5));
		}
		
		public function removeGroup(g:Group):void
		{
			APEngine.removeGroup(g);
			g = null;
		}
		
		public function updateScore(newValue:int):void
		{
			score = newValue;
			_score.scoreValue.text = score+" m";
		}
		
		public function getContainer():Sprite
		{
			return _container;
		}
		
		public function runEngine(event:Event):void
		{
			APEngine.step();
			APEngine.paint();
			moveWorld();
		}
		
		public function get wheels():Array
		{
			return _gameEnvironement.wheels;
		}
		
	}
}