package engine.core
{
   public class BoxInt
   {
       
      
      public var value:int;
      
      public function BoxInt(param1:int = 0)
      {
         super();
         this.value = param1;
      }
      
      public function toString() : String
      {
         return this.value.toString();
      }
   }
}
