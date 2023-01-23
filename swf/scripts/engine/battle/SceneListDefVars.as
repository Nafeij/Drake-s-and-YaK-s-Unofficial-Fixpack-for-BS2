package engine.battle
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SceneListDefVars extends SceneListDef
   {
      
      public static const schema:Object = {
         "name":"BattleSceneListDefVars",
         "properties":{"scenes":{
            "type":"array",
            "items":SceneListItemDefVars.schema
         }}
      };
       
      
      public function SceneListDefVars(param1:Object, param2:ILogger)
      {
         var _loc3_:Object = null;
         var _loc4_:SceneListItemDef = null;
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.scenes)
         {
            _loc4_ = new SceneListItemDefVars(_loc3_,param2);
            addItem(_loc4_);
         }
      }
   }
}
