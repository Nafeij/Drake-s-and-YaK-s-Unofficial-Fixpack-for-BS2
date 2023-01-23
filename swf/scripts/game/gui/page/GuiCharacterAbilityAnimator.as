package game.gui.page
{
   import com.greensock.TweenMax;
   import engine.anim.view.AnimController;
   import engine.anim.view.AnimControllerSpriteFlash;
   import engine.anim.view.IAnimControllerListener;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.def.IsoAnimLibraryResource;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityDef;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   
   public class GuiCharacterAbilityAnimator implements IAnimControllerListener
   {
       
      
      private var _entityDef:IEntityDef;
      
      private var _animController:AnimController;
      
      private var _resman:ResourceManager;
      
      private var _animLibraryRes:IsoAnimLibraryResource;
      
      private var _logger:ILogger;
      
      private var _sprite:AnimControllerSpriteFlash;
      
      private var _callback:Function;
      
      private var _controller:AnimController;
      
      private var _animId:String;
      
      private var _inCallback:Boolean;
      
      private var _lastAnimCount:int = 0;
      
      public function GuiCharacterAbilityAnimator(param1:ResourceManager)
      {
         super();
         this._resman = param1;
         this._logger = this._resman.logger;
      }
      
      public function cleanup() : void
      {
         this.entityDef = null;
         this._resman = null;
         this._logger = null;
      }
      
      public function get entityDef() : IEntityDef
      {
         return this._entityDef;
      }
      
      public function set entityDef(param1:IEntityDef) : void
      {
         var _loc2_:IEntityAppearanceDef = null;
         var _loc3_:String = null;
         this._entityDef = param1;
         this._animId = null;
         if(this._entityDef)
         {
            _loc2_ = this._entityDef.appearance;
            if(_loc2_)
            {
               _loc3_ = _loc2_.animsUrl.replace(".anim.",".anim_pg.");
               if(!(Boolean(this._animLibraryRes) && this._animLibraryRes.url == _loc3_))
               {
                  this.animLibraryRes = this._resman.getResource(_loc3_,IsoAnimLibraryResource) as IsoAnimLibraryResource;
               }
            }
            else
            {
               this.animLibraryRes = null;
            }
         }
         else
         {
            this.animLibraryRes = null;
         }
      }
      
      public function get animLibraryRes() : IsoAnimLibraryResource
      {
         return this._animLibraryRes;
      }
      
      public function set animLibraryRes(param1:IsoAnimLibraryResource) : void
      {
         if(this._animLibraryRes == param1)
         {
            return;
         }
         if(this._sprite)
         {
            this._sprite.displayObjectWrapper.removeFromParent();
            this._sprite.cleanup();
            this._sprite = null;
         }
         if(this._controller)
         {
            this._controller.cleanup();
            this._controller = null;
         }
         if(this._animLibraryRes)
         {
            this._animLibraryRes.removeResourceListener(this.animLibraryLoadedHandler);
            this._animLibraryRes.release();
            this._animLibraryRes = null;
         }
         TweenMax.killDelayedCallsTo(this.delayedCallbackNotify);
         this._animLibraryRes = param1;
      }
      
      public function createAnimControllerSprite(param1:Function) : void
      {
         this._logger.info("ANIMATOR createAnimControllerSprite");
         if(this._sprite)
         {
            param1(this._sprite);
            return;
         }
         this._callback = param1;
         if(this._animLibraryRes)
         {
            this._animLibraryRes.addResourceListener(this.animLibraryLoadedHandler);
         }
      }
      
      private function makeControllerSprite() : Boolean
      {
         if(Boolean(this._animLibraryRes) && this._animLibraryRes.ok)
         {
            if(this._sprite)
            {
               this._sprite.displayObjectWrapper.removeFromParent();
               this._sprite.cleanup();
               this._sprite = null;
            }
            if(this._controller)
            {
               this._controller.cleanup();
               this._controller = null;
            }
            this._controller = new AnimController(this._entityDef.id,this._animLibraryRes.library,this,this._logger);
            this._controller.facing = BattleFacing.SE;
            this._sprite = new AnimControllerSpriteFlash(this._entityDef.id,this._controller,this._logger,this._resman,true);
            this.processAnimId();
            TweenMax.delayedCall(0,this.delayedCallbackNotify);
            return true;
         }
         return false;
      }
      
      private function delayedCallbackNotify() : void
      {
         if(this._callback != null)
         {
            if(this._sprite)
            {
               this._callback(this._sprite);
            }
         }
      }
      
      private function animLibraryLoadedHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:IsoAnimLibraryResource = param1.resource as IsoAnimLibraryResource;
         this._logger.info("ANIMATOR animLibraryLoadedHandler " + _loc2_);
         _loc2_.removeResourceListener(this.animLibraryLoadedHandler);
         this.makeControllerSprite();
      }
      
      public function get animId() : String
      {
         return this._animId;
      }
      
      public function set animId(param1:String) : void
      {
         this._animId = param1;
         this.processAnimId();
      }
      
      private function processAnimId() : void
      {
         if(this._controller)
         {
            if(!this._animId)
            {
               this._controller.stop();
               this._controller.ambientMix = null;
               return;
            }
            this._lastAnimCount = 0;
            if(this._animId.indexOf("mix_") == 0)
            {
               this._controller.stop();
               this._controller.facing = null;
               this._controller.ambientMix = this._animId;
            }
            else
            {
               this._controller.ambientMix = null;
               this._controller.facing = BattleFacing.SE;
               if(this._controller.library.hasOrientedAnims(this._controller.layer,this._animId))
               {
                  this._controller.playAnim(this._animId,0,false,true);
               }
               else
               {
                  this._logger.error("No such oriented anim [" + this._animId + "] for [" + this._controller.library.url + "]");
                  this._controller.stop();
               }
            }
         }
      }
      
      public function update(param1:int) : void
      {
         if(this._controller)
         {
            if(this._controller.anim)
            {
               if(!this._controller.isAmbient && this._controller.anim.playing)
               {
                  if(this._controller.anim.count > this._lastAnimCount)
                  {
                     this._lastAnimCount = 0;
                     if(this._controller._facing)
                     {
                        this._controller.facing = this._controller._facing.clockwise();
                     }
                  }
               }
            }
            this._controller.update(param1);
         }
         if(this._sprite)
         {
            this._sprite.update();
         }
      }
      
      public function animControllerHandler_current(param1:AnimController) : void
      {
         if(this._inCallback)
         {
            return;
         }
         this._inCallback = true;
         this._inCallback = false;
      }
      
      public function animControllerHandler_event(param1:AnimController, param2:String, param3:String) : void
      {
      }
      
      public function animControllerHandler_loco(param1:AnimController, param2:String) : void
      {
      }
   }
}
