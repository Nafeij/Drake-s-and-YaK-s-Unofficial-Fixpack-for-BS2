package engine.battle.entity.view
{
   import as3isolib.display.IsoSprite;
   import as3isolib.geom.Pt;
   import engine.anim.event.AnimControllerEvent;
   import engine.anim.view.AnimClip;
   import engine.anim.view.AnimController;
   import engine.anim.view.AnimControllerSprite;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.battle.board.model.BattleEntityMobilityEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.resource.AnimClipResource;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   import engine.vfx.VfxDef;
   import engine.vfx.VfxLibrary;
   
   public class EntityView_Character
   {
       
      
      private var view:EntityView;
      
      private var starsVfxIsoSprite:IsoSprite;
      
      private var starsVfxAcr:AnimClipResource;
      
      private var _animController:AnimController;
      
      private var wilstat:Stat;
      
      private var moveStarted:Boolean;
      
      private var _starsVfxAnim:XAnimClipSpriteBase;
      
      public function EntityView_Character(param1:EntityView)
      {
         super();
         this.view = param1;
         this.wilstat = this.character.stats.getStat(StatType.WILLPOWER,false);
         if(this.wilstat)
         {
            this.wilstat.addEventListener(StatEvent.CHANGE,this.starsHandler);
         }
         this.entity.addEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
         this.entity.addEventListener(BattleEntityEvent.SELECTED,this.entitySelectedHandler);
         this.entity.mobility.addEventListener(BattleEntityMobilityEvent.MOVING,this.entityMovingHandler);
         this._animController = this.entity.animController;
         if(this._animController)
         {
            this._animController.addEventListener(AnimControllerEvent.FINISHING,this.animControllerFinishingEvent);
         }
         this.updateAnim();
      }
      
      public function get entity() : IBattleEntity
      {
         return this.view.entity;
      }
      
      public function get animSprite() : AnimControllerSprite
      {
         return this.view.animSprite;
      }
      
      public function cleanup() : void
      {
         if(this._animController)
         {
            this._animController.removeEventListener(AnimControllerEvent.FINISHING,this.animControllerFinishingEvent);
            this._animController = null;
         }
         if(this.wilstat)
         {
            this.wilstat.removeEventListener(StatEvent.CHANGE,this.starsHandler);
            this.wilstat = null;
         }
         this.entity.removeEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
         this.entity.removeEventListener(BattleEntityEvent.SELECTED,this.entitySelectedHandler);
         this.entity.mobility.removeEventListener(BattleEntityMobilityEvent.MOVING,this.entityMovingHandler);
         this.starsVfxAnim = null;
      }
      
      protected function entityMovingHandler(param1:BattleEntityMobilityEvent) : void
      {
         this.updateAnim();
      }
      
      public function handleFacing() : void
      {
         this.updateAnim();
      }
      
      public function update(param1:int) : void
      {
         if(this._starsVfxAnim)
         {
            this._starsVfxAnim.clip.advance(param1);
            if(this._starsVfxAnim)
            {
               this._starsVfxAnim.update();
            }
         }
      }
      
      private function updateAnim() : void
      {
         if(!this.entity.alive)
         {
            return;
         }
         if(this.character.mobility.moving)
         {
            if(!this.moveStarted)
            {
               this.moveStarted = true;
               this.animSprite.controller.startLoco(this.entity.locoId);
            }
         }
         else
         {
            if(this.moveStarted)
            {
               this.animSprite.controller.stopLoco(this.entity.locoId);
            }
            this.moveStarted = false;
         }
         this.animSprite.controller.facing = this.entity.facing;
      }
      
      protected function animControllerFinishingEvent(param1:AnimControllerEvent) : void
      {
         if(this.moveStarted)
         {
            if(Boolean(this._animController) && this._animController.currentDefName == "walk")
            {
               this.animSprite.controller.playAnim("walkstop",1);
               this.moveStarted = false;
            }
         }
      }
      
      public function get starsVfxAnim() : XAnimClipSpriteBase
      {
         return this._starsVfxAnim;
      }
      
      public function set starsVfxAnim(param1:XAnimClipSpriteBase) : void
      {
         if(this._starsVfxAnim)
         {
            this._starsVfxAnim.clip.cleanup();
            this._starsVfxAnim.cleanup();
         }
         this._starsVfxAnim = param1;
      }
      
      protected function starsHandler(param1:StatEvent) : void
      {
         this.playStarsVfx(Math.abs(param1.delta));
      }
      
      protected function playStarsVfx(param1:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:VfxDef = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Pt = null;
         if(param1 == 0)
         {
            return;
         }
         var _loc2_:VfxLibrary = this.view.theVfxLibrary;
         if(_loc2_ != null)
         {
            _loc3_ = "use_star";
            _loc4_ = _loc2_.getVfxDef(_loc3_);
            if(_loc4_ != null)
            {
               _loc5_ = Math.min(_loc4_.numClipUrls - 1,param1 - 1);
               _loc6_ = _loc4_.getClipUrl(_loc5_);
               this.starsVfxAcr = _loc2_.getAnimClipResource(_loc6_);
               this.starsVfxIsoSprite = new IsoSprite("stars");
               this.view.battleBoardView.isoScenes.getIsoScene("main0").addChild(this.starsVfxIsoSprite);
               _loc7_ = new Pt(this.view.x + this.view.width / 2,this.view.y + this.view.length / 2,this.view.z);
               this.starsVfxAnim = this.view.playSpriteTowards(this.view,_loc7_,this.view.z + this.view.height / 2,this.starsVfxIsoSprite,this.starsVfxAcr,this.starsVfxCompleteHandler);
               this.checkStarsVfxWaits();
            }
            if(Math.abs(param1) > 1)
            {
               this.view.battleBoardView.board._scene._context.staticSoundController.playSound("ui_willpower_use",null);
            }
         }
      }
      
      private function starsVfxCompleteHandler(param1:AnimClip) : void
      {
         this.starsVfxAnim = null;
         if(this.starsVfxIsoSprite)
         {
            if(this.starsVfxIsoSprite.sprites.length)
            {
               this.starsVfxIsoSprite.sprites.splice(0,this.starsVfxIsoSprite.sprites.length);
               this.starsVfxIsoSprite.invalidateSprites();
            }
         }
         this.checkStarsVfxWaits();
      }
      
      private function checkStarsVfxWaits() : void
      {
         if(this.starsVfxIsoSprite)
         {
            if(this.starsVfxIsoSprite.sprites.length == 0)
            {
               if(this.starsVfxIsoSprite.parent)
               {
                  this.starsVfxIsoSprite.parent.removeChild(this.starsVfxIsoSprite);
               }
               this.starsVfxIsoSprite = null;
            }
         }
      }
      
      public function get character() : BattleEntity
      {
         return this.entity as BattleEntity;
      }
      
      protected function entitySelectedHandler(param1:BattleEntityEvent) : void
      {
         this.updateAnimationMix();
      }
      
      private function updateAnimationMix() : void
      {
         if(this.character.animController)
         {
            this.character.animController.setAmbientMixMasterState(this.character.selected);
         }
      }
      
      protected function entityMovedHandler(param1:BattleEntityEvent) : void
      {
         this.view.updatePosition();
      }
   }
}
