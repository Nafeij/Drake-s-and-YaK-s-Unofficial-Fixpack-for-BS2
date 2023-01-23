package engine.session
{
   import flash.events.EventDispatcher;
   
   public class Alert extends EventDispatcher
   {
      
      public static const RESPONSE_OK:String = "OK";
      
      public static const RESPONSE_CANCEL:String = "CANCEL";
      
      public static const RESPONSE_EXIT:String = "EXIT";
       
      
      public var sender_display_name:String;
      
      public var sender_id:int;
      
      public var msg:String;
      
      public var arrival:int;
      
      public var _response:String;
      
      public var data;
      
      public var okMsg:String;
      
      public var okColor;
      
      public var cancelMsg:String;
      
      public var orientation:AlertOrientationType;
      
      public var style:AlertStyleType;
      
      public var removeOnResponse:Boolean = true;
      
      public function Alert()
      {
         super();
      }
      
      public static function create(param1:int, param2:String, param3:String, param4:String, param5:String, param6:AlertOrientationType, param7:AlertStyleType, param8:*) : Alert
      {
         var _loc9_:Alert = new Alert();
         _loc9_.sender_id = param1;
         _loc9_.data = param8;
         _loc9_.sender_display_name = param2;
         _loc9_.msg = param3;
         _loc9_.cancelMsg = param5;
         _loc9_.okMsg = param4;
         _loc9_.orientation = param6;
         _loc9_.style = param7;
         return _loc9_;
      }
      
      public function get response() : String
      {
         return this._response;
      }
      
      public function set response(param1:String) : void
      {
         if(this._response == param1)
         {
         }
         this._response = param1;
         this.notifyChanged();
         dispatchEvent(new AlertEvent(AlertEvent.ALERT_RESPONSE,this));
      }
      
      public function notifyChanged() : void
      {
         dispatchEvent(new AlertEvent(AlertEvent.ALERT_CHANGED,this));
      }
   }
}
