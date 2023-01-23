package engine.core
{
   public class BoxNumber
   {
       
      
      public var value:Number;
      
      public function BoxNumber(param1:Number = 0)
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
