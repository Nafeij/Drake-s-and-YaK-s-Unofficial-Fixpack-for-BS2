package engine.tile.def
{
   public class TileRectRange
   {
      
      private static var _b_left:int;
      
      private static var _b_front:int;
      
      private static var _b_right:int;
      
      private static var _b_back:int;
      
      private static var _a_left:int;
      
      private static var _a_front:int;
      
      private static var _a_right:int;
      
      private static var _a_back:int;
       
      
      public function TileRectRange()
      {
         super();
      }
      
      public static function computeRange(param1:TileRect, param2:TileRect) : int
      {
         var _loc3_:int = 0;
         _b_left = param2.loc._x + param2._cached_d_left;
         _b_front = param2.loc._y + param2._cached_d_front;
         _b_right = param2.loc._x + param2._cached_d_right;
         _b_back = param2.loc._y + param2._cached_d_back;
         _a_left = param1.loc._x + param1._cached_d_left;
         _a_front = param1.loc._y + param1._cached_d_front;
         _a_right = param1.loc._x + param1._cached_d_right;
         _a_back = param1.loc._y + param1._cached_d_back;
         if(_b_left >= _a_right)
         {
            _loc3_ = _b_left - _a_right + 1;
         }
         else if(_a_left >= _b_right)
         {
            _loc3_ = _a_left - _b_right + 1;
         }
         var _loc4_:int = 0;
         if(_b_front >= _a_back)
         {
            _loc4_ = _b_front - _a_back + 1;
         }
         else if(_a_front >= _b_back)
         {
            _loc4_ = _a_front - _b_back + 1;
         }
         return _loc3_ + _loc4_;
      }
      
      public static function computeTileRange(param1:TileLocation, param2:TileRect) : int
      {
         var _loc3_:int = 0;
         _b_left = param2.loc._x + param2._cached_d_left;
         _b_front = param2.loc._y + param2._cached_d_front;
         _b_right = param2.loc._x + param2._cached_d_right;
         _b_back = param2.loc._y + param2._cached_d_back;
         if(_b_left >= param1.x + 1)
         {
            _loc3_ = _b_left - (param1.x + 1) + 1;
         }
         else if(param1.x >= _b_right)
         {
            _loc3_ = param1.x - _b_right + 1;
         }
         var _loc4_:int = 0;
         if(_b_front >= param1.y + 1)
         {
            _loc4_ = _b_front - (param1.y + 1) + 1;
         }
         else if(param1.y >= _b_back)
         {
            _loc4_ = param1.y - _b_back + 1;
         }
         return _loc3_ + _loc4_;
      }
   }
}
