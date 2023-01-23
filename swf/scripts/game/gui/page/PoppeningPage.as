package game.gui.page
{
   import engine.core.render.BoundedCamera;
   import engine.saga.SagaPresenceManager;
   import engine.saga.SagaPresenceState;
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoCursor;
   import engine.saga.convo.def.ConvoOptionDef;
   import flash.display.MovieClip;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiConvo;
   
   public class PoppeningPage extends GamePage
   {
      
      public static var mcClazzPopppening:Class;
       
      
      private var gui:IGuiConvo;
      
      private var _convo:Convo;
      
      private var keyhelper:ConvoKeyboardHelper;
      
      private var sagaPresenceState:SagaPresenceState;
      
      public function PoppeningPage(param1:GameConfig, param2:Convo)
      {
         super(param1);
         this.convo = param2;
         this.allowPageScaling = false;
         param1.addEventListener(GameConfig.EVENT_FF,this.configFfHandler);
      }
      
      override public function update(param1:int) : void
      {
      }
      
      private function configFfHandler(param1:Event) : Boolean
      {
         if(this.keyhelper)
         {
            return this.keyhelper.doFf();
         }
         return false;
      }
      
      public function get convo() : Convo
      {
         return this._convo;
      }
      
      public function set convo(param1:Convo) : void
      {
         if(this._convo == param1)
         {
            return;
         }
         if(this._convo)
         {
            if(this.sagaPresenceState)
            {
               this.sagaPresenceState.remove();
               this.sagaPresenceState = null;
            }
            this._convo.cursor.removeEventListener(ConvoCursor.EVENT_JUMP,this.convoNodeHandler);
            if(this.keyhelper)
            {
               this.keyhelper.cleanup();
               this.keyhelper = null;
            }
         }
         this._convo = param1;
         if(this._convo)
         {
            this.sagaPresenceState = SagaPresenceManager.pushNewState(SagaPresenceManager.StateDecision);
            this._convo.cursor.addEventListener(ConvoCursor.EVENT_JUMP,this.convoNodeHandler);
            this.keyhelper = new ConvoKeyboardHelper(config.keybinder,this.keyNextHandler,this.keySelectHandler,config.options.developer);
            config.gameGuiContext.playSound("ui_poppenings");
         }
         else
         {
            if(this.sagaPresenceState)
            {
               this.sagaPresenceState.remove();
               this.sagaPresenceState = null;
            }
            if(this.keyhelper)
            {
               this.keyhelper.cleanup();
               this.keyhelper = null;
            }
         }
         this.checkConvo();
      }
      
      private function convoNodeHandler(param1:Event) : void
      {
         this.checkConvo();
      }
      
      private function checkConvo() : void
      {
         if(Boolean(this.convo) && this.convo.readyToFinish)
         {
            if(this.sagaPresenceState)
            {
               this.sagaPresenceState.remove();
               this.sagaPresenceState = null;
            }
            this.convo.finish();
            return;
         }
         if(this.gui)
         {
            this.gui.convo = this.convo;
         }
         if(this.convo)
         {
            this.convo.handleCursorAudioCmds();
            this.keyhelper.cursor = this.convo.cursor;
            if(this.gui)
            {
               this.gui.showConvoCursor(this.convo.cursor);
            }
         }
         else if(this.keyhelper)
         {
            this.keyhelper.cursor = null;
         }
         if(stage && this.convo && Boolean(this.gui))
         {
            stage.focus = this.gui as MovieClip;
         }
      }
      
      override public function cleanup() : void
      {
         config.removeEventListener(GameConfig.EVENT_FF,this.configFfHandler);
         if(this.gui)
         {
            this.gui.cleanup();
            this.gui = null;
         }
         this.convo = null;
         super.cleanup();
      }
      
      override protected function handleStart() : void
      {
         setFullPageMovieClipClass(mcClazzPopppening);
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this.gui)
         {
            removeChildFromContainer(fullScreenMc);
            addChild(fullScreenMc);
            fullScreenMc.x = 0;
            fullScreenMc.y = 0;
            this.gui = fullScreenMc as IGuiConvo;
            this.gui.init(config.gameGuiContext,null,true);
            this.resizeHandler();
            this.checkConvo();
         }
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         super.resizeHandler();
         if(this.gui)
         {
            fullScreenMc.scaleX = fullScreenMc.scaleY = BoundedCamera.computeDpiScaling(width,height);
            fullScreenMc.x = width / 2;
            fullScreenMc.y = height / 2;
            _loc1_ = 800;
            _loc2_ = 700;
            this.gui.setConvoRect((width - _loc1_) / 2,(height - _loc2_) / 2,_loc1_,_loc2_);
         }
      }
      
      public function keySelectHandler(param1:ConvoCursor, param2:ConvoOptionDef) : void
      {
         if(!this.convo.cursor.hasOptions)
         {
            return;
         }
         if(this.convo.selectedNode)
         {
            return;
         }
         if(!param2)
         {
            return;
         }
         this.convo.select(param2);
      }
      
      public function keyNextHandler(param1:ConvoCursor) : void
      {
         if(this._convo.finished || this._convo.readyToFinish)
         {
            return;
         }
         if(this._convo.cursor.hasOptions)
         {
            return;
         }
         if(this._convo.selectedNode)
         {
            return;
         }
         this._convo.next();
      }
   }
}
