package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class Op_KindleKnockback extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_KindleKnockback",
         "properties":{"move_ability":{
            "type":"string",
            "optional":true
         }}
      };
       
      
      private var destinationTile:Tile;
      
      private var move:BattleMove;
      
      private var alreadyHits:Dictionary;
      
      private var move_ability:BattleAbilityDef;
      
      private const LOCO_ID:String = "ability_stumble_back";
      
      public function Op_KindleKnockback(param1:EffectDefOp, param2:Effect)
      {
         this.alreadyHits = new Dictionary();
         super(param1,param2);
         if(param1.params.move_ability)
         {
            this.move_ability = manager.factory.fetch(param1.params.move_ability) as BattleAbilityDef;
         }
      }
      
      public function getStopTile(param1:IBattleEntity, param2:int, param3:int, param4:int) : Tile
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Tile = null;
         var _loc12_:Boolean = false;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:Tile = null;
         var _loc18_:IBattleEntity = null;
         var _loc5_:IBattleBoard = param1.board;
         var _loc6_:Tiles = _loc5_.tiles;
         var _loc7_:Tile = null;
         var _loc8_:int = 1;
         while(_loc8_ <= param4)
         {
            _loc9_ = param2 * _loc8_;
            _loc10_ = param3 * _loc8_;
            _loc11_ = _loc6_.getTile(param1.x + _loc9_,param1.y + _loc10_);
            _loc12_ = true;
            _loc13_ = 0;
            while(_loc13_ < param1.boardWidth && _loc12_)
            {
               _loc14_ = 0;
               for(; _loc14_ < param1.boardLength && _loc12_; _loc14_++)
               {
                  _loc15_ = param1.x + _loc13_ + _loc9_;
                  _loc16_ = param1.y + _loc14_ + _loc10_;
                  _loc17_ = _loc6_.getTile(_loc15_,_loc16_);
                  if(Boolean(_loc17_) && _loc17_.getWalkableFor(param1))
                  {
                     _loc18_ = param1.board.findEntityOnTile(_loc15_,_loc16_,true,param1);
                     if(!_loc18_)
                     {
                        continue;
                     }
                  }
                  _loc12_ = false;
               }
               _loc13_++;
            }
            if(!_loc12_)
            {
               break;
            }
            _loc7_ = _loc11_;
            _loc8_++;
         }
         return _loc7_;
      }
      
      override public function execute() : EffectResult
      {
         var _loc1_:IPersistedEffects = target.effects;
         if(Boolean(_loc1_) && Boolean(_loc1_.hasTag(EffectTag.NO_KNOCKBACK)))
         {
            return EffectResult.FAIL;
         }
         var _loc2_:int = effect.ability.def.maxResultDistance;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:TileRect = target.rect;
         var _loc6_:TileRect = caster.rect;
         var _loc7_:int = _loc5_.left >= _loc6_.right ? 1 + _loc5_.left - _loc6_.right : 0;
         var _loc8_:int = _loc6_.left >= _loc5_.right ? 1 + _loc6_.left - _loc5_.right : 0;
         var _loc9_:int = _loc5_.front >= _loc6_.back ? 1 + _loc5_.front - _loc6_.back : 0;
         var _loc10_:int = _loc6_.front >= _loc5_.back ? 1 + _loc6_.front - _loc5_.back : 0;
         if(_loc7_ >= _loc8_ && _loc7_ >= _loc9_ && _loc7_ >= _loc10_)
         {
            _loc3_ = 1;
         }
         else if(_loc8_ >= _loc7_ && _loc8_ >= _loc9_ && _loc8_ >= _loc10_)
         {
            _loc3_ = -1;
         }
         else if(_loc9_ >= _loc8_ && _loc9_ >= _loc7_ && _loc9_ >= _loc10_)
         {
            _loc4_ = 1;
         }
         else if(_loc10_ >= _loc8_ && _loc10_ >= _loc7_ && _loc10_ >= _loc9_)
         {
            _loc4_ = -1;
         }
         var _loc11_:Tile = this.getStopTile(target,_loc3_,_loc4_,_loc2_);
         this.destinationTile = _loc11_;
         if(!this.destinationTile)
         {
            return EffectResult.FAIL;
         }
         effect.addTag(EffectTag.KNOCKBACK_SOMEWHERE);
         target.effects.addTag(EffectTag.KNOCKBACK_SOMEWHERE);
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc5_:Tile = null;
         if(ability.fake || manager.faking)
         {
            return;
         }
         if(!this.destinationTile)
         {
            return;
         }
         if(!target.alive)
         {
            return;
         }
         if(!target.mobile)
         {
            return;
         }
         this.move = new BattleMove(target);
         this.move.forcedMove = true;
         this.move.reactToEntityIntersect = true;
         var _loc1_:* = target.y == this.destinationTile.y;
         var _loc2_:int = _loc1_ ? this.destinationTile.x - Number(target.x) : this.destinationTile.y - Number(target.y);
         var _loc3_:int = _loc2_ > 0 ? 1 : -1;
         var _loc4_:int = _loc3_;
         while(_loc2_ != 0)
         {
            _loc5_ = null;
            if(_loc1_)
            {
               _loc5_ = caster.board.tiles.getTile(target.x + _loc4_,target.y);
            }
            else
            {
               _loc5_ = caster.board.tiles.getTile(target.x,target.y + _loc4_);
            }
            this.move.addStep(_loc5_);
            _loc4_ += _loc3_;
            _loc2_ -= _loc3_;
         }
         this.addListeners();
         this.move.setCommitted("Op_KindleKnockback.apply");
         effect.blockComplete();
         target.mobility.executeMove(this.move);
      }
      
      private function addListeners() : void
      {
         target.locoId = this.LOCO_ID;
         target.ignoreFreezeFrame = false;
         target.ignoreFacing = true;
         if(this.move)
         {
            if(this.move_ability)
            {
               target.addEventListener(BattleEntityEvent.TILE_CHANGED,this.tileChangedEvent);
            }
            target.addEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
            this.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.addEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
         }
      }
      
      private function removeListeners() : void
      {
         if(target.locoId == this.LOCO_ID)
         {
            target.locoId = null;
         }
         target.ignoreFreezeFrame = true;
         target.ignoreFacing = false;
         target.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         target.removeEventListener(BattleEntityEvent.TILE_CHANGED,this.tileChangedEvent);
         if(this.move)
         {
            this.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
         }
         effect.unblockComplete();
      }
      
      private function aliveHandler(param1:BattleEntityEvent) : void
      {
         logger.info("Op_KindleKnockback.aliveHandler " + this);
         this.removeListeners();
      }
      
      private function tileChangedEvent(param1:BattleEntityEvent) : void
      {
         var _loc2_:BattleAbility = null;
         if(this.move_ability)
         {
            _loc2_ = new BattleAbility(target,this.move_ability,manager);
            _loc2_.targetSet.setTarget(target);
            _loc2_.execute(null);
         }
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         logger.info("Op_KindleKnockback.moveExecutedHandler " + this);
         this.removeListeners();
         target.effects.removeTag(EffectTag.KNOCKBACK_SOMEWHERE);
      }
      
      private function moveInterruptedHandler(param1:BattleMoveEvent) : void
      {
         logger.info("Op_KindleKnockback.moveInterruptedHandler " + this);
         this.removeListeners();
         target.effects.removeTag(EffectTag.KNOCKBACK_SOMEWHERE);
      }
   }
}
