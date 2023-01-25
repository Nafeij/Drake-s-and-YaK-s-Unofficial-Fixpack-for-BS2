package engine.battle.entity.view
{
   import as3isolib.data.INode;
   import as3isolib.display.IsoGroup;
   import as3isolib.display.IsoSprite;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import engine.anim.AnimDispatcherEvent;
   import engine.anim.def.AnimLibrary;
   import engine.anim.def.OrientedAnims;
   import engine.anim.event.AnimControllerEvent;
   import engine.anim.view.AnimClip;
   import engine.anim.view.AnimController;
   import engine.anim.view.AnimControllerSprite;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.battle.CombatColors;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.event.TargetAnimEvent;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.indicator.EntityFlyText;
   import engine.battle.board.view.indicator.EntityFlyTextEntry;
   import engine.battle.def.IsoAnimLibraryResource;
   import engine.battle.def.IsoVfxLibraryResource;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.entity.model.BattleEntityTalentEvent;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.def.AssetBundle;
   import engine.entity.def.IAssetBundle;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityAssetBundle;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiSoundDebug;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.AnimClipResource;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.Saga;
   import engine.scene.SceneContext;
   import engine.sound.NullSoundDriver;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundLibraryResource;
   import engine.sound.view.ISound;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   import engine.talent.TalentDef;
   import engine.tile.def.TileRect;
   import engine.vfx.VfxLibrary;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   
   public class EntityView extends IsoGroup
   {
      
      public static const CAMERA_DIR:Point = new Point(Math.SQRT1_2,Math.SQRT1_2);
      
      protected static const ISO_W_PCT:Number = 0.4;
      
      protected static const SMOOTH_ENTITY_VIEWS:Boolean = true;
      
      public static var _last_ordinal:int;
      
      private static const _fontname_vinque:String = "Vinque";
      
      public static var INVISIBLE_SHOW:Boolean;
      
      public static var INVISIBLE_SHOW_ALPHA:Number = 0.3;
       
      
      public var entity:IBattleEntity;
      
      public var battleBoardView:BattleBoardView;
      
      private var _ready:Boolean;
      
      public var playedDeathAnim:Boolean;
      
      public var isoSprite:IsoSprite;
      
      public var iso:DisplayObjectWrapper;
      
      protected var flyText:EntityFlyText;
      
      public var shadowBitmapWrapper:DisplayObjectWrapper;
      
      public var animSprite:AnimControllerSprite;
      
      public var indicator:TargetIndicatorSprite;
      
      private var goAnimation:XAnimClipSpriteBase;
      
      private var goAnimationIso:IsoSprite;
      
      private var _propAnimClipSprite:XAnimClipSpriteBase = null;
      
      private var resourceGroup:ResourceGroup;
      
      public var logger:ILogger;
      
      private var animDispatcher:IEventDispatcher;
      
      private var character:EntityView_Character;
      
      private var animController:AnimController;
      
      public var armstat:Stat;
      
      public var layer:String = "main0";
      
      public var _ordinal:int;
      
      private var _entityId:String;
      
      private var _assetBundle:IAssetBundle;
      
      public var _entityViewVfx:EntityViewVfx;
      
      private var _entityBundle:IEntityAssetBundle;
      
      public var cleanedup:Boolean;
      
      private var _alpha:Number = 1;
      
      private var _didEnableFade:Boolean;
      
      private var _scratchCenter:Pt;
      
      private var _lastIncorporealFade:Boolean;
      
      public function EntityView(param1:BattleBoardView, param2:IBattleEntity, param3:ResourceManager, param4:Boolean, param5:IEntityAssetBundleManager)
      {
         this._scratchCenter = new Pt();
         super("view_" + param2.id);
         this._ordinal = ++_last_ordinal;
         this.resourceGroup = new ResourceGroup(this,param3.logger);
         this.battleBoardView = param1;
         this.entity = param2;
         this._entityId = param2.id;
         this.logger = param2.board.logger;
         this.animDispatcher = param1.board._scene._context.animDispatcher;
         this.animSprite = this.handleCreateAnimControllerSprite();
         this.configureSprites();
         this._assetBundle = new AssetBundle(this.toString(),this.logger);
         this.preloadAssets(param5,param4);
         this.updatePosition();
         param2.addEventListener(BattleEntityEvent.ALIVE,this.entityAliveHandler);
         param2.addEventListener(BattleEntityEvent.VISIBLE,this.entityVisibleHandler);
         param2.addEventListener(BattleEntityEvent.FLASH_VISIBLE,this.entityFlashVisibleHandler);
         param2.addEventListener(BattleEntityEvent.FACING,this.entityFacingHandler);
         param2.addEventListener(BattleEntityEvent.FLY_TEXT,this.entityFlyTextHandler);
         param2.addEventListener(BattleEntityEvent.GO_ANIMATION,this.entityGoAnimationHandler);
         this.animSprite.controller.addEventListener(AnimControllerEvent.EVENT,this.onAnimEvent);
         param2.addEventListener(BattleEntityEvent.ENABLED,this.enabledHandler);
         this._entityViewVfx = new EntityViewVfx(this.battleBoardView,this,this.logger);
         if(param2.mobile == true)
         {
            param2.stats.getStat(StatType.STRENGTH).addEventListener(StatEvent.BASE_CHANGE,this.strengthBaseChangeHandler);
            this.armstat = param2.stats.getStat(StatType.ARMOR,false);
            if(this.armstat)
            {
               this.armstat.addEventListener(StatEvent.BASE_CHANGE,this.armorBaseChangeHandler);
            }
            param2.addEventListener(BattleEntityEvent.MISSED,this.entityMissedHandler);
            param2.addEventListener(BattleEntityEvent.KILL_STOP,this.entityKillStopHandler);
            param2.addEventListener(BattleEntityEvent.RESISTED,this.entityResistedHandler);
            param2.addEventListener(BattleEntityEvent.DIVERTED,this.entityDivertedHandler);
            param2.addEventListener(BattleEntityEvent.CRIT,this.entityCritHandler);
            param2.addEventListener(BattleEntityEvent.ABSORBING,this.entityAbsorbingHandler);
            param2.addEventListener(BattleEntityEvent.DODGE,this.entityDodgeHandler);
            param2.addEventListener(BattleEntityTalentEvent.EXECUTED,this.entityTalentHandler);
            param2.addEventListener(BattleEntityEvent.SUBMERGED,this.entitySubmergedHandler);
            param2.addEventListener(BattleEntityEvent.TELEPORTING,this.entityTeleportingHandler);
         }
         this.enabledHandler(null);
         param2.animEventDispatcher.addEventListener(TargetAnimEvent.EVENT,this.animEvent);
         var _loc6_:IEntityAppearanceDef = param2.def.appearance;
         if(Boolean(_loc6_) && Boolean(_loc6_.animsUrl))
         {
            this.animController = this.animSprite.controller;
            this.animController.useDefaultAmbientMix = true;
         }
         if(param2.mobile)
         {
            this.character = new EntityView_Character(this);
         }
      }
      
      public function getBattleInfoFlagPosition(param1:Point) : Point
      {
         var _loc2_:Number = this.battleBoardView.board.scene.camera.scale;
         param1.setTo(_loc2_ * mainContainer.x,_loc2_ * (mainContainer.y - (height + 15)));
         return param1;
      }
      
      public function getSpeechBubblePosition(param1:Point) : Point
      {
         if(this.cleanedup)
         {
            return param1;
         }
         var _loc2_:Number = this.battleBoardView.board.scene.camera.scale;
         param1.setTo(mainContainer.x,mainContainer.y - (height + 5));
         return param1;
      }
      
      public function getBattleDamageFlagPosition(param1:Point) : Point
      {
         var _loc2_:Number = this.battleBoardView.board.scene.camera.scale;
         var _loc3_:Number = width / 4;
         var _loc4_:Number = length / 4;
         param1.setTo(_loc2_ * (mainContainer.x + _loc3_ - _loc4_),_loc2_ * (mainContainer.y + _loc4_ + _loc3_));
         return param1;
      }
      
      protected function handleCreateAnimControllerSprite() : AnimControllerSprite
      {
         return null;
      }
      
      public function get propAnimClipSprite() : XAnimClipSpriteBase
      {
         return this._propAnimClipSprite;
      }
      
      public function set propAnimClipSprite(param1:XAnimClipSpriteBase) : void
      {
         if(this._propAnimClipSprite)
         {
            this._propAnimClipSprite.clip.cleanup();
            this._propAnimClipSprite.cleanup();
         }
         this._propAnimClipSprite = param1;
      }
      
      private function _listenAsset(param1:IResource, param2:Function) : void
      {
         if(param1)
         {
            param1.addResourceListener(param2);
         }
      }
      
      private function _unlistenAsset(param1:IResource, param2:Function) : void
      {
         if(param1)
         {
            param1.removeResourceListener(param2);
         }
      }
      
      private function set entityBundle(param1:IEntityAssetBundle) : void
      {
         if(this._entityBundle)
         {
            this._unlistenAsset(this._entityBundle.alr,this.animSetDefResourceComplete);
            this._unlistenAsset(this._entityBundle.slr,this.soundLibraryResourceCompleteHandler);
            this._unlistenAsset(this._entityBundle.propAnimClipResource,this.propAnimClipResourceCompleteHandler);
            this._unlistenAsset(this._entityBundle.shadowBitmapResource,this.onShadowLoaded);
            this._unlistenAsset(this._entityBundle.goAnimationRes,this.onGoAnimationLoad);
            this._entityBundle.releaseReference();
         }
         this._entityBundle = param1;
         if(this._entityBundle)
         {
            this._entityBundle.addReference();
            this._listenAsset(this._entityBundle.alr,this.animSetDefResourceComplete);
            this._listenAsset(this._entityBundle.slr,this.soundLibraryResourceCompleteHandler);
            this._listenAsset(this._entityBundle.propAnimClipResource,this.propAnimClipResourceCompleteHandler);
            this._listenAsset(this._entityBundle.shadowBitmapResource,this.onShadowLoaded);
            this._listenAsset(this._entityBundle.goAnimationRes,this.onGoAnimationLoad);
         }
      }
      
      private function preloadAssets(param1:IEntityAssetBundleManager, param2:Boolean) : void
      {
         var ed:IEntityDef = null;
         var ep:IEntityAssetBundle = null;
         var eps:IEntityAssetBundleManager = param1;
         var withSpeechBubble:Boolean = param2;
         ed = this.entity.def;
         try
         {
            ep = eps.getEntityPreload(ed,this._assetBundle,withSpeechBubble,false,true);
            if(this.entity.isPlayer)
            {
               ep.loadVersus();
            }
            this.entityBundle = ep;
         }
         catch(e:Error)
         {
            logger.error("failed to preload entity view assets for [" + ed + "]:\n" + e.getStackTrace());
         }
      }
      
      public function cleanup() : void
      {
         var clip:AnimClip = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("double cleanup, not so clean");
         }
         if(this.character)
         {
            this.character.cleanup();
            this.character = null;
         }
         super.removeAllChildren();
         this.entity.animEventDispatcher.removeEventListener(TargetAnimEvent.EVENT,this.animEvent);
         if(this.entity.mobile)
         {
            this.entity.stats.getStat(StatType.STRENGTH).removeEventListener(StatEvent.BASE_CHANGE,this.strengthBaseChangeHandler);
         }
         if(this.armstat)
         {
            this.armstat.removeEventListener(StatEvent.BASE_CHANGE,this.armorBaseChangeHandler);
            this.armstat = null;
         }
         this.propAnimClipSprite = null;
         this.entity.removeEventListener(BattleEntityEvent.MISSED,this.entityMissedHandler);
         this.entity.removeEventListener(BattleEntityEvent.KILL_STOP,this.entityKillStopHandler);
         this.entity.removeEventListener(BattleEntityEvent.RESISTED,this.entityResistedHandler);
         this.entity.removeEventListener(BattleEntityEvent.DIVERTED,this.entityDivertedHandler);
         this.entity.removeEventListener(BattleEntityEvent.CRIT,this.entityCritHandler);
         this.entity.removeEventListener(BattleEntityEvent.ABSORBING,this.entityAbsorbingHandler);
         this.entity.removeEventListener(BattleEntityEvent.DODGE,this.entityDodgeHandler);
         this.entity.removeEventListener(BattleEntityTalentEvent.EXECUTED,this.entityTalentHandler);
         this.entity.removeEventListener(BattleEntityEvent.VISIBLE,this.entityVisibleHandler);
         this.entity.removeEventListener(BattleEntityEvent.FLASH_VISIBLE,this.entityFlashVisibleHandler);
         this.entity.removeEventListener(BattleEntityEvent.FACING,this.entityFacingHandler);
         this.entity.removeEventListener(BattleEntityEvent.ALIVE,this.entityAliveHandler);
         this.entity.removeEventListener(BattleEntityEvent.FLY_TEXT,this.entityFlyTextHandler);
         this.entity.removeEventListener(BattleEntityEvent.GO_ANIMATION,this.entityGoAnimationHandler);
         this.animSprite.controller.removeEventListener(AnimControllerEvent.EVENT,this.onAnimEvent);
         this.entity.removeEventListener(BattleEntityEvent.ENABLED,this.enabledHandler);
         try
         {
            if(this.flyText)
            {
               this.flyText.cleanup();
               this.flyText = null;
            }
         }
         catch(e:Error)
         {
            logger.error("EntityView for " + entity.id + " failed to cleanup flytext:\n" + e.getStackTrace());
         }
         this._entityViewVfx.cleanup();
         if(this.goAnimation)
         {
            clip = this.goAnimation.clip;
            this.goAnimation.cleanup();
            this.goAnimation = null;
            if(clip)
            {
               clip.cleanup();
            }
         }
         this.entityBundle = null;
         this.cleanupSprites();
         this.animSprite.cleanup();
         this.animSprite = null;
         this.animDispatcher = null;
         this.logger = null;
         this.entity = null;
         this.battleBoardView = null;
         if(this.resourceGroup)
         {
            this.resourceGroup.release();
            this.resourceGroup = null;
         }
         if(this._assetBundle)
         {
            this._assetBundle.releaseReference();
            this._assetBundle.cleanup();
            this._assetBundle = null;
         }
         super.cleanupIsoContainer();
         this.cleanedup = true;
      }
      
      public function animEvent(param1:TargetAnimEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:ISound = null;
         if(this.battleBoardView.soundDriver is NullSoundDriver || !this.battleBoardView.soundDriver.system.mixer.sfxEnabled)
         {
            return;
         }
         var _loc2_:BattleEntity = this.entity as BattleEntity;
         if(param1.eventId == "footstep_left" || param1.eventId == "footstep_right" || param1.eventId == "fsl" || param1.eventId == "fsr")
         {
            _loc3_ = "footstep";
         }
         else if(param1.eventId.indexOf("foley_") == 0)
         {
            _loc3_ = param1.eventId;
         }
         else if(param1.eventId.indexOf("^") == 0)
         {
            _loc3_ = param1.eventId.substr(1);
         }
         else if(param1.eventId == "*release")
         {
            if(Boolean(this.entity.mobility) && this.entity.mobility.moving)
            {
               this.entity.animController.stop();
            }
         }
         if(_loc3_)
         {
            if(GuiSoundDebug.DEBUGGING)
            {
               if(_loc3_ == "foley_shield_hit")
               {
                  return;
               }
            }
            _loc4_ = _loc2_.soundController.playSound(_loc3_,null);
            if(!_loc4_)
            {
               if(this.animDispatcher)
               {
                  this.animDispatcher.dispatchEvent(new AnimDispatcherEvent(AnimDispatcherEvent.SOUND_ERROR,_loc2_,_loc3_,null,null));
               }
            }
         }
      }
      
      private function translateGui(param1:String) : String
      {
         if(this.entity && this.entity.board && this.entity.board.scene && Boolean(this.entity.board.scene.context))
         {
            return this.entity.board.scene.context.locale.translateGui(param1);
         }
         return "!!>" + param1 + "<!!";
      }
      
      private function entityCritHandler(param1:BattleEntityEvent) : void
      {
         this.showFlyText(this.translateGui("flytext_crit"),CombatColors.CRIT,_fontname_vinque,20);
      }
      
      private function playOptionalSound(param1:String) : void
      {
         var _loc2_:ISoundDef = null;
         if(this.entity && this.entity.soundController && Boolean(this.entity.soundController.library))
         {
            _loc2_ = this.entity.soundController.library.getSoundDef(param1);
            if(Boolean(_loc2_) && Boolean(_loc2_.eventName))
            {
               this.entity.soundController.playSound(param1,null);
            }
         }
      }
      
      private function entityAbsorbingHandler(param1:BattleEntityEvent) : void
      {
         this.showFlyText(this.translateGui("flytext_absorb"),CombatColors.CRIT,_fontname_vinque,20);
         this.playOptionalSound("armor_absorb");
      }
      
      private function entitySubmergedHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:Number = NaN;
         if(this.shadowBitmapWrapper)
         {
            _loc2_ = this.entity.isSubmerged ? 0 : 1;
            TweenMax.to(this.shadowBitmapWrapper,0.5,{"alpha":_loc2_});
         }
      }
      
      private function entityTeleportingHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:Number = NaN;
         if(this.shadowBitmapWrapper)
         {
            _loc2_ = this.entity.isTeleporting ? 0 : 1;
            TweenMax.to(this.shadowBitmapWrapper,0.5,{"alpha":_loc2_});
         }
      }
      
      private function entityDodgeHandler(param1:BattleEntityEvent) : void
      {
         this.playOptionalSound("dodge");
         this.showFlyText(this.translateGui("flytext_dodge"),CombatColors.MISS,_fontname_vinque,20);
      }
      
      private function entityTalentHandler(param1:BattleEntityTalentEvent) : void
      {
         var _loc8_:String = null;
         if(!this.entity || !this.entity.board || !this.entity.board.scene || !this.entity.board.scene.context)
         {
            return;
         }
         var _loc2_:SceneContext = this.entity.board.scene.context;
         var _loc3_:Locale = _loc2_.locale;
         var _loc4_:TalentDef = param1.talentDef;
         var _loc5_:String = _loc4_.getLocalizedName(_loc3_);
         var _loc6_:uint = _loc4_.parentStatType.color;
         this.showFlyText(_loc5_,_loc6_,_fontname_vinque,20);
         var _loc7_:Saga = _loc2_.saga as Saga;
         if(_loc7_)
         {
            _loc8_ = _loc7_.def.talentDefs.getSoundCombatByParentStatType(_loc4_.parentStatType);
            _loc2_.staticSoundController.playSound(_loc8_,null);
         }
      }
      
      private function entityDivertedHandler(param1:BattleEntityEvent) : void
      {
         this.showFlyText(this.translateGui("flytext_divert"),CombatColors.MISS,_fontname_vinque,20);
      }
      
      private function entityResistedHandler(param1:BattleEntityEvent) : void
      {
         this.showFlyText(this.translateGui("flytext_resist"),CombatColors.MISS,_fontname_vinque,20);
      }
      
      private function entityMissedHandler(param1:BattleEntityEvent) : void
      {
         this.playOptionalSound("deflect");
         this.showFlyText(this.translateGui("flytext_deflect"),CombatColors.MISS,_fontname_vinque,20);
      }
      
      private function entityKillStopHandler(param1:BattleEntityEvent) : void
      {
         this.showFlyText(this.translateGui("flytext_protected"),CombatColors.KILL_STOP,_fontname_vinque,20);
      }
      
      private function armorBaseChangeHandler(param1:StatEvent) : void
      {
         if(this.entity.suppressFlytext)
         {
            return;
         }
         if(param1.delta < 0)
         {
            this.showFlyText(param1.delta.toString(),CombatColors.DAMAGE_ARMOR,_fontname_vinque,39);
         }
         else if(param1.delta > 0)
         {
            this.showFlyText("+" + param1.delta.toString(),CombatColors.DAMAGE_ARMOR,_fontname_vinque,39);
         }
      }
      
      private function strengthBaseChangeHandler(param1:StatEvent) : void
      {
         if(this.entity.suppressFlytext)
         {
            return;
         }
         if(param1.delta < 0)
         {
            this.showFlyText(param1.delta.toString(),CombatColors.DAMAGE_STRENGTH,_fontname_vinque,39);
         }
         else if(param1.delta > 0)
         {
            this.showFlyText("+" + param1.delta.toString(),CombatColors.DAMAGE_STRENGTH,_fontname_vinque,39);
         }
      }
      
      private function _computeBaseAlpha() : Number
      {
         if(this.entity.incorporealFade)
         {
            return 0.5;
         }
         return 1;
      }
      
      public function entityFlashVisibleHandler(param1:BattleEntityEvent) : void
      {
         var _loc7_:DisplayObjectWrapper = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc2_:int = int(this.entity.visibleFadeMs);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:Number = this.invisibleAlpha;
         var _loc4_:Number = !!this.entity.visible ? this.invisibleAlpha : 1;
         var _loc5_:Number = !!this.entity.visible ? 1 : this.invisibleAlpha;
         var _loc6_:Number = this._computeBaseAlpha();
         _loc4_ *= _loc6_;
         _loc5_ *= _loc6_;
         for each(_loc7_ in this.isoSprite.sprites)
         {
            _loc8_ = Math.abs(_loc4_ - _loc5_);
            _loc9_ = _loc2_ / 1000 * _loc8_;
            _loc7_.alpha = _loc5_;
            TweenMax.to(_loc7_,_loc9_,{
               "alpha":_loc4_,
               "ease":Quad.easeIn,
               "yoyo":true,
               "repeat":1
            });
         }
      }
      
      public function entityFacingHandler(param1:BattleEntityEvent) : void
      {
         this.updatePosition();
         this._updateSpriteSizes();
         this.positionShadow();
         if(this._entityViewVfx)
         {
            this._entityViewVfx.updateEntityOrientation();
         }
         if(!this.indicator)
         {
         }
         if(this.character)
         {
            this.character.handleFacing();
         }
      }
      
      private function get invisibleAlpha() : Number
      {
         if(this.entity.isPlayer)
         {
            return 0.5;
         }
         return INVISIBLE_SHOW ? INVISIBLE_SHOW_ALPHA : 0;
      }
      
      public function set alpha(param1:Number) : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         if(this.cleanedup)
         {
            return;
         }
         this._alpha = param1;
         if(this.isoSprite)
         {
            for each(_loc2_ in this.isoSprite.sprites)
            {
               _loc2_.alpha = this._alpha;
            }
         }
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function fadeEntity(param1:int, param2:Boolean) : void
      {
         var _loc3_:Number = param2 ? 1 : this.invisibleAlpha;
         var _loc4_:Number = this._computeBaseAlpha();
         _loc3_ *= _loc4_;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("EntityView.fadeEntity " + this + " " + param2 + " in " + param1 + " ta=" + _loc3_);
         }
         if(!param1)
         {
            this.killFadeTweens(_loc3_);
            return;
         }
         TweenMax.killTweensOf(this);
         var _loc5_:Number = Math.abs(this._alpha - _loc3_);
         var _loc6_:Number = param1 / 1000 * _loc5_;
         TweenMax.to(this,_loc6_,{
            "alpha":_loc3_,
            "ease":Quad.easeIn
         });
      }
      
      public function entityVisibleHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:int = int(this.entity.visibleFadeMs);
         this.fadeEntity(_loc2_,this.entity.visible);
      }
      
      private function killFadeTweensToVisibility() : void
      {
         var _loc1_:Number = !!this.entity.visible ? 1 : this.invisibleAlpha;
         this.killFadeTweens(_loc1_);
      }
      
      private function killFadeTweens(param1:Number) : void
      {
         TweenMax.killTweensOf(this);
         this.alpha = param1;
      }
      
      private function entityAliveHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:AnimController = null;
         var _loc5_:OrientedAnims = null;
         if(!this.entity)
         {
            return;
         }
         if(!this.entity.alive)
         {
            _loc2_ = this.entity.deathAnim;
            _loc3_ = this.entity.deathVocalization;
            this.playDeathAnim(_loc2_,_loc3_);
         }
         else
         {
            height = this.entity.height * this.battleBoardView.units;
            this.playedDeathAnim = false;
            _loc4_ = this.animSprite.controller;
            _loc5_ = _loc4_.current;
            if(_loc5_)
            {
               if(_loc5_.hold)
               {
                  _loc5_.hold = false;
                  if(_loc5_.holding)
                  {
                     _loc5_.holding = false;
                     _loc4_.stop();
                  }
               }
            }
            this.battleBoardView.moveToLayer(this,"main0");
            _loc4_.ambientMix = "mix_idle";
         }
      }
      
      public function playDeathAnim(param1:String, param2:String) : void
      {
         var _loc3_:AnimController = null;
         if(!this.playedDeathAnim)
         {
            _loc3_ = this.animSprite.controller;
            this.playedDeathAnim = true;
            _loc3_.ambientMix = null;
            if(param1 && _loc3_ && _loc3_.library && _loc3_.library.hasOrientedAnims(_loc3_.layer,param1))
            {
               this.animSprite.controller.playAnim(param1,1,true,false,false,1,null,5);
            }
            else
            {
               this.entity.setVisible(false,500);
            }
            if(param2)
            {
               this.entity.soundController.playSound(param2,null);
            }
         }
      }
      
      internal function playSpriteTowards(param1:EntityView, param2:Pt, param3:Number, param4:IsoSprite, param5:AnimClipResource, param6:Function) : XAnimClipSpriteBase
      {
         var _loc7_:Point = null;
         if(!param5)
         {
            this.logger.error("EntityView.playSpriteTowards " + param1 + " requires an AnimClipResource");
            return null;
         }
         var _loc8_:Point = new Point(param1.width / 2,param1.length / 2);
         var _loc9_:Point = new Point(param1.x + _loc8_.x,param1.y + _loc8_.y);
         if(param2 != null)
         {
            _loc7_ = new Point(param2.x - _loc9_.x,param2.y - _loc9_.y);
            _loc7_.normalize(1);
         }
         else
         {
            _loc7_ = CAMERA_DIR;
         }
         var _loc10_:XAnimClipSpriteBase = !!param5 ? param5.animClipSprite : null;
         if(_loc10_ == null)
         {
            this.logger.error("EntityView.playSpriteTowards: No XAnimClipSprite found on " + param5.url);
            return null;
         }
         _loc10_.name = "sprite_" + (!!param5 ? param5.url : "?");
         _loc10_.clip.repeatLimit = 1;
         _loc10_.clip.finishedCallback = param6;
         _loc10_.clip.start(0);
         var _loc11_:Number = this.battleBoardView.units / 100;
         var _loc12_:Number = Math.sqrt(_loc8_.x * _loc8_.x + _loc8_.y * _loc8_.y) + _loc11_ * 2;
         var _loc13_:Number = Math.sqrt(_loc8_.x * _loc8_.x + _loc8_.y * _loc8_.y) / 16;
         param4.setSize(_loc11_,_loc11_,_loc11_);
         var _loc14_:Pt = new Pt(_loc9_.x + _loc7_.x * _loc12_,_loc9_.y + _loc7_.y * _loc12_,param3);
         param4.moveTo(_loc14_.x,_loc14_.y,_loc14_.z);
         var _loc15_:Pt = new Pt(_loc9_.x + _loc7_.x * _loc13_,_loc9_.y + _loc7_.y * _loc13_,param3);
         var _loc16_:Pt = IsoMath.isoToScreen(_loc14_);
         var _loc17_:Pt = IsoMath.isoToScreen(_loc15_);
         _loc10_.x = _loc17_.x - _loc16_.x;
         _loc10_.y = _loc17_.y - _loc16_.y;
         this.killFadeTweensToVisibility();
         param4.sprites = [_loc10_.displayObjectWrapper];
         return _loc10_;
      }
      
      private function enabledHandler(param1:BattleEntityEvent) : void
      {
         this.isoSprite.container.visible = this.entity.enabled;
         if(Boolean(this.entity.enabled) && Boolean(this.entity.visible))
         {
            if(!this._didEnableFade)
            {
               this._didEnableFade = true;
               if(this.entity.board.boardSetup)
               {
                  this.fadeEntity(0,false);
                  this.fadeEntity(300,true);
               }
            }
         }
      }
      
      private function onGoAnimationLoad(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:AnimClipResource = param1.resource as AnimClipResource;
         _loc2_.removeResourceListener(this.onGoAnimationLoad);
         if(_loc2_.ok)
         {
            this.goAnimation = _loc2_.animClipSprite;
            this.goAnimation.visible = false;
            this.goAnimation.clip.stop();
            this.goAnimation.clip.finishedCallback = this.goAnimationCallback;
            this.goAnimationIso = new IsoSprite("go");
            this.goAnimationIso.sprites = [this.goAnimation.displayObjectWrapper];
         }
      }
      
      private function onShadowLoaded(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:BitmapResource = param1.resource as BitmapResource;
         _loc2_.removeResourceListener(this.onShadowLoaded);
         if(!_loc2_.ok)
         {
            return;
         }
         this.shadowBitmapWrapper = _loc2_.getWrapper();
         this.shadowBitmapWrapper.name = "shadow";
         this.shadowBitmapWrapper.blendMode = BlendMode.MULTIPLY;
         this.positionShadow();
         this.killFadeTweensToVisibility();
         if(this._propAnimClipSprite == null)
         {
            this.isoSprite.sprites = [this.shadowBitmapWrapper,this.indicator.displayObjectWrapper,this.animSprite.displayObjectWrapper];
         }
         else
         {
            this.isoSprite.sprites = [this.shadowBitmapWrapper,this.indicator.displayObjectWrapper,this.animSprite.displayObjectWrapper,this._propAnimClipSprite.displayObjectWrapper];
         }
      }
      
      private function positionShadow() : void
      {
         if(!this.shadowBitmapWrapper)
         {
            return;
         }
         this.shadowBitmapWrapper.x = -1 * (this.shadowBitmapWrapper.width / 2);
         if(this.entity.boardWidth == 2 && this.entity.boardLength == 1)
         {
            this.shadowBitmapWrapper.scaleX = -1;
            this.shadowBitmapWrapper.x = -this.shadowBitmapWrapper.x;
            this.shadowBitmapWrapper.x += this.isoSprite.length / 2;
         }
         else if(this.entity.boardWidth == 1 && this.entity.boardLength == 2)
         {
            this.shadowBitmapWrapper.scaleX = 1;
            this.shadowBitmapWrapper.x -= this.isoSprite.width / 2;
         }
         else
         {
            this.shadowBitmapWrapper.y = -1 * (this.shadowBitmapWrapper.height / 2);
            this.shadowBitmapWrapper.y += this.isoSprite.length / 2;
         }
      }
      
      protected function animSetDefResourceComplete(param1:ResourceLoadedEvent) : void
      {
         var _loc3_:AnimLibrary = null;
         var _loc4_:AnimController = null;
         var _loc2_:IsoAnimLibraryResource = param1.resource as IsoAnimLibraryResource;
         if(_loc2_)
         {
            _loc2_.removeResourceListener(this.animSetDefResourceComplete);
            _loc3_ = _loc2_.library;
            if(Boolean(this._entityBundle) && _loc2_ == this._entityBundle.alr)
            {
               this.animSprite.library = !!_loc3_ ? _loc3_.variation(this.entity.def.appearanceIndex) : null;
            }
         }
         if(!this.entity.alive)
         {
            _loc4_ = !!this.animSprite ? this.animSprite.controller : null;
            if(this.animSprite && _loc4_ && this.animSprite.library && this.animSprite.library.hasOrientedAnims(null,this.entity.deathAnim))
            {
               this.animSprite.controller.holdLastFrame(this.entity.deathAnim);
            }
         }
         this.updatePosition();
      }
      
      protected function propAnimClipResourceCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:AnimClipResource = param1.resource as AnimClipResource;
         _loc2_.removeEventListener(Event.COMPLETE,this.propAnimClipResourceCompleteHandler);
         if(_loc2_.ok)
         {
            if(Boolean(this._entityBundle) && this._entityBundle.propAnimClipResource == _loc2_)
            {
               this.propAnimClipSprite = _loc2_.animClipSprite;
               this.propAnimClipSprite.clip.start();
               this.propAnimClipSprite.x = 0;
               this.propAnimClipSprite.y = this.entity.boardWidth * this.isoSprite.height / 2;
               this.killFadeTweensToVisibility();
               if(this.shadowBitmapWrapper)
               {
                  this.isoSprite.sprites = [this.shadowBitmapWrapper,this.indicator.displayObjectWrapper,this.animSprite.displayObjectWrapper,this._propAnimClipSprite.displayObjectWrapper];
               }
               else
               {
                  this.isoSprite.sprites = [this.indicator.displayObjectWrapper,this.animSprite.displayObjectWrapper,this._propAnimClipSprite.displayObjectWrapper];
               }
            }
         }
      }
      
      public function get theVfxLibrary() : VfxLibrary
      {
         if(Boolean(this._entityBundle) && Boolean(this._entityBundle.vlr))
         {
            return (this._entityBundle.vlr as IsoVfxLibraryResource).library;
         }
         return null;
      }
      
      protected function soundLibraryResourceCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:SoundLibraryResource = param1.resource as SoundLibraryResource;
         if(_loc2_)
         {
            this.entity.soundController.library = _loc2_.library;
            if(Boolean(this._entityBundle) && this._entityBundle.slr == _loc2_)
            {
               _loc2_.removeResourceListener(this.soundLibraryResourceCompleteHandler);
            }
         }
      }
      
      private function configureSprites() : void
      {
         this.isoSprite = new IsoSprite(this.entity.id);
         this.iso = this.isoSprite.container;
         addChild(this.isoSprite);
         if(!this.entity.def.id)
         {
            this.entity.logger.error("Cannot configure sprites for entity with null def id");
            return;
         }
         this.indicator = new TargetIndicatorSprite(this,this.battleBoardView.board.sim.fsm,this.battleBoardView.units,this.battleBoardView.bitmapPool,this.battleBoardView.animClipSpritePool,this.battleBoardView.board.assets);
         this.indicator.displayObjectWrapper.y = this.isoSprite.width / 2;
         this.killFadeTweensToVisibility();
         this.isoSprite.sprites = [this.indicator.displayObjectWrapper,this.animSprite.displayObjectWrapper];
         this.entityFacingHandler(null);
         this.ready = true;
      }
      
      private function _updateSpriteSizes() : void
      {
         if(!this.battleBoardView || !this.isoSprite || !this.entity || !this.animSprite)
         {
            return;
         }
         var _loc1_:Number = this.battleBoardView.units;
         var _loc2_:Number = _loc1_ * this.entity.diameter;
         var _loc3_:Number = _loc1_ * this.entity.boardWidth;
         var _loc4_:Number = _loc1_ * this.entity.boardLength;
         var _loc5_:Number = _loc1_ * this.entity.height;
         var _loc6_:Number = _loc1_ * (this.entity.localLength - this.entity.diameter);
         this.isoSprite.setSize(_loc3_,_loc4_,_loc5_);
         setSize(_loc3_,_loc4_,_loc5_);
         var _loc7_:DisplayObjectWrapper = this.animSprite.displayObjectWrapper;
         if(_loc3_ == _loc4_)
         {
            _loc7_.y = _loc2_;
            _loc7_.x = 0;
         }
         else if(this.entity.facing == BattleFacing.NE)
         {
            _loc7_.y = _loc2_;
            _loc7_.x = 0;
         }
         else if(this.entity.facing == BattleFacing.NW)
         {
            _loc7_.y = _loc2_;
            _loc7_.x = 0;
         }
         else if(this.entity.facing == BattleFacing.SE)
         {
            _loc7_.y = _loc2_ + _loc6_ / 2;
            _loc7_.x = _loc6_;
         }
         else if(this.entity.facing == BattleFacing.SW)
         {
            _loc7_.y = _loc2_ + _loc6_ / 2;
            _loc7_.x = -_loc6_;
         }
      }
      
      private function cleanupSprites() : void
      {
         this.isoSprite.sprites = null;
         this.indicator.cleanup();
         this.indicator = null;
         removeChild(this.isoSprite);
         this.isoSprite.cleanupIsoContainer();
         this.isoSprite = null;
         if(this.shadowBitmapWrapper)
         {
            TweenMax.killTweensOf(this.shadowBitmapWrapper);
            this.shadowBitmapWrapper.release();
            this.shadowBitmapWrapper = null;
         }
      }
      
      protected function showFlyText(param1:String, param2:uint, param3:String, param4:int) : void
      {
         var _loc5_:Number = NaN;
         if(!BattleFsmConfig.guiFlytextShouldRender)
         {
            return;
         }
         if(!this.flyText)
         {
            this.flyText = new EntityFlyText(this,null);
            _loc5_ = this.animSprite.height * 0.75;
            this.flyText.moveTo(x,y,z + _loc5_);
            this.battleBoardView.isoScenes.getIsoScene("fg0").addChild(this.flyText);
         }
         this.flyText.push(param1,param2,param3,param4);
      }
      
      private function entityGoAnimationHandler(param1:BattleEntityEvent) : void
      {
         if(!BattleFsmConfig.guiTilesEnabled)
         {
            return;
         }
         if(this.goAnimationIso.parent == null)
         {
            addChild(this.goAnimationIso);
         }
         this.goAnimation.visible = true;
         this.battleBoardView.board._scene._context.staticSoundController.playSound("ui_players_turn",null);
         this.goAnimation.clip.repeatLimit = 1;
         this.goAnimation.clip.count = 0;
         this.goAnimation.clip.restart();
      }
      
      private function goAnimationCallback(param1:AnimClip) : void
      {
         if(Boolean(this.goAnimation) && this.goAnimation.clip == param1)
         {
            this.goAnimation.visible = false;
            removeChild(this.goAnimationIso);
         }
      }
      
      private function entityFlyTextHandler(param1:BattleEntityEvent) : void
      {
         this.showFlyText(this.entity.flyText,this.entity.flyTextColor,this.entity.flyTextFontName,this.entity.flyTextFontSize);
      }
      
      public function onAnimEvent(param1:AnimControllerEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:INode = null;
         var _loc5_:IsoSprite = null;
         if(this.playedDeathAnim)
         {
            if(param1.eventId == "*hold")
            {
               height = 0;
               this.z += this.entity.board.deathOffset;
               _loc2_ = 0;
               while(_loc2_ < numChildren)
               {
                  _loc4_ = getChildAt(_loc2_);
                  if(_loc4_)
                  {
                     _loc5_ = _loc4_ as IsoSprite;
                     if(_loc5_)
                     {
                        _loc5_.container.y += this.entity.board.deathOffset;
                     }
                     _loc5_.invalidateSprites();
                  }
                  _loc2_++;
               }
               this.battleBoardView.moveToLayer(this,"bg0");
               render(true);
               _loc3_ = 1;
               this.entity.board.deathOffset += _loc3_;
            }
         }
         if(GuiSoundDebug.DEBUGGING)
         {
            if(param1.eventId == "foley_shield_hit")
            {
               return;
            }
         }
         if(this.animDispatcher)
         {
            this.animDispatcher.dispatchEvent(new AnimDispatcherEvent(AnimDispatcherEvent.ANIM_EVENT,this.entity,param1.controller.id,param1.animId,param1.eventId));
         }
         this.entity.animEventDispatcher.dispatchEvent(new TargetAnimEvent(TargetAnimEvent.EVENT,param1.animId,param1.eventId));
      }
      
      public function toString() : String
      {
         return "[EntityView entity=" + this.entity + "]";
      }
      
      internal function updatePosition() : void
      {
         var _loc5_:Number = NaN;
         var _loc1_:Number = this.battleBoardView.units;
         var _loc2_:TileRect = this.entity.rect;
         var _loc3_:Number = _loc1_ * (this.entity.x + _loc2_.posLeft);
         var _loc4_:Number = _loc1_ * (this.entity.y + _loc2_.posFront);
         moveTo(_loc3_,_loc4_,z);
         validatePosition();
         if(this.flyText)
         {
            _loc5_ = !!this.animSprite ? this.animSprite.height * 0.75 : 0;
            this.flyText.moveTo(x,y,z + _loc5_);
         }
      }
      
      public function get ready() : Boolean
      {
         return this._ready;
      }
      
      public function set ready(param1:Boolean) : void
      {
         this._ready = param1;
         this.battleBoardView.onEntityViewReady(this);
      }
      
      public function get centerScreenPointGlobal() : Point
      {
         if(!this.battleBoardView || !this.entity)
         {
            this._scratchCenter.setTo(0,0);
            return this._scratchCenter;
         }
         var _loc1_:Number = this.battleBoardView.units;
         var _loc2_:int = this.entity.boardWidth * _loc1_;
         var _loc3_:int = this.entity.boardLength * _loc1_;
         this._scratchCenter.setTo(x + _loc2_ / 2,y + _loc3_ / 2);
         return this.battleBoardView.getScreenPointGlobalPt(this._scratchCenter);
      }
      
      public function update(param1:int) : void
      {
         if(this._lastIncorporealFade != this.entity.incorporealFade)
         {
            this.fadeEntity(300,this.entity.visible);
            this._lastIncorporealFade = this.entity.incorporealFade;
         }
         this._entityViewVfx.update(param1);
         if(this._propAnimClipSprite)
         {
            if(this._propAnimClipSprite.clip.playing)
            {
               this._propAnimClipSprite.clip.advance(param1);
            }
            this._propAnimClipSprite.update();
         }
         if(this.goAnimation && this.goAnimation.visible && Boolean(this.goAnimation.clip))
         {
            this.goAnimation.clip.advance(param1);
            this.goAnimation.update();
         }
         if(this.character)
         {
            this.character.update(param1);
         }
         if(this.animSprite)
         {
            this.animSprite.update();
         }
         if(Boolean(this.animController) && this.animController.consumeFlip())
         {
            this.entity.flipFacing(true);
         }
      }
      
      public function createFlyTextEntry(param1:String, param2:BitmapData) : EntityFlyTextEntry
      {
         return null;
      }
   }
}
