package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.session.Credentials;
   import engine.session.IAuthentication;
   import flash.events.Event;
   import game.session.GameState;
   
   public class PreAuthState extends GameState
   {
      
      public static var authenticator:IAuthentication;
       
      
      public function PreAuthState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         if(gameFsm.config.options.alwaysOffline)
         {
            phase = StatePhase.COMPLETED;
            return;
         }
         credentials.addEventListener(Credentials.EVENT_COMMITTED,this.credentialsChangeEvent);
         gameFsm.logout();
         if(credentials.steamId)
         {
            credentials.steamAuthTicketHandle = 1;
            credentials.steamAuthTicket = null;
            if(config.options.overrideSteamId)
            {
               credentials.steamAuthTicket = "override-authticket";
               credentials.commit();
            }
            else
            {
               credentials.steamAuthTicket = authenticator.requestAuthSessionTicket(null);
               logger.info("PreAuthState.handleEnteredState STEAM TICKET=" + credentials.steamAuthTicket);
               if(credentials.steamAuthTicket)
               {
                  credentials.commit();
                  return;
               }
            }
         }
         if(config.runMode.autologin)
         {
            credentials.vbb_name = "kiosk";
            credentials.password = "kiosk";
            if(Math.random() > 0.5)
            {
               credentials.displayName = config.gameGuiContext.randomMaleName;
            }
            else
            {
               credentials.displayName = config.gameGuiContext.randomFemaleName;
            }
            credentials.commit();
            return;
         }
         data.setValue(GameStateDataEnum.SHOW_LOGIN_SCREEN,true);
      }
      
      override protected function handleCleanup() : void
      {
         credentials.removeEventListener(Credentials.EVENT_COMMITTED,this.credentialsChangeEvent);
      }
      
      protected function credentialsChangeEvent(param1:Event) : void
      {
         if(credentials.valid)
         {
            phase = StatePhase.COMPLETED;
         }
      }
   }
}
