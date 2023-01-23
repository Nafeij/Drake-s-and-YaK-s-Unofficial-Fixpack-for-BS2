package engine.battle.fsm
{
   public class BattleFinishedData
   {
       
      
      public var victoriousTeam:String;
      
      private var _total_renown:int;
      
      public var rewards:Vector.<BattleRewardData>;
      
      public function BattleFinishedData()
      {
         this.rewards = new Vector.<BattleRewardData>();
         super();
         this.victoriousTeam = "";
      }
      
      public function cleanup() : void
      {
         this.rewards = null;
      }
      
      public function setupTeams(param1:int) : void
      {
         var _loc2_:int = this.rewards.length;
         while(_loc2_ < param1)
         {
            this.rewards.push(new BattleRewardData());
            _loc2_++;
         }
      }
      
      public function fromJson(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:BattleRewardData = null;
         this.victoriousTeam = param1.victoriousTeam;
         this.total_renown = param1.total_renown;
         for each(_loc2_ in param1.rewards)
         {
            _loc3_ = new BattleRewardData();
            _loc3_.parseJson(_loc2_);
            this.rewards.push(_loc3_);
         }
      }
      
      public function getAward(param1:int, param2:BattleRenownAwardType) : int
      {
         return this.rewards[param1].getAward(param2);
      }
      
      public function getReward(param1:int) : BattleRewardData
      {
         if(param1 >= 0 && param1 < this.rewards.length)
         {
            return this.rewards[param1];
         }
         return null;
      }
      
      public function addRenownAward(param1:int, param2:BattleRenownAwardType, param3:int) : void
      {
         var _loc4_:BattleRewardData = this.rewards[param1];
         if(_loc4_)
         {
            _loc4_.addRenownAward(param2,param3);
         }
      }
      
      public function mergeAchievements(param1:BattleFinishedData) : void
      {
         var _loc2_:int = 0;
         if(this.rewards.length == param1.rewards.length)
         {
            _loc2_ = 0;
            while(_loc2_ < this.rewards.length)
            {
               this.rewards[_loc2_].mergeAchievements(param1.rewards[_loc2_]);
               _loc2_++;
            }
         }
      }
      
      public function get total_renown() : int
      {
         return this._total_renown;
      }
      
      public function set total_renown(param1:int) : void
      {
         this._total_renown = param1;
      }
   }
}
