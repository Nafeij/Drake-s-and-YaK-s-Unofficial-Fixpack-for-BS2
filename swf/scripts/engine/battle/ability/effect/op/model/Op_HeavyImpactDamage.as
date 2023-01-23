package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.entity.model.BattleEntity;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   
   public class Op_HeavyImpactDamage extends Op
   {
       
      
      public var amount:int;
      
      public var stat_target_deduct:Stat;
      
      protected var validTargets:Array;
      
      public function Op_HeavyImpactDamage(param1:EffectDefOp, param2:Effect)
      {
         this.validTargets = new Array();
         super(param1,param2);
         this.stat_target_deduct = requireStat(target,StatType.STRENGTH);
      }
      
      override public function execute() : EffectResult
      {
         var _loc1_:BattleEntity = null;
         _loc1_ = target as BattleEntity;
         var _loc2_:int = _loc1_.pos.x;
         var _loc3_:int = _loc1_.pos.y;
         var _loc4_:TileRect = target.rect;
         this.validTargets.splice(0);
         _loc4_.visitAdjacentTileLocations(this.addEnemy,this.validTargets);
         if(this.validTargets.length > 0)
         {
            return EffectResult.OK;
         }
         return EffectResult.FAIL;
      }
      
      override public function apply() : void
      {
         var _loc1_:IBattleAbilityDef = null;
         var _loc2_:Stat = null;
         var _loc3_:BattleAbility = null;
         var _loc4_:int = 0;
         var _loc5_:IBattleAbilityDef = null;
         if(result == EffectResult.OK)
         {
            if(this.validTargets.length > 0)
            {
               _loc1_ = null;
               _loc2_ = caster.stats.getStat(StatType.MASTER_ABILITY_SUNDERING_IMPACT,false);
               if(_loc2_ != null && _loc2_.value != 0)
               {
                  _loc5_ = target.board.abilityManager.getFactory.fetchIBattleAbilityDef("abl_sunderingimpact_damage_targets");
                  _loc1_ = _loc5_.getAbilityDefForLevel(_loc2_.value) as BattleAbilityDef;
               }
               else
               {
                  _loc1_ = target.board.abilityManager.getFactory.fetchIBattleAbilityDef("abl_heavyimpact_damage_targets");
               }
               _loc3_ = new BattleAbility(caster,_loc1_,target.board.abilityManager);
               _loc4_ = 0;
               while(_loc4_ < this.validTargets.length)
               {
                  _loc3_.targetSet.addTarget(this.validTargets[_loc4_]);
                  _loc4_++;
               }
               effect.ability.addChildAbility(_loc3_);
            }
         }
      }
      
      protected function addEnemy(param1:int, param2:int, param3:Array) : void
      {
         var _loc4_:BattleEntity = this.getEnemyBattleEntityOnTile(param1,param2);
         if(_loc4_ != null && param3.indexOf(_loc4_) == -1)
         {
            param3.push(_loc4_);
         }
      }
      
      protected function getEnemyBattleEntityOnTile(param1:int, param2:int) : BattleEntity
      {
         var _loc4_:ITileResident = null;
         var _loc5_:BattleEntity = null;
         var _loc3_:Tile = target.board.tiles.getTile(param1,param2);
         if(_loc3_ != null)
         {
            _loc4_ = _loc3_.findResident(null);
            if(_loc4_ != null && _loc4_ is BattleEntity)
            {
               _loc5_ = _loc4_ as BattleEntity;
               if(_loc5_.alive == true && _loc5_.attackable == true && _loc5_.team != caster.team)
               {
                  return _loc5_;
               }
            }
         }
         return null;
      }
   }
}
