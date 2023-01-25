package engine.battle.fsm
{
   import engine.core.util.Enum;
   import flash.utils.Dictionary;
   
   public class BattleRewardData
   {
       
      
      public var awards:Dictionary;
      
      public var achievements:Dictionary;
      
      public var items:Vector.<String>;
      
      private var _total_renown:int;
      
      public function BattleRewardData()
      {
         this.awards = new Dictionary();
         this.achievements = new Dictionary();
         this.items = new Vector.<String>();
         super();
      }
      
      public function parseJson(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:BattleRenownAwardType = null;
         if(param1 == null)
         {
            return;
         }
         for(_loc2_ in param1.awards)
         {
            _loc3_ = Enum.parse(BattleRenownAwardType,_loc2_) as BattleRenownAwardType;
            this.awards[_loc3_] = param1.awards[_loc2_];
         }
         for(_loc2_ in param1.achievements)
         {
            this.achievements[_loc2_] = param1.achievements[_loc2_];
         }
         this.total_renown = param1.total_renown;
      }
      
      public function getAward(param1:BattleRenownAwardType) : int
      {
         return this.awards[param1];
      }
      
      public function getAchievementRenown(param1:String) : int
      {
         return this.achievements[param1];
      }
      
      public function mergeAchievements(param1:BattleRewardData) : void
      {
         var _loc2_:Object = null;
         for(_loc2_ in param1.achievements)
         {
            this.achievements[_loc2_] = param1.achievements[_loc2_];
         }
      }
      
      public function addRenownAward(param1:BattleRenownAwardType, param2:int) : void
      {
         var _loc3_:int = int(this.awards[param1]);
         this.awards[param1] = _loc3_ + param2;
         this._total_renown += param2;
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
