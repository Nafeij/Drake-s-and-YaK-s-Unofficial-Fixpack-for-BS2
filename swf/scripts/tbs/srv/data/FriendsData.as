package tbs.srv.data
{
   import engine.core.logging.ILogger;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class FriendsData extends EventDispatcher
   {
       
      
      public var friends:Vector.<FriendData>;
      
      public var byId:Dictionary;
      
      private var logger:ILogger;
      
      public var initialized:Boolean;
      
      public function FriendsData(param1:ILogger)
      {
         this.friends = new Vector.<FriendData>();
         this.byId = new Dictionary();
         super();
         this.logger = param1;
      }
      
      public function addFriendData(param1:FriendData, param2:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc3_:FriendData = this.byId[param1.id];
         if(_loc3_)
         {
            this.byId[param1.id] = param1;
            _loc4_ = this.friends.indexOf(param1);
            this.friends[_loc4_] = param1;
            if(!param2)
            {
               dispatchEvent(new FriendsDataEvent(FriendsDataEvent.CHANGED,param1));
            }
         }
         else
         {
            this.byId[param1.id] = param1;
            this.friends.push(param1);
         }
      }
      
      public function updateLocation(param1:GameLocationData) : void
      {
         var _loc2_:FriendData = this.byId[param1.account_id];
         if(_loc2_)
         {
            if(_loc2_.location != param1.location || !_loc2_.online)
            {
               _loc2_.location = param1.location;
               _loc2_.online = true;
               dispatchEvent(new FriendsDataEvent(FriendsDataEvent.CHANGED,_loc2_));
            }
         }
      }
      
      public function updateOnline(param1:FriendOnlineData) : FriendData
      {
         return this.setOnline(param1.account_id,param1.online);
      }
      
      public function setOnline(param1:int, param2:Boolean) : FriendData
      {
         var _loc3_:FriendData = this.byId[param1];
         if(_loc3_)
         {
            if(_loc3_.online != param2)
            {
               _loc3_.online = param2;
               dispatchEvent(new FriendsDataEvent(FriendsDataEvent.CHANGED,_loc3_));
            }
         }
         return _loc3_;
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc4_:Object = null;
         var _loc5_:FriendData = null;
         var _loc3_:Boolean = this.initialized;
         this.initialized = true;
         for each(_loc4_ in param1.friends)
         {
            _loc5_ = this.byId[_loc4_.id];
            if(!_loc5_)
            {
               _loc5_ = new FriendData();
            }
            _loc5_.parseJson(_loc4_,param2);
            this.addFriendData(_loc5_,!_loc3_);
         }
         if(!_loc3_)
         {
            dispatchEvent(new FriendsDataEvent(FriendsDataEvent.INIT,null));
         }
      }
   }
}
