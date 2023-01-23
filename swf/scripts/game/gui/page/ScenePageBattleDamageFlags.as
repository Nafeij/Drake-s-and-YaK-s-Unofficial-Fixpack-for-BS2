package game.gui.page
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.entity.view.EntityView;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleTurn;
   import engine.core.render.Camera;
   import engine.saga.Saga;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   
   public class ScenePageBattleDamageFlags extends Sprite
   {
      
      public static var mcClazz:Class;
       
      
      private var scenePage:ScenePage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var idToFlag:Dictionary;
      
      private var flagToEnt:Dictionary;
      
      private var board:BattleBoard;
      
      private var boardView:BattleBoardView;
      
      public var flags:Array;
      
      private var _sortDirty:Boolean;
      
      private var scratchPt:Point;
      
      private var lastScale:Number = 1;
      
      public function ScenePageBattleDamageFlags(param1:ScenePage)
      {
         this.idToFlag = new Dictionary();
         this.flagToEnt = new Dictionary();
         this.flags = [];
         this.scratchPt = new Point();
         super();
         this.name = "ScenePageBattleDamageFlags";
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         this.scenePage = param1;
         this.config = param1.config;
         this.mouseEnabled = this.mouseChildren = false;
         this.battleGuiEnableHandler(null);
      }
      
      private function battleGuiEnableHandler(param1:Event) : void
      {
         this.visible = BattleFsmConfig.guiHudShouldRender;
      }
      
      private function createDamageFlag() : MovieClip
      {
         var _loc1_:MovieClip = new mcClazz();
         _loc1_.mouseChildren = _loc1_.mouseEnabled = false;
         return _loc1_;
      }
      
      private function updateDamageFlagValue(param1:MovieClip, param2:IBattleEntity) : void
      {
         var _loc3_:TextField = param1.getChildByName("damage_text") as TextField;
         _loc3_.text = param2.battleDamageFlagValue.toString();
      }
      
      public function cleanup() : void
      {
         var _loc1_:BattleEntity = null;
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         if(this.board)
         {
            this.board.removeEventListener(BattleEntityEvent.BATTLE_DAMAGE_FLAG_VISIBLE,this.battleDamageFlagVisibleHandler);
            this.board = null;
         }
         this.boardView = null;
         if(this.saga)
         {
            this.saga = null;
         }
         for each(_loc1_ in this.flagToEnt)
         {
            _loc1_.removeEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
            _loc1_.removeEventListener(BattleEntityEvent.BATTLE_DAMAGE_FLAG_VALUE,this.battleDamageFlagValueHandler);
         }
         this.flagToEnt = null;
         this.flags = null;
         this.idToFlag = null;
      }
      
      public function doInitReady() : void
      {
         this.saga = this.config.saga;
         this.board = this.scenePage.scene.focusedBoard;
         if(this.board)
         {
            this.board.addEventListener(BattleEntityEvent.BATTLE_DAMAGE_FLAG_VISIBLE,this.battleDamageFlagVisibleHandler);
            this.boardView = this.scenePage.view.boards.focusedBoardView;
         }
      }
      
      private function battleDamageFlagVisibleHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         var _loc3_:MovieClip = this.idToFlag[_loc2_.id];
         if(!_loc3_)
         {
            _loc3_ = this.createDamageFlag();
            this.idToFlag[_loc2_.id] = _loc3_;
            this.flagToEnt[_loc3_] = _loc2_;
         }
         var _loc4_:int = 0;
         if(!_loc2_.battleDamageFlagVisible || !_loc2_.enabled || !_loc2_.visibleToPlayer || !_loc2_.active)
         {
            _loc2_.removeEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
            _loc2_.removeEventListener(BattleEntityEvent.BATTLE_DAMAGE_FLAG_VALUE,this.battleDamageFlagValueHandler);
            if(_loc3_.parent)
            {
               _loc3_.parent.removeChild(_loc3_);
               _loc4_ = this.flags.indexOf(_loc3_);
               this.flags.splice(_loc4_,1);
            }
         }
         else
         {
            _loc2_.addEventListener(BattleEntityEvent.MOVED,this.entityMovedHandler);
            _loc2_.addEventListener(BattleEntityEvent.BATTLE_DAMAGE_FLAG_VALUE,this.battleDamageFlagValueHandler);
            if(!_loc3_.parent)
            {
               addChild(_loc3_);
               this.flags.push(_loc3_);
               this._sortDirty = true;
            }
            this.updateDamageFlagValue(_loc3_,_loc2_);
            this.updateFlag(_loc3_);
         }
         _loc3_.visible = _loc2_.battleDamageFlagVisible;
      }
      
      private function battleDamageFlagValueHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         var _loc3_:MovieClip = this.idToFlag[_loc2_.id];
         this.updateDamageFlagValue(_loc3_,_loc2_);
      }
      
      private function entityMovedHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         var _loc3_:MovieClip = this.idToFlag[_loc2_.id];
         this._sortDirty = true;
      }
      
      private function updateFlag(param1:MovieClip) : void
      {
         var _loc2_:IBattleEntity = this.flagToEnt[param1];
         var _loc3_:EntityView = this.boardView.getEntityView(_loc2_);
         _loc3_.getBattleDamageFlagPosition(this.scratchPt);
         param1.x = this.scratchPt.x;
         param1.y = this.scratchPt.y;
         param1.scaleX = param1.scaleY = this.lastScale;
      }
      
      public function resetAllFlags() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this.flags.length)
         {
            _loc2_ = this.flags[_loc1_] as MovieClip;
            this.updateFlag(_loc2_);
            _loc1_++;
         }
      }
      
      public function update() : void
      {
         var _loc3_:Number = NaN;
         var _loc5_:MovieClip = null;
         if(!this.board || !this.boardView || !BattleFsmConfig.guiHudShouldRender || !this.boardView.layerSprite)
         {
            return;
         }
         if(!this.board.fsm || Boolean(this.board.fsm.finishedData))
         {
            this.visible = false;
            return;
         }
         var _loc1_:BattleTurn = this.board.fsm.turn as BattleTurn;
         if(!_loc1_ || _loc1_._numAbilities > 0)
         {
            this.visible = false;
            return;
         }
         var _loc2_:Camera = this.board.scene.camera;
         _loc3_ = !!_loc2_ ? _loc2_.scale : 1;
         this.x = this.scenePage.width / 2 + (this.boardView.layerSprite.x + this.board.def.pos.x) * _loc3_;
         this.y = this.scenePage.height / 2 + (this.boardView.layerSprite.y + this.board.def.pos.y) * _loc3_;
         var _loc4_:int = 0;
         var _loc6_:Number = Math.max(1,_loc3_);
         if(this.lastScale != _loc6_)
         {
            _loc4_ = 0;
            while(_loc4_ < this.flags.length)
            {
               _loc5_ = this.flags[_loc4_] as MovieClip;
               _loc5_.scaleX = _loc5_.scaleY = _loc6_;
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
               _loc5_ = this.flags[_loc4_] as MovieClip;
               this.updateFlag(_loc5_);
               _loc4_++;
            }
            this.flags.sortOn("y",Array.NUMERIC);
            _loc4_ = 0;
            while(_loc4_ < this.flags.length)
            {
               _loc5_ = this.flags[_loc4_] as MovieClip;
               setChildIndex(_loc5_,_loc4_);
               _loc4_++;
            }
         }
         this.visible = this.flags.length > 0;
      }
   }
}
