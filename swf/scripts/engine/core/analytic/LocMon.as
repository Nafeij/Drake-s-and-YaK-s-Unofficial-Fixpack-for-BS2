package engine.core.analytic
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
   public class LocMon
   {
      
      public static var av:String;
      
      public static var cid:String;
      
      public static var logger:ILogger;
       
      
      public function LocMon()
      {
         super();
      }
      
      public static function init(param1:ILogger, param2:String, param3:String) : void
      {
         LocMon.logger = param1;
         LocMon.cid = escape(param3);
         LocMon.av = escape(param2);
      }
      
      public static function notify(param1:int, param2:int) : void
      {
      }
      
      private static function send(param1:URLVariables) : void
      {
         var m_loader:SmartUrlLoader_LocMon = null;
         var uv:URLVariables = param1;
         var url:String = "http://tbs-locmon.stoicstudio.com/notify";
         var ul:URLRequest = new URLRequest(url);
         ul.method = URLRequestMethod.POST;
         ul.data = uv;
         ul.contentType = "application/x-www-form-urlencoded";
         m_loader = new SmartUrlLoader_LocMon();
         m_loader.addEventListener(Event.COMPLETE,onUrlLoadComplete);
         m_loader.addEventListener(IOErrorEvent.IO_ERROR,onUrlIoError);
         try
         {
            m_loader.load(ul);
         }
         catch(error:Error)
         {
            if(logger)
            {
               logger.error("Ga fail: " + m_loader.debugString);
               logger.error(error.getStackTrace());
            }
         }
      }
      
      protected static function onUrlIoError(param1:IOErrorEvent) : void
      {
         var _loc2_:SmartUrlLoader_LocMon = param1.target as SmartUrlLoader_LocMon;
         if(Boolean(logger) && logger.isDebugEnabled)
         {
            logger.debug("Ga onUrlIoError " + _loc2_.debugString);
         }
      }
      
      protected static function onUrlLoadComplete(param1:Event) : void
      {
         var _loc2_:SmartUrlLoader_LocMon = param1.target as SmartUrlLoader_LocMon;
      }
   }
}

import flash.net.URLLoader;
import flash.net.URLRequest;

class SmartUrlLoader_LocMon extends URLLoader
{
    
   
   public var req:URLRequest;
   
   public function SmartUrlLoader_LocMon(param1:URLRequest = null)
   {
      super(param1);
      this.req = param1;
   }
   
   override public function load(param1:URLRequest) : void
   {
      this.req = param1;
      super.load(param1);
   }
   
   public function get debugString() : String
   {
      return this.req.url + " var=" + this.debugStringVars;
   }
   
   public function get debugStringVars() : String
   {
      var _loc2_:String = null;
      var _loc3_:String = null;
      var _loc1_:* = "";
      if(this.req.data)
      {
         for(_loc2_ in this.req.data)
         {
            _loc3_ = String(this.req.data[_loc2_]);
            if(_loc1_)
            {
               _loc1_ += ", ";
            }
            _loc1_ += _loc2_ + "=" + _loc3_;
         }
      }
      return _loc1_;
   }
}
