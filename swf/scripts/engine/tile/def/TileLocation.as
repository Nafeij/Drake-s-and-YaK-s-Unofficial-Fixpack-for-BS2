package engine.tile.def
{
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class TileLocation
   {
      
      private static var cache:Dictionary = new Dictionary();
      
      private static const bias:int = 10000;
      
      private static const secret:Object = {};
       
      
      public var _x:int;
      
      public var _y:int;
      
      public function TileLocation(param1:*, param2:int, param3:int)
      {
         super();
         if(param1 != secret)
         {
            throw new IllegalOperationError("Use TileLocation.fetch, homie");
         }
         this._x = param2;
         this._y = param3;
      }
      
      public static function fetch(param1:int, param2:int) : TileLocation
      {
         var _loc3_:int = param1 + bias + (param2 + bias) * bias * 2;
         var _loc4_:TileLocation = cache[_loc3_];
         if(!_loc4_)
         {
            _loc4_ = new TileLocation(secret,param1,param2);
            cache[_loc3_] = _loc4_;
         }
         return _loc4_;
      }
      
      public static function manhattanDistance(param1:int, param2:int, param3:int, param4:int) : int
      {
         return Math.abs(param1 - param3) + Math.abs(param2 - param4);
      }
      
      public function get y() : int
      {
         return this._y;
      }
      
      public function get x() : int
      {
         return this._x;
      }
      
      public function equals(param1:TileLocation) : Boolean
      {
         return this._x == param1._x && this._y == param1._y;
      }
      
      public function manhattanDistanceTo(param1:TileLocation) : int
      {
         return Math.abs(this.x - param1.x) + Math.abs(this.y - param1.y);
      }
      
      public function toString() : String
      {
         return "[" + this.x + "," + this.y + "]";
      }
   }
}
