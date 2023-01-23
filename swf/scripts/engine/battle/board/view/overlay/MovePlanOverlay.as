package engine.battle.board.view.overlay
{
   import engine.battle.BattleAssetsDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.EntityLinkedDirtyRenderSprite;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.path.PathFloodSolverNode;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import flash.geom.Point;
   
   public class MovePlanOverlay extends EntityLinkedDirtyRenderSprite
   {
       
      
      private var _turn:BattleTurn;
      
      public var tho:TileHoverOverlay;
      
      private var arrows:Vector.<DisplayObjectWrapper>;
      
      private var _error:DisplayObjectWrapper;
      
      private var _move:IBattleMove;
      
      public function MovePlanOverlay(param1:BattleBoardView)
      {
         this.arrows = new Vector.<DisplayObjectWrapper>();
         super(param1);
         _fsm.addEventListener(BattleFsmEvent.TURN,this.turnHandler);
         _fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.abilityHandler);
         _fsm.addEventListener(BattleFsmEvent.TURN_ATTACK,this.attackHandler);
         _fsm.addEventListener(BattleFsmEvent.TURN_COMMITTED,this.fsmEventHandler);
         _fsm.addEventListener(BattleFsmEvent.INTERACT,this.interactHandler);
         var _loc2_:BattleAssetsDef = view.board.assets;
         view.bitmapPool.addPool(_loc2_.board_move_arrow_north,4,16);
         view.bitmapPool.addPool(_loc2_.board_move_arrow_south,4,16);
         view.bitmapPool.addPool(_loc2_.board_move_star_north,4,5);
         view.bitmapPool.addPool(_loc2_.board_move_star_south,4,5);
         view.bitmapPool.addPool(_loc2_.board_move_blocked_1,1,5);
         view.bitmapPool.addPool(_loc2_.board_move_blocked_2,1,5);
         view.bitmapPool.addPool(_loc2_.board_move_blocked_1x2,1,5);
      }
      
      public static function centerTheDisplayObject(param1:BattleFacing, param2:DisplayObjectWrapper, param3:Boolean, param4:Boolean) : void
      {
         if(!param4)
         {
            switch(param1)
            {
               case BattleFacing.NE:
                  param2.scaleX = 1;
                  param2.scaleY = 1;
                  break;
               case BattleFacing.SE:
                  param2.scaleX = 1;
                  param2.scaleY = -1;
                  break;
               case BattleFacing.SW:
                  param2.scaleX = -1;
                  param2.scaleY = -1;
                  break;
               case BattleFacing.NW:
                  param2.scaleX = -1;
                  param2.scaleY = 1;
            }
         }
         else
         {
            param2.scaleX = param2.scaleY = 1;
         }
         if(param3)
         {
            param2.x = -param2.scaleX * param2.width / 2;
            param2.y = -param2.scaleY * param2.height / 2;
         }
         else
         {
            param2.x = param2.y = 0;
         }
      }
      
      public static function canRenderOverlay(param1:BattleTurn) : Boolean
      {
         if(!param1 || param1.committed)
         {
            return false;
         }
         var _loc2_:IBattleEntity = param1.entity;
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:IBattleMove = param1.move;
         if(!_loc3_ || param1.move.committed)
         {
            return false;
         }
         return Boolean(_loc2_.playerControlled) && !param1.turnInteract && !param1.ability && param1.move.numSteps > 1;
      }
      
      override public function cleanup() : void
      {
         this.removeAllArrows();
         if(_fsm)
         {
            _fsm.removeEventListener(BattleFsmEvent.TURN_COMMITTED,this.fsmEventHandler);
            _fsm.removeEventListener(BattleFsmEvent.INTERACT,this.interactHandler);
            _fsm.removeEventListener(BattleFsmEvent.TURN,this.turnHandler);
            _fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.abilityHandler);
            _fsm.removeEventListener(BattleFsmEvent.TURN_ATTACK,this.attackHandler);
         }
         this.turn = null;
         super.cleanup();
      }
      
      private function comparePathFloodSolverNodes(param1:PathFloodSolverNode, param2:PathFloodSolverNode) : int
      {
         return param1.g - param2.g;
      }
      
      private function removeAllArrows() : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.arrows.length)
         {
            _loc2_ = this.arrows[_loc1_];
            view.bitmapPool.reclaim(_loc2_);
            _loc1_++;
         }
         displayObjectWrapper.removeAllChildren();
      }
      
      override protected function onRender() : void
      {
         var _loc4_:Tile = null;
         var _loc5_:Tile = null;
         var _loc6_:* = false;
         var _loc7_:DisplayObjectWrapper = null;
         var _loc8_:TileLocation = null;
         var _loc9_:TileLocation = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Point = null;
         var _loc13_:String = null;
         var _loc14_:DisplayObjectWrapper = null;
         var _loc15_:Tile = null;
         var _loc16_:BattleFacing = null;
         var _loc17_:* = false;
         this.removeAllArrows();
         if(!_entity || !this._turn || this._turn.move.committed)
         {
            return;
         }
         var _loc1_:Number = _entity._diameter / 2;
         var _loc2_:int = 1;
         while(_loc2_ < this._turn.move.numSteps)
         {
            _loc4_ = this._turn.move.getStep(_loc2_ - 1);
            _loc5_ = this._turn.move.getStep(_loc2_ - 0);
            _loc6_ = _loc2_ > _entity.stats.getValue(StatType.MOVEMENT);
            _loc7_ = this.getArrow(_loc4_.location,_loc5_.location,_loc6_);
            if(!_loc7_)
            {
               _loc7_ = _loc7_;
            }
            else
            {
               this.arrows.push(_loc7_);
               displayObjectWrapper.addChild(_loc7_);
               _loc8_ = _loc4_.location;
               _loc9_ = _loc5_.location;
               _loc10_ = (_loc8_._x + _loc9_._x) / 2 + _loc1_;
               _loc11_ = (_loc8_._y + _loc9_._y) / 2 + _loc1_;
               _loc12_ = IsoBattleRectangleUtils.getIsoPointScreenPoint(view.units,_loc10_,_loc11_);
               if(_loc7_.scaleX < 0)
               {
                  _loc7_.x = _loc12_.x + _loc7_.width / 2;
               }
               else
               {
                  _loc7_.x = _loc12_.x - _loc7_.width / 2;
               }
               _loc7_.y = _loc12_.y - _loc7_.height / 2;
            }
            _loc2_++;
         }
         var _loc3_:ISaga = SagaInstance.instance;
         if(Boolean(_loc3_) && _loc3_.logger.isDebugEnabled)
         {
            _loc13_ = this.getBlockedUrl();
            if(_loc13_)
            {
               _loc14_ = view.bitmapPool.pop(_loc13_);
            }
            this.setError(_loc14_);
            if(this._error)
            {
               _loc15_ = this._turn.move.last;
               _loc10_ = _loc15_.x + _loc1_;
               _loc11_ = _loc15_.y + _loc1_;
               _loc12_ = IsoBattleRectangleUtils.getIsoPointScreenPoint(view.units,_loc10_,_loc11_);
               _loc16_ = this._turn.move.lastFacing;
               _loc17_ = _entity._length == _entity._width;
               centerTheDisplayObject(_loc16_,this._error,true,_loc17_);
               this._error.x += _loc12_.x;
               this._error.y += _loc12_.y;
            }
         }
      }
      
      private function getBlockedUrl() : String
      {
         if(!this._move || !this._move.pathEndBlocked)
         {
            return null;
         }
         var _loc1_:BattleAssetsDef = view.board.assets;
         if(_entity.localLength == 2 && _entity.localWidth == 1)
         {
            return _loc1_.board_move_blocked_1x2;
         }
         if(_entity.diameter == 1)
         {
            return _loc1_.board_move_blocked_1;
         }
         return _loc1_.board_move_blocked_2;
      }
      
      private function setError(param1:DisplayObjectWrapper) : void
      {
         if(param1 == this._error)
         {
            return;
         }
         if(this._error)
         {
            displayObjectWrapper.removeChild(this._error);
            view.bitmapPool.reclaim(this._error);
         }
         this._error = param1;
         if(this._error)
         {
            displayObjectWrapper.addChild(this._error);
         }
      }
      
      private function getArrow(param1:TileLocation, param2:TileLocation, param3:Boolean) : DisplayObjectWrapper
      {
         var _loc7_:DisplayObjectWrapper = null;
         var _loc4_:int = param2.x - param1.x;
         var _loc5_:int = param2.y - param1.y;
         var _loc6_:BattleAssetsDef = view.board.assets;
         if(param3)
         {
            if(_loc4_ > 0)
            {
               _loc7_ = view.bitmapPool.pop(_loc6_.board_move_star_south);
            }
            else if(_loc5_ < 0)
            {
               _loc7_ = view.bitmapPool.pop(_loc6_.board_move_star_north);
            }
            else if(_loc5_ > 0)
            {
               _loc7_ = view.bitmapPool.pop(_loc6_.board_move_star_south);
               _loc7_.scaleX = -_loc7_.scaleX;
            }
            else if(_loc4_ < 0)
            {
               _loc7_ = view.bitmapPool.pop(_loc6_.board_move_star_north);
               _loc7_.scaleX = -_loc7_.scaleX;
            }
         }
         else if(_loc4_ > 0)
         {
            _loc7_ = view.bitmapPool.pop(_loc6_.board_move_arrow_south);
         }
         else if(_loc5_ < 0)
         {
            _loc7_ = view.bitmapPool.pop(_loc6_.board_move_arrow_north);
         }
         else if(_loc5_ > 0)
         {
            _loc7_ = view.bitmapPool.pop(_loc6_.board_move_arrow_south);
            _loc7_.scaleX = -_loc7_.scaleX;
         }
         else if(_loc4_ < 0)
         {
            _loc7_ = view.bitmapPool.pop(_loc6_.board_move_arrow_north);
            _loc7_.scaleX = -_loc7_.scaleX;
         }
         return _loc7_;
      }
      
      private function attackHandler(param1:BattleFsmEvent) : void
      {
         setRenderDirty();
      }
      
      private function abilityHandler(param1:BattleFsmEvent) : void
      {
         setRenderDirty();
      }
      
      private function turnHandler(param1:BattleFsmEvent) : void
      {
         this.turn = view.board.sim.fsm.turn as BattleTurn;
      }
      
      public function get turn() : BattleTurn
      {
         return this._turn;
      }
      
      public function set turn(param1:BattleTurn) : void
      {
         this._turn = param1;
         entity = !!this.turn ? this.turn.entity as BattleEntity : null;
         this.move = !!this.turn ? this.turn.move : null;
         setRenderDirty();
      }
      
      public function get move() : IBattleMove
      {
         return this._move;
      }
      
      public function set move(param1:IBattleMove) : void
      {
         if(this._move == param1)
         {
            return;
         }
         if(this._move)
         {
            this._move.removeEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
            this._move.removeEventListener(BattleMoveEvent.MOVE_CHANGED,this.moveChangedHandler);
         }
         this._move = param1;
         if(this._move)
         {
            this._move.addEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
            this._move.addEventListener(BattleMoveEvent.MOVE_CHANGED,this.moveChangedHandler);
         }
      }
      
      private function interactHandler(param1:BattleFsmEvent) : void
      {
         setRenderDirty();
      }
      
      private function moveChangedHandler(param1:BattleMoveEvent) : void
      {
         this.checkCanRender();
         setRenderDirty();
      }
      
      private function moveCommittedHandler(param1:BattleMoveEvent) : void
      {
         this.checkCanRender();
      }
      
      private function fsmEventHandler(param1:BattleFsmEvent) : void
      {
         this.checkCanRender();
      }
      
      override protected function checkCanRender() : void
      {
         canRender = canRenderOverlay(this._turn);
      }
      
      override protected function handleCanRenderChanged() : void
      {
         if(this.tho)
         {
            this.tho.makeHoverDirty();
         }
      }
   }
}
