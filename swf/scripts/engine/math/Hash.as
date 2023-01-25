package engine.math
{
   public class Hash
   {
       
      
      public function Hash()
      {
         super();
      }
      
      public static function RSHash(param1:String) : uint
      {
         var _loc2_:uint = 378551;
         var _loc3_:uint = 63689;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_ = _loc4_ * _loc3_ + uint(param1.charCodeAt(_loc5_));
            _loc3_ *= _loc2_;
            _loc5_++;
         }
         return _loc4_;
      }
      
      public static function JSHash(param1:String) : uint
      {
         var _loc2_:uint = 1315423911;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ ^= (_loc2_ << 5) + uint(param1.charCodeAt(_loc3_)) + (_loc2_ >> 2);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function PJWHash(param1:String) : uint
      {
         var _loc2_:uint = uint(4 * 8);
         var _loc3_:uint = uint(_loc2_ * 3 / 4);
         var _loc4_:uint = uint(_loc2_ / 8);
         var _loc5_:uint = uint(uint(4294967295) << _loc2_ - _loc4_);
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:int = 0;
         while(_loc8_ < param1.length)
         {
            _loc6_ = uint((_loc6_ << _loc4_) + uint(param1.charCodeAt(_loc8_)));
            if((_loc7_ = uint(_loc6_ & _loc5_)) != 0)
            {
               _loc6_ = uint((_loc6_ ^ _loc7_ >> _loc3_) & ~_loc5_);
            }
            _loc8_++;
         }
         return _loc6_;
      }
      
      public static function ELFHash(param1:String) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = uint((_loc2_ << 4) + uint(param1.charCodeAt(_loc4_)));
            _loc3_ = uint(_loc2_ & 4026531840);
            if(_loc3_ != 0)
            {
               _loc2_ ^= _loc3_ >> 24;
            }
            _loc2_ &= ~_loc3_;
            _loc4_++;
         }
         return _loc2_;
      }
      
      public static function BKDRHash(param1:String) : uint
      {
         var _loc2_:uint = 131;
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = _loc3_ * _loc2_ + uint(param1.charCodeAt(_loc4_));
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function SDBMHash(param1:String) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = uint(uint(param1.charCodeAt(_loc3_)) + (_loc2_ << 6) + (_loc2_ << 16) - _loc2_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function DJBHash(param1:String) : uint
      {
         var _loc2_:uint = 5381;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = uint((_loc2_ << 5) + _loc2_ + uint(param1.charCodeAt(_loc3_)));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function DEKHash(param1:String) : uint
      {
         var _loc2_:uint = uint(param1.length);
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = uint(_loc2_ << 5 ^ _loc2_ >> 27 ^ uint(param1.charCodeAt(_loc3_)));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function BPHash(param1:String) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = uint(_loc2_ << 7 ^ uint(param1.charCodeAt(_loc3_)));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function FNVHash(param1:String) : uint
      {
         var _loc2_:uint = 2166136261;
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ *= _loc2_;
            _loc3_ ^= uint(param1.charCodeAt(_loc4_));
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function APHash(param1:String) : uint
      {
         var _loc3_:uint = 0;
         var _loc2_:uint = 2863311530;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = uint(param1.charCodeAt(_loc4_));
            if((_loc4_ & 1) == 0)
            {
               _loc2_ ^= _loc2_ << 7 ^ _loc3_ * (_loc2_ >> 3);
            }
            else
            {
               _loc2_ ^= ~((_loc2_ << 11) + _loc3_ ^ _loc2_ >> 5);
            }
            _loc4_++;
         }
         return _loc2_;
      }
   }
}
