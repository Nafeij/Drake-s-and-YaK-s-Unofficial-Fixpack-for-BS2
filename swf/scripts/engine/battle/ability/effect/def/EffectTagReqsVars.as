package engine.battle.ability.effect.def
{
   import engine.battle.ability.effect.model.EffectTag;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class EffectTagReqsVars extends EffectTagReqs
   {
      
      public static const schema:Object = {
         "name":"EffectTagReqsVars",
         "properties":{
            "all":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "any":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "none":{
               "type":"array",
               "items":"string",
               "optional":true
            }
         }
      };
      
      private static var ev:Vector.<EffectTag> = new Vector.<EffectTag>();
       
      
      public function EffectTagReqsVars(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         all = captureTagSet(param1.all);
         any = captureTagSet(param1.any);
         none = captureTagSet(param1.none);
      }
      
      public static function save(param1:EffectTagReqs, param2:Boolean = false) : Object
      {
         param1 = !!param1 ? param1 : empty;
         var _loc3_:Object = {};
         if(Boolean(param1.all) || param2)
         {
            _loc3_.all = saveTags(param1.all);
         }
         if(Boolean(param1.any) || param2)
         {
            _loc3_.any = saveTags(param1.any);
         }
         if(Boolean(param1.none) || param2)
         {
            _loc3_.none = saveTags(param1.none);
         }
         return _loc3_;
      }
      
      private static function saveTags(param1:Vector.<EffectTag>) : Array
      {
         var _loc3_:EffectTag = null;
         param1 = !!param1 ? param1 : ev;
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
         {
            _loc2_.push(_loc3_.name);
         }
         return _loc2_;
      }
      
      public static function factory(param1:Object, param2:ILogger) : EffectTagReqs
      {
         if(!param1)
         {
            return null;
         }
         return new EffectTagReqsVars(param1,param2);
      }
   }
}
