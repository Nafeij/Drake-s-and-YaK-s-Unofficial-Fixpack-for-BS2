package tbs.srv.battle.data.client
{
   import engine.core.logging.ILogger;
   import tbs.srv.battle.data.BattlePartyData;
   
   public class BattleCreateData extends BaseBattleTurnData
   {
       
      
      public var parties:Vector.<BattlePartyData>;
      
      public var scene:String;
      
      public var friendly:Boolean;
      
      public function BattleCreateData()
      {
         this.parties = new Vector.<BattlePartyData>();
         super();
      }
      
      public function setupBattleCreateData(param1:String) : BattleCreateData
      {
         this.battle_id = param1;
         return this;
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:Object = null;
         var _loc4_:BattlePartyData = null;
         super.parseJson(param1,param2);
         this.scene = param1.scene;
         this.friendly = param1.friendly;
         for each(_loc3_ in param1.parties)
         {
            _loc4_ = new BattlePartyData();
            _loc4_.parseJson(_loc3_,param2);
            this.parties.push(_loc4_);
         }
      }
   }
}
