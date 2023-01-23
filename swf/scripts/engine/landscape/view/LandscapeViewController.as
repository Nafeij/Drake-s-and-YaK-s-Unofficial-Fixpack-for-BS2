package engine.landscape.view
{
   import com.stoicstudio.platform.PlatformFlash;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.IKeyBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.model.Landscape;
   import engine.landscape.travel.view.TravelViewController;
   import engine.saga.Saga;
   import engine.saga.SagaCheat;
   import engine.saga.vars.IVariable;
   import engine.scene.model.Scene;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   
   public class LandscapeViewController extends EventDispatcher
   {
      
      public static const EVENT_SELECTED_CLICKABLE:String = "SceneViewController.EVENT_SELECTED_CLICKABLE";
      
      private static var BINDGROUP:String = "Landscape";
       
      
      private var cmd_jump_right:Cmd;
      
      private var _landscapeClickable:LandscapeSpriteDef;
      
      private var view:ILandscapeView;
      
      private var travel:TravelViewController;
      
      public var landscape:Landscape;
      
      private var keybinder:IKeyBinder;
      
      private var landscapeClickCallback:Function;
      
      private var logger:ILogger;
      
      private var _autoClicked:Dictionary;
      
      public function LandscapeViewController(param1:ILandscapeView, param2:Function)
      {
         var _loc4_:Boolean = false;
         this.cmd_jump_right = new Cmd("cmd_jump_right",this.cmdfunc_jump_right);
         super();
         this.keybinder = param1.landscape.context.keybinder;
         this.landscapeClickCallback = param2;
         this.view = param1;
         this.landscape = param1.landscape;
         this.logger = param1.logger;
         var _loc3_:Saga = this.landscape.scene._context.saga as Saga;
         if(param1.travelView)
         {
            this.travel = new TravelViewController(param1.travelView,this);
         }
         else if(!param1.landscape.scene.convo && (!_loc3_ || !_loc3_.mapCamp))
         {
            _loc4_ = param1.landscape.scene._context.developer;
            if(_loc4_)
            {
               this.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.cmd_jump_right,BINDGROUP);
            }
            GpDevBinder.instance.bind(null,GpControlButton.A,1,this.doFf);
         }
         this.landscape.addEventListener(Landscape.EVENT_ENABLE_HOVER,this.landscapeEnableHoverHandler);
      }
      
      public function doFf(param1:Boolean = false) : Boolean
      {
         SagaCheat.devCheat("ff landscape");
         if(Boolean(this.travel) && !param1)
         {
            if(this.travel.doFf())
            {
               return true;
            }
         }
         return this._performDoFf(param1);
      }
      
      private function cmdfunc_jump_right(param1:CmdExec) : void
      {
         this.doFf(false);
      }
      
      public function _performDoFf(param1:Boolean) : Boolean
      {
         var _loc4_:LandscapeSpriteDef = null;
         var _loc5_:LandscapeSpriteDef = null;
         if(!this.landscape)
         {
            return true;
         }
         var _loc2_:Scene = this.landscape.scene;
         if(!_loc2_.cleanedup)
         {
            _loc2_.forceReady();
         }
         if(_loc2_.cleanedup)
         {
            return true;
         }
         var _loc3_:Saga = _loc2_._context.saga as Saga;
         if(_loc3_)
         {
            _loc3_.terminateWaits();
         }
         if(_loc2_.cleanedup)
         {
            return true;
         }
         if(!_loc2_.ready)
         {
            return true;
         }
         if(!this.view)
         {
            return true;
         }
         if(Boolean(this.view.travelView) && !param1)
         {
            return true;
         }
         if(Boolean(_loc3_.convo) && Boolean(_loc3_.convo.cursor))
         {
            _loc3_.convo.cursor.ff();
            return true;
         }
         for each(_loc4_ in this.view.clickableDefs)
         {
            if(Boolean(_loc4_) && this.view.isClickableEnabled(_loc4_))
            {
               if(_loc4_.nameId.indexOf("click_leave") == 0)
               {
                  this.landscapeClickable = null;
                  this.performLandscapeClick(_loc4_);
                  return true;
               }
               if(_loc4_.nameId != "click_market" && _loc4_.nameId != "click_rest" && _loc4_.nameId != "click_heroes" && _loc4_.nameId != "click_training" && _loc4_.nameId != "click_human" && _loc4_.nameId != "click_map")
               {
                  if(!_loc5_)
                  {
                     if(!this._autoClicked || !this._autoClicked[_loc5_])
                     {
                        _loc5_ = _loc4_;
                     }
                  }
               }
            }
         }
         if(_loc5_)
         {
            if(!this._autoClicked)
            {
               this._autoClicked = new Dictionary();
            }
            this._autoClicked[_loc5_] = true;
            this.landscapeClickable = null;
            this.performLandscapeClick(_loc5_);
            return true;
         }
         if(this._clickATalkie(_loc3_))
         {
            return true;
         }
         return false;
      }
      
      private function _clickATalkie(param1:Saga) : Boolean
      {
         var _loc4_:IEntityDef = null;
         var _loc5_:IVariable = null;
         if(!param1 || !param1.caravan || !param1.camped || Boolean(this.landscape.scene.focusedBoard))
         {
            return false;
         }
         if(this.view)
         {
            if(!this.view.hasTalkies)
            {
               return false;
            }
         }
         var _loc2_:IEntityListDef = param1.caravan._legend.roster;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.numEntityDefs)
         {
            _loc4_ = _loc2_.getEntityDef(_loc3_);
            _loc5_ = _loc4_.vars.fetch("talk",null);
            if(_loc5_)
            {
               if(_loc5_.asInteger != 0)
               {
                  _loc5_.asAny = 0;
                  param1.triggerTalk(_loc4_.id);
                  return true;
               }
            }
            _loc3_++;
         }
         return false;
      }
      
      public function cleanup() : void
      {
         this.landscapeClickCallback = null;
         this.landscape.removeEventListener(Landscape.EVENT_ENABLE_HOVER,this.landscapeEnableHoverHandler);
         this.landscape = null;
         GpDevBinder.instance.unbind(this.doFf);
         this.keybinder.unbind(this.cmd_jump_right);
         this.keybinder = null;
         this.cmd_jump_right.cleanup();
         this.cmd_jump_right = null;
         this._landscapeClickable = null;
         if(this.travel)
         {
            this.travel.cleanup();
            this.travel = null;
         }
         this.view = null;
         this.keybinder = null;
      }
      
      private function landscapeEnableHoverHandler(param1:Event) : void
      {
         this.mouseMoveHandler(0,0);
      }
      
      private function getLandscapeClickable(param1:Number, param2:Number) : LandscapeSpriteDef
      {
         return this.view.getClickableUnderMouse(param1,param2);
      }
      
      public function get landscapeClickable() : LandscapeSpriteDef
      {
         return this._landscapeClickable;
      }
      
      public function set landscapeClickable(param1:LandscapeSpriteDef) : void
      {
         this._landscapeClickable = param1;
      }
      
      public function clear() : void
      {
         this.view.pressedClickable = null;
         this.view.displayHover(null);
         this.landscapeClickable = null;
         if(this.travel)
         {
            this.travel.clear();
         }
      }
      
      final public function mouseDownHandler(param1:Number, param2:Number) : void
      {
         if(!this.view.landscape || !this.view.landscape.scene.ready)
         {
            return;
         }
         this.landscapeClickable = this.getLandscapeClickable(param1,param2);
         this.view.pressedClickable = this.landscapeClickable;
         if(this.travel)
         {
            this.travel.mouseDownHandler(param1,param2);
         }
      }
      
      final public function mouseUpHandler(param1:Number, param2:Number) : void
      {
         if(!this.view.landscape.scene.ready)
         {
            return;
         }
         var _loc3_:LandscapeSpriteDef = this.getLandscapeClickable(param1,param2);
         if(this._landscapeClickable == _loc3_ && Boolean(_loc3_))
         {
            this.handleLandscapeClick();
         }
         this.landscapeClickable = null;
         if(this.travel)
         {
            this.travel.mouseUpHandler(param1,param2);
         }
      }
      
      public function handleLandscapeClick() : void
      {
         if(!this.view || !this.landscape || !this.landscape.scene.ready)
         {
            return;
         }
         this.performLandscapeClick(this._landscapeClickable);
      }
      
      public function performLandscapeClick(param1:LandscapeSpriteDef) : void
      {
         var _loc2_:Saga = null;
         if(param1)
         {
            if(this.view.isClickableEnabled(param1))
            {
               _loc2_ = this.view.landscape.context.saga as Saga;
               if(Boolean(_loc2_) && _loc2_.paused)
               {
                  this.logger.info("LandscapeViewController CLICK ignored due to paused saga " + param1.nameId + " in " + this.landscape.scene);
                  return;
               }
               if(Boolean(_loc2_) && _loc2_.isProcessingActionTween)
               {
                  this.logger.info("LandscapeViewController CLICK ignored due to in-progress action_tween " + param1.nameId + " in " + this.landscape.scene);
                  return;
               }
               this.logger.info("LandscapeViewController CLICK ****** " + param1.nameId + " in " + this.landscape.scene);
               this.view.setClickableHasBeenClicked(param1);
               if(param1.triggerClick(_loc2_))
               {
                  this.logger.info("Landscape click handled by sprite happening, skipping saga triggers and default handler for " + param1 + " in " + this.landscape.scene);
                  return;
               }
               if(this.landscapeClickCallback != null)
               {
                  if(this.landscapeClickCallback(param1))
                  {
                     return;
                  }
               }
            }
            else
            {
               this.logger.error("Attempt to click on disabled clickable " + param1.nameId + " in " + this.landscape.scene);
            }
         }
      }
      
      final public function mouseMoveHandler(param1:Number, param2:Number) : void
      {
         if(!this.view || !this.view.isSceneReady || !this.view.visible)
         {
            return;
         }
         var _loc3_:Number = PlatformFlash.stage.mouseX;
         var _loc4_:Number = PlatformFlash.stage.mouseY;
         this.landscapeClickable = this.getLandscapeClickable(_loc3_,_loc4_);
         if(this.view)
         {
            this.view.displayHover(this.landscapeClickable);
            this.view.setDisplayHoverStagePosition(param1,param2);
            this.view.setDisplayHoverStagePositionEnabled(true);
         }
         if(this.travel)
         {
            this.travel.mouseMoveHandler(_loc3_,_loc3_);
         }
      }
   }
}
