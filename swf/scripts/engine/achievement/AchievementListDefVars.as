package engine.achievement
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class AchievementListDefVars extends AchievementListDef
   {
      
      public static const schema:Object = {
         "name":"AchievementListDefVars",
         "properties":{"achievements":{
            "type":"array",
            "items":AchievementDefVars.schema
         }}
      };
       
      
      public function AchievementListDefVars(param1:Object, param2:ILogger, param3:Locale)
      {
         var _loc5_:Object = null;
         var _loc6_:AchievementDef = null;
         super();
         var _loc4_:Localizer = param3.getLocalizer(LocaleCategory.ACHIEVEMENT);
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc5_ in param1.achievements)
         {
            _loc6_ = new AchievementDefVars(_loc5_,param2,_loc4_);
            addDef(_loc6_);
         }
      }
   }
}
