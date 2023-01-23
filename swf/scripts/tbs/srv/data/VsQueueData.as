package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class VsQueueData
   {
       
      
      public var account_id:int;
      
      public var type:String;
      
      public var powers:Array;
      
      public var counts:Array;
      
      public function VsQueueData()
      {
         super();
      }
      
      public function toString() : String
      {
         return "VsQueueData: [type=" + this.type + "]";
      }
      
      public function parseJson(param1:Object, param2:ILogger) : VsQueueData
      {
         this.account_id = param1.account_id;
         this.type = param1.type;
         this.powers = param1.powers;
         this.counts = param1.counts;
         return this;
      }
   }
}
