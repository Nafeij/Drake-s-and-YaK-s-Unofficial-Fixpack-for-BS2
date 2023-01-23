package tbs.srv.util
{
   import engine.core.logging.ILogger;
   
   public class AchievementProgressData
   {
       
      
      public var account_id:int;
      
      public var session_id:int;
      
      public var achievement_type:String;
      
      public var delta:int;
      
      public var total:int;
      
      public var handle:String;
      
      public var acquired:Vector.<String>;
      
      public function AchievementProgressData()
      {
         this.acquired = new Vector.<String>();
         super();
      }
      
      public function toString() : String
      {
         return "AchievementProgressData{account_id:" + this.account_id + ", session_id:" + this.session_id + ", achievement_type:\"" + this.achievement_type + "\", delta:" + this.delta + ", total:" + this.total + ", handle:\"" + this.handle + "\", acquired:[" + this.acquired + "]}";
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:String = null;
         this.account_id = param1.account_id;
         this.session_id = param1.session_id;
         this.achievement_type = param1.achievement_type;
         this.delta = param1.delta;
         this.total = param1.total;
         this.handle = param1.handle;
         for each(_loc3_ in param1.acquired)
         {
            this.acquired.push(_loc3_);
         }
      }
   }
}
