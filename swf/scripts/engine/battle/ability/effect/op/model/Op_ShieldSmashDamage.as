package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.entity.model.BattleEntity;
   import engine.stat.def.StatType;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   
   public class Op_ShieldSmashDamage extends Op
   {
       
      
      public var amount:int;
      
      protected var validTargets:Array;
      
      public var dam:int;
      
      public function Op_ShieldSmashDamage(param1:EffectDefOp, param2:Effect)
      {
         this.validTargets = new Array();
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         var _loc5_:int = 0;
         var _loc1_:BattleEntity = target as BattleEntity;
         var _loc2_:TileRect = _loc1_.rect;
         var _loc3_:int = _loc1_.pos.x;
         var _loc4_:int = _loc1_.pos.y;
         this.validTargets.splice(0);
         _loc2_.visitAdjacentTileLocations(this.addEnemy,this.validTargets);
         if(this.validTargets.length > 0)
         {
            _loc5_ = int(caster.stats.getValue(StatType.ARMOR));
            this.dam = Math.max(1,_loc5_ / this.validTargets.length);
            return EffectResult.OK;
         }
         return EffectResult.FAIL;
      }
      
      override public function apply() : void
      {
         var _loc1_:IBattleAbilityDef = null;
         var _loc2_:BattleAbility = null;
         var _loc3_:int = 0;
         if(result == EffectResult.OK)
         {
            if(this.validTargets.length > 0)
            {
               _loc1_ = null;
               caster.stats.setBase(StatType.SHIELD_SMASH_DAMAGE,this.dam);
               _loc1_ = target.board.abilityManager.getFactory.fetchIBattleAbilityDef("abl_shield_smash_aoe_dam");
               _loc2_ = new BattleAbility(caster,_loc1_,target.board.abilityManager);
               _loc3_ = 0;
               while(_loc3_ < this.validTargets.length)
               {
                  _loc2_.targetSet.addTarget(this.validTargets[_loc3_]);
                  _loc3_++;
               }
               effect.ability.addChildAbility(_loc2_);
            }
         }
         caster.stats.setBase(StatType.ARMOR,0);
      }
      
      protected function addEnemy(param1:int, param2:int, param3:Array) : void
      {
         var _loc4_:BattleEntity = this.getEnemyBattleEntityOnTile(param1,param2);
         if(_loc4_ != caster)
         {
            if(_loc4_ != null && param3.indexOf(_loc4_) == -1)
            {
               param3.push(_loc4_);
            }
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
