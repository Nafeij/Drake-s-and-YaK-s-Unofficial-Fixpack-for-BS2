package tbs.srv.battle.data
{
   import engine.core.logging.ILogger;
   
   public class BattlePartyData
   {
       
      
      public var user:int;
      
      public var team:String;
      
      public var display_name:String;
      
      public var defs:Array;
      
      public var match_handle:int;
      
      public var timer:int;
      
      public var party_index:int;
      
      public function BattlePartyData()
      {
         this.defs = [];
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.user = param1.user;
         this.team = param1.team;
         this.display_name = param1.display_name;
         this.defs = param1.defs;
         this.match_handle = param1.match_handle;
         this.timer = param1.timer;
         this.party_index = param1.party_index;
      }
   }
}
