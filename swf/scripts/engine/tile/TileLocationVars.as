package engine.tile
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.tile.def.TileLocation;
   
   public class TileLocationVars
   {
      
      public static const schema:Object = {
         "name":"TileLocationVars",
         "type":"object",
         "properties":{
            "x":{"type":"number"},
            "y":{"type":"number"},
            "class":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function TileLocationVars()
      {
         super();
      }
      
      public static function parse(param1:Object, param2:ILogger) : TileLocation
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         return TileLocation.fetch(param1.x,param1.y);
      }
      
      public static function parseString(param1:String, param2:ILogger) : TileLocation
      {
         var _loc3_:int = param1.indexOf(" ");
         if(_loc3_ < 0)
         {
            throw new ArgumentError("invalid tile location string [" + param1 + "]");
         }
         var _loc4_:Number = Number(param1.substring(0,_loc3_));
         var _loc5_:Number = Number(param1.substring(_loc3_ + 1));
         return TileLocation.fetch(_loc4_,_loc5_);
      }
      
      public static function saveString(param1:TileLocation) : String
      {
         return param1.x.toString() + " " + param1.y.toString();
      }
      
      public static function save(param1:TileLocation) : Object
      {
         return {
            "x":param1.x,
            "y":param1.y
         };
      }
   }
}
