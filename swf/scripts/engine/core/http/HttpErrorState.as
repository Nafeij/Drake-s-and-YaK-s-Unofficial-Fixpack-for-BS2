package engine.core.http
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getTimer;
   
   public class HttpErrorState extends EventDispatcher
   {
      
      public static const EVENT_ERROR_STATE:String = "HttpErrorState.EVENT_ERROR_STATE";
      
      private static const PROBATION_TIME:int = 5000;
      
      private static const ERROR_TIME:int = 5000;
       
      
      private var _probation:Boolean;
      
      private var _error:Boolean;
      
      private var probationStartTime:int;
      
      private var lastErrorTime:int;
      
      private var logger:ILogger;
      
      public function HttpErrorState(param1:ILogger)
      {
         super();
         this.logger = param1;
      }
      
      public function noticeError() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = getTimer();
         this.lastErrorTime = _loc1_;
         if(this.probation)
         {
            _loc2_ = _loc1_ - this.probationStartTime;
            if(_loc2_ > PROBATION_TIME)
            {
               this.error = true;
            }
            else
            {
               this.logger.debug("HttpErrorState probationing");
            }
         }
         else if(this.error)
         {
            this.logger.debug("HttpErrorState wallowing");
         }
         else
         {
            this.probation = true;
         }
      }
      
      public function noticeOk() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = getTimer();
         if(this.probation)
         {
            this.probation = false;
         }
         else if(this.error)
         {
            _loc2_ = _loc1_ - this.lastErrorTime;
            if(_loc2_ > ERROR_TIME)
            {
               this.error = false;
            }
            else
            {
               this.logger.debug("HttpErrorState recovering");
            }
         }
      }
      
      public function get probation() : Boolean
      {
         return this._probation;
      }
      
      public function set probation(param1:Boolean) : void
      {
         if(this._probation == param1)
         {
            return;
         }
         this._probation = param1;
         if(this._probation)
         {
            this.logger.debug("HttpErrorState ENTER probation");
            this.probationStartTime = this.lastErrorTime;
         }
         else if(!this._error)
         {
            this.logger.debug("HttpErrorState EXIT probation");
         }
      }
      
      public function get error() : Boolean
      {
         return this._error;
      }
      
      public function set error(param1:Boolean) : void
      {
         if(this._error == param1)
         {
            return;
         }
         this._error = param1;
         if(this._error)
         {
            this.logger.info("HttpErrorState ENTER NETWORK ERROR");
            this.probation = false;
         }
         else
         {
            this.logger.info("HttpErrorState EXIT NETWORK ERROR");
         }
         dispatchEvent(new Event(EVENT_ERROR_STATE));
      }
   }
}
