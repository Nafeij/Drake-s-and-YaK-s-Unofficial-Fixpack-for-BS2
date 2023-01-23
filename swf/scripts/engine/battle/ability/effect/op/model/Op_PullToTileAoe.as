package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.sim.TileDiamond;
   import engine.core.util.ArrayUtil;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class Op_PullToTileAoe extends Op
   {
      
      private static const HARD_MIN:int = 1;
      
      private static const HARD_MAX:int = 10;
      
      private static const LOCO_ID:String = "ability_stumble_back";
      
      public static const schema:Object = {
         "name":"Op_PullToTileAoe",
         "properties":{
            "minRange":{"type":"number"},
            "maxRange":{"type":"number"},
            "pullAmount":{"type":"number"}
         }
      };
       
      
      public var maxRange:int = 1;
      
      public var minRange:int = 1;
      
      public var pullAmount:int = 1;
      
      private var targets:Vector.<IBattleEntity>;
      
      private var curMove:BattleMove;
      
      public function Op_PullToTileAoe(param1:EffectDefOp, param2:Effect)
      {
         this.targets = new Vector.<IBattleEntity>();
         super(param1,param2);
         this.pullAmount = this.boundNum(1,10000,param1.params.pullAmount);
         this.maxRange = this.boundNum(HARD_MIN,HARD_MAX,param1.params.maxRange);
         this.minRange = this.boundNum(HARD_MIN,this.maxRange,param1.params.minRange);
      }
      
      private function boundNum(param1:int, param2:int, param3:Number) : int
      {
         return int(Math.min(param2,Math.max(param1,param3)));
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(ability.fake || manager.faking)
         {
            return;
         }
         effect.blockComplete();
         this.targets.length = 0;
         var _loc1_:int = this.minRange;
         while(_loc1_ <= this.maxRange)
         {
            this.targets = this.targets.concat(this.getEntitiesAtDistance(_loc1_));
            _loc1_++;
         }
         this.moveNextEntity();
      }
      
      private function moveNextEntity() : void
      {
         var _loc4_:int = 0;
         if(this.targets.length < 1)
         {
            this.entityMovementComplete();
            return;
         }
         var _loc1_:IBattleEntity = this.targets[0];
         var _loc2_:TileRect = _loc1_.rect.clone();
         if(_loc2_.area == 2)
         {
            _loc2_.setRect(_loc2_.loc.x,_loc2_.loc.y,1,1);
         }
         var _loc3_:Vector.<Tile> = this.findPath(_loc1_,_loc2_,tile.x,tile.y);
         if(_loc3_)
         {
            _loc3_.pop();
         }
         if(Boolean(_loc3_) && _loc3_.length > 0)
         {
            this.curMove = new BattleMove(_loc1_);
            this.curMove.forcedMove = true;
            this.curMove.reactToEntityIntersect = true;
            _loc4_ = _loc3_.length - 1;
            while(_loc4_ >= 0)
            {
               this.curMove.addStep(_loc3_[_loc4_]);
               _loc4_--;
            }
            _loc1_.locoId = LOCO_ID;
            this.curMove.addEventListener(BattleMoveEvent.EXECUTED,this.onMoveComplete);
            this.curMove.addEventListener(BattleMoveEvent.INTERRUPTED,this.onMoveComplete);
            this.curMove.setCommitted("Op_PullToTileAoe.moveNextEntity " + this);
            _loc1_.mobility.executeMove(this.curMove);
            return;
         }
         ArrayUtil.removeAt(this.targets,0);
         this.moveNextEntity();
      }
      
      private function findPath(param1:IBattleEntity, param2:TileRect, param3:int, param4:int) : Vector.<Tile>
      {
         var _loc5_:Vector.<Tile> = null;
         var _loc6_:Vector.<Tile> = null;
         if(param2.contains(param3,param4) || !this.validPosition(param1,param2))
         {
            return new Vector.<Tile>();
         }
         var _loc7_:TileLocation = param2.loc;
         var _loc8_:int = this.boundNum(-1,1,param3 - _loc7_.x);
         var _loc9_:int = this.boundNum(-1,1,param4 - _loc7_.y);
         if(_loc8_)
         {
            param2.setLocation(TileLocation.fetch(_loc7_.x + _loc8_,_loc7_.y));
            _loc5_ = this.findPath(param1,param2,param3,param4);
         }
         if(_loc9_)
         {
            param2.setLocation(TileLocation.fetch(_loc7_.x,_loc7_.y + _loc9_));
            _loc6_ = this.findPath(param1,param2,param3,param4);
            if(!_loc5_ || _loc6_ && _loc6_.length > _loc5_.length)
            {
               _loc5_ = _loc6_;
            }
         }
         if(_loc5_)
         {
            _loc5_.push(board.tiles.getTile(_loc7_.x,_loc7_.y));
         }
         return _loc5_;
      }
      
      private function validPosition(param1:IBattleEntity, param2:TileRect) : Boolean
      {
         if(!board.tiles.hasTilesForRect(param2))
         {
            return false;
         }
         if(board.findAllRectIntersectionEntities(param2,param1,null))
         {
            return false;
         }
         if(param2.visitEnclosedTileLocations(this._checkUnwalkable,param1))
         {
            return false;
         }
         return true;
      }
      
      private function _checkUnwalkable(param1:int, param2:int, param3:ITileResident) : Boolean
      {
         var _loc4_:Tile = board.tiles.getTile(param1,param2);
         return !_loc4_ || !_loc4_.getWalkableFor(param3 as ITileResident);
      }
      
      private function onMoveComplete(param1:BattleMoveEvent) : void
      {
         if(param1.mv.entity.locoId == LOCO_ID)
         {
            param1.mv.entity.locoId = null;
         }
         this.curMove.removeEventListener(BattleMoveEvent.EXECUTED,this.onMoveComplete);
         this.curMove.removeEventListener(BattleMoveEvent.INTERRUPTED,this.onMoveComplete);
         ArrayUtil.removeAt(this.targets,0);
         this.moveNextEntity();
      }
      
      private function entityMovementComplete() : void
      {
         effect.unblockComplete();
      }
      
      private function getEntitiesAtDistance(param1:int) : Vector.<IBattleEntity>
      {
         var _loc6_:TileLocation = null;
         var _loc7_:IBattleEntity = null;
         var _loc2_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc3_:TileRect = tile.rect;
         var _loc4_:Tiles = board.tiles;
         var _loc5_:TileDiamond = new TileDiamond(_loc4_,_loc3_,param1,param1,null,-1);
         for each(_loc6_ in _loc5_.hugs)
         {
            _loc7_ = caster.board.findEntityOnTile(_loc6_.x,_loc6_.y,true,target);
            if(_loc7_ && _loc7_.mobile && _loc7_.attackable && _loc7_ != caster)
            {
               _loc2_.push(_loc7_);
            }
         }
         return _loc2_;
      }
   }
}
