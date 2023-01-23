package engine.battle.fsm
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.tile.Tile;
   import engine.tile.TileLocationVars;
   import engine.tile.def.TileLocation;
   
   public class BattleMoveVars extends BattleMove
   {
      
      public static const schema:Object = {
         "name":"BattleMoveVars",
         "type":"object",
         "properties":{
            "entity":{"type":"string"},
            "tiles":{
               "type":"array",
               "items":TileLocationVars.schema
            },
            "battleId":{
               "type":"string",
               "optional":true
            },
            "turn":{
               "type":"number",
               "optional":true
            },
            "user":{
               "type":"number",
               "optional":true
            },
            "ordinal":{
               "type":"number",
               "optinal":true
            },
            "class":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function BattleMoveVars(param1:IBattleBoard, param2:Object, param3:ILogger)
      {
         var _loc5_:Object = null;
         var _loc6_:TileLocation = null;
         var _loc7_:Tile = null;
         EngineJsonDef.validateThrow(param2,schema,param3);
         var _loc4_:IBattleEntity = param1.getEntity(param2.entity);
         super(_loc4_);
         steps.splice(0,steps.length);
         for each(_loc5_ in param2.tiles)
         {
            _loc6_ = TileLocationVars.parse(_loc5_,param3);
            _loc7_ = param1.tiles.getTile(_loc6_.x,_loc6_.y);
            steps.push(_loc7_);
         }
      }
      
      public static function save(param1:IBattleMove) : Object
      {
         var _loc3_:Tile = null;
         var _loc2_:Object = {
            "entity":param1.entity.id,
            "tiles":[]
         };
         var _loc4_:int = 0;
         while(_loc4_ < param1.numSteps)
         {
            _loc3_ = param1.getStep(_loc4_);
            _loc2_.tiles.push(TileLocationVars.save(_loc3_.location));
            _loc4_++;
         }
         return _loc2_;
      }
   }
}
