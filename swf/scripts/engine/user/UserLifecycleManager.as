package engine.user
{
   import engine.core.logging.Log;
   import engine.input.InputDeviceEvent;
   import engine.saga.Saga;
   import flash.events.EventDispatcher;
   
   public class UserLifecycleManager extends EventDispatcher
   {
      
      private static var instance:UserLifecycleManager;
       
      
      public var userName:String;
      
      public var userNeedsTranslation:Boolean;
      
      public var userAlwaysValid:Boolean = true;
      
      private var saga:Saga;
      
      private var appBackgroundPauseToken:Object;
      
      private var controllerLostPauseToken:Object;
      
      public var noUserWarningDisplayed:Boolean;
      
      public function UserLifecycleManager()
      {
         super();
         this.appBackgroundPauseToken = new Object();
         this.controllerLostPauseToken = new Object();
      }
      
      public static function Instance() : UserLifecycleManager
      {
         if(instance == null)
         {
            instance = new UserLifecycleManager();
         }
         return instance;
      }
      
      public function Initialize(param1:Saga) : void
      {
         this.saga = param1;
      }
      
      public function isUserLoggedIn() : Boolean
      {
         if(this.userAlwaysValid)
         {
            return true;
         }
         if(!this.userName || this.userName == "xbl_no_user")
         {
            return false;
         }
         return true;
      }
      
      private function updateUserName(param1:String) : void
      {
         Log.getLogger("TBS-0").info("UserLifecycleManager: update username to " + param1 + " from " + this.userName);
         if(Boolean(this.userName) && this.userName != param1)
         {
            this.saga.saveManager.resetForNewUser();
         }
         if(!param1)
         {
            this.userNeedsTranslation = true;
            this.userName = "xbl_no_user";
         }
         else
         {
            this.userNeedsTranslation = false;
            this.userName = param1;
         }
      }
      
      public function userChanged(param1:String, param2:Boolean) : void
      {
         this.updateUserName(param1);
         dispatchEvent(new UserEvent(UserEvent.USER_CHANGED,false,false,this.userName,param2));
      }
      
      public function establishInitialUser(param1:String, param2:Boolean) : void
      {
         this.updateUserName(param1);
         dispatchEvent(new UserEvent(UserEvent.INITIAL_USER_ESTABLISHED,false,false,this.userName,param2));
      }
      
      public function controllerLost(param1:Number) : void
      {
         if(this.saga)
         {
            this.saga.pause(this.controllerLostPauseToken);
         }
         dispatchEvent(new InputDeviceEvent(InputDeviceEvent.CONTROLLER_LOST));
      }
      
      public function controllerReestablished(param1:Number) : void
      {
         if(this.saga)
         {
            this.saga.unpause(this.controllerLostPauseToken);
         }
         dispatchEvent(new InputDeviceEvent(InputDeviceEvent.CONTROLLER_REESTABLISHED));
      }
      
      public function accountPickerOpened() : void
      {
         Log.getLogger("TBS-0").info("App acct picker open");
         dispatchEvent(new UserEvent(UserEvent.ACCOUNT_PICKER_OPENED));
      }
      
      public function accountPickerClosed() : void
      {
         Log.getLogger("TBS-0").info("App acct picker closed without user change");
         dispatchEvent(new UserEvent(UserEvent.ACCOUNT_PICKER_CLOSED));
      }
      
      public function applicationEnteredBackground() : void
      {
         Log.getLogger("TBS-0").info("App entered background");
         if(this.saga)
         {
            this.saga.pause(this.appBackgroundPauseToken);
         }
      }
      
      public function applicationEnteredForeground() : void
      {
         Log.getLogger("TBS-0").info("App entered foreground");
         if(this.saga)
         {
            this.saga.unpause(this.appBackgroundPauseToken);
         }
      }
      
      public function activeUserLost() : void
      {
         this.updateUserName(null);
         dispatchEvent(new UserEvent(UserEvent.ACTIVE_USER_LOST,false,false,this.userName,false));
      }
   }
}
