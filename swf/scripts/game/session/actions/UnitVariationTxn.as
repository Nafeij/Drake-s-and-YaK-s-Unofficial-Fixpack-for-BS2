package game.session.actions
{
   import engine.core.http.HttpJsonAction;
   import engine.core.http.HttpRequestMethod;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.session.Credentials;
   
   public class UnitVariationTxn extends HttpJsonAction
   {
      
      public static const PATH:String = "services/roster/unit/variation";
       
      
      private var unit:IEntityDef;
      
      private var variation:int;
      
      public function UnitVariationTxn(param1:Credentials, param2:Function, param3:ILogger, param4:IEntityDef, param5:int, param6:int)
      {
         this.unit = param4;
         this.variation = param5;
         super(PATH + param1.urlCred + "/" + param4.id + "/" + param5 + "/" + param6,HttpRequestMethod.POST,body,param2,param3);
         resendOnFail = true;
         resendOnFailDelayMs = 1000;
      }
      
      override protected function handleJsonResponseProcessing() : void
      {
         consumedTxn = true;
         if(success)
         {
            this.unit.appearanceIndex = this.variation;
         }
      }
   }
}
