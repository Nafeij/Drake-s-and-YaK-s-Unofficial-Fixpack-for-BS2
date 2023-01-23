package game.gui.page
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.entity.view.EntityView;
   import engine.core.logging.ILogger;
   import engine.core.render.Camera;
   import engine.saga.Saga;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   
   public class ScenePageAnimDebug extends Sprite
   {
      
      public static var ENABLED:Boolean = false;
       
      
      private var scenePage:ScenePage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var board:BattleBoard;
      
      private var boardView:BattleBoardView;
      
      private var ent2Debug:Dictionary;
      
      private var _logger:ILogger;
      
      private var scratchPt:Point;
      
      private var lastScale:Number = 1;
      
      private var _enabled:Boolean = false;
      
      public function ScenePageAnimDebug(param1:ScenePage)
      {
         this.ent2Debug = new Dictionary();
         this.scratchPt = new Point();
         super();
         this.scenePage = param1;
         this.config = param1.config;
         this._logger = param1.logger;
         this.mouseEnabled = this.mouseChildren = false;
         name = "anim_debug";
      }
      
      public function cleanup() : void
      {
         this.removeAll();
         if(this.board)
         {
            this.board.removeEventListener(BattleEntityEvent.ADDED,this.battleEntityAddedHandler);
            this.board.removeEventListener(BattleEntityEvent.REMOVED,this.battleEntityRemovedHandler);
            this.board = null;
         }
         this.boardView = null;
         if(this.saga)
         {
            this.saga = null;
         }
         this.ent2Debug = null;
         this.scenePage = null;
         this.config = null;
      }
      
      public function doInitReady() : void
      {
         this.saga = this.config.saga;
         this.board = this.scenePage.scene.focusedBoard;
         if(this.board)
         {
            this.board.addEventListener(BattleEntityEvent.ADDED,this.battleEntityAddedHandler);
            this.board.addEventListener(BattleEntityEvent.REMOVED,this.battleEntityRemovedHandler);
            this.boardView = this.scenePage.view.boards.focusedBoardView;
            this.addAll();
         }
      }
      
      private function battleEntityAddedHandler(param1:BattleEntityEvent) : void
      {
         this.addEntity(param1.entity);
      }
      
      private function addEntity(param1:IBattleEntity) : void
      {
         var _loc2_:DebugInfo = new DebugInfo(param1,this.scenePage.config.textBitmapGenerator);
         addChild(_loc2_.bmp);
         this.ent2Debug[_loc2_.ent] = _loc2_;
      }
      
      private function battleEntityRemovedHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:DebugInfo = this.ent2Debug[param1.entity];
         if(_loc2_)
         {
            removeChild(_loc2_.bmp);
            _loc2_.cleanup();
         }
         delete this.ent2Debug[param1.entity];
      }
      
      public function resetAllFlags() : void
      {
      }
      
      private function removeAll() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:* = null;
         var _loc3_:DebugInfo = null;
         for(_loc2_ in this.ent2Debug)
         {
            _loc1_ = true;
            _loc3_ = this.ent2Debug[_loc2_];
            if(_loc3_)
            {
               _loc3_.cleanup();
            }
         }
         if(_loc1_)
         {
            this.ent2Debug = new Dictionary();
         }
      }
      
      private function addAll() : void
      {
         var _loc1_:BattleEntity = null;
         for each(_loc1_ in this.board.entities)
         {
            this.addEntity(_loc1_);
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc4_:* = null;
         var _loc5_:BattleEntity = null;
         var _loc6_:EntityView = null;
         var _loc7_:DebugInfo = null;
         var _loc8_:Bitmap = null;
         if(!this.board || !this.boardView)
         {
            return;
         }
         if(!ENABLED)
         {
            if(this._enabled)
            {
               visible = false;
               this.removeAll();
            }
            this._enabled = false;
            return;
         }
         if(!this._enabled)
         {
            visible = true;
            this._enabled = true;
            this.addAll();
         }
         var _loc2_:Camera = this.board.scene.camera;
         var _loc3_:Number = !!_loc2_ ? _loc2_.scale : 1;
         this.x = int(this.scenePage.width / 2 + (this.boardView.layerSprite.x + this.board.def.pos.x) * _loc3_);
         this.y = int(this.scenePage.height / 2 + (this.boardView.layerSprite.y + this.board.def.pos.y) * _loc3_);
         this.lastScale = _loc3_;
         for(_loc4_ in this.ent2Debug)
         {
            _loc5_ = _loc4_ as BattleEntity;
            _loc6_ = this.boardView.getEntityView(_loc5_);
            _loc6_.getBattleDamageFlagPosition(this.scratchPt);
            _loc7_ = this.ent2Debug[_loc4_];
            if(_loc7_)
            {
               _loc7_.update();
            }
            _loc8_ = _loc7_.bmp;
            _loc8_.x = this.scratchPt.x;
            _loc8_.y = this.scratchPt.y;
         }
      }
   }
}

import engine.anim.view.IAnim;
import engine.battle.board.model.IBattleEntity;
import engine.battle.entity.model.BattleEntityMobility;
import engine.scene.ITextBitmapGenerator;
import flash.display.Bitmap;
import flash.display.BitmapData;

class DebugInfo
{
    
   
   public var ent:IBattleEntity;
   
   public var str:String;
   
   public var bmpd:BitmapData;
   
   public var bmp:Bitmap;
   
   public var gen:ITextBitmapGenerator;
   
   public function DebugInfo(param1:IBattleEntity, param2:ITextBitmapGenerator)
   {
      this.bmp = new Bitmap();
      super();
      this.ent = param1;
      this.gen = param2;
   }
   
   public function cleanup() : void
   {
      if(Boolean(this.bmp) && Boolean(this.bmp.parent))
      {
         this.bmp.parent.removeChild(this.bmp);
         this.bmp = null;
      }
      if(this.bmpd)
      {
         this.bmpd.dispose();
         this.bmpd = null;
      }
   }
   
   public function update() : void
   {
      var _loc2_:IAnim = null;
      var _loc3_:BattleEntityMobility = null;
      var _loc1_:* = this.ent.id + "\n" + this.ent.rect + "\n";
      if(this.ent.animController)
      {
         _loc2_ = this.ent.animController.anim;
         if(_loc2_)
         {
            _loc1_ += _loc2_.def.name + " @" + _loc2_.frame + " :" + _loc2_.count;
         }
      }
      if(Boolean(this.ent.mobility) && Boolean(this.ent.mobility.moving))
      {
         _loc3_ = this.ent.mobility as BattleEntityMobility;
         _loc1_ += "\nmv=" + _loc3_.walkTilesBehavior._t.toFixed(2);
      }
      if(_loc1_ == this.str)
      {
         return;
      }
      this.str = _loc1_;
      if(this.bmpd)
      {
         this.bmp.bitmapData = null;
         this.bmpd.dispose();
         this.bmpd = null;
      }
      if(this.str)
      {
         this.bmpd = this.gen.generateTextBitmap("minion",14,16777215,0,this.str,2000);
         this.bmp.bitmapData = this.bmpd;
      }
   }
}
