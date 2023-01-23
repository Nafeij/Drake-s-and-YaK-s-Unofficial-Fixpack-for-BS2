package game.gui.page
{
   import engine.core.fsm.FsmEvent;
   import engine.gui.page.PageState;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiDialog;
   import game.session.states.AuthBuildMismatchState;
   import game.session.states.AuthFailedState;
   import game.session.states.AuthState;
   import game.session.states.GameStateDataEnum;
   import game.session.states.PreAuthState;
   
   public class LoginPage extends GamePage implements IGuiLoginListener
   {
       
      
      private var _dialog:IGuiDialog;
      
      public function LoginPage(param1:GameConfig)
      {
         super(param1);
         mouseChildren = true;
         param1.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
      }
      
      override public function cleanup() : void
      {
         config.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
      }
      
      private function closeDialog() : void
      {
         if(this._dialog)
         {
            this._dialog.closeDialog(null);
            this._dialog = null;
         }
      }
      
      private function openDialog(param1:String, param2:String, param3:String) : void
      {
         this.closeDialog();
         this._dialog = config.gameGuiContext.createDialog();
         this._dialog.openDialog(param1,param2,param3,this.dialogCloseHandler);
      }
      
      private function openTwoBtnDialog(param1:String, param2:String, param3:String, param4:String) : void
      {
         this.closeDialog();
         this._dialog = config.gameGuiContext.createDialog();
         this._dialog.openTwoBtnDialog(param1,param2,param3,param4,this.dialogCloseHandler);
      }
      
      private function parseMismatchMessage(param1:AuthBuildMismatchState) : String
      {
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc2_:Array = param1.buildNumber.split(".");
         var _loc3_:Array = config.context.appInfo.buildVersion.split(".");
         var _loc4_:Boolean = true;
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.length && _loc5_ < _loc3_.length)
         {
            _loc7_ = Number(_loc2_[_loc5_]);
            _loc8_ = Number(_loc3_[_loc5_]);
            if(_loc7_ > _loc8_)
            {
               _loc4_ = false;
               break;
            }
            _loc5_++;
         }
         if(_loc4_)
         {
            _loc6_ = "Your Client Version " + config.context.appInfo.buildVersion + " is TOO NEW.  Server is " + param1.buildNumber;
         }
         else
         {
            _loc6_ = "Your Client Version " + config.context.appInfo.buildVersion + " is TOO OLD.  Server is " + param1.buildNumber;
         }
         return _loc6_;
      }
      
      private function parseFailedMessage(param1:AuthFailedState) : String
      {
         var _loc2_:* = null;
         if(param1.message)
         {
            _loc2_ = "Login failed:\n<font color=\'#ffdd00\'>" + param1.message + "</font>";
         }
         else
         {
            _loc2_ = "Login failed:\nNo more info available!";
         }
         return _loc2_;
      }
      
      private function fsmCurrentHandler(param1:FsmEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc2_:AuthBuildMismatchState = config.fsm.current as AuthBuildMismatchState;
         if(_loc2_)
         {
            _loc4_ = this.parseMismatchMessage(_loc2_);
            this.openDialog("Client Mismatch",_loc4_,"Disconnect");
            return;
         }
         var _loc3_:AuthFailedState = config.fsm.current as AuthFailedState;
         if(_loc3_)
         {
            _loc5_ = this.parseFailedMessage(_loc3_);
            this.openTwoBtnDialog("Login Failed",_loc5_,"Retry","Disconnect");
            return;
         }
         if(config.fsm.currentClass == AuthState || config.fsm.currentClass == PreAuthState)
         {
            if(config.fsm.current.data.getValue(GameStateDataEnum.SHOW_LOGIN_SCREEN))
            {
               this.openDialog("Authenticating...","Please wait.",null);
            }
            else
            {
               this.closeDialog();
            }
            return;
         }
         this.closeDialog();
      }
      
      private function dialogCloseHandler(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1 == "Disconnect")
         {
            config.context.appInfo.terminateError("Login Disconnect");
            return;
         }
         var _loc2_:AuthBuildMismatchState = config.fsm.current as AuthBuildMismatchState;
         if(_loc2_)
         {
            _loc2_.overrideBuildNumber = false;
         }
         config.fsm.transitionTo(PreAuthState,config.fsm.current.data);
      }
      
      override protected function handleStart() : void
      {
         state = PageState.LOADING;
         this.fsmCurrentHandler(null);
      }
      
      override protected function canBeReady() : Boolean
      {
         return false;
      }
      
      public function guiLoginSetAttemptLogin(param1:String, param2:String) : void
      {
      }
      
      public function guiLoginCancelLogin() : void
      {
      }
      
      public function guiLoginGoOffline() : void
      {
      }
      
      public function guiLoginServerSelected(param1:String) : void
      {
      }
   }
}
