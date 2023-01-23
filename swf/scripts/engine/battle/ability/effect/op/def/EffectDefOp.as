package engine.battle.ability.effect.op.def
{
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.op.model.IOp;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   
   public class EffectDefOp
   {
       
      
      public var id:IdEffectOp;
      
      public var params:Object;
      
      public var name:String;
      
      public var enabled:Boolean = true;
      
      public function EffectDefOp()
      {
         super();
      }
      
      public static function constructDef(param1:Object, param2:ILogger) : EffectDefOp
      {
         var _loc3_:IdEffectOp = Enum.parse(IdEffectOp,param1.id) as IdEffectOp;
         return new _loc3_.defClazz(param1,param2) as EffectDefOp;
      }
      
      public function toString() : String
      {
         return "DefOp [" + this.id + ", " + this.name + "]";
      }
      
      public function construct(param1:IEffect) : IOp
      {
         return new this.id.clazz(this,param1) as IOp;
      }
      
      public function link(param1:IBattleAbilityDefFactory) : void
      {
      }
   }
}
