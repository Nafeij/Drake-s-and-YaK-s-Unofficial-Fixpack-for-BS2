package engine.heraldry
{
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.def.EngineJsonDef;
   
   public class HeraldrySystemVars extends HeraldrySystem
   {
      
      public static const schema:Object = {
         "name":"HeraldrySystemVars",
         "type":"object",
         "properties":{
            "heraldries":{
               "type":"array",
               "items":HeraldryDefVars.schema
            },
            "crests":{
               "type":"array",
               "items":CrestDefVars.schema
            },
            "crestUrl":{"type":"string"},
            "bannerUrl":{"type":"string"},
            "additional":{"type":"string"}
         }
      };
       
      
      public function HeraldrySystemVars(param1:PrefBag)
      {
         super(param1);
      }
      
      public static function toJson(param1:HeraldrySystem) : Object
      {
         var _loc3_:CrestDef = null;
         var _loc4_:HeraldryDef = null;
         var _loc2_:Object = {
            "heraldries":[],
            "crests":[],
            "crestUrl":param1.baseCrestUrl,
            "bannerUrl":param1.baseBannerUrl,
            "additional":param1.additionalUrl
         };
         for each(_loc3_ in param1.crestDefs)
         {
            _loc2_.crests.push(CrestDefVars.toJson(_loc3_,param1));
         }
         for each(_loc4_ in param1.heraldryDefs)
         {
            _loc2_.heraldries.push(HeraldryDefVars.toJson(_loc4_,param1));
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : HeraldrySystemVars
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:CrestDef = null;
         var _loc6_:HeraldryDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         baseCrestUrl = param1.crestUrl;
         baseBannerUrl = param1.bannerUrl;
         if(!HeraldrySystem.SUPPRESS_ADDITIONAL_HERALDRY)
         {
            additionalUrl = param1.additional;
         }
         for each(_loc3_ in param1.crests)
         {
            _loc5_ = new CrestDefVars().fromJson(_loc3_,param2);
            addCrestDef(_loc5_);
         }
         for each(_loc4_ in param1.heraldries)
         {
            _loc6_ = new HeraldryDefVars().fromJson(_loc4_,param2);
            addHeraldryDef(_loc6_);
         }
         return this;
      }
   }
}
