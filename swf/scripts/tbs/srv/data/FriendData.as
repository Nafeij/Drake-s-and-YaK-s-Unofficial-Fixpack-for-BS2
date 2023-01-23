package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class FriendData
   {
       
      
      public var id:int;
      
      public var display_name:String;
      
      public var location:String;
      
      public var online:Boolean;
      
      public var steam_id:String;
      
      public var avatar128:String;
      
      public var avatar64:String;
      
      public var avatar32:String;
      
      public var wins:int;
      
      public var losses:int;
      
      public var last_battle_time:uint;
      
      public function FriendData()
      {
         super();
      }
      
      public function toString() : String
      {
         return "FriendData: [id=" + this.id + ", display_name=" + this.display_name + ", location=" + this.location + ", online=" + this.online + ", record=" + this.wins + ":" + this.losses + "]";
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.id = param1.id;
         this.display_name = param1.display_name;
         this.location = param1.location;
         this.online = param1.online;
         this.steam_id = param1.steam_id;
         this.avatar128 = param1.avatar128;
         this.avatar64 = param1.avatar64;
         this.avatar32 = param1.avatar32;
         this.wins = param1.wins;
         this.losses = param1.losses;
         this.last_battle_time = param1.last_battle_time;
      }
   }
}
