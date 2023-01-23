package game.cfg
{
   import engine.saga.save.SagaSave;
   
   public class SagaLoadParams
   {
       
      
      public var sagaHappening:String;
      
      public var sagaSave:SagaSave;
      
      public var sagaImported:SagaSave;
      
      public var sagaSelectedVariable:String;
      
      public var sagaDifficulty:int = 0;
      
      public var sagaProfileIndex:int = -1;
      
      public var parentSagaUrl:String;
      
      public function SagaLoadParams()
      {
         super();
      }
      
      public function clear() : void
      {
         this.sagaSave = null;
         this.sagaImported = null;
         this.sagaSelectedVariable = null;
         this.parentSagaUrl = null;
      }
   }
}
