package com.stoicstudio.platform
{
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class UrlPlatformShare
   {
       
      
      private var url:String;
      
      public function UrlPlatformShare(param1:String)
      {
         super();
         if(!param1)
         {
            throw new ArgumentError("Don\'t do this");
         }
         this.url = param1;
      }
      
      public function showAppShare() : void
      {
         var _loc1_:URLRequest = null;
         if(this.url)
         {
            _loc1_ = new URLRequest(this.url);
            navigateToURL(_loc1_);
         }
      }
   }
}
