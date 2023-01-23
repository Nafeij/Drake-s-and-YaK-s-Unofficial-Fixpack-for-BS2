package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.core.util.Enum;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   
   public class Op_IntStatMod extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_IntStatMod",
         "properties":{
            "stat":{"type":"string"},
            "charges":{"type":"number"},
            "amount":{"type":"number"}
         }
      };
       
      
      private var type:StatType;
      
      private var stat:Stat;
      
      public function Op_IntStatMod(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.type = Enum.parse(StatType,param1.params.stat) as StatType;
         if(target.stats.hasStat(this.type) == false)
         {
            target.stats.addStat(this.type,0);
         }
         this.stat = target.stats.getStat(this.type);
      }
      
      override public function apply() : void
      {
         this.stat.addMod(effect,def.params.amount,def.params.charges);
      }
      
      override public function remove() : void
      {
         this.stat.removeMods(effect);
      }
   }
}
