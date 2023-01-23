package game.session.states
{
   import engine.core.analytic.GaConfig;
   import engine.core.analytic.GaOptState;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.def.BooleanVars;
   import game.gui.IGaOptStateDialogListener;
   import game.session.GameState;
   import game.session.actions.AccountInfoTxn;
   
   public class AccountInfoState extends GameState implements IGaOptStateDialogListener
   {
      
      private static const INI_STARTUP_WARNING:String = "startupWarning";
      
      private static const INI_STARTUP_WARNING_URL:String = "startupWarningUrl";
      
      private static const INI_STARTUP_WARNING_MSG:String = "startupWarningMsg";
      
      private static const INI_STARTUP_WARNING_LOCALE:String = "startupWarningLocale";
      
      private static const INI_STARTUP_WARNING_TIME:String = "startupWarningTime";
       
      
      private var action:AccountInfoTxn;
      
      public function AccountInfoState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:Boolean = data.getValue(GameStateDataEnum.AUTH_REQUIRE);
         if(!_loc1_)
         {
            if(!credentials.valid || !credentials.displayName || !credentials.userId || !credentials.sessionKey)
            {
               if(this.performGaOptQuery())
               {
                  return;
               }
               if(this.performStartupWarning())
               {
                  return;
               }
               phase = StatePhase.COMPLETED;
               return;
            }
         }
         this.action = new AccountInfoTxn(this.actionHandler,gameFsm.config);
         this.action.send(communicator);
      }
      
      private function actionHandler(param1:AccountInfoTxn) : void
      {
         if(param1 != this.action)
         {
            return;
         }
         if(!param1.success)
         {
            phase = StatePhase.FAILED;
            return;
         }
         if(this.performStartupWarning())
         {
            return;
         }
         phase = StatePhase.COMPLETED;
      }
      
      private function performStartupWarning() : Boolean
      {
         var _loc1_:AppInfo = config.context.appInfo;
         var _loc2_:* = BooleanVars.parse(_loc1_.getIni(INI_STARTUP_WARNING,undefined),false);
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:String = _loc1_.getIni(INI_STARTUP_WARNING_URL,undefined);
         var _loc4_:Number = _loc1_.getIni(INI_STARTUP_WARNING_TIME,5);
         var _loc5_:String = _loc1_.getIni(INI_STARTUP_WARNING_MSG,undefined);
         _loc5_ = _loc5_.replace(/\\n/g,"\n");
         var _loc6_:String = _loc1_.getIni(INI_STARTUP_WARNING_LOCALE,undefined);
         data.setValue(GameStateDataEnum.FLASH_URL,_loc3_);
         data.setValue(GameStateDataEnum.FLASH_TIME,_loc4_);
         data.setValue(GameStateDataEnum.FLASH_MSG,_loc5_);
         data.setValue(GameStateDataEnum.FLASH_LOCALE,_loc6_);
         fsm.transitionTo(StartupWarningState,data);
         return true;
      }
      
      private function performGaOptQuery() : Boolean
      {
         if(GaConfig.optState != GaOptState.QUERY)
         {
            return false;
         }
         config.gameGuiContext.showGaOptStateDialog(this);
         return true;
      }
      
      public function gaOptStateDialogClosed() : void
      {
         this.handleEnteredState();
      }
   }
}
