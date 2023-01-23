package tbs.srv.data
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   
   public class LeaderboardData
   {
       
      
      public var leaderboard_type:String;
      
      public var tourney_id:int;
      
      public var tourney_name:String;
      
      public var entries:Vector.<LeaderboardEntryData>;
      
      public var user_display_name:String;
      
      public var user_value:Number = 0;
      
      public var user_rank:int;
      
      public var user_account_id:String;
      
      public var global:Boolean;
      
      public function LeaderboardData()
      {
         this.entries = new Vector.<LeaderboardEntryData>();
         super();
      }
      
      public function addEntry(param1:String, param2:Number, param3:String = "") : void
      {
         this.entries.push(new LeaderboardEntryData(param1,param2,param3));
      }
      
      public function entryBelongsToUser(param1:LeaderboardEntryData) : Boolean
      {
         if(param1.account_id)
         {
            return param1.account_id == this.user_account_id;
         }
         return param1.display_name == this.user_display_name;
      }
      
      public function updateUserEntry() : void
      {
         if(this.user_rank <= 0)
         {
            return;
         }
         var _loc1_:int = -1;
         var _loc2_:int = this.entries.length - 1;
         while(_loc2_ >= 0)
         {
            if(this.entryBelongsToUser(this.entries[_loc2_]))
            {
               _loc1_ = _loc2_;
               this.entries.splice(_loc2_,1);
            }
            _loc2_--;
         }
         if(this.global)
         {
            _loc1_ = Math.min(this.user_rank - 1,this.entries.length);
         }
         if(_loc1_ > -1)
         {
            this.entries.splice(_loc1_,0,new LeaderboardEntryData(this.user_display_name,this.user_value,this.user_account_id));
         }
      }
      
      public function toString() : String
      {
         return this.leaderboard_type + " global=" + this.global;
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.leaderboard_type = param1.leaderboard_type;
         var _loc3_:int = Math.min(param1.display_names.length,param1.values.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            this.addEntry(param1.display_names[_loc4_],param1.values[_loc4_]);
            _loc4_++;
         }
         this.user_display_name = param1.user_display_name;
         this.user_value = param1.user_value;
         this.user_rank = param1.user_rank;
         this.tourney_id = param1.tourney_id;
         this.tourney_name = param1.tourney_name;
      }
      
      public function getDebugString() : String
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:String = null;
         var _loc1_:* = "";
         var _loc2_:String = "    ";
         _loc1_ += _loc2_ + "LEADERBOARD: " + this.leaderboard_type + (this.global ? " GLOBAL" : " FRIENDS") + "\n";
         _loc1_ += _loc2_ + "PLAYER:      " + this.user_display_name + ": " + this.user_value + " @ " + this.user_rank + "\n";
         while(_loc3_ < this.entries.length)
         {
            _loc4_ = this.entries[_loc3_].value;
            _loc5_ = this.entries[_loc3_].display_name;
            _loc1_ += _loc2_ + _loc2_ + StringUtil.padLeft(_loc3_.toString()," ",2) + ".  ";
            _loc1_ += StringUtil.padLeft(_loc4_.toString()," ",5) + "   ";
            _loc1_ += _loc5_;
            if(this.entries[_loc3_].account_id)
            {
               _loc1_ += " (" + this.entries[_loc3_].account_id + ")";
            }
            _loc1_ += "\n";
            _loc3_++;
         }
         return _loc1_;
      }
   }
}
