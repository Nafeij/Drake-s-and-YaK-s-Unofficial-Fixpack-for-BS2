package game.session.actions
{
   import flash.system.Capabilities;
   
   public class ClientConfigData
   {
       
      
      public var os:String;
      
      public var os_language:String;
      
      public var client_language:String;
      
      public var screen_w:int;
      
      public var screen_h:int;
      
      public var screen_dpi:int;
      
      public function ClientConfigData(param1:String)
      {
         super();
         this.os = Capabilities.os;
         this.os_language = Capabilities.language;
         this.client_language = !!param1 ? param1 : "";
         this.screen_w = Capabilities.screenResolutionX;
         this.screen_h = Capabilities.screenResolutionY;
         this.screen_dpi = Capabilities.screenDPI;
      }
   }
}
