package tbs.srv.battle.data
{
   import engine.core.logging.ILogger;
   import engine.session.Chat;
   import engine.session.ChatMsg;
   import flash.utils.Dictionary;
   
   public class BattleNotification
   {
       
      
      public var start:Boolean;
      
      public var victor:String;
      
      public var teamMembers:Dictionary;
      
      public var numTeams:int;
      
      public function BattleNotification()
      {
         this.teamMembers = new Dictionary();
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc4_:String = null;
         var _loc5_:Vector.<String> = null;
         var _loc6_:String = null;
         this.start = param1.start;
         this.victor = param1.victor;
         var _loc3_:int = 0;
         for each(_loc4_ in param1.teams)
         {
            _loc5_ = new Vector.<String>();
            this.teamMembers[_loc4_] = _loc5_;
            for each(_loc6_ in param1.members[_loc3_])
            {
               _loc5_.push(_loc6_);
            }
            ++this.numTeams;
         }
      }
      
      public function generateChatMsg() : ChatMsg
      {
         var _loc1_:ChatMsg = new ChatMsg();
         _loc1_.room = Chat.GLOBAL_ROOM;
         _loc1_.user = 0;
         _loc1_.username = "BATTLE";
         if(this.start)
         {
            _loc1_.msg = this.generateStartString();
         }
         else if(this.victor)
         {
            _loc1_.msg = this.generateVictoryString();
         }
         return _loc1_;
      }
      
      private function generateStartString() : String
      {
         var _loc3_:* = null;
         var _loc4_:String = null;
         var _loc1_:String = "Starting ";
         var _loc2_:int = 0;
         for(_loc3_ in this.teamMembers)
         {
            _loc4_ = this.generateTeamString(_loc3_);
            if(_loc2_ > 0)
            {
               _loc1_ += " vs. " + _loc4_;
            }
            else
            {
               _loc1_ += _loc4_;
            }
            _loc2_++;
         }
         return _loc1_ + ".";
      }
      
      private function generateVictoryString() : String
      {
         var _loc4_:* = null;
         var _loc5_:String = null;
         var _loc1_:String = "";
         var _loc2_:String = this.generateTeamString(this.victor);
         _loc1_ += _loc2_ + " defeated ";
         var _loc3_:int = 0;
         for(_loc4_ in this.teamMembers)
         {
            if(_loc4_ != this.victor)
            {
               _loc5_ = this.generateTeamString(_loc4_);
               if(_loc3_ > 0)
               {
                  _loc1_ += " and " + _loc5_;
               }
               else
               {
                  _loc1_ += _loc5_;
               }
               _loc3_++;
            }
         }
         return _loc1_ + ".";
      }
      
      private function generateTeamString(param1:String) : String
      {
         var _loc5_:String = null;
         var _loc2_:String = "";
         var _loc3_:Vector.<String> = this.teamMembers[param1];
         if(!_loc3_)
         {
            return "ERROR";
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            if(_loc4_ == 0)
            {
               _loc2_ += _loc5_;
            }
            else if(_loc4_ == _loc3_.length - 1)
            {
               _loc2_ += ", and " + _loc5_;
            }
            else
            {
               _loc2_ += ", " + _loc5_;
            }
            _loc4_++;
         }
         return _loc2_;
      }
   }
}
