package engine.path
{
   public class PathStatus
   {
      
      public static const WAITING:PathStatus = new PathStatus("WAITING");
      
      public static const WORKING:PathStatus = new PathStatus("WORKING");
      
      public static const FAILED:PathStatus = new PathStatus("FAILED");
      
      public static const COMPLETE:PathStatus = new PathStatus("COMPLETE");
      
      public static const TERMINATE:PathStatus = new PathStatus("TERMINATE");
       
      
      public var name:String;
      
      public function PathStatus(param1:String)
      {
         super();
         this.name = param1;
      }
   }
}
