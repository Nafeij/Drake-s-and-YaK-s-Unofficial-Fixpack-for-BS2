package engine.tile
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import engine.tile.def.TileRect;
   
   public class TileLocationAreaVars
   {
      
      public static const schema:Object = {
         "name":"TileLocationAreaVars",
         "type":"object",
         "properties":{
            "tiles":{
               "type":"array",
               "items":TileLocationVars.schema,
               "optional":true
            },
            "tilesx":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "rects":{
               "type":"array",
               "items":TileRectVars.schema,
               "optional":true
            }
         }
      };
       
      
      public function TileLocationAreaVars()
      {
         super();
      }
      
      public static function parse(param1:Object, param2:ILogger) : TileLocationArea
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:TileLocation = null;
         var _loc7_:String = null;
         var _loc8_:TileLocation = null;
         var _loc9_:TileRect = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         EngineJsonDef.validateThrow(param1,schema,param2);
         var _loc3_:TileLocationArea = new TileLocationArea();
         if(param1.tiles)
         {
            for each(_loc5_ in param1.tiles)
            {
               _loc6_ = TileLocationVars.parse(_loc5_,param2);
               _loc3_.addTile(_loc6_);
            }
         }
         else if(param1.tilesx)
         {
            for each(_loc7_ in param1.tilesx)
            {
               _loc8_ = TileLocationVars.parseString(_loc7_,param2);
               _loc3_.addTile(_loc8_);
            }
         }
         for each(_loc4_ in param1.rects)
         {
            _loc9_ = TileRectVars.parse(_loc4_,param2);
            _loc10_ = _loc9_.left;
            while(_loc10_ < _loc9_.right)
            {
               _loc11_ = _loc9_.front;
               while(_loc11_ < _loc9_.back)
               {
                  _loc3_.addTile(TileLocation.fetch(_loc10_,_loc11_));
                  _loc11_++;
               }
               _loc10_++;
            }
         }
         _loc3_.fit();
         return _loc3_;
      }
      
      public static function save(param1:TileLocationArea) : Object
      {
         var _loc3_:TileLocation = null;
         var _loc2_:Object = {};
         _loc2_.tilesx = [];
         for each(_loc3_ in param1.locations)
         {
            _loc2_.tilesx.push(TileLocationVars.saveString(_loc3_));
         }
         (_loc2_.tilesx as Array).sort();
         return _loc2_;
      }
   }
}
