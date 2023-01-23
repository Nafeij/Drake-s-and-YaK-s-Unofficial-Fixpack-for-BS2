package engine.battle.board.def
{
   import engine.ability.def.StringIntPair;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   import engine.tile.TileLocationAreaVars;
   
   public class BattleDeploymentAreaVars extends BattleDeploymentArea
   {
      
      public static const schema:Object = {
         "name":"BattleDeploymentAreaVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "facing":{"type":"string"},
            "area":{"type":TileLocationAreaVars.schema},
            "execAbilityId":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function BattleDeploymentAreaVars()
      {
         super();
      }
      
      public static function save(param1:BattleDeploymentArea) : Object
      {
         var _loc2_:Object = {
            "id":param1.id,
            "facing":param1.facing.name,
            "area":TileLocationAreaVars.save(param1.area)
         };
         if(param1.execAbilityId)
         {
            _loc2_.execAbilityId = param1.execAbilityId.save();
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleDeploymentArea
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         id = param1.id;
         facing = Enum.parse(BattleFacing,param1.facing) as BattleFacing;
         area = TileLocationAreaVars.parse(param1.area,param2);
         if(param1.execAbilityId)
         {
            execAbilityId = new StringIntPair().parseString(param1.execAbilityId,1);
         }
         return this;
      }
   }
}
