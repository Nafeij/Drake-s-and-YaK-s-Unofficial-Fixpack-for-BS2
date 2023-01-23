package engine.core.analytic
{
   import engine.core.util.AppInfo;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   
   public class SteamDataSuite
   {
      
      public static const URL:String = "https://ldns.co/ca/";
      
      private static var TOKEN:String;
      
      private static var _appInfo:AppInfo;
       
      
      public function SteamDataSuite()
      {
         super();
      }
      
      public static function init(param1:AppInfo, param2:String) : void
      {
         _appInfo = param1;
         TOKEN = param2;
      }
      
      public static function firsttime() : void
      {
         if(!TOKEN)
         {
            return;
         }
         send("/?m=firstrun");
      }
      
      private static function send(param1:String) : void
      {
         var _loc3_:URLRequest = null;
         var _loc4_:URLLoader = null;
         if(!_appInfo)
         {
            return;
         }
         var _loc2_:String = URL + TOKEN + param1;
         if(HttpConfig.USE_APPINFO_FOR_HTTP)
         {
            _appInfo.httpRequestAsync("POST",_loc2_,null);
         }
         else
         {
            _loc3_ = new URLRequest(_loc2_);
            _loc3_.method = URLRequestMethod.POST;
            _loc4_ = new URLLoader();
            _loc4_.addEventListener(Event.COMPLETE,onUrlLoadComplete);
            _loc4_.addEventListener(IOErrorEvent.IO_ERROR,onUrlIoError);
            try
            {
               _loc4_.load(_loc3_);
            }
            catch(error:Error)
            {
            }
         }
      }
      
      protected static function onUrlIoError(param1:IOErrorEvent) : void
      {
         param1 = param1;
      }
      
      protected static function onUrlLoadComplete(param1:Event) : void
      {
         param1 = param1;
      }
   }
}
