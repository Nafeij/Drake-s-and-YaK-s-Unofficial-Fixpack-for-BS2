package engine.battle.ability.phantasm.def
{
   import engine.anim.view.ColorPulsatorDef;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class PhantasmDefColorPulsator extends PhantasmDef
   {
      
      public static const schema:Object = {
         "name":"PhantasmDefColorPulsator",
         "type":"object",
         "properties":{
            "base":{"type":PhantasmDefVars.schema},
            "pulsator":{"type":ColorPulsatorDef.schema}
         }
      };
       
      
      public var pulsator:ColorPulsatorDef;
      
      public function PhantasmDefColorPulsator(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         PhantasmDefVars.parse(this,param1.base,param2);
         this.pulsator = new ColorPulsatorDef().fromJson(param1.pulsator,param2);
      }
      
      override public function toJson() : Object
      {
         return {
            "pulsator":this.pulsator.toJson(),
            "base":PhantasmDefVars.save(this)
         };
      }
      
      override public function toString() : String
      {
         return "PDColorPulsator " + super.toString() + " " + this.pulsator.toString();
      }
   }
}
