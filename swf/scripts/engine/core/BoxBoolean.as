package engine.core
{
   public class BoxBoolean
   {
       
      
      public var value:Boolean;
      
      public function BoxBoolean(param1:Boolean = false)
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
