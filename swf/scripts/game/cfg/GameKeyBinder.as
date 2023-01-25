package game.cfg
{
   import com.stoicstudio.platform.Platform;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBinder;
   import engine.core.render.Screenshot;
   import engine.core.util.AppInfo;
   import engine.core.util.StringUtil;
   import engine.math.MathUtil;
   import engine.resource.ResourceCollector;
   import engine.saga.Saga;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import game.gui.GuiGamePrefs;
   import starling.core.Starling;
   
   public class GameKeyBinder extends KeyBinder
   {
       
      
      private var config:GameConfig;
      
      private var _localization_down:Boolean;
      
      public function GameKeyBinder(param1:GameConfig, param2:int)
      {
         super(param1.shell,param1.logger);
         this.config = param1;
         if(param2 == 0)
         {
            bind(true,false,true,Keyboard.F,new Cmd("toggle_fullscreen",this.func_toggle_fullscreen),"Game");
            bind(true,false,false,Keyboard.F,new Cmd("toggle_fullscreen",this.func_toggle_fullscreen),"Game");
            bind(false,false,true,Keyboard.F,new Cmd("toggle_fullscreen",this.func_toggle_fullscreen),"Game");
         }
         var _loc3_:Boolean = param1.options.developer;
         if(_loc3_)
         {
            bind(true,false,true,Keyboard.R,new Cmd("toggle_redraw_regions",this.wrap(param1.context.appInfo.toggleRedrawRegions)),"Game");
            bind(true,false,true,Keyboard.F10,new Cmd("save_load_page",this.func_save_load_page),"Game");
            bind(true,false,true,Keyboard.F9,new Cmd("save_load_quick",this.func_save_quickload),"Game");
            bind(true,false,true,Keyboard.F8,new Cmd("save_store_quick",this.func_save_quickstore),"Game");
            bind(true,false,true,Keyboard.S,new Cmd("toggle_starling_stats",this.func_toggle_starling_stats),"Game");
            bind(true,false,true,Keyboard.N,new Cmd("battle_snapshot_store",this.func_battle_snapshot_store),"Game");
            bind(true,false,true,Keyboard.M,new Cmd("battle_snapshot_load",this.func_battle_snapshot_load),"Game");
            bind(true,false,true,Keyboard.C,new Cmd("resource_check",this.func_resource_check),"Game");
            bind(true,false,true,Keyboard.E,new Cmd("resource_collection",this.func_resource_collection),"Game");
            bind(true,false,true,Keyboard.W,new Cmd("toggled_dev_panel",this.func_toggle_dev_panel),"Game");
         }
         bind(true,false,true,Keyboard.EQUAL,new Cmd("gui_size_up",this.func_gui_size_up),"Game");
         bind(false,true,true,Keyboard.EQUAL,new Cmd("gui_size_up",this.func_gui_size_up),"Game");
         bind(true,false,true,Keyboard.MINUS,new Cmd("gui_size_up",this.func_gui_size_down),"Game");
         bind(false,true,true,Keyboard.MINUS,new Cmd("gui_size_up",this.func_gui_size_down),"Game");
         bind(true,false,true,Keyboard.D,new Cmd("dispose_context3d",this.func_dispose_context3d),"Game");
         bind(true,false,true,Keyboard.G,new Cmd("open_logfile",this.func_open_logfile),"Game");
         bind(false,false,false,Keyboard.F11,new Cmd("screenshot",this.func_screenshot),"Game");
         bind(true,false,false,Keyboard.F11,new Cmd("screenshot",this.func_screenshot),"Game");
         bind(true,true,false,Keyboard.F11,new Cmd("screenshot",this.func_screenshot),"Game");
         bind(true,true,true,Keyboard.F11,new Cmd("screenshot",this.func_screenshot),"Game");
         bind(false,true,false,Keyboard.F11,new Cmd("screenshot",this.func_screenshot),"Game");
         bind(false,true,true,Keyboard.F11,new Cmd("screenshot",this.func_screenshot),"Game");
         bind(true,false,true,Keyboard.F11,new Cmd("screenshot",this.func_screenshot),"Game");
         bind(true,false,true,Keyboard.A,new Cmd("localization_down",this.func_localization_down),"",new Cmd("localization_up",this.func_localization_up));
      }
      
      private static function screenshot(param1:DisplayObject, param2:AppInfo) : void
      {
         var _loc3_:ByteArray = Screenshot.screenshotPng(param1,500,500,param2,true);
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:Date = new Date();
         var _loc5_:String = _loc4_.fullYear.toString();
         var _loc6_:String = StringUtil.padLeft(_loc4_.month.toString(),"0",2);
         var _loc7_:String = StringUtil.padLeft(_loc4_.date.toString(),"0",2);
         var _loc8_:String = StringUtil.padLeft(_loc4_.hours.toString(),"0",2);
         var _loc9_:String = StringUtil.padLeft(_loc4_.minutes.toString(),"0",2);
         var _loc10_:String = StringUtil.padLeft(_loc4_.seconds.toString(),"0",2);
         var _loc11_:String = StringUtil.padLeft(_loc4_.milliseconds.toString(),"0",3);
         var _loc12_:String = _loc5_ + _loc6_ + _loc7_ + "_" + _loc8_ + _loc9_ + _loc10_ + "_" + _loc11_;
         var _loc13_:* = "screenshots/" + _loc12_ + ".png";
         param2.saveFile(SaveManager.SAVE_DIR,_loc13_,_loc3_,false);
      }
      
      private static function computeGuiSize(param1:Number) : Number
      {
         var _loc2_:int = Math.round(param1 * 10);
         var _loc3_:Number = _loc2_ / 10;
         return MathUtil.clampValue(_loc3_,0.5,2);
      }
      
      public function wrap(param1:Function) : Function
      {
         var f:Function = param1;
         return function(param1:CmdExec):void
         {
            f();
         };
      }
      
      private function func_save_quickload(param1:CmdExec) : void
      {
         var _loc2_:int = 0;
         if(this.config.saga)
         {
            _loc2_ = !!this.config.saga ? this.config.saga.profile_index : -1;
            if(_loc2_ < 0)
            {
               _loc2_ = Saga.PROFILE_COUNT - 1;
            }
            this.config.saga.loadMostRecentSave(false,_loc2_);
         }
      }
      
      private function func_save_load_page(param1:CmdExec) : void
      {
         this.config.pageManager.showSaveLoad(true,-1,true);
      }
      
      private function func_toggle_fullscreen(param1:CmdExec) : void
      {
         if(!this.config || !this.config.context || !this.config.gameGuiContext)
         {
            return;
         }
         this.config.context.appInfo.toggleFullscreen();
         this.config.gameGuiContext.setPref(GuiGamePrefs.PREF_OPTION_FULLSCREEN,this.config.context.appInfo.fullscreen);
      }
      
      public function func_save_quickstore(param1:CmdExec) : void
      {
         var _loc2_:SagaSave = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(this.config.saga)
         {
            if(!this.config.saga.canSave(null,null))
            {
               this.config.logger.info("Cannot save right now. reason [" + this.config.saga.cannotSaveReason + "]");
            }
            else
            {
               _loc3_ = new Date().getTime() / 1000;
               _loc4_ = new Date(2013,11,1).getTime() / 1000;
               _loc3_ -= _loc4_;
               _loc5_ = _loc3_.toString();
               _loc2_ = this.config.saga.saveSaga(_loc5_,null,null);
            }
            if(_loc2_)
            {
               this.config.flyManager.showScreenFlyText("QuickSave OK: " + _loc2_.id,11206570,"ui_stats_glisten",0);
            }
            else
            {
               _loc6_ = Boolean(this.config) && Boolean(this.config.saga) ? this.config.saga.cannotSaveReason : "NO REASON";
               this.config.flyManager.showScreenFlyText("Unable to QuickSave\n" + _loc6_,16746632,"ui_error",1);
            }
         }
      }
      
      private function func_screenshot(param1:CmdExec) : void
      {
         this.takeScreenshot();
      }
      
      public function func_localization_down(param1:CmdExec) : void
      {
         if(!this._localization_down)
         {
            this.config.logger.info("GameKeyBinder.func_localization_down");
            this._localization_down = true;
         }
      }
      
      public function func_localization_up(param1:CmdExec) : void
      {
         if(this._localization_down)
         {
            this.config.logger.info("GameKeyBinder.func_localization_up");
            this._localization_down = false;
         }
      }
      
      override protected function handleKeyDown(param1:int) : void
      {
         var _loc4_:Vector.<String> = null;
         var _loc5_:String = null;
         if(!this._localization_down)
         {
            return;
         }
         var _loc2_:int = int(Keyboard.NUMBER_1);
         var _loc3_:int = param1 - _loc2_;
         if(_loc3_ >= 0)
         {
            _loc4_ = this.config.context.appInfo.locales;
            if(_loc3_ < _loc4_.length)
            {
               _loc5_ = _loc4_[_loc3_];
               this.config.logger.info("GameKeyBinder.handleKeyDown " + _loc3_ + " [" + _loc5_ + "]");
               this.config.changeLocale(_loc5_,null);
            }
         }
      }
      
      public function takeScreenshot() : void
      {
         if(!this.config || !this.config.context || !this.config.pageManager)
         {
            return;
         }
         var _loc1_:int = getTimer();
         screenshot(this.config.pageManager.holder,this.config.context.appInfo);
         var _loc2_:int = getTimer();
         var _loc3_:int = _loc2_ - _loc1_;
         this.config.logger.info("Screenshot in " + _loc3_ + " ms");
      }
      
      public function func_gui_size_up(param1:CmdExec) : void
      {
         Platform.setTextScale(computeGuiSize(Platform.textScale + 0.1));
         logger.info("Platform.textScale " + Platform.textScale);
      }
      
      public function func_gui_size_down(param1:CmdExec) : void
      {
         Platform.setTextScale(computeGuiSize(Platform.textScale - 0.1));
         logger.info("Platform.textScale " + Platform.textScale);
      }
      
      public function func_open_logfile(param1:CmdExec) : void
      {
         this.config.context.appInfo.openLogFile();
      }
      
      public function func_dispose_context3d(param1:CmdExec) : void
      {
         if(Starling.current)
         {
            Starling.current.context.dispose(true);
         }
      }
      
      public function func_toggle_starling_stats(param1:CmdExec) : void
      {
         if(Starling.current)
         {
            if(!Starling.current.showStats)
            {
               Starling.current.showStatsAt("left","middle",1);
            }
            else
            {
               Starling.current.showStats = false;
            }
         }
      }
      
      public function func_battle_snapshot_store(param1:CmdExec) : void
      {
         var _loc2_:Saga = this.config.saga;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.battleSnapshotStore("test");
      }
      
      public function func_battle_snapshot_load(param1:CmdExec) : void
      {
         var _loc2_:Saga = this.config.saga;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.battleSnapshotLoad("test",null);
      }
      
      public function func_resource_collection(param1:CmdExec) : void
      {
         ResourceCollector.output(this.config.context.appInfo,this.config.resman);
      }
      
      public function func_resource_check(param1:CmdExec) : void
      {
         GameConfigShellCmdManager.performResourceCheck(".clip",this.config);
      }
      
      public function func_toggle_dev_panel(param1:CmdExec) : void
      {
         this.config.dispatchEvent(new Event(GameConfig.EVENT_TOGGLE_DEV_PANEL));
      }
   }
}
