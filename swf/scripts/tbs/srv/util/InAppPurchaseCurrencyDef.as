package tbs.srv.util
{
   public class InAppPurchaseCurrencyDef
   {
       
      
      public var id:String;
      
      public var conversion:Number;
      
      public function InAppPurchaseCurrencyDef(param1:Object)
      {
         super();
         this.id = param1.id;
         this.conversion = param1.conversion;
      }
   }
}
