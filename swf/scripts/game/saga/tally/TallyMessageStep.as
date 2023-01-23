package game.saga.tally
{
   public class TallyMessageStep implements ITallyStep
   {
       
      
      public var messageKey:String;
      
      public function TallyMessageStep(param1:String)
      {
         super();
         this.messageKey = param1;
      }
      
      public function get text() : String
      {
         return this.messageKey;
      }
   }
}
