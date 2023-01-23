package tbs.srv.battle.data.client
{
   import engine.core.logging.ILogger;
   
   public class BattleKilledData extends BaseBattleTurnData
   {
       
      
      public var killer:String;
      
      public var killedparty:int;
      
      public var killerparty:int;
      
      public function BattleKilledData()
      {
         super();
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         super.parseJson(param1,param2);
         this.killer = param1.killer;
         this.killedparty = param1.killedparty;
         this.killerparty = param1.killerparty;
      }
   }
}
