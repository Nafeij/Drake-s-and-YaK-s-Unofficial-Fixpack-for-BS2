package engine.battle.ability.effect.op.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.stat.def.StatType;
   
   public class OpDef_DamageArm extends EffectDefOp
   {
      
      public static const schema:Object = {
         "name":"OpDef_DamageArm",
         "properties":{
            "damage":{"type":"number"},
            "damage_param":{
               "type":"string",
               "optional":true
            },
            "casterBonus":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var damage:int;
      
      public var damage_param:String;
      
      public var statType_casterBonus:StatType;
      
      public function OpDef_DamageArm(param1:Object, param2:ILogger)
      {
         super();
         EffectDefOpVars.parse(this,param1,param2,schema);
         this.damage = params.damage;
         this.damage_param = params.damage_param;
         var _loc3_:String = params.casterBonus;
         if(_loc3_)
         {
            this.statType_casterBonus = Enum.parse(StatType,_loc3_) as StatType;
         }
      }
   }
}
