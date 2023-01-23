package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   
   public class SagaDlcs
   {
       
      
      public var entries:Vector.<SagaDlcEntry>;
      
      public function SagaDlcs()
      {
         this.entries = new Vector.<SagaDlcEntry>();
         super();
      }
      
      public function applyDlcs(param1:Saga, param2:AppInfo) : void
      {
         var _loc3_:SagaDlcEntry = null;
         for each(_loc3_ in this.entries)
         {
            _loc3_.conditionallyApplyDlc(param1,param2);
         }
      }
      
      public function getDlc(param1:String) : SagaDlcEntry
      {
         var _loc2_:SagaDlcEntry = null;
         for each(_loc2_ in this.entries)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function reportDlcKeys(param1:ILogger) : void
      {
         var _loc2_:SagaDlcEntry = null;
         for each(_loc2_ in this.entries)
         {
            param1.info("SAGA DLC ENTRY [" + _loc2_.id + "] key [" + SagaDlcEntry.computeEntryKey(_loc2_.id) + "]");
         }
      }
   }
}
