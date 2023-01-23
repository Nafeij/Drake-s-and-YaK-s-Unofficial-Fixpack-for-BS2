package engine.saga
{
   public final class NullSagaDlc implements ISagaDlc
   {
       
      
      public function NullSagaDlc()
      {
         super();
      }
      
      public function ownsDlc(param1:SagaDlcEntry, param2:Function = null) : int
      {
         if(param1.ownedDefault)
         {
            return SagaDlcEntry.DLC_OWNED;
         }
         return SagaDlcEntry.DLC_STATUS_UNKNOWN;
      }
   }
}
