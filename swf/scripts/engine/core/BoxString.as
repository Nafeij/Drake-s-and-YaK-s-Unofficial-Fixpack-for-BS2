package engine.core
{
   public class BoxString
   {
       
      
      public var value:String;
      
      public function BoxString(param1:String = "")
      {
         super();
         this.value = param1;
      }
      
      public function toString() : String
      {
         return this.value;
      }
   }
}
