package engine.battle.entity.view
{
   import as3isolib.display.IsoSprite;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import engine.anim.view.AnimClip;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.phantasm.def.VfxSequenceDef;
   import engine.battle.ability.phantasm.model.VfxSequence;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.phantasm.VfxSequenceView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.resource.AnimClipResource;
   import engine.resource.IResourceManager;
   import engine.saga.Saga;
   import engine.vfx.AttachedVfx;
   import engine.vfx.VfxDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class EntityViewVfx
   {
       
      
      private var _vfxList:Vector.<VfxSequenceView>;
      
      private var _battleBoardView:BattleBoardView;
      
      private var _parentEntity:EntityView;
      
      private var _logger:ILogger;
      
      private var _attachedVfxList:Vector.<AttachedVfx>;
      
      private const ENOUGH_KILLS_FOR_PROMOTION_VFX_NAME:String = "earn_promote";
      
      private const ENOUGH_KILLS_FOR_PROMOTION_ISO_NAME:String = "iso_enough_kills_for_promotion";
      
      public function EntityViewVfx(param1:BattleBoardView, param2:EntityView, param3:ILogger)
      {
         this._vfxList = new Vector.<VfxSequenceView>();
         this._attachedVfxList = new Vector.<AttachedVfx>();
         super();
         if(!param1 || !param2 || !param3)
         {
            param3.error("EntityViewVfx.EntityViewVfx: Null parameter passed into EntityViewVfx constructor");
            return;
         }
         this._battleBoardView = param1;
         this._parentEntity = param2;
         this._logger = param3;
         this._parentEntity.entity.addEventListener(BattleEntityEvent.ENOUGH_KILLS_TO_PROMOTE_VFX,this.playEnoughKillsToPromoteVfx);
      }
      
      public function playChildVfxDef(param1:VfxSequenceDef, param2:Number) : void
      {
         var _loc3_:IResourceManager = this._battleBoardView.board.resman;
         var _loc4_:VfxSequence = new VfxSequence(param1,_loc3_,this._parentEntity.theVfxLibrary,this._logger,0,this._parentEntity.entity.facing);
         _loc4_.transient = true;
         this.playVfxSequence(_loc4_,0,0,true,null,param2,false,"");
      }
      
      public function playChildVfx(param1:VfxSequence, param2:Number) : void
      {
         this.playVfxSequence(param1,0,0,true,null,param2,false,"");
      }
      
      private function playVfxSequence(param1:VfxSequence, param2:Number, param3:Number, param4:Boolean, param5:BattleEntity, param6:Number, param7:Boolean, param8:String) : void
      {
         var _loc11_:IsoScene = null;
         var _loc9_:Number = this._battleBoardView.units;
         var _loc10_:VfxSequenceView = new VfxSequenceView(param1,this._logger,true);
         if(param4)
         {
            switch(param1.def.depth)
            {
               case "back":
               case "bg2":
               case "bg1":
                  _loc10_.x = param2 - 0.001;
                  _loc10_.y = param3 - 0.001;
                  this._parentEntity.addChildAt(_loc10_,0);
                  break;
               case "front":
               default:
                  _loc10_.x = param2 + 0.001;
                  _loc10_.y = param3 + 0.001;
                  this._parentEntity.addChild(_loc10_);
            }
            _loc10_.x = _loc10_.y = this._parentEntity.entity.diameter * _loc9_ / 2;
            this.updateVfxSequenceViewOffset(_loc10_,this._parentEntity.entity.facing);
            _loc10_.updatePosition();
         }
         else
         {
            _loc11_ = this._battleBoardView.isoScenes.getIsoScene(param8);
            _loc11_.addChild(_loc10_);
            _loc10_.x = (this._parentEntity.x + this._parentEntity.entity.diameter) * _loc9_;
            _loc10_.y = (this._parentEntity.y + this._parentEntity.entity.diameter) * _loc9_;
         }
         _loc10_.container.alpha = param1.def.alpha;
         _loc10_.container.color = param1.def.color;
         _loc10_.spriteOffsetY = -param6 * _loc9_;
         if(param7)
         {
            _loc10_.container.scaleX *= -1;
         }
         _loc10_.dispatcher.addEventListener(VfxSequenceView.EVENT_SEQUENCE_COMPLETE,this.onPlayVfxCompleteHandler);
         this._vfxList.push(_loc10_);
      }
      
      public function updateEntityOrientation() : void
      {
         var _loc1_:VfxSequenceView = null;
         for each(_loc1_ in this._vfxList)
         {
            if(_loc1_.vfx.def.orientedOffset)
            {
               this.updateVfxSequenceViewOffset(_loc1_,this._parentEntity.entity.facing);
               _loc1_.updatePosition();
            }
         }
      }
      
      private function updateVfxSequenceViewOffset(param1:VfxSequenceView, param2:BattleFacing) : void
      {
         if(param1.vfx.def.orientedOffset)
         {
            switch(param2)
            {
               case BattleFacing.NE:
                  param1.orientationOffset = new Point(param1.vfx.def.orientedOffset.ne.x,param1.vfx.def.orientedOffset.ne.y);
                  break;
               case BattleFacing.SE:
                  param1.orientationOffset = new Point(param1.vfx.def.orientedOffset.se.x,param1.vfx.def.orientedOffset.se.y);
                  break;
               case BattleFacing.NW:
                  param1.orientationOffset = new Point(param1.vfx.def.orientedOffset.nw.x,param1.vfx.def.orientedOffset.nw.y);
                  break;
               case BattleFacing.SW:
                  param1.orientationOffset = new Point(param1.vfx.def.orientedOffset.sw.x,param1.vfx.def.orientedOffset.sw.y);
            }
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc4_:AttachedVfx = null;
         var _loc5_:VfxSequenceView = null;
         var _loc2_:int = int(this._attachedVfxList.length - 1);
         while(_loc2_ >= 0)
         {
            _loc4_ = this._attachedVfxList[_loc2_];
            if(Boolean(_loc4_) && Boolean(_loc4_.spriteBase))
            {
               _loc4_.spriteBase.clip.advance(param1);
               if(_loc4_)
               {
                  _loc4_.spriteBase.update();
               }
               else
               {
                  ArrayUtil.removeAt(this._attachedVfxList,_loc2_);
               }
            }
            else
            {
               ArrayUtil.removeAt(this._attachedVfxList,_loc2_);
            }
            _loc2_--;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this._vfxList.length)
         {
            _loc5_ = this._vfxList[_loc3_];
            _loc5_.vfx.update(param1);
            _loc5_.update(param1);
            _loc3_++;
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:AttachedVfx = null;
         var _loc2_:VfxSequenceView = null;
         for each(_loc1_ in this._attachedVfxList)
         {
            if(_loc1_)
            {
               _loc1_.spriteBase.cleanup();
            }
         }
         this._attachedVfxList = null;
         for each(_loc2_ in this._vfxList)
         {
            if(_loc2_)
            {
               _loc2_.dispatcher.removeEventListener(VfxSequenceView.EVENT_SEQUENCE_COMPLETE,this.onPlayVfxCompleteHandler);
               if(_loc2_.parent)
               {
                  _loc2_.parent.removeChild(_loc2_);
               }
            }
         }
         this._vfxList = null;
         this._parentEntity.entity.removeEventListener(BattleEntityEvent.ENOUGH_KILLS_TO_PROMOTE_VFX,this.playEnoughKillsToPromoteVfx);
      }
      
      private function onPlayVfxCompleteHandler(param1:Event) : void
      {
         var _loc3_:VfxSequenceView = null;
         var _loc5_:VfxSequenceView = null;
         var _loc2_:EventDispatcher = param1.target as EventDispatcher;
         _loc2_.removeEventListener(VfxSequenceView.EVENT_SEQUENCE_COMPLETE,this.onPlayVfxCompleteHandler);
         var _loc4_:int = 0;
         while(_loc4_ < this._vfxList.length)
         {
            _loc5_ = this._vfxList[_loc4_];
            if(_loc5_.dispatcher == _loc2_)
            {
               _loc3_ = _loc5_;
               break;
            }
            _loc4_++;
         }
         if(_loc3_)
         {
            if(_loc3_.parent)
            {
               _loc3_.parent.removeChild(_loc3_);
            }
            else
            {
               this._logger.error("EntityViewVfx.onPlayVfxCompleteHandler: Received onCompleteHandler for [" + _loc3_.name + "] but its parent was null");
            }
            _loc3_.cleanup();
            ArrayUtil.removeAt(this._vfxList,this._vfxList.indexOf(_loc3_));
         }
         else
         {
            this._logger.error("EntityViewVfx.onPlayVfxCompleteHandler: Received onCompleteHandler call but was unable to find the vfxSequence that fired it. event [" + param1.toString() + "]");
         }
      }
      
      protected function playSlidingVfx(param1:String, param2:Number, param3:String, param4:String, param5:Pt, param6:Number) : void
      {
         var _loc8_:AnimClipResource = null;
         var _loc9_:IsoSprite = null;
         var _loc10_:XAnimClipSpriteBase = null;
         if(!this._parentEntity.entity.playerControlled || !this._parentEntity.entity.isPlayer || Saga.instance && Saga.instance.def.survival || !this._parentEntity.theVfxLibrary)
         {
            return;
         }
         var _loc7_:VfxDef = this._parentEntity.theVfxLibrary.getVfxDef(param1);
         if(_loc7_)
         {
            _loc8_ = this._parentEntity.theVfxLibrary.getAnimClipResource(_loc7_.getClipUrl(param2));
            _loc9_ = new IsoSprite(param3);
            this._battleBoardView.isoScenes.getIsoScene(param4).addChild(_loc9_);
            _loc10_ = this._parentEntity.playSpriteTowards(this._parentEntity,param5,param6,_loc9_,_loc8_,this.onPlaySlidingVfxCompleteHandler);
            this._attachedVfxList.push(new AttachedVfx(_loc9_.id,param4,_loc10_));
         }
      }
      
      private function onPlaySlidingVfxCompleteHandler(param1:AnimClip) : void
      {
         var _loc3_:AttachedVfx = null;
         var _loc4_:IsoSprite = null;
         var _loc2_:int = int(this._attachedVfxList.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._attachedVfxList[_loc2_];
            if(Boolean(_loc3_) && _loc3_.spriteBase.clip.def.id == param1.def.id)
            {
               _loc3_.spriteBase.clip.cleanup();
               _loc3_.spriteBase.cleanup();
               _loc4_ = this._battleBoardView.isoScenes.getIsoScene(_loc3_.isoLayerName).removeChildByID(_loc3_.isoSpriteId) as IsoSprite;
               if(!_loc4_)
               {
                  this._logger.error("EntityViewVfx.onPlaySlidingVfxCompleteHandler: Received onCompleteHandler but was unable to find the attachedVfx that associated with it. animClip [" + param1.def.id + "]");
               }
               ArrayUtil.removeAt(this._attachedVfxList,_loc2_);
               break;
            }
            _loc2_--;
         }
      }
      
      protected function playEnoughKillsToPromoteVfx(param1:BattleEntityEvent) : void
      {
         this.playSlidingVfx("earn_promote",0,this.ENOUGH_KILLS_FOR_PROMOTION_ISO_NAME,"main0",new Pt(this._parentEntity.x + this._parentEntity.width / 2,this._parentEntity.y + this._parentEntity.length / 2,this._parentEntity.z),this._parentEntity.z + this._parentEntity.height / 2);
      }
   }
}
