package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.IBattleTurn;
   import engine.path.PathFloodSolverNode;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class Op_Runaway extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_Runaway",
         "properties":{"distance":{"type":"number"}}
      };
       
      
      public var distance:int = 0;
      
      private var move:BattleMove;
      
      private var interrupted:Boolean;
      
      private var finished:Boolean;
      
      private var _transientBlockageId:int = 0;
      
      public function Op_Runaway(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.distance = param1.params.distance;
      }
      
      override public function execute() : EffectResult
      {
         if(!target || !target.effects || Boolean(target.effects.hasTag(EffectTag.RANAWAY)))
         {
            return EffectResult.FAIL;
         }
         return EffectResult.OK;
      }
      
      private function _stripUnwalkableNodes(param1:Array) : void
      {
         var _loc2_:PathFloodSolverNode = null;
         var _loc3_:Tile = null;
         if(!param1)
         {
            return;
         }
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = param1[_loc4_];
            _loc3_ = _loc2_.node.key as Tile;
            if(!_loc3_.getWalkableFor(caster))
            {
               param1.splice(_loc4_,1);
            }
            else
            {
               _loc4_++;
            }
         }
      }
      
      private function computeMove() : void
      {
         var mv:int;
         var n:PathFloodSolverNode;
         var t:Tile;
         var tr:TileRect;
         var ns:Array = null;
         if(target.mobility.moving)
         {
            return;
         }
         if(!target.effects || Boolean(target.effects.hasTag(EffectTag.RANAWAY)))
         {
            return;
         }
         this.move = new BattleMove(target,0);
         mv = int(target.stats.getValue(StatType.MOVEMENT));
         mv = Math.min(mv,this.distance);
         while(mv > 0)
         {
            ns = this.move.flood.getNodesAtDistance(mv);
            if(Boolean(ns) && ns.length > 0)
            {
               break;
            }
            ns = null;
            mv--;
         }
         this._stripUnwalkableNodes(ns);
         if(!ns || ns.length == 0)
         {
            this.move = null;
            return;
         }
         ns.sort(function comp(param1:PathFloodSolverNode, param2:PathFloodSolverNode):int
         {
            var _loc3_:Tile = param1.node.key as Tile;
            var _loc4_:Tile = param2.node.key as Tile;
            var _loc5_:TileRect = new TileRect(_loc3_.location,target.boardWidth,target.boardLength);
            var _loc6_:TileRect = new TileRect(_loc4_.location,target.boardWidth,target.boardLength);
            var _loc7_:int = TileRectRange.computeRange(_loc5_,caster.rect);
            var _loc8_:int = TileRectRange.computeRange(_loc6_,caster.rect);
            return _loc8_ - _loc7_;
         });
         n = ns[0];
         t = n.node.key as Tile;
         this.move.process(t,true);
         tr = target.rect.clone();
         tr.setLocation(t.location);
         tr.facing = this.move.lastFacing;
         this._transientBlockageId = Tiles.addTransientBlockage(tr,target);
      }
      
      override public function apply() : void
      {
         if(ability.fake || manager.faking)
         {
            return;
         }
         if(result != EffectResult.OK)
         {
            return;
         }
         if(!target || !target.effects)
         {
            return;
         }
         if(!target.alive)
         {
            return;
         }
         this.computeMove();
         if(this.move)
         {
            effect.addTag(EffectTag.RANAWAY);
            target.effects.addTag(EffectTag.RANAWAY);
            effect.blockComplete();
            this.addListeners();
            this.move.setCommitted("Op_Runaway");
            target.mobility.executeMove(this.move);
         }
         else
         {
            this.finishMove();
         }
      }
      
      override public function remove() : void
      {
         if(!this.finished)
         {
            this.finishMove();
         }
         this.removeListeners();
      }
      
      private function addListeners() : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Runaway.addListeners move=" + this.move);
         }
         if(this.move)
         {
            this.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.addEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
         }
      }
      
      private function removeListeners() : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Runaway.addListeners move=" + this.move);
         }
         if(this.move)
         {
            this.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
         }
         Tiles.removeTransientBlockage(this._transientBlockageId);
      }
      
      private function finishMove() : void
      {
         var _loc1_:IBattleTurn = null;
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Runaway.finishMove finished=" + this.finished + " move=" + this.move);
         }
         if(this.finished)
         {
            return;
         }
         this.finished = true;
         if(this.move)
         {
            _loc1_ = caster.board.fsm.turn;
            if(_loc1_)
            {
               if(_loc1_.entity == target)
               {
                  if(!_loc1_.move.committed)
                  {
                     _loc1_.move.reset(target.tile);
                  }
                  _loc1_.committed = true;
               }
            }
            if(logger.isDebugEnabled)
            {
               logger.debug("Op_Runaway finishMove");
            }
            this.removeListeners();
            this.move = null;
            effect.unblockComplete();
         }
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Runaway.moveExecutedHandler");
         }
         this.finishMove();
      }
      
      private function moveInterruptedHandler(param1:BattleMoveEvent) : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("Op_Runaway.moveInterruptedHandler");
         }
         this.interrupted = true;
         this.finishMove();
      }
   }
}
