package engine.tile
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class TileRectVars
   {
      
      public static const schema:Object = {
         "name":"TileRectVars",
         "type":"object",
         "properties":{
            "loc":{"type":TileLocationVars.schema},
            "width":{"type":"number"},
            "length":{"type":"number"}
         }
      };
       
      
      public function TileRectVars()
      {
         super();
      }
      
      public static function parse(param1:Object, param2:ILogger) : TileRect
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         var _loc3_:TileLocation = TileLocationVars.parse(param1.loc,param2);
         return new TileRect(_loc3_,param1.width,param1.length);
      }
      
      public static function parseString(param1:String, param2:ILogger) : TileRect
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:Array = param1.split(" ");
         if(_loc3_.length != 4)
         {
            throw new ArgumentError("Malformed tilerectvar string [" + param1 + "]");
         }
         var _loc4_:int = int(_loc3_[0]);
         var _loc5_:int = int(_loc3_[1]);
         var _loc6_:int = int(_loc3_[2]);
         var _loc7_:int = int(_loc3_[3]);
         var _loc8_:TileLocation = TileLocation.fetch(_loc4_,_loc5_);
         return new TileRect(_loc8_,_loc6_,_loc7_);
      }
      
      public static function saveString(param1:TileRect) : String
      {
         return param1.toSaveString();
      }
   }
}
