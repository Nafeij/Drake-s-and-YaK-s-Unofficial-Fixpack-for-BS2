package game.gui.page
{
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.view.EntityView;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.render.Camera;
   import engine.core.util.MovieClipAdapter;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.entity.model.IEntity;
   import engine.gui.GuiUtil;
   import engine.saga.Saga;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.gui.GuiIcon;
   
   public class ScenePageBattleVfx extends Sprite
   {
      
      public static var mcClazz_renown:Class;
      
      public static var mcClazz_survivalDied:Class;
      
      public static var mcClazz_survivalItem:Class;
       
      
      private var scenePage:ScenePage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var board:BattleBoard;
      
      private var boardView:BattleBoardView;
      
      public var mcas:Array;
      
      public var icons:Dictionary;
      
      private var ents:Vector.<BattleEntity>;
      
      private var _logger:ILogger;
      
      private var _bonusEntities:Vector.<IBattleEntity>;
      
      private var _sortDirty:Boolean;
      
      private var scratchPt:Point;
      
      private var lastScale:Number = 1;
      
      public function ScenePageBattleVfx(param1:ScenePage)
      {
         this.mcas = [];
         this.icons = new Dictionary();
         this.ents = new Vector.<BattleEntity>();
         this._bonusEntities = new Vector.<IBattleEntity>();
         this.scratchPt = new Point();
         super();
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.addEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         this.scenePage = param1;
         this.config = param1.config;
         this._logger = param1.logger;
         this.mouseEnabled = this.mouseChildren = false;
         name = "battle_vfx";
         this.battleGuiEnableHandler(null);
      }
      
      private function battleGuiEnableHandler(param1:Event) : void
      {
         this.visible = BattleFsmConfig.guiHudShouldRender;
      }
      
      private function createRenownVfx() : MovieClipAdapter
      {
         var _loc1_:MovieClip = new mcClazz_renown() as MovieClip;
         _loc1_.name = "renown";
         _loc1_.mouseEnabled = false;
         _loc1_.mouseChildren = false;
         return new MovieClipAdapter(_loc1_,30,null,false,this._logger,null,this.mcaCompleteHandler,false,this.config.context.locale);
      }
      
      private function createSurvivalDiedVfx() : MovieClipAdapter
      {
         var _loc1_:MovieClip = null;
         _loc1_ = new mcClazz_survivalDied() as MovieClip;
         _loc1_.name = "survival_died";
         _loc1_.mouseEnabled = false;
         _loc1_.mouseChildren = false;
         return new MovieClipAdapter(_loc1_,30,null,false,this._logger,null,this.mcaCompleteHandler,false,this.config.context.locale);
      }
      
      private function createSurvivalItemVfx() : MovieClipAdapter
      {
         var _loc1_:MovieClip = new mcClazz_survivalItem() as MovieClip;
         _loc1_.name = "survival_item";
         _loc1_.mouseEnabled = false;
         _loc1_.mouseChildren = false;
         return new MovieClipAdapter(_loc1_,30,null,false,this._logger,null,this.mcaCompleteHandler,false,this.config.context.locale);
      }
      
      private function mcaCompleteHandler(param1:MovieClipAdapter) : void
      {
         var _loc2_:int = this.mcas.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.mcas.splice(_loc2_,1);
         }
         var _loc3_:GuiIcon = this.icons[param1];
         if(_loc3_)
         {
            _loc3_.release();
            delete this.icons[param1];
         }
         param1.cleanup();
      }
      
      public function cleanup() : void
      {
         var _loc1_:MovieClipAdapter = null;
         var _loc2_:GuiIcon = null;
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_HUD_ENABLE,this.battleGuiEnableHandler);
         BattleFsmConfig.dispatcher.removeEventListener(BattleFsmConfig.EVENT_GUI_VISIBLE,this.battleGuiEnableHandler);
         if(this.board)
         {
            this.board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.battleBoardEntityAliveHandler);
            this.board.removeEventListener(BattleBoardEvent.BOARD_SURVIVAL_DIED,this.battleBoardEntitySurvivalDiedHandler);
            this.board.removeEventListener(BattleBoardEvent.BOARD_SURVIVAL_ITEM,this.battleBoardEntitySurvivalItemHandler);
            this.board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_BONUS_RENOWN,this.battleBoardEntityBonusRenownHandler);
            this.board = null;
         }
         this.boardView = null;
         if(this.saga)
         {
            this.saga = null;
         }
         for each(_loc1_ in this.mcas)
         {
            _loc1_.cleanup();
         }
         for each(_loc2_ in this.icons)
         {
            if(_loc2_)
            {
               _loc2_.release();
            }
         }
         this.icons = null;
         this.ents = null;
         this.mcas = null;
         this.scenePage = null;
         this.config = null;
      }
      
      public function doInitReady() : void
      {
         this.saga = this.config.saga;
         this.board = this.scenePage.scene.focusedBoard;
         if(this.board)
         {
            this.board.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.battleBoardEntityAliveHandler);
            this.board.addEventListener(BattleBoardEvent.BOARD_SURVIVAL_DIED,this.battleBoardEntitySurvivalDiedHandler);
            this.board.addEventListener(BattleBoardEvent.BOARD_SURVIVAL_ITEM,this.battleBoardEntitySurvivalItemHandler);
            this.board.addEventListener(BattleBoardEvent.BOARD_ENTITY_BONUS_RENOWN,this.battleBoardEntityBonusRenownHandler);
            this.boardView = this.scenePage.view.boards.focusedBoardView;
         }
      }
      
      private function battleBoardEntityBonusRenownHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         if(!BattleFsmConfig.guiFlytextShouldRender)
         {
            return;
         }
         this._bonusEntities.push(_loc2_);
      }
      
      private function battleBoardEntitySurvivalItemHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         this.addSurvivalItem(_loc2_);
      }
      
      private function battleBoardEntitySurvivalDiedHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         this.addSurvivalDied(_loc2_);
      }
      
      private function battleBoardEntityAliveHandler(param1:BattleBoardEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:IBattleEntity = param1.entity;
         if(_loc2_.alive)
         {
            return;
         }
         if(_loc2_.deathCount > 1)
         {
            return;
         }
         if(_loc2_.party && !_loc2_.party.isPlayer && Boolean(_loc2_.enabled))
         {
            if(_loc2_.mobile)
            {
               _loc3_ = _loc2_.killRenown;
               if(_loc3_)
               {
                  this.addRenown(_loc2_,_loc3_);
               }
            }
         }
      }
      
      private function translateRenown(param1:MovieClip, param2:int) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:TextField = null;
         var _loc5_:Number = NaN;
         var _loc6_:Locale = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         if(param1.numChildren == 3)
         {
            _loc3_ = param1.getChildAt(2) as MovieClip;
            if(Boolean(_loc3_) && _loc3_.numChildren == 1)
            {
               _loc4_ = _loc3_.getChildAt(0) as TextField;
               if(_loc4_)
               {
                  _loc5_ = _loc4_.width;
                  _loc6_ = this.config.context.locale;
                  _loc7_ = "+" + param2 + " " + _loc6_.translateGui("renown");
                  _loc4_.htmlText = _loc7_;
                  _loc6_.fixTextFieldFormat(_loc4_);
                  _loc8_ = 4;
                  if(_loc4_.textWidth + _loc8_ > _loc5_)
                  {
                     _loc9_ = _loc5_ / (_loc4_.textWidth + _loc8_);
                     _loc4_.width = _loc4_.textWidth + _loc8_;
                     _loc4_.height = _loc4_.textHeight + 2;
                     _loc4_.scaleX = _loc4_.scaleY = _loc9_;
                     _loc4_.y = -_loc4_.height / 2;
                     _loc4_.x = -_loc4_.width / 2;
                  }
                  _loc4_.cacheAsBitmap = true;
               }
            }
         }
      }
      
      private function translateSurvivalDied(param1:MovieClip, param2:IEntityDef) : void
      {
         var _loc4_:TextField = null;
         var _loc5_:Number = NaN;
         var _loc6_:Locale = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc3_:MovieClip = param1.getChildByName("text_holder") as MovieClip;
         if(Boolean(_loc3_) && _loc3_.numChildren == 1)
         {
            _loc4_ = _loc3_.getChildAt(0) as TextField;
            if(_loc4_)
            {
               _loc5_ = _loc4_.width;
               _loc6_ = this.config.context.locale;
               _loc7_ = _loc6_.translateGui("survival_died");
               _loc7_ = _loc7_.replace("{NAME}",param2.name);
               _loc4_.htmlText = _loc7_;
               _loc6_.fixTextFieldFormat(_loc4_);
               _loc8_ = 4;
               if(_loc4_.textWidth + _loc8_ > _loc5_)
               {
                  _loc9_ = _loc5_ / (_loc4_.textWidth + _loc8_);
                  _loc4_.width = _loc4_.textWidth + _loc8_;
                  _loc4_.height = _loc4_.textHeight + 2;
                  _loc4_.scaleX = _loc4_.scaleY = _loc9_;
                  _loc4_.y = -_loc4_.height / 2;
                  _loc4_.x = -_loc4_.width / 2;
               }
               _loc4_.cacheAsBitmap = true;
            }
         }
      }
      
      private function translateSurvivalItem(param1:MovieClip, param2:IEntity) : void
      {
         var _loc5_:TextField = null;
         var _loc6_:Number = NaN;
         var _loc7_:Locale = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc3_:Item = param2.item;
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:MovieClip = param1.getChildByName("text_holder") as MovieClip;
         if(Boolean(_loc4_) && _loc4_.numChildren == 1)
         {
            _loc5_ = _loc4_.getChildAt(0) as TextField;
            if(_loc5_)
            {
               _loc6_ = _loc5_.width;
               _loc7_ = this.config.context.locale;
               _loc8_ = _loc3_.def.name;
               _loc8_ = _loc8_;
               _loc5_.htmlText = _loc8_;
               _loc7_.fixTextFieldFormat(_loc5_);
               _loc9_ = 4;
               if(_loc5_.textWidth + _loc9_ > _loc6_)
               {
                  _loc10_ = _loc6_ / (_loc5_.textWidth + _loc9_);
                  _loc5_.width = _loc5_.textWidth + _loc9_;
                  _loc5_.height = _loc5_.textHeight + 2;
                  _loc5_.scaleX = _loc5_.scaleY = _loc10_;
                  _loc5_.y = -_loc5_.height / 2;
                  _loc5_.x = -_loc5_.width / 2;
               }
               _loc5_.cacheAsBitmap = true;
            }
         }
      }
      
      private function addSurvivalDied(param1:IBattleEntity) : void
      {
         if(!this.saga || !this.saga.def.survival)
         {
            return;
         }
         this._sortDirty = true;
         var _loc2_:MovieClipAdapter = this.createSurvivalDiedVfx();
         this.mcas.push(_loc2_);
         _loc2_.playOnce();
         var _loc3_:MovieClip = _loc2_.mc;
         addChild(_loc3_);
         this.translateSurvivalDied(_loc3_,param1.def);
         var _loc4_:MovieClip = _loc3_.getChildByName("censor") as MovieClip;
         var _loc5_:String = this.config.gameGuiContext.censorId;
         GuiUtil.performCensor(_loc4_,_loc5_,this._logger);
         var _loc6_:EntityView = this.boardView.getEntityView(param1);
         _loc6_.getBattleInfoFlagPosition(this.scratchPt);
         _loc3_.x = int(this.scratchPt.x);
         _loc3_.y = int(this.scratchPt.y);
         _loc3_.scaleX = _loc3_.scaleY = this.lastScale;
         var _loc7_:GuiIcon = this.config.gameGuiContext.getEntityIcon(param1.def,EntityIconType.INIT_ORDER);
         _loc7_.x = -38;
         _loc7_.y = -38;
         this.icons[_loc2_] = _loc7_;
         var _loc8_:MovieClip = _loc3_.getChildByName("holder") as MovieClip;
         _loc8_.addChild(_loc7_);
      }
      
      private function addSurvivalItem(param1:IBattleEntity) : void
      {
         if(!this.saga)
         {
            return;
         }
         var _loc2_:Item = param1.item;
         if(!_loc2_)
         {
            return;
         }
         this._sortDirty = true;
         var _loc3_:MovieClipAdapter = this.createSurvivalItemVfx();
         this.mcas.push(_loc3_);
         _loc3_.playOnce();
         var _loc4_:MovieClip = _loc3_.mc;
         addChild(_loc4_);
         this.translateSurvivalItem(_loc4_,param1);
         var _loc5_:EntityView = this.boardView.getEntityView(param1);
         _loc5_.getBattleInfoFlagPosition(this.scratchPt);
         _loc4_.x = int(this.scratchPt.x);
         _loc4_.y = int(this.scratchPt.y);
         _loc4_.scaleX = _loc4_.scaleY = this.lastScale;
         var _loc6_:GuiIcon = this.config.gameGuiContext.getIcon(_loc2_.def.icon);
         _loc6_.x = -128 / 2;
         _loc6_.y = -128 / 2;
         _loc6_.scaleX = _loc6_.scaleY = 0.5;
         this.icons[_loc3_] = _loc6_;
         var _loc7_:MovieClip = _loc4_.getChildByName("holder") as MovieClip;
         _loc7_.addChild(_loc6_);
      }
      
      private function addRenown(param1:IBattleEntity, param2:int) : void
      {
         if(!BattleFsmConfig.guiFlytextShouldRender)
         {
            return;
         }
         if(Boolean(this.saga) && this.saga.inTrainingBattle)
         {
            return;
         }
         this._sortDirty = true;
         var _loc3_:MovieClipAdapter = this.createRenownVfx();
         this.mcas.push(_loc3_);
         _loc3_.playOnce();
         var _loc4_:MovieClip = _loc3_.mc;
         addChild(_loc4_);
         this.translateRenown(_loc4_,param2);
         var _loc5_:EntityView = this.boardView.getEntityView(param1);
         _loc5_.getBattleInfoFlagPosition(this.scratchPt);
         _loc4_.x = int(this.scratchPt.x);
         _loc4_.y = int(this.scratchPt.y);
         _loc4_.scaleX = _loc4_.scaleY = this.lastScale;
      }
      
      public function resetAllFlags() : void
      {
      }
      
      public function update(param1:int) : void
      {
         var _loc5_:MovieClipAdapter = null;
         var _loc7_:IBattleEntity = null;
         var _loc8_:int = 0;
         if(!this.board || !this.boardView || !BattleFsmConfig.guiHudShouldRender || !this.boardView.layerSprite)
         {
            return;
         }
         if(Boolean(this._bonusEntities) && Boolean(this._bonusEntities.length))
         {
            for each(_loc7_ in this._bonusEntities)
            {
               _loc8_ = _loc7_.consumeBonusRenown();
               if(_loc8_)
               {
                  this.addRenown(_loc7_,_loc8_);
               }
            }
            this._bonusEntities.splice(0,this._bonusEntities.length);
         }
         var _loc2_:Camera = this.board.scene.camera;
         var _loc3_:Number = !!_loc2_ ? _loc2_.scale : 1;
         this.x = int(this.scenePage.width / 2 + (this.boardView.layerSprite.x + this.board.def.pos.x) * _loc3_);
         this.y = int(this.scenePage.height / 2 + (this.boardView.layerSprite.y + this.board.def.pos.y) * _loc3_);
         var _loc4_:int = 0;
         var _loc6_:Number = Math.max(1,_loc3_);
         if(this.lastScale != _loc6_)
         {
            _loc4_ = 0;
            while(_loc4_ < this.mcas.length)
            {
               _loc5_ = this.mcas[_loc4_] as MovieClipAdapter;
               _loc5_.mc.scaleX = _loc5_.mc.scaleY = _loc6_;
               _loc4_++;
            }
            this.lastScale = _loc6_;
         }
         _loc4_ = 0;
         while(_loc4_ < this.mcas.length)
         {
            _loc5_ = this.mcas[_loc4_] as MovieClipAdapter;
            _loc5_.update(param1);
            _loc4_++;
         }
         if(this._sortDirty)
         {
            this._sortDirty = false;
            this.mcas.sortOn("y",Array.NUMERIC);
            _loc4_ = 0;
            while(_loc4_ < this.mcas.length)
            {
               _loc5_ = this.mcas[_loc4_] as MovieClipAdapter;
               setChildIndex(_loc5_.mc,_loc4_);
               _loc4_++;
            }
         }
      }
   }
}
