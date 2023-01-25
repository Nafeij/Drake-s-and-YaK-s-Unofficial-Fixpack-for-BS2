package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.locale.Locale;
   import engine.saga.Saga;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiDialog;
   import game.session.states.SagaSelectorState;
   
   public class SagaSelectorPage extends GamePage implements IGuiSagaSelectorListener
   {
      
      public static var mcClazz:Class;
      
      private static var disabled:Dictionary = new Dictionary();
       
      
      private var gui:IGuiSagaSelector;
      
      private var cmd_ssel_1:Cmd;
      
      private var cmd_ssel_2:Cmd;
      
      public function SagaSelectorPage(param1:GameConfig)
      {
         this.cmd_ssel_1 = new Cmd("cmd_ssel_1",this.func_cmd_ssel);
         this.cmd_ssel_2 = new Cmd("cmd_ssel_2",this.func_cmd_ssel);
         super(param1);
      }
      
      public static function addDisable(param1:String, param2:String, param3:String) : void
      {
         if(Boolean(param3) && Boolean(param2))
         {
            disabled[param1] = {
               "token_body":param3,
               "token_title":param2
            };
         }
         else
         {
            delete disabled[param1];
         }
      }
      
      private function func_cmd_ssel(param1:CmdExec) : void
      {
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(this.gui)
         {
            this.gui.update(param1);
         }
      }
      
      override protected function handleStart() : void
      {
         config.keybinder.bind(false,true,true,Keyboard.NUMBER_1,this.cmd_ssel_1,"ssel");
         config.keybinder.bind(true,false,true,Keyboard.NUMBER_2,this.cmd_ssel_2,"ssel");
         setFullPageMovieClipClass(mcClazz);
      }
      
      override public function cleanup() : void
      {
         config.keybinder.unbind(this.cmd_ssel_1);
         GpBinder.gpbinder.unbind(this.cmd_ssel_2);
         this.cmd_ssel_1.cleanup();
         this.cmd_ssel_2.cleanup();
         if(this.gui)
         {
            this.gui.cleanup();
            this.gui = null;
         }
      }
      
      override protected function handleLoaded() : void
      {
         var _loc2_:Saga = null;
         var _loc1_:SagaSelectorState = config.fsm.current as SagaSelectorState;
         if(!_loc1_)
         {
            return;
         }
         if(Boolean(fullScreenMc) && !this.gui)
         {
            _loc2_ = config.saga;
            this.gui = fullScreenMc as IGuiSagaSelector;
            this.gui.init(config.gameGuiContext,this);
         }
      }
      
      public function guiSagaSelector_select(param1:String) : void
      {
         var _loc5_:IGuiDialog = null;
         var _loc6_:Locale = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc2_:Object = !!disabled ? disabled[param1] : null;
         if(_loc2_)
         {
            _loc5_ = config.gameGuiContext.createDialog();
            _loc6_ = config.context.locale;
            _loc7_ = _loc6_.translateGui(_loc2_.token_title);
            _loc8_ = _loc6_.translateGui(_loc2_.token_body);
            _loc9_ = _loc6_.translateGui("ok");
            _loc5_.openDialog(_loc7_,_loc8_,_loc9_);
            return;
         }
         var _loc3_:Dictionary = new Dictionary();
         _loc3_["saga1"] = "saga1/saga1.json.z";
         _loc3_["saga2"] = "saga2/saga2.json.z";
         _loc3_["saga3"] = "saga3/saga3.json.z";
         var _loc4_:String = String(_loc3_[param1]);
         config.saga.launchSagaByUrl(_loc4_,null,0,config.saga.def.url);
      }
   }
}
