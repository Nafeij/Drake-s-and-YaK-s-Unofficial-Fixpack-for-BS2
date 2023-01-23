package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.State;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.MovieClipAdapter;
   import engine.gui.GuiUtil;
   import engine.gui.page.PageState;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.FlashState;
   
   public class FlashPage extends GamePage
   {
       
      
      private var flash_escape:Cmd;
      
      private var flash_ff:Cmd;
      
      private var timer:Timer;
      
      private var mca:MovieClipAdapter;
      
      public function FlashPage(param1:GameConfig)
      {
         this.flash_escape = new Cmd("flash_escape",this.cmdEscapeFunc);
         this.flash_ff = new Cmd("flash_ff",this.cmdFfFunc);
         this.timer = new Timer(1000,1);
         super(param1,1920,1080);
         this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         this.opaqueBackground = 0;
         this.debugRender = 0;
      }
      
      private function getClassFromUrl(param1:String) : Class
      {
         var slashpos:int = 0;
         var cn:String = null;
         var cz:Class = null;
         var url:String = param1;
         if(!url)
         {
            throw new ArgumentError("FlashPage attempted to load null url");
         }
         try
         {
            slashpos = url.indexOf("/");
            if(slashpos > 0)
            {
               cn = url.substr(slashpos + 1);
               cz = getDefinitionByName(cn) as Class;
               return cz;
            }
         }
         catch(e:Error)
         {
            throw new Error("Failed to resolve Flash URL class [" + url + "] cn=[" + cn + "]:\n" + e.getStackTrace());
         }
         return null;
      }
      
      private function unbind() : void
      {
         if(config)
         {
            config.keybinder.unbind(this.flash_escape);
            config.gpbinder.unbind(this.flash_escape);
         }
      }
      
      override protected function handleStateChanged() : void
      {
         var _loc1_:FlashState = null;
         if(state == PageState.READY)
         {
            if(config.saga)
            {
               _loc1_ = config.fsm.current as FlashState;
               config.saga.triggerFlashPageReady(!!_loc1_ ? _loc1_.url : null);
            }
         }
      }
      
      private function bind() : void
      {
         config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.flash_escape,KeyBindGroup.FLASH);
         config.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.flash_escape,KeyBindGroup.FLASH);
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.flash_escape,KeyBindGroup.FLASH);
         config.gpbinder.bindPress(GpControlButton.B,this.flash_escape,"");
         config.gpbinder.bindPress(GpControlButton.A,this.flash_escape,"");
      }
      
      override protected function handleStart() : void
      {
         var _loc3_:TextField = null;
         var _loc4_:Locale = null;
         var _loc5_:MovieClip = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Function = null;
         config.context.appInfo.setSystemIdleKeepAwake(true);
         config.globalAmbience.audio = null;
         var _loc1_:FlashState = config.fsm.current as FlashState;
         if(Boolean(_loc1_) && !_loc1_.disableCloseButton)
         {
            this.bind();
         }
         if(_loc1_.time > 0)
         {
            this.timer.delay = _loc1_.time * 1000;
         }
         var _loc2_:Class = this.getClassFromUrl(_loc1_.url);
         setFullPageMovieClipClass(_loc2_);
         if(fullScreenMc)
         {
            _loc3_ = fullScreenMc.text as TextField;
            if(_loc3_)
            {
               if(_loc1_.msg)
               {
                  _loc3_.htmlText = _loc1_.msg;
               }
               else
               {
                  _loc3_.htmlText = "";
               }
            }
            else if(_loc1_.msg)
            {
               logger.error("No text on FlashPage " + _loc1_.url + " but msg nonempty [" + _loc1_.msg + "]");
            }
            _loc4_ = config.context.locale;
            _loc4_.translateDisplayObjects(LocaleCategory.GUI,fullScreenMc,logger);
            _loc4_.info._fixTextFieldFormat(_loc3_,_loc1_.lang);
            _loc5_ = fullScreenMc.getChildByName("censor") as MovieClip;
            _loc6_ = config.censorId;
            GuiUtil.performCensor(_loc5_,config.censorId,logger);
            if(Boolean(_loc3_) && Boolean(_loc1_.msg))
            {
               _loc3_.width = _loc3_.textWidth + 10;
               _loc3_.height = _loc3_.textHeight + 10;
               _loc3_.x = -_loc3_.width / 2;
               _loc3_.y = -_loc3_.height / 2;
            }
            _loc7_ = 30;
            _loc8_ = null;
            this.mca = new MovieClipAdapter(fullScreenMc,_loc7_,0,false,logger,null,_loc8_,true,_loc4_);
            this.mca.playOnce();
            if(_loc1_.time > 0 && _loc8_ == null)
            {
               this.timer.start();
            }
         }
      }
      
      private function movieCompleteHandler(param1:MovieClipAdapter) : void
      {
         this.timerCompleteHandler(null);
      }
      
      private function timerCompleteHandler(param1:TimerEvent) : void
      {
         this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         this.timer.stop();
         if(Boolean(this.mca) && this.mca.isPlaying)
         {
            this.mca.stop();
         }
         if(fullScreenMc)
         {
            fullScreenMc.stop();
         }
         var _loc2_:FlashState = config.fsm.current as FlashState;
         if(_loc2_)
         {
            _loc2_.handleFlashComplete();
            if(_loc2_.cleanedup || config.fsm.current != _loc2_)
            {
               this.unbind();
            }
         }
      }
      
      override protected function handleButtonClosePress() : void
      {
         this.timerCompleteHandler(null);
      }
      
      override protected function handleTap() : void
      {
         var _loc1_:FlashState = config.fsm.current as FlashState;
         if(Boolean(_loc1_) && _loc1_.disableCloseButton)
         {
            return;
         }
         showButtonClose(3);
      }
      
      private function cmdEscapeFunc(param1:CmdExec) : void
      {
         this.timerCompleteHandler(null);
      }
      
      private function cmdFfFunc(param1:CmdExec) : void
      {
         this.timerCompleteHandler(null);
      }
      
      override public function cleanup() : void
      {
         if(this.mca)
         {
            if(this.mca.isPlaying)
            {
               this.mca.stop();
            }
            this.mca.completeCallback = null;
         }
         this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
         this.timer.stop();
         if(fullScreenMc)
         {
            fullScreenMc.stop();
         }
         this.unbind();
         config.context.appInfo.setSystemIdleKeepAwake(false);
         super.cleanup();
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         if(fullScreenMc)
         {
            fullScreenMc.x = fullScreenMc.y = 0;
         }
      }
      
      override public function canReusePageForState(param1:State) : Boolean
      {
         return false;
      }
   }
}
