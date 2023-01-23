package engine.saga.vars
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class VariableDefBindVars extends VariableDefBind
   {
      
      public static const schema:Object = {
         "name":"VariableDefBindVars",
         "type":"object",
         "properties":{
            "src":{"type":"string"},
            "src_multiplier":{
               "type":"string",
               "optional":true
            },
            "src_divisor":{
               "type":"string",
               "optional":true
            },
            "src_constant":{
               "type":"string",
               "optional":true
            },
            "factor":{
               "type":"number",
               "optional":true
            },
            "multiplier":{
               "type":"number",
               "optional":true
            },
            "divisor":{
               "type":"number",
               "optional":true
            },
            "constant":{"type":"number"}
         }
      };
       
      
      public function VariableDefBindVars(param1:VariableDef)
      {
         super(param1);
      }
      
      public static function save(param1:VariableDefBind) : Object
      {
         var _loc2_:Object = {
            "src":param1.src,
            "multiplier":param1.multiplier,
            "divisor":param1.divisor,
            "constant":param1.constant
         };
         if(param1.src_multiplier)
         {
            _loc2_.src_multiplier = param1.src_multiplier;
         }
         if(param1.src_divisor)
         {
            _loc2_.src_divisor = param1.src_divisor;
         }
         if(param1.src_constant)
         {
            _loc2_.src_constant = param1.src_constant;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : void
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.src = param1.src;
         if(param1.factor != undefined)
         {
            this.multiplier = param1.factor;
         }
         else if(param1.multiplier != undefined)
         {
            this.multiplier = param1.multiplier;
         }
         if(param1.divisor != undefined)
         {
            this.divisor = param1.divisor;
         }
         src_multiplier = param1.src_multiplier;
         src_divisor = param1.src_divisor;
         src_constant = param1.src_constant;
         this.constant = param1.constant;
      }
   }
}
