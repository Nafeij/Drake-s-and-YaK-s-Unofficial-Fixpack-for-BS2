package engine.saga.vars
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.def.EngineJsonDef;
   
   public class VariableKeyVars extends VariableKey
   {
      
      public static const schema:Object = {
         "name":"VariableKeyVars",
         "type":"object",
         "properties":{
            "varname":{
               "type":"string",
               "optional":true
            },
            "min":{
               "type":"number",
               "optional":true
            },
            "max":{
               "type":"number",
               "optional":true
            },
            "factor":{
               "type":"number",
               "optional":true
            },
            "modulus":{
               "type":"number",
               "optional":true
            },
            "varvalue":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function VariableKeyVars()
      {
         super();
      }
      
      public static function save(param1:VariableKey) : Object
      {
         var _loc2_:Object = {"varname":(!!param1.varname ? param1.varname : "")};
         if(param1.max == param1.min)
         {
            _loc2_.varvalue = param1.max;
         }
         else
         {
            if(param1.min != VariableKey.DEFAULT_MIN)
            {
               _loc2_.min = param1.min;
            }
            if(param1.max != VariableKey.DEFAULT_MAX)
            {
               _loc2_.max = param1.max;
            }
         }
         if(param1.factor != 1)
         {
            _loc2_.factor = param1.factor;
         }
         if(param1.modulus)
         {
            _loc2_.modulus = param1.modulus;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : VariableKeyVars
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         varname = param1.varname;
         if(varname)
         {
            varname = StringUtil.stripSurroundingSpace(varname);
            varname = varname.replace(/ /g,"_");
         }
         if(param1.modulus != undefined)
         {
            modulus = param1.modulus;
         }
         if(param1.min != undefined)
         {
            min = param1.min;
         }
         if(param1.max != undefined)
         {
            max = param1.max;
         }
         if(param1.factor != undefined)
         {
            factor = param1.factor;
         }
         if(param1.varvalue != undefined)
         {
            min = max = param1.varvalue;
         }
         return this;
      }
   }
}
