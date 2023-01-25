package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class Op_BatteringRam extends Op
   {
       
      
      private var destination:Tile;
      
      private var move:BattleMove;
      
      private var alreadyHits:Dictionary;
      
      private const LOCO_ID:String = "ability_stumble_back";
      
      public function Op_BatteringRam(param1:EffectDefOp, param2:Effect)
      {
         this.alreadyHits = new Dictionary();
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         if(!target.mobile)
         {
            return EffectResult.FAIL;
         }
         this.destination = Op_KnockbackHelper.getKnockbackStopTile(ability.def,caster,caster.rect,target,true);
         if(this.destination)
         {
            return EffectResult.OK;
         }
         return EffectResult.FAIL;
      }
      
      override public function apply() : void
      {
         var _loc9_:Tile = null;
         if(ability.fake || manager.faking)
         {
            return;
         }
         var _loc1_:BattleAbilityDef = manager.factory.fetchBattleAbilityDef("abl_batteringram_initial_arm_dam");
         var _loc2_:BattleAbilityDef = _loc1_.getAbilityDefForLevel(effect.ability.def.level) as BattleAbilityDef;
         var _loc3_:BattleAbility = new BattleAbility(caster,_loc2_,manager);
         _loc3_.targetSet.setTarget(target);
         _loc3_.execute(null);
         if(effect.result != EffectResult.OK)
         {
            return;
         }
         var _loc4_:IPersistedEffects = target.effects;
         if(_loc4_.hasTag(EffectTag.NO_KNOCKBACK))
         {
            return;
         }
         this.move = new BattleMove(target);
         this.move.forcedMove = true;
         this.move.reactToEntityIntersect = true;
         var _loc5_:* = target.y == this.destination.y;
         var _loc6_:int = _loc5_ ? int(this.destination.x - target.x) : int(this.destination.y - target.y);
         var _loc7_:int = _loc6_ > 0 ? 1 : -1;
         var _loc8_:int = _loc7_;
         while(_loc6_ != 0)
         {
            _loc9_ = null;
            if(_loc5_)
            {
               _loc9_ = caster.board.tiles.getTile(target.x + _loc8_,target.y);
            }
            else
            {
               _loc9_ = caster.board.tiles.getTile(target.x,target.y + _loc8_);
            }
            this.move.addStep(_loc9_);
            _loc8_ += _loc7_;
            _loc6_ -= _loc7_;
         }
         this.addListeners();
         effect.addTag(EffectTag.KNOCKBACK_SOMEWHERE);
         target.effects.addTag(EffectTag.KNOCKBACK_SOMEWHERE);
         this.move.setCommitted("Op_BatteringRam.apply");
         effect.blockComplete();
         target.mobility.executeMove(this.move);
      }
      
      private function addListeners() : void
      {
         target.locoId = this.LOCO_ID;
         target.ignoreFreezeFrame = false;
         target.ignoreFacing = true;
         target.addEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         if(this.move)
         {
            this.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.addEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
            this.move.addEventListener(BattleMoveEvent.INTERSECT_ENTITY,this.moveIntersectEntityHandler);
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
         if(this.move)
         {
            this.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERSECT_ENTITY,this.moveIntersectEntityHandler);
         }
         effect.unblockComplete();
      }
      
      private function aliveHandler(param1:BattleEntityEvent) : void
      {
         logger.info("Op_BatteringRam.aliveHandler " + this);
         this.removeListeners();
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         this.removeListeners();
         target.effects.removeTag(EffectTag.KNOCKBACK_SOMEWHERE);
      }
      
      private function moveInterruptedHandler(param1:BattleMoveEvent) : void
      {
         this.removeListeners();
         target.effects.removeTag(EffectTag.KNOCKBACK_SOMEWHERE);
      }
      
      private function moveIntersectEntityHandler(param1:BattleMoveEvent) : void
      {
         var _loc2_:TileRect = target.rect;
         _loc2_.visitEnclosedTileLocations(this._visitIntersectedTiles,null);
      }
      
      private function _visitIntersectedTiles(param1:int, param2:int, param3:*) : void
      {
         var _loc5_:ITileResident = null;
         var _loc6_:IBattleEntity = null;
         var _loc7_:BattleAbilityDef = null;
         var _loc8_:BattleAbility = null;
         var _loc4_:Tile = board.tiles.getTile(param1,param2);
         for each(_loc5_ in _loc4_.residents)
         {
            if(_loc5_ is IBattleEntity)
            {
               _loc6_ = _loc5_ as IBattleEntity;
               if(_loc6_.alive == true && target != _loc6_)
               {
                  if(_loc6_.effects.hasTag(EffectTag.GHOSTED))
                  {
                     caster.logger.info("Op_BatteringRap.moveIntersectEntityHandler SKIPPING " + _loc6_ + ", entity is GHOSTED");
                  }
                  else if(this.alreadyHits[_loc6_])
                  {
                     caster.logger.info("Op_BatteringRam.moveIntersectEntityHandler SKIPPING " + _loc6_ + ", already hit");
                  }
                  else
                  {
                     this.alreadyHits[_loc6_] = _loc6_;
                     _loc7_ = manager.factory.fetchBattleAbilityDef("abl_batteringram_fallthrough_arm_dam");
                     _loc8_ = new BattleAbility(_loc6_,_loc7_,manager);
                     _loc8_.targetSet.setTarget(target);
                     _loc8_.execute(null);
                  }
               }
            }
         }
      }
   }
}
