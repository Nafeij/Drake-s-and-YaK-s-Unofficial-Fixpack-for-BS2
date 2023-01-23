package com.stoicstudio.platform
{
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.DisplayObjectWrapperStarling;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.errors.IllegalOperationError;
   import flash.events.MouseEvent;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.events.Event;
   
   public class PlatformStarling
   {
      
      public static var instance:PlatformStarling;
      
      public static var toucher:IUserInputToucher;
      
      public static var _panning:Boolean;
      
      public static var _fullscreenGui:Boolean;
      
      public static var _fullscreenOverlay:int;
      
      public static var STARLING_STAGE_COLOR:uint = 0;
      
      public static var DEBUG_KILLER:Boolean;
       
      
      private var mStarling:Starling;
      
      private var logger:ILogger;
      
      public function PlatformStarling()
      {
         super();
         if(instance)
         {
            throw new IllegalOperationError("no");
         }
         instance = this;
      }
      
      public static function displayObjectWrapperCtor(param1:DisplayObject) : DisplayObjectWrapper
      {
         return new DisplayObjectWrapperStarling(param1);
      }
      
      public static function init(param1:ILogger) : void
      {
         param1.info("PlatformStarling STARLING INIT");
         new PlatformStarling();
         instance.logger = param1;
      }
      
      public static function getInfo(param1:ILogger) : void
      {
         param1.info("PlatformStarling:");
         param1.info("        _panning           = " + _panning);
         param1.info("        _fullscreenGui     = " + _fullscreenGui);
         param1.info("        _fullscreenOverlay = " + _fullscreenOverlay);
         if(instance)
         {
            instance.getInstanceInfo(param1);
         }
      }
      
      public static function handleResize(param1:Number, param2:Number) : void
      {
         if(instance)
         {
            instance.logger.info("PlatformStarling resize viewport to " + param1 + "x" + param2);
            instance.mStarling.viewPort.setTo(0,0,param1,param2);
            instance.mStarling.stage.stageHeight = param2;
            instance.mStarling.stage.stageWidth = param1;
         }
      }
      
      public static function setPanning(param1:Boolean, param2:ILogger, param3:String) : void
      {
         var _loc4_:Sprite = null;
         if(_panning != param1)
         {
            _panning = param1;
            if(param2.isDebugEnabled)
            {
            }
            if(Starling.current)
            {
               _loc4_ = Starling.current.nativeOverlay;
               _loc4_.mouseChildren = _loc4_.mouseEnabled = !_panning;
            }
         }
      }
      
      public static function setFullscreenGui(param1:Boolean, param2:String, param3:ILogger) : void
      {
         if(!instance || !instance.mStarling)
         {
            return;
         }
         if(_fullscreenGui != param1)
         {
            _fullscreenGui = param1;
            param3.debug("PlatformStarling.setFullscreenGui: {0}: {1}",param1,param2);
            if(instance.mStarling.root)
            {
               instance.mStarling.root.touchable = !_fullscreenGui;
            }
            if(_fullscreenGui)
            {
               setPanning(false,param3,"PlatformStarling._fullscreenGui");
            }
         }
      }
      
      public static function fullscreenIncrement(param1:String, param2:ILogger) : void
      {
         ++_fullscreenOverlay;
         if(param2.isDebugEnabled)
         {
         }
         if(_fullscreenOverlay == 1)
         {
            if(Starling.current)
            {
               Starling.current.root.touchable = !_fullscreenOverlay;
            }
         }
         setPanning(false,param2,"fulscreenIncrement");
      }
      
      public static function fullscreenDecrement(param1:String, param2:ILogger) : void
      {
         if(_fullscreenOverlay == 0)
         {
            throw new IllegalOperationError("too many PlatformStarling.fullscreenDecrement");
         }
         --_fullscreenOverlay;
         if(param2.isDebugEnabled)
         {
         }
         if(_fullscreenOverlay == 0)
         {
            if(Starling.current)
            {
               Starling.current.root.touchable = !_fullscreenOverlay;
            }
         }
      }
      
      public static function get blockStarling() : Boolean
      {
         return _fullscreenOverlay || _fullscreenGui || !instance || !instance || !instance.mStarling || !instance.mStarling.isStarted;
      }
      
      public static function get isContextValid() : Boolean
      {
         if(!Starling.current)
         {
            return false;
         }
         return checkContextValid();
      }
      
      private static function checkContextValid() : Boolean
      {
         return Boolean(Starling.context) && Starling.context.driverInfo != "Disposed";
      }
      
      private function getInstanceInfo(param1:ILogger) : void
      {
         param1.info("        instance:");
         param1.info("            mStarling                = " + this.mStarling);
         if(this.mStarling)
         {
            param1.info("            mStarling.touchProcessor = " + (!!this.mStarling.touchProcessor ? this.mStarling.touchProcessor.getDebugInfo() : "<null>"));
         }
      }
      
      protected function onStarlingContextCreated(param1:Event) : void
      {
         this.logger.info("Starling context created. Stage=" + this.mStarling.stage.stageWidth + "x" + this.mStarling.stage.stageHeight + ", viewport=" + this.mStarling.viewPort.width + "x" + this.mStarling.viewPort.height);
      }
      
      public function update() : void
      {
         if(this.mStarling.isStarted)
         {
            if(!Platform.suspended)
            {
               this.mStarling.nextFrame();
            }
            this.mStarling.updateNativeOverlay();
         }
      }
      
      public function startup(param1:Stage) : void
      {
         var _loc2_:Stage3D = null;
         Starling.handleLostContext = true;
         this.mStarling = new Starling(PlatformStarlingGame,param1,null,_loc2_,"auto","baseline");
         this.mStarling.addEventListener(Event.CONTEXT3D_CREATE,this.onStarlingContextCreated);
         this.mStarling.stage.color = STARLING_STAGE_COLOR;
         this.mStarling.start();
         this.mStarling.nativeOverlay.addEventListener(MouseEvent.MOUSE_MOVE,this.eventKiller);
         this.mStarling.nativeOverlay.addEventListener(MouseEvent.MOUSE_DOWN,this.eventKiller);
         this.mStarling.nativeOverlay.addEventListener(MouseEvent.MOUSE_UP,this.eventKiller);
      }
      
      public function pause3D() : void
      {
         if(Boolean(this.mStarling) && this.mStarling.isStarted)
         {
            this.mStarling.stop(false);
         }
      }
      
      public function pause() : void
      {
         if(Boolean(this.mStarling) && this.mStarling.isStarted)
         {
            this.mStarling.stop(true);
         }
      }
      
      public function resume() : void
      {
         if(Boolean(this.mStarling) && !this.mStarling.isStarted)
         {
            this.mStarling.start();
         }
      }
      
      private function eventKiller(param1:MouseEvent) : void
      {
         if(toucher)
         {
            toucher.touchInputActive();
         }
         if(_panning && param1.type != MouseEvent.MOUSE_DOWN)
         {
            return;
         }
         if(!_panning && param1.type == MouseEvent.MOUSE_UP)
         {
            return;
         }
         if(!_fullscreenOverlay && !_fullscreenGui)
         {
            if(param1.target != Starling.current.nativeOverlay)
            {
               if(DEBUG_KILLER)
               {
                  this.logger.info("PlatformStarling eventKiller _fullScreenGui=" + _fullscreenGui + ": " + param1);
               }
               param1.stopPropagation();
               return;
            }
         }
         if(Boolean(_fullscreenOverlay) || _fullscreenGui)
         {
            if(param1.type == MouseEvent.MOUSE_MOVE)
            {
               if(DEBUG_KILLER)
               {
                  this.logger.info("PlatformStarling eventKiller _fullscreenOverlay=" + _fullscreenOverlay + ", _fullScreenGui=" + _fullscreenGui + ": " + param1);
               }
               param1.stopPropagation();
               return;
            }
         }
      }
      
      public function get game() : PlatformStarlingGame
      {
         return this.mStarling.root as PlatformStarlingGame;
      }
      
      public function reset() : void
      {
         var _loc1_:Boolean = false;
         if(this.mStarling)
         {
            _loc1_ = this.mStarling.isStarted;
            this.pause();
            if(this.mStarling.context)
            {
               this.mStarling.context.dispose(true);
            }
            if(_loc1_)
            {
               this.mStarling.start();
            }
         }
      }
   }
}
