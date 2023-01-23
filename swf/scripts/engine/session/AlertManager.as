package engine.session
{
   import engine.core.logging.ILogger;
   import flash.events.EventDispatcher;
   
   public class AlertManager extends EventDispatcher
   {
       
      
      public var alerts:Vector.<Alert>;
      
      public var logger:ILogger;
      
      private var _enabled:Boolean = true;
      
      public function AlertManager(param1:ILogger)
      {
         this.alerts = new Vector.<Alert>();
         super();
         this.logger = param1;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
            return;
         }
         this._enabled = param1;
         dispatchEvent(new AlertEvent(AlertEvent.ALERTS_ENABLED,null));
      }
      
      public function addAlert(param1:Alert) : void
      {
         this.alerts.push(param1);
         param1.addEventListener(AlertEvent.ALERT_RESPONSE,this.alertResponseHandler);
         dispatchEvent(new AlertEvent(AlertEvent.ALERT_ADDED,param1));
      }
      
      public function removeAlert(param1:Alert) : void
      {
         var _loc2_:int = this.alerts.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.alerts.splice(_loc2_,1);
            param1.removeEventListener(AlertEvent.ALERT_RESPONSE,this.alertResponseHandler);
            dispatchEvent(new AlertEvent(AlertEvent.ALERT_REMOVED,param1));
         }
      }
      
      private function alertResponseHandler(param1:AlertEvent) : void
      {
         dispatchEvent(new AlertEvent(param1.type,param1.alert));
         if(param1.alert.removeOnResponse)
         {
            if(param1.alert.response)
            {
               this.removeAlert(param1.alert);
            }
         }
      }
      
      public function getAlertByStyle(param1:AlertStyleType) : Alert
      {
         var _loc2_:Alert = null;
         for each(_loc2_ in this.alerts)
         {
            if(_loc2_.style == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
   }
}
