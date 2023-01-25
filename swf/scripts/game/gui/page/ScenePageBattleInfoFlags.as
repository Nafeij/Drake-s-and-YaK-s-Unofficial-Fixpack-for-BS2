package game.gui.page
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.entity.view.EntityView;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.IBattleFsm;
   import engine.core.render.Camera;
   import engine.gui.IGuiBattleInfoFlag;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   
   public class ScenePageBattleInfoFlags extends Sprite
   {
      
      public static var mcClazzMobile:Class;
      
      public static var mcClazzProp:Class;
      
      public static var mcClazzAbsorption:Class;
      
      private static const HOVER_SCALE:Number = 1.3;
       
      
      private var scenePage:ScenePage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var idToFlag:Dictionary;
      
      private var board:BattleBoard;
      
      private var fsm:IBattleFsm;
      
      private var boardView:BattleBoardView;
      
      public var flags:Array;
      
      private var ents:Vector.<IBattleEntity>;
      
      private var _lastInteract:BattleEntity;
      
      private var _sortDirty:Boolean;
      
      private var scratchPt:Point;
      
      private var lastScale:Number = 1;
      
      public function ScenePageBattleInfoFlags(param1:ScenePage)
      {
         this.idToFlag = new Dictionary();
         this.flags = [];
         this.ents = new Vector.<IBattleEntity>();
         this.scratchPt = new Point();
         super();
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         this.scenePage = param1;
         this.config = param1.config;
         this.mouseEnabled = this.mouseChildren = false;
         name = "battle_info_flags";
         this.battleGuiEnableHandler(null);
      }
      
      private function battleGuiEnableHandler(param1:Event) : void
      {
         this.visible = BattleFsmConfig.guiHudShouldRender;
      }
      
      private function createInfoFlag(param1:IBattleEntity, param2:Class) : IGuiBattleInfoFlag
      {
         var _loc3_:MovieClip = null;
         var _loc4_:IGuiBattleInfoFlag = null;
         param2 = !!param2 ? param2 : this.getFlagClass(param1);
         _loc3_ = new param2() as MovieClip;
         _loc3_.name = "guiInfoFlag";
         _loc4_ = _loc3_ as IGuiBattleInfoFlag;
         _loc3_.mouseEnabled = false;
         _loc3_.mouseChildren = false;
         _loc4_.ctorClazz = param2;
         return _loc4_;
      }
      
      private function getFlagClass(param1:IBattleEntity) : Class
      {
         if(!param1.mobile)
         {
            return mcClazzProp;
         }
         var _loc2_:Stat = param1.stats.getStat(StatType.DAMAGE_ABSORPTION_SHIELD,false);
         if(Boolean(_loc2_) && _loc2_.value > 0)
         {
            return mcClazzAbsorption;
         }
         return mcClazzMobile;
      }
      
      public function cleanup() : void
      {
         var _loc1_:Object = null;
         var _loc2_:BattleEntity = null;
         var _loc3_:String = null;
         var _loc4_:IGuiBattleInfoFlag = null;
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         if(this.board)
         {
            this.board.removeEventListener(BattleEntityEvent.BATTLE_INFO_FLAG_VISIBLE,this.battleInfoFlagVisibleHandler);
            this.board.removeEventListener(BattleEntityEvent.HOVERING,this.battleInfoFlagVisibleHandler);
            this.board = null;
         }
         if(this.fsm)
         {
            this.fsm.removeEventListener(BattleFsmEvent.INTERACT,this.battleInteractHandler);
            this.fsm = null;
         }
         this.boardView = null;
         if(this.saga)
         {
            this.saga = null;
         }
         for(_loc1_ in this.idToFlag)
         {
            _loc3_ = _loc1_ as String;
            _loc4_ = this.idToFlag[_loc3_];
            _loc4_.cleanup();
         }
         for each(_loc2_ in this.ents)
         {
            _loc2_.removeEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
         }
         this.ents = null;
         this.flags = null;
         this.idToFlag = null;
         this.scenePage = null;
         this.config = null;
      }
      
      public function doInitReady() : void
      {
         this.saga = this.config.saga;
         this.board = this.scenePage.scene.focusedBoard;
         this.fsm = !!this.board ? this.board.fsm : null;
         if(this.board)
         {
            this.board.addEventListener(BattleEntityEvent.BATTLE_INFO_FLAG_VISIBLE,this.battleInfoFlagVisibleHandler);
            if(this.fsm)
            {
               this.fsm.addEventListener(BattleFsmEvent.INTERACT,this.battleInteractHandler);
            }
            this.board.addEventListener(BattleEntityEvent.HOVERING,this.battleInfoFlagVisibleHandler);
            this.boardView = this.scenePage.view.boards.focusedBoardView;
         }
      }
      
      private function battleInteractHandler(param1:BattleFsmEvent) : void
      {
         var _loc2_:BattleEntity = !!this.fsm ? this.fsm.interact as BattleEntity : null;
         this._updateEntity(this._lastInteract);
         this._updateEntity(_loc2_);
         this._lastInteract = _loc2_;
      }
      
      private function battleInfoFlagVisibleHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         this._updateEntity(_loc2_);
      }
      
      private function _destroyFlag(param1:String, param2:IGuiBattleInfoFlag) : void
      {
         this.removeFlagFromDisplay(param2);
         param2.cleanup();
         param2 = null;
         this.idToFlag[param1] = null;
      }
      
      private function _getOrCreateEntityFlag(param1:IBattleEntity) : IGuiBattleInfoFlag
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:String = String(param1.id);
         var _loc3_:IGuiBattleInfoFlag = this.idToFlag[_loc2_];
         var _loc4_:Class = this.getFlagClass(param1);
         if(Boolean(_loc3_) && _loc3_.ctorClazz != _loc4_)
         {
            this._destroyFlag(_loc2_,_loc3_);
         }
         if(!_loc3_)
         {
            _loc3_ = this.createInfoFlag(param1,null);
            this.idToFlag[_loc2_] = _loc3_;
         }
         return _loc3_;
      }
      
      private function _updateEntity(param1:IBattleEntity) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         if(!param1)
         {
            return;
         }
         var _loc2_:IGuiBattleInfoFlag = this._getOrCreateEntityFlag(param1);
         _loc3_ = param1.battleInfoFlagVisible && Boolean(param1.enabled) && Boolean(param1.visibleToPlayer) && Boolean(param1.active) && Boolean(param1.stats);
         if(!_loc3_)
         {
            param1.removeEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
            this.removeFlagFromDisplay(_loc2_);
            _loc4_ = this.ents.indexOf(param1);
            if(_loc4_ >= 0)
            {
               this.ents.splice(_loc4_,1);
            }
            _loc2_.setEntityAndStats(null,null,true,param1.attackable);
         }
         else
         {
            _loc2_.setEntityAndStats(param1.id,param1.stats,param1.isPlayer,param1.attackable);
            param1.addEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
            if(!_loc2_.movieClip.parent)
            {
               addChild(_loc2_.movieClip);
               this.flags.push(_loc2_);
               this._sortDirty = true;
               _loc2_.dirty = true;
            }
            this.ents.push(param1);
            this.updateFlag(_loc2_);
         }
         _loc2_.visible = _loc3_;
      }
      
      private function removeFlagFromDisplay(param1:IGuiBattleInfoFlag) : void
      {
         var _loc2_:int = 0;
         if(param1.movieClip.parent)
         {
            param1.movieClip.parent.removeChild(param1.movieClip);
            _loc2_ = this.flags.indexOf(param1);
            this.flags.splice(_loc2_,1);
         }
      }
      
      private function entityMovedHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         var _loc3_:IGuiBattleInfoFlag = this.idToFlag[_loc2_.id];
         _loc3_.dirty = true;
         this._sortDirty = true;
      }
      
      private function updateFlag(param1:IGuiBattleInfoFlag) : void
      {
         var _loc2_:BattleEntity = this.board.getEntity(param1.entityId) as BattleEntity;
         var _loc3_:EntityView = this.boardView.getEntityView(_loc2_);
         if(_loc3_)
         {
            _loc3_.getBattleInfoFlagPosition(this.scratchPt);
         }
         param1.x = this.scratchPt.x;
         param1.y = this.scratchPt.y;
         var _loc4_:Boolean = _loc2_.hovering;
         if(!_loc4_ && Boolean(this.fsm))
         {
         }
         var _loc5_:Number = _loc4_ ? HOVER_SCALE : 1;
         param1.scale_zoom = this.lastScale;
         param1.scale_emphasis = _loc5_;
         param1.dirty = false;
      }
      
      public function resetAllFlags() : void
      {
         var _loc2_:IGuiBattleInfoFlag = null;
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this.flags.length)
         {
            _loc2_ = this.flags[_loc1_] as IGuiBattleInfoFlag;
            this.updateFlag(_loc2_);
            _loc1_++;
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc5_:IGuiBattleInfoFlag = null;
         if(!this.board || !this.boardView || !BattleFsmConfig.guiHudShouldRender || !this.boardView.layerSprite)
         {
            return;
         }
         var _loc2_:Camera = this.board.scene.camera;
         var _loc3_:Number = !!_loc2_ ? _loc2_.scale : 1;
         this.x = this.scenePage.width / 2 + (this.boardView.layerSprite.x + this.board.def.pos.x) * _loc3_;
         this.y = this.scenePage.height / 2 + (this.boardView.layerSprite.y + this.board.def.pos.y) * _loc3_;
         var _loc4_:int = 0;
         var _loc6_:Number = Math.max(1,_loc3_);
         if(this.lastScale != _loc6_)
         {
            _loc4_ = 0;
            while(_loc4_ < this.flags.length)
            {
               _loc5_ = this.flags[_loc4_] as IGuiBattleInfoFlag;
               _loc5_.movieClip.scaleX = _loc5_.movieClip.scaleY = _loc6_;
               _loc4_++;
            }
            this.lastScale = _loc6_;
         }
         if(this._sortDirty)
         {
            this._sortDirty = false;
            _loc4_ = 0;
            while(_loc4_ < this.flags.length)
            {
               _loc5_ = this.flags[_loc4_] as IGuiBattleInfoFlag;
               if(_loc5_.dirty)
               {
                  this.updateFlag(_loc5_);
               }
               _loc4_++;
            }
            this.flags.sortOn("y",Array.NUMERIC);
            _loc4_ = 0;
            while(_loc4_ < this.flags.length)
            {
               _loc5_ = this.flags[_loc4_] as IGuiBattleInfoFlag;
               setChildIndex(_loc5_.movieClip,_loc4_);
               _loc4_++;
            }
         }
         _loc4_ = 0;
         while(_loc4_ < this.flags.length)
         {
            _loc5_ = this.flags[_loc4_] as IGuiBattleInfoFlag;
            _loc5_.update(param1);
            _loc4_++;
         }
      }
   }
}
