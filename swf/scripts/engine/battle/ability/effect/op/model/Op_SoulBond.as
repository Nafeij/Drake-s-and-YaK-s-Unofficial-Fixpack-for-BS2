package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.stat.def.StatType;
   
   public class Op_SoulBond extends Op_DamageRecourse implements IOp_DamageRecourse
   {
      
      public static const schema:Object = {
         "name":"Op_SoulBond",
         "properties":{"onRecourseAbility":{
            "type":"string",
            "optional":true
         }}
      };
       
      
      private var _willpower_drained:int;
      
      public function Op_SoulBond(param1:EffectDefOp, param2:Effect)
      {
         param1.params.recourseMult = 1;
         param1.params.recoursePercent = 1;
         super(param1,param2);
         _statsToRecourse = new Vector.<StatType>();
         _statsToRecourse.push(StatType.STRENGTH);
      }
      
      override public function remove() : void
      {
         if(target)
         {
            target.removeEventListener(BattleEntityEvent.TILE_CHANGED,this.targetTileChangedHandler);
         }
      }
      
      private function targetTileChangedHandler(param1:BattleEntityEvent) : void
      {
         if(Boolean(caster) && Boolean(target))
         {
            (caster as BattleEntity).turnToFace(target.rect,false);
         }
      }
      
      override public function apply() : void
      {
         if(ability.fake)
         {
            return;
         }
         target.addEventListener(BattleEntityEvent.TILE_CHANGED,this.targetTileChangedHandler);
         var _loc1_:int = int(caster.stats.getValue(StatType.WILLPOWER,0));
         if(!ability.fake)
         {
            if(ability.def.costs)
            {
               _loc1_ += ability.def.costs.getValue(StatType.WILLPOWER,0);
            }
            else
            {
               _loc1_ += 1;
            }
         }
         var _loc2_:int = int(target.stats.getValue(StatType.WILLPOWER,0));
         var _loc3_:int = Math.max(0,_loc1_ - _loc2_);
         var _loc4_:int = Math.min(_loc2_,_loc3_);
         _loc4_ = Math.max(0,_loc4_);
         this._willpower_drained = _loc4_;
         target.stats.changeBase(StatType.WILLPOWER,-_loc4_,0);
      }
      
      override public function casterStartTurn() : Boolean
      {
         if(Boolean(this._willpower_drained) && target.alive)
         {
            caster.stats.changeBase(StatType.STRENGTH,this._willpower_drained,0);
         }
         return true;
      }
   }
}
