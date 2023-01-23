package engine.automator
{
   import engine.core.logging.ILogger;
   import flash.utils.getTimer;
   
   public class EngineAutomator
   {
      
      public static var instance:EngineAutomator;
      
      public static var HANG_TIMEOUT_MS:int = 6000;
      
      public static var TERMINATE_ON_FAILURE:Boolean = true;
       
      
      private var _notifications:Vector.<String>;
      
      private var _oldNotifications:Vector.<String>;
      
      public var _program:AutomatedProgram;
      
      public var _executor:AutomatedProgramExecutor;
      
      public var context:AutomatedProgramContext;
      
      public var logger:ILogger;
      
      private var lastNext:int = 0;
      
      private var exiting:Boolean;
      
      public function EngineAutomator(param1:AutomatedProgramContext, param2:ILogger)
      {
         this._notifications = new Vector.<String>();
         this._oldNotifications = new Vector.<String>();
         super();
         this.logger = param2;
         this.context = param1;
      }
      
      public static function notify(param1:String) : void
      {
         if(instance)
         {
            instance.addNotification(param1);
         }
      }
      
      public static function init(param1:AutomatedProgramContext, param2:ILogger) : void
      {
         if(!instance)
         {
            instance = new EngineAutomator(param1,param2);
         }
      }
      
      public static function update() : void
      {
         if(instance)
         {
            instance.updateEngineAutomator();
         }
      }
      
      public function get program() : AutomatedProgram
      {
         return this._program;
      }
      
      public function runProgramScript(param1:AutomatedProgram) : void
      {
         this.logger.i("AUTO","EngineAutomator.runProgramScript ptof=" + EngineAutomator.TERMINATE_ON_FAILURE);
         this.lastNext = getTimer();
         this._program = param1;
         this._executor = new AutomatedProgramExecutor(this._program);
      }
      
      private function addNotification(param1:String) : void
      {
         this.logger.i("AUTO","NOTIFICATION ADDED " + param1);
         this._notifications.push(param1);
         this._oldNotifications.push(param1);
      }
      
      private function consumeNotifications() : Boolean
      {
         var _loc2_:String = null;
         if(!this._executor || !this._executor.canConsumeNotifications)
         {
            return false;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._notifications.length)
         {
            if(!this._executor.canConsumeNotifications)
            {
               break;
            }
            _loc2_ = this._notifications[_loc1_];
            if(this._executor.consumeNotification(_loc2_))
            {
               this.logger.i("AUTO","NOTIFICATION CONSUMED " + _loc2_);
               this._notifications.splice(_loc1_,1);
            }
            else
            {
               _loc1_++;
            }
         }
         return true;
      }
      
      private function updateEngineAutomator() : void
      {
         var _loc3_:Vector.<String> = null;
         if(!this.context)
         {
            return;
         }
         if(this.exiting)
         {
            return;
         }
         if(!this._executor)
         {
            return;
         }
         this.consumeNotifications();
         if(this._executor.checkNext())
         {
            this.lastNext = getTimer();
            this._executor.execute();
            this.consumeNotifications();
            this._notifications.splice(0,this._notifications.length);
            _loc3_ = this._notifications;
            if(this._oldNotifications.length)
            {
               this.logger.i("AUTO","NOTIFICATION KEEPING " + this._oldNotifications.join(","));
            }
            this._notifications = this._oldNotifications;
            this._oldNotifications = _loc3_;
            return;
         }
         var _loc1_:int = getTimer();
         var _loc2_:int = _loc1_ - this.lastNext;
         if(_loc2_ > HANG_TIMEOUT_MS)
         {
            this.logger.e("AUTO","HANG_TIMEOUT_MS exceeded " + _loc2_);
            this.logger.e("AUTO","hung at line " + this._executor._line);
            this.exiting = true;
            this.context.exit(false);
         }
      }
      
      public function stop() : void
      {
         if(this._executor)
         {
            this._executor = null;
            this._program = null;
            this.logger.i("AUTO","Program stopped");
         }
         else
         {
            this.logger.i("AUTO","No program to stop");
         }
      }
      
      public function list() : void
      {
         if(this._executor)
         {
            this._executor.list();
         }
      }
      
      public function where() : void
      {
         if(this._executor)
         {
            this._executor.where();
         }
      }
   }
}
