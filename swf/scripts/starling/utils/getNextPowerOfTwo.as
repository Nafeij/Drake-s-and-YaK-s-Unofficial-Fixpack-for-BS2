package starling.utils
{
   public function getNextPowerOfTwo(param1:Number) : int
   {
      var _loc2_:* = 0;
      if(param1 is int && param1 > 0 && (param1 & param1 - 1) == 0)
      {
         return param1;
      }
      _loc2_ = 1;
      param1 -= 1e-9;
      while(_loc2_ < param1)
      {
         _loc2_ <<= 1;
      }
      return _loc2_;
   }
}
