package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class CaravanDefVars extends CaravanDef
   {
      
      public static const schema:Object = {
         "name":"CaravanDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "roster":{
               "type":"array",
               "items":"string"
            },
            "party":{
               "type":"array",
               "items":"string"
            },
            "leader":{
               "type":"string",
               "optional":true
            },
            "heraldryEnabled":{
               "type":"boolean",
               "optional":true
            },
            "banner":{
               "type":"number",
               "optional":true
            },
            "disable_metrics":{
               "type":"boolean",
               "optional":true
            },
            "saves":{
               "type":"boolean",
               "optional":true
            },
            "ga":{
               "type":"boolean",
               "optional":true
            },
            "animBaseUrl":{
               "type":"string",
               "optional":true
            },
            "closePoleUrl":{
               "type":"string",
               "optional":true
            },
            "trainingPopUrl":{
               "type":"string",
               "optional":true
            },
            "campUrls":{
               "type":"array",
               "items":"string",
               "optional":true
            }
         }
      };
       
      
      public function CaravanDefVars(param1:SagaDef)
      {
         super(param1);
      }
      
      public static function save(param1:CaravanDef) : Object
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:Object = {
            "name":param1.name,
            "roster":[],
            "party":[],
            "banner":param1.banner,
            "leader":(!!param1.leader ? param1.leader : "")
         };
         for each(_loc3_ in param1.roster)
         {
            _loc2_.roster.push(_loc3_);
         }
         for each(_loc4_ in param1.party)
         {
            _loc2_.party.push(_loc4_);
         }
         if(param1.heraldryEnabled)
         {
            _loc2_.heraldryEnabled = true;
         }
         if(param1.disable_metrics)
         {
            _loc2_.disable_metrics = true;
         }
         if(!param1.saves)
         {
            _loc2_.saves = param1.saves;
         }
         if(param1.ga)
         {
            _loc2_.ga = param1.ga;
         }
         if(param1.animBaseUrl)
         {
            _loc2_.animBaseUrl = param1.animBaseUrl;
         }
         if(param1.closePoleUrl)
         {
            _loc2_.caravanClosePoleUrl = param1.closePoleUrl;
         }
         if(param1.trainingPopUrl)
         {
            _loc2_.trainingPopUrl = param1.trainingPopUrl;
         }
         if(param1.campUrls)
         {
            _loc2_.campUrls = param1.campUrls;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         name = param1.name;
         shortname = name.replace("_caravan","").replace("caravan_","");
         for each(_loc3_ in param1.roster)
         {
            roster.push(_loc3_);
         }
         for each(_loc4_ in param1.party)
         {
            party.push(_loc4_);
         }
         if(param1.banner)
         {
            banner = param1.banner;
         }
         leader = param1.leader;
         heraldryEnabled = BooleanVars.parse(param1.heraldryEnabled,heraldryEnabled);
         disable_metrics = BooleanVars.parse(param1.disable_metrics,disable_metrics);
         saves = BooleanVars.parse(param1.saves,saves);
         ga = param1.ga;
         animBaseUrl = param1.animBaseUrl;
         closePoleUrl = param1.closePoleUrl;
         trainingPopUrl = param1.trainingPopUrl;
         campUrls = param1.campUrls;
      }
   }
}
