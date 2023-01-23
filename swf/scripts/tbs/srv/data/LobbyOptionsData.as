package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class LobbyOptionsData extends LobbyData
   {
       
      
      public var timer:int = 30;
      
      public var scene:String = null;
      
      public var display_name:String;
      
      public var msg:String = "LobbyOptionsData.msg DEFAULT";
      
      public function LobbyOptionsData()
      {
         super();
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         super.parseJson(param1,param2);
         this.timer = param1.timer;
         this.scene = param1.scene;
         this.display_name = param1.display_name;
         this.msg = param1.msg;
      }
   }
}
