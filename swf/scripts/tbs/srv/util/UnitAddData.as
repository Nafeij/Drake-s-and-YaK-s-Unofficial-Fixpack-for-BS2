package tbs.srv.util
{
   import engine.core.logging.ILogger;
   
   public class UnitAddData
   {
       
      
      public var account_id:int;
      
      public var unitv:Object;
      
      public function UnitAddData()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.account_id = param1.account_id;
         this.unitv = param1.unit;
      }
   }
}
