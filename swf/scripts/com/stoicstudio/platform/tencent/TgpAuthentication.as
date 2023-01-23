package com.stoicstudio.platform.tencent
{
   import air.tencent.ane.TencentAne;
   import engine.session.IAuthentication;
   import flash.events.Event;
   
   public class TgpAuthentication implements IAuthentication
   {
       
      
      private var tencent:TencentAne;
      
      private var railAuthTicket:String = null;
      
      private var authCallback:Function;
      
      public function TgpAuthentication(param1:TencentAne)
      {
         super();
         this.tencent = param1;
      }
      
      public function requestAuthSessionTicket(param1:Function) : String
      {
         if(param1 != null)
         {
            this.authCallback = param1;
            this.tencent.addEventListener("railAuthTicket",this.authTicketHandler);
         }
         this.railAuthTicket = this.tencent.TencentAPI_RequestSessionTicket();
         return null;
      }
      
      private function authTicketHandler(param1:Event) : void
      {
         var _loc2_:Function = null;
         this.tencent.removeEventListener("railAuthTicket",this.authTicketHandler);
         if(this.railAuthTicket != null)
         {
            _loc2_ = this.authCallback;
            this.authCallback = null;
            _loc2_(this.railAuthTicket);
         }
      }
      
      public function getUserID() : String
      {
         return this.tencent.TencentAPI_GetRailID();
      }
      
      public function getAccountID(param1:String) : int
      {
         return 0;
      }
      
      public function getDisplayName() : String
      {
         this.tencent.logger.i("TECNENT","Getting display name");
         var _loc1_:String = this.tencent.TencentAPI_GetRailPlayerName();
         this.tencent.logger.i("TENCENT","UserName: " + _loc1_);
         return !!_loc1_ ? _loc1_ : "unknown_user";
      }
      
      public function getUserLanguage() : String
      {
         return this.tencent.TencentAPI_GetPlatformLanguageCode();
      }
      
      public function get enabled() : Boolean
      {
         var _loc1_:Boolean = Boolean(this.tencent) && this.tencent.enabled;
         return Boolean(this.tencent) && this.tencent.enabled;
      }
      
      public function get initialized() : Boolean
      {
         var _loc1_:Boolean = Boolean(this.tencent) && this.tencent.initialized;
         return Boolean(this.tencent) && this.tencent.initialized;
      }
   }
}
