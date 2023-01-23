package engine.battle
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class SceneListItemDefVars extends SceneListItemDef
   {
      
      public static const schema:Object = {
         "name":"BattleSceneListItemDefVars",
         "properties":{
            "id":{"type":"string"},
            "url":{"type":"string"},
            "weight":{"type":"number"},
            "icon":{"type":"string"},
            "test":{
               "type":"boolean",
               "optional":true
            },
            "town":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function SceneListItemDefVars(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.url = param1.url;
         this.weight = param1.weight;
         this.icon = param1.icon;
         this.test = BooleanVars.parse(param1.test);
         this.town = BooleanVars.parse(param1.town);
      }
   }
}
