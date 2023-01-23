package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class LobbyPartyData extends LobbyData
   {
       
      
      public var party:Array;
      
      public function LobbyPartyData()
      {
         this.party = [];
         super();
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         super.parseJson(param1,param2);
         this.party = param1.party;
      }
   }
}
