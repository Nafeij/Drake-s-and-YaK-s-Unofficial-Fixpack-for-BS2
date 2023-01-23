package tbs.srv.util
{
   import engine.core.logging.ILogger;
   
   public class CurrencyData
   {
       
      
      public var currency:String;
      
      public function CurrencyData()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.currency = param1.currency;
      }
   }
}
