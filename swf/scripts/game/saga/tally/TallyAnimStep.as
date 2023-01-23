package game.saga.tally
{
   public class TallyAnimStep implements ITallyStep
   {
       
      
      public var startLabel:String;
      
      public var endLabel:String;
      
      public function TallyAnimStep(param1:String, param2:String)
      {
         super();
         this.startLabel = param1;
         this.endLabel = param2;
      }
      
      public function get text() : String
      {
         return null;
      }
   }
}
