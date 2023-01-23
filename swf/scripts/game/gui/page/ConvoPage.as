package game.gui.page
{
   import engine.convo.view.ConvoView;
   import engine.core.render.BoundedCamera;
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoCursor;
   import engine.saga.convo.def.ConvoOptionDef;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiConvo;
   
   public class ConvoPage extends GamePage
   {
      
      public static var mcClazz:Class;
       
      
      public var gui:IGuiConvo;
      
      public var scenePage:ScenePage;
      
      public var convoView:ConvoView;
      
      private var keyhelper:ConvoKeyboardHelper;
      
      public function ConvoPage(param1:GameConfig, param2:ScenePage)
      {
         super(param1);
         this.scenePage = param2;
         debugRender = 1727987712;
         this.convoView = param2.view.convoView;
         this.convoView.addEventListener(ConvoView.EVENT_CURSOR_SHOWN,this.cursorShownHandler);
         this.convoView.addEventListener(ConvoView.EVENT_CURSOR_HIDE,this.cursorHideHandler);
         this.convoView.convo.addEventListener(Convo.EVENT_AUDIO_BLOCK,this.audioEventCursorBlockHandler);
         this.convoView.convo.addEventListener(Convo.EVENT_AUDIO_UNBLOCK,this.audioEventCursorUnblockHandler);
      }
      
      public function doFf() : Boolean
      {
         return Boolean(this.keyhelper) && this.keyhelper.doFf();
      }
      
      public function cursorShownHandler(param1:Event) : void
      {
         if(this.gui)
         {
            this.keyhelper.cursor = this.convoView.convo.cursor;
            this.gui.showConvoCursor(this.convoView.convo.cursor);
            if(this.convoView.convo.readyToFinish)
            {
               this.convoView.convo.finish();
            }
         }
      }
      
      public function cursorHideHandler(param1:Event) : void
      {
         if(!this.gui)
         {
         }
      }
      
      public function audioEventCursorBlockHandler(param1:Event) : void
      {
         if(this.gui)
         {
            this.gui.showConvoCursorButton(false);
         }
      }
      
      public function audioEventCursorUnblockHandler(param1:Event) : void
      {
         if(this.gui)
         {
            this.gui.showConvoCursorButton(true);
         }
      }
      
      override public function start() : void
      {
         super.start();
      }
      
      override public function cleanup() : void
      {
         if(this.gui)
         {
            this.gui.cleanup();
         }
         this.gui = null;
         this.convoView.removeEventListener(ConvoView.EVENT_CURSOR_HIDE,this.cursorHideHandler);
         this.convoView.removeEventListener(ConvoView.EVENT_CURSOR_SHOWN,this.cursorShownHandler);
         this.convoView.convo.removeEventListener(Convo.EVENT_AUDIO_BLOCK,this.audioEventCursorBlockHandler);
         this.convoView.convo.removeEventListener(Convo.EVENT_AUDIO_UNBLOCK,this.audioEventCursorUnblockHandler);
         this.convoView = null;
         if(this.keyhelper)
         {
            this.keyhelper.cleanup();
            this.keyhelper = null;
         }
         super.cleanup();
      }
      
      override protected function handleStart() : void
      {
         setFullPageMovieClipClass(mcClazz);
         this.keyhelper = new ConvoKeyboardHelper(config.keybinder,this.keyNextHandler,this.keySelectHandler,config.options.developer);
         this.keyhelper.cursor = this.convoView.convo.cursor;
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
            this.gui.init(config.gameGuiContext,this.convoView.convo,false);
            this.resizeHandler();
            if(this.convoView.convo.cursor)
            {
               this.gui.showConvoCursor(this.convoView.convo.cursor);
            }
         }
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this.gui)
         {
            _loc1_ = Math.max(BoundedCamera.UI_AUTHOR_WIDTH * 1.2,width);
            _loc2_ = Math.max(BoundedCamera.UI_AUTHOR_HEIGHT * 1.2,height);
            _loc3_ = BoundedCamera.computeDpiScaling(_loc1_,_loc2_);
            _loc3_ = Math.min(2,_loc3_);
            fullScreenMc.scaleX = fullScreenMc.scaleY = _loc3_;
            this.gui.setConvoRect(0,0,width,height);
         }
      }
      
      public function keySelectHandler(param1:ConvoCursor, param2:ConvoOptionDef) : void
      {
         if(!this.convoView.convo.cursor.hasOptions)
         {
            return;
         }
         if(this.convoView.convo.selectedNode)
         {
            return;
         }
         if(!param2)
         {
            return;
         }
         this.convoView.convo.select(param2);
      }
      
      public function keyNextHandler(param1:ConvoCursor) : void
      {
         if(this.convoView.convo.finished || this.convoView.convo.readyToFinish)
         {
            return;
         }
         if(this.convoView.convo.cursor.hasOptions)
         {
            return;
         }
         if(this.convoView.convo.selectedNode)
         {
            return;
         }
         this.convoView.convo.next();
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "GUI:\n" + this.gui.getDebugString();
         _loc1_ += "ScenePage:\n" + this.scenePage.getDebugString();
         return _loc1_ + ("ConvoView:\n" + this.convoView.getDebugString());
      }
   }
}
