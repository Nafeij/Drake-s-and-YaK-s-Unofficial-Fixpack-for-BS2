package engine.expression
{
   import flash.utils.Dictionary;
   
   public class Symbols implements ISymbols
   {
       
      
      public var cache:Dictionary;
      
      public function Symbols()
      {
         this.cache = new Dictionary();
         super();
      }
      
      public static function hash(param1:String) : uint
      {
         var _loc2_:uint = 7;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = _loc2_ * 31 + param1.charCodeAt(_loc3_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function process(param1:*) : Number
      {
         var _loc2_:Number = NaN;
         var _loc3_:uint = 0;
         var _loc4_:String = null;
         if(param1 is String)
         {
            if(!param1)
            {
               return 0;
            }
            _loc2_ = Number(param1);
            if(!isNaN(_loc2_))
            {
               _loc4_ = _loc2_.toString();
               if(_loc4_ == param1 || "0" + param1 == _loc4_)
               {
                  return _loc2_;
               }
            }
            return hash(param1);
         }
         return param1;
      }
      
      public function getSymbolValue(param1:String, param2:Boolean) : Number
      {
         var _loc3_:* = undefined;
         if(this.cache[param1] != undefined)
         {
            _loc3_ = this.cache[param1];
            return process(_loc3_);
         }
         if(param2)
         {
            throw new ArgumentError("No such symbol: [" + param1 + "]");
         }
         return 0;
      }
   }
}
