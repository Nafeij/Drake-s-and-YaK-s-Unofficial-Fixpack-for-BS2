package engine.expression
{
   public class ErrorExp extends Error
   {
       
      
      public var index:int;
      
      public function ErrorExp(param1:String, param2:int)
      {
         super(param1);
         this.index = param2;
      }
      
      public function print(param1:String) : String
      {
         var _loc2_:* = "";
         _loc2_ += "Failure: " + message + " at position " + this.index + "\n";
         _loc2_ += param1 + "\n";
         var _loc3_:int = 0;
         while(_loc3_ < this.index)
         {
            _loc2_ += ".";
            _loc3_++;
         }
         return _loc2_ + "^...";
      }
   }
}
