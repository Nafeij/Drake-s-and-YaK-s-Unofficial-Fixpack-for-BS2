package tbs.srv.battle.data.client
{
   import engine.core.logging.ILogger;
   
   public class BattleSyncData extends BaseBattleTurnData
   {
       
      
      public var team:String;
      
      public var hash:int;
      
      public function BattleSyncData()
      {
         super();
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         super.parseJson(param1,param2);
         this.team = param1.team;
         this.hash = param1.hash;
      }
   }
}
