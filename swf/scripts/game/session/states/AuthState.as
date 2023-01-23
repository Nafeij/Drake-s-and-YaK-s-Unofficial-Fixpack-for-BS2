package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   import game.session.actions.AuthTxn;
   
   public class AuthState extends GameState
   {
      
      private static const LOCAL_BUILD_NUMBER:String = "locally";
       
      
      private var action:AuthTxn;
      
      public function AuthState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleCleanup() : void
      {
         if(this.action)
         {
            this.action.abort();
            this.action = null;
         }
      }
      
      override protected function handleEnteredState() : void
      {
         credentials.offline = false;
         communicator.connected = false;
         if(gameFsm.config.options.alwaysOffline)
         {
            phase = StatePhase.COMPLETED;
            return;
         }
         this.action = new AuthTxn(credentials,config.client_language,this.authCallbackHandler,config.logger);
         logger.info("AuthState AUTHENTICATING " + communicator.hostUrl + ", " + credentials.vbb_name + ": " + credentials.childNumber + " steam=" + credentials.steamId);
         this.action.send(communicator);
      }
      
      private function authCallbackHandler(param1:AuthTxn) : void
      {
         if(param1 != this.action)
         {
            return;
         }
         var _loc2_:Boolean = data.getValue(GameStateDataEnum.AUTH_REQUIRE);
         if(param1 && param1.success && Boolean(param1.jsonObject))
         {
            config.systemMessage.msg = param1.jsonObject.system_msg;
            communicator.connected = true;
            if(param1.buildNumber != config.context.appInfo.buildVersion)
            {
               logger.info("Server build number is " + param1.buildNumber + ", but ours is " + config.context.appInfo.buildVersion + ", seeking confirmation");
               if(config.context.appInfo.buildVersion != LOCAL_BUILD_NUMBER && param1.buildNumber != LOCAL_BUILD_NUMBER)
               {
                  this.action = null;
                  data.setValue(GameStateDataEnum.BUILD_NUMBER,param1.buildNumber);
                  if(_loc2_)
                  {
                     gameFsm.transitionTo(AuthBuildMismatchState,data);
                  }
                  else
                  {
                     phase = StatePhase.COMPLETED;
                  }
                  return;
               }
            }
            if(!credentials.valid || !credentials.displayName || !credentials.userId || !credentials.sessionKey)
            {
               logger.error("Invalid credentials: " + credentials);
               data.setValue(GameStateDataEnum.SERVER_MESSAGE,"Invalid Credentials");
               phase = StatePhase.FAILED;
               return;
            }
            phase = StatePhase.COMPLETED;
         }
         else if(param1.canRetry)
         {
            if(_loc2_)
            {
               param1.resend(communicator,5000);
            }
            else
            {
               phase = StatePhase.COMPLETED;
            }
         }
         else
         {
            this.action.abort();
            this.action = null;
            data.setValue(GameStateDataEnum.SERVER_MESSAGE,param1.message);
            if(_loc2_)
            {
               phase = StatePhase.FAILED;
            }
            else
            {
               phase = StatePhase.COMPLETED;
            }
         }
      }
   }
}
