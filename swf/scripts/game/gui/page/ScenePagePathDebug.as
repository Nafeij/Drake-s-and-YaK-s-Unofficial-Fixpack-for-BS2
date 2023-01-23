package game.gui.page
{
   import com.dncompute.graphics.GraphicsUtil;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleTurn;
   import engine.battle.fsm.aimodule.AiModuleDredge;
   import engine.core.cmd.Cmd;
   import engine.core.logging.ILogger;
   import engine.core.render.Camera;
   import engine.core.util.ColorUtil;
   import engine.math.MathUtil;
   import engine.path.IPathGraphNode;
   import engine.path.PathFloodSolverNode;
   import engine.saga.Saga;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.cfg.GameKeyBinder;
   
   public class ScenePagePathDebug extends Sprite
   {
      
      private static var _ENABLED:Boolean = false;
      
      private static var _instance:ScenePagePathDebug;
      
      private static var UNITS:int = 64;
      
      private static var u:int = UNITS / 2;
      
      private static var u2:int = UNITS;
       
      
      private var scenePage:ScenePage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var board:BattleBoard;
      
      private var boardView:BattleBoardView;
      
      private var fsm:IBattleFsm;
      
      private var _logger:ILogger;
      
      private var scratchPt:Point;
      
      private var lastScale:Number = 1;
      
      private var _enabled:Boolean = false;
      
      private var _dirtyPath:Boolean;
      
      private var _dirtyScreen:Boolean;
      
      private var _spriteTiles:Sprite;
      
      private var keybinder:GameKeyBinder;
      
      public var infos:Dictionary;
      
      private var cmd_release:Cmd;
      
      private var _scratchPt1:Point;
      
      private var _scratchPt2:Point;
      
      public function ScenePagePathDebug(param1:ScenePage)
      {
         this.scratchPt = new Point();
         this._spriteTiles = new Sprite();
         this.cmd_release = new Cmd("release_ai",this.cmdfunc_release);
         this._scratchPt1 = new Point();
         this._scratchPt2 = new Point();
         super();
         _instance = this;
         this.scenePage = param1;
         this.keybinder = param1.config.keybinder;
         this.config = param1.config;
         this._logger = param1.logger;
         this.mouseEnabled = this.mouseChildren = false;
         name = "path_debug";
         addChild(this._spriteTiles);
      }
      
      public static function get ENABLED() : Boolean
      {
         return _ENABLED;
      }
      
      public static function set ENABLED(param1:Boolean) : void
      {
         if(_ENABLED == param1)
         {
            return;
         }
         _ENABLED = param1;
         AiModuleDredge.HOLD_CHOICE = _ENABLED;
         AiModuleDredge.RELEASE_CHOICE = false;
         if(_instance)
         {
            _instance.handleBind(_ENABLED);
         }
      }
      
      private function handleBind(param1:Boolean) : void
      {
         if(param1)
         {
            this.keybinder.bind(true,false,true,Keyboard.SPACE,this.cmd_release,"");
         }
         else
         {
            this.keybinder.unbind(this.cmd_release);
         }
      }
      
      private function cmdfunc_release(param1:*) : void
      {
         AiModuleDredge.RELEASE_CHOICE = true;
      }
      
      public function cleanup() : void
      {
         _instance = null;
         this.handleBind(false);
         this.removeAllInfos();
         if(this.board)
         {
            this.board = null;
         }
         this.boardView = null;
         if(this.saga)
         {
            this.saga = null;
         }
         if(this.fsm)
         {
            this.fsm.removeEventListener(BattleFsmEvent.TURN,this.turnHandler);
            this.fsm = null;
         }
         this.scenePage = null;
         this.config = null;
      }
      
      public function doInitReady() : void
      {
         this.saga = this.config.saga;
         this.board = this.scenePage.scene.focusedBoard;
         if(this.board)
         {
            this.fsm = this.board.fsm;
            this.boardView = this.scenePage.view.boards.focusedBoardView;
            this.fsm.addEventListener(BattleFsmEvent.TURN,this.turnHandler);
            this._dirtyPath = true;
         }
      }
      
      private function turnHandler(param1:BattleFsmEvent) : void
      {
         this._dirtyPath = true;
         this.removeAllInfos();
      }
      
      private function removeAllInfos() : void
      {
         var _loc1_:DebugInfo = null;
         if(this.infos)
         {
            for each(_loc1_ in this.infos)
            {
               _loc1_.cleanup();
            }
            this.infos = null;
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:DebugInfo = null;
         var _loc8_:PathFloodSolverNode = null;
         if(!this.board || !this.boardView)
         {
            return;
         }
         if(!ENABLED)
         {
            if(this._enabled)
            {
               visible = false;
               this.removeAllInfos();
            }
            this._enabled = false;
            return;
         }
         if(!this._enabled)
         {
            visible = true;
            this._enabled = true;
         }
         var _loc2_:Camera = this.board.scene.camera;
         _loc3_ = !!_loc2_ ? _loc2_.scale : 1;
         this._spriteTiles.scaleX = this._spriteTiles.scaleY = _loc3_;
         this.x = int(this.scenePage.width / 2 + (this.boardView.layerSprite.x + this.board.def.pos.x) * _loc3_);
         this.y = int(this.scenePage.height / 2 + (this.boardView.layerSprite.y + this.board.def.pos.y) * _loc3_);
         this.lastScale = _loc3_;
         if(this.infos)
         {
            for each(_loc4_ in this.infos)
            {
               this._updateDebugInfo(_loc4_);
            }
         }
         if(!this._dirtyPath)
         {
            return;
         }
         this._dirtyPath = false;
         var _loc5_:Graphics = this._spriteTiles.graphics;
         _loc5_.clear();
         var _loc6_:IBattleTurn = this.fsm.turn;
         var _loc7_:IBattleMove = !!_loc6_ ? _loc6_.move : null;
         if(!_loc7_ || !_loc7_.flood)
         {
            return;
         }
         var _loc9_:Number = 0;
         for each(_loc8_ in _loc7_.flood.resultSet)
         {
            _loc9_ = Math.max(_loc9_,_loc8_.gg);
         }
         for each(_loc8_ in _loc7_.flood.resultSet)
         {
            this.createDebugInfo(_loc8_,_loc9_);
         }
         for each(_loc8_ in _loc7_.flood.resultSet)
         {
            this._drawPathFloodSolverNode(_loc8_);
         }
         for each(_loc8_ in _loc7_.flood.resultSet)
         {
            this._drawPathLink(_loc8_);
         }
      }
      
      private function _drawPathFloodSolverNode(param1:PathFloodSolverNode) : void
      {
         var _loc2_:Graphics = this._spriteTiles.graphics;
         var _loc3_:IPathGraphNode = param1.node;
         var _loc4_:Tile = _loc3_.key as Tile;
         var _loc5_:TileLocation = _loc4_.location;
         var _loc6_:Number = Math.min(1,param1.gg / 16);
         var _loc7_:uint = MathUtil.lerp(0,255,_loc6_);
         var _loc8_:uint = MathUtil.lerp(255,0,_loc6_);
         var _loc9_:uint = _loc7_ << 16 | _loc8_ << 8;
         _loc2_.lineStyle(2,_loc9_,1);
         _loc2_.beginFill(_loc9_,0.5);
         var _loc10_:Number = (_loc5_.x + _loc5_.y) / 2;
         var _loc11_:Number = _loc5_.x - _loc5_.y;
         _loc11_ *= UNITS;
         _loc10_ *= UNITS;
         var _loc12_:int = 4;
         _loc2_.moveTo(_loc11_,_loc10_ + 4);
         _loc2_.lineTo(_loc11_ - u2 + 4,_loc10_ + u);
         _loc2_.lineTo(_loc11_,_loc10_ + u2 - 4);
         _loc2_.lineTo(_loc11_ + u2 - 4,_loc10_ + u);
         _loc2_.lineTo(_loc11_,_loc10_ + 4);
         _loc2_.endFill();
      }
      
      private function _drawPathLink(param1:PathFloodSolverNode) : void
      {
         var _loc10_:Tile = null;
         var _loc2_:Graphics = this._spriteTiles.graphics;
         var _loc3_:IPathGraphNode = param1.node;
         var _loc4_:Tile = _loc3_.key as Tile;
         var _loc5_:TileLocation = _loc4_.location;
         var _loc6_:Number = Math.min(1,param1.gg / 16);
         var _loc7_:uint = MathUtil.lerp(0,255,_loc6_);
         var _loc8_:uint = MathUtil.lerp(255,0,_loc6_);
         var _loc9_:uint = _loc7_ << 16 | _loc8_ << 8;
         if(param1.parent)
         {
            _loc10_ = param1.parent.node.key as Tile;
            this._drawParentLink(_loc10_.location,_loc5_,_loc9_);
         }
      }
      
      private function _drawParentLink(param1:TileLocation, param2:TileLocation, param3:uint) : void
      {
         var _loc4_:Graphics = this._spriteTiles.graphics;
         param3 = ColorUtil.lerpColor(param3,16777215,0.5);
         _loc4_.lineStyle(3,param3,1);
         var _loc5_:Number = (param1.x + param1.y + 1) / 2;
         var _loc6_:Number = param1.x - param1.y;
         var _loc7_:Number = (param2.x + param2.y + 1) / 2;
         var _loc8_:Number = param2.x - param2.y;
         _loc5_ *= UNITS;
         _loc6_ *= UNITS;
         _loc7_ *= UNITS;
         _loc8_ *= UNITS;
         this._scratchPt1.setTo(_loc6_,_loc5_);
         this._scratchPt2.setTo(_loc8_,_loc7_);
         GraphicsUtil.drawArrow(_loc4_,this._scratchPt1,this._scratchPt2);
      }
      
      private function createDebugInfo(param1:PathFloodSolverNode, param2:Number) : DebugInfo
      {
         if(!this.infos)
         {
            this.infos = new Dictionary();
         }
         var _loc3_:DebugInfo = this.infos[param1];
         if(!_loc3_)
         {
            _loc3_ = new DebugInfo(param1,this.scenePage.config.textBitmapGenerator,param2);
            this.infos[param1] = _loc3_;
            addChild(_loc3_.bmp);
            this._updateDebugInfo(_loc3_);
         }
         return _loc3_;
      }
      
      private function _updateDebugInfo(param1:DebugInfo) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:IPathGraphNode = param1.pfsn.node;
         var _loc3_:Tile = !!_loc2_ ? _loc2_.key as Tile : null;
         var _loc4_:TileLocation = !!_loc3_ ? _loc3_.location : null;
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:Number = (_loc4_.x + _loc4_.y + 1) / 2;
         var _loc6_:Number = _loc4_.x - _loc4_.y;
         _loc6_ *= UNITS * this.lastScale;
         _loc5_ *= UNITS * this.lastScale;
         param1.bmp.x = _loc6_ - param1.bmp.width / 2;
         param1.bmp.y = _loc5_ - param1.bmp.height / 2;
      }
   }
}

import engine.core.util.ColorUtil;
import engine.math.MathUtil;
import engine.path.PathFloodSolverNode;
import engine.scene.ITextBitmapGenerator;
import flash.display.Bitmap;
import flash.display.BitmapData;

class DebugInfo
{
    
   
   public var pfsn:PathFloodSolverNode;
   
   public var str:String;
   
   public var bmpd:BitmapData;
   
   public var bmp:Bitmap;
   
   public var gen:ITextBitmapGenerator;
   
   public var topGG:Number = 16;
   
   public function DebugInfo(param1:PathFloodSolverNode, param2:ITextBitmapGenerator, param3:int)
   {
      this.bmp = new Bitmap();
      super();
      this.pfsn = param1;
      this.gen = param2;
      this.topGG = Math.max(param3,8);
      this.renderText();
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
      this.pfsn = null;
      this.gen = null;
   }
   
   public function renderText() : void
   {
      var _loc2_:Number = NaN;
      var _loc3_:uint = 0;
      var _loc4_:uint = 0;
      var _loc5_:uint = 0;
      var _loc1_:String = "gg=" + this.pfsn.gg;
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
         _loc2_ = Math.min(1,Number(this.pfsn.gg) / Number(this.topGG));
         _loc3_ = MathUtil.lerp(0,255,_loc2_);
         _loc4_ = MathUtil.lerp(255,0,_loc2_);
         _loc5_ = _loc3_ << 16 | _loc4_ << 8;
         _loc5_ = ColorUtil.lerpColor(_loc5_,16777215,0.75);
         this.bmpd = this.gen.generateTextBitmap("minion",14,_loc5_,0,this.str,2000);
         this.bmp.bitmapData = this.bmpd;
      }
   }
}
