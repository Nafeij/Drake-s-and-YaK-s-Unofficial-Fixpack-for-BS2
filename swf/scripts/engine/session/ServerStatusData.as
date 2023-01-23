package engine.session
{
   public class ServerStatusData
   {
       
      
      public var session_count:int;
      
      public var msg:String;
      
      public function ServerStatusData()
      {
         super();
      }
      
      public static function parse(param1:Object) : ServerStatusData
      {
         var _loc2_:ServerStatusData = new ServerStatusData();
         _loc2_.session_count = param1.session_count;
         return _loc2_;
      }
      
      public function toString() : String
      {
         return "[" + this.session_count + ", " + this.msg + "]";
      }
   }
}
