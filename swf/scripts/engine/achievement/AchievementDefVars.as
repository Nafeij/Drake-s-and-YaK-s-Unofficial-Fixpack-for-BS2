package engine.achievement
{
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class AchievementDefVars extends AchievementDef
   {
      
      public static const schema:Object = {
         "name":"AchievementDefVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "type":{"type":"string"},
            "progressCount":{
               "type":"number",
               "optional":true
            },
            "progressVar":{
               "type":"string",
               "optional":true
            },
            "iconurl":{"type":"string"},
            "local":{
               "type":"boolean",
               "optional":true
            },
            "renownreward":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function AchievementDefVars(param1:Object, param2:ILogger, param3:Localizer)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.type = Enum.parse(AchievementType,param1.type) as AchievementType;
         this.progressCount = param1.progressCount;
         this.progressVar = param1.progressVar;
         if(type == AchievementType.CLASS_UNLOCK)
         {
            if(!this.progressVar)
            {
               this.progressVar = id.replace("acv_","prg_");
            }
         }
         if(Boolean(this.progressCount) && !this.progressVar)
         {
            param2.error("Achievement " + id + " has a progress count but no var");
         }
         if(this.progressVar)
         {
            this.progressCount = Math.max(1,this.progressCount);
         }
         this.iconUrl = param1.iconurl;
         this.renownAwardAmount = param1.renownreward;
         this.local = param1.local;
         localizeAchievementDef(param3);
      }
   }
}
