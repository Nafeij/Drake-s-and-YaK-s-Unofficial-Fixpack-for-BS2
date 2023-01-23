package engine.expression.exp.operator
{
   public class Operator
   {
       
      
      public var str:String;
      
      public var escapedStr:String;
      
      public function Operator(param1:String)
      {
         super();
         this.str = param1;
         this.escapedStr = "";
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this.escapedStr = this.escapedStr + "\\" + param1.charAt(_loc2_);
            _loc2_++;
         }
      }
      
      public static function _b2n(param1:Boolean) : Number
      {
         return param1 ? 1 : 0;
      }
      
      public function toString() : String
      {
         return this.str;
      }
   }
}
