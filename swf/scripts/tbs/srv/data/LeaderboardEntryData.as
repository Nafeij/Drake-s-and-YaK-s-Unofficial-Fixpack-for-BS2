package tbs.srv.data
{
   public class LeaderboardEntryData
   {
       
      
      public var display_name:String;
      
      public var value:Number;
      
      public var account_id:String;
      
      public function LeaderboardEntryData(param1:String, param2:Number, param3:String = "")
      {
         super();
         this.display_name = param1;
         this.value = param2;
         this.account_id = param3;
      }
   }
}
