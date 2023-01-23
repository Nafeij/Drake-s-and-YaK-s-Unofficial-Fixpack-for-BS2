package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.core.util.Enum;
   import engine.expression.Parser;
   import engine.expression.exp.Exp;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   
   public class Op_SetStat extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SetStat",
         "properties":{
            "stat":{"type":"string"},
            "rhs":{"type":"string"},
            "removeIfCreated":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var type:StatType;
      
      private var stat:Stat;
      
      private var rhs:String;
      
      private var rhs_exp:Exp;
      
      private var value:Number = 0;
      
      private var removeIfCreated:Boolean;
      
      private var wasCreated:Boolean;
      
      public function Op_SetStat(param1:EffectDefOp, param2:Effect)
      {
         var _loc5_:int = 0;
         super(param1,param2);
         this.type = Enum.parse(StatType,param1.params.stat) as StatType;
         this.stat = target.stats.getStat(this.type,false);
         this.rhs = param1.params.rhs;
         this.removeIfCreated = param1.params.removeIfCreated;
         if(!this.rhs)
         {
            this.rhs = "0";
         }
         var _loc3_:Parser = new Parser(this.rhs,logger);
         this.rhs_exp = _loc3_.exp;
         var _loc4_:EffectSymbols = new EffectSymbols(param2);
         _loc4_.addSymbol("current",!!this.stat ? this.stat.base : 0);
         this.value = this.rhs_exp.evaluate(_loc4_,true);
         if(this.type == StatType.WEAVED_ENERGY_NEXT && this.value == 5)
         {
            _loc5_ = Saga.instance != null ? Saga.instance.minutesPlayed : 0;
            SagaAchievements.unlockAchievementById("acv_3_24_pass_it_on",_loc5_,true);
         }
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function remove() : void
      {
         if(this.removeIfCreated && this.wasCreated)
         {
            target.stats.removeStat(this.type);
         }
      }
      
      override public function apply() : void
      {
         if(!this.stat)
         {
            this.stat = target.stats.addStat(this.type,this.value);
            this.wasCreated = true;
         }
         else
         {
            this.stat.base = this.value;
         }
         checkSagaTriggers();
      }
   }
}
