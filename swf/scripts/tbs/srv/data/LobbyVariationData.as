package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class LobbyVariationData extends LobbyData
   {
       
      
      public var unit_id:String;
      
      public var variation:int;
      
      public function LobbyVariationData()
      {
         super();
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         super.parseJson(param1,param2);
         this.unit_id = param1.unit_id;
         this.variation = param1.variation;
      }
   }
}
