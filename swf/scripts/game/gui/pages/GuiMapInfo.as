package game.gui.pages
{
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.session.NewsDef;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiMapInfo;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.events.TouchPhase;
   
   public class GuiMapInfo extends GuiBase implements IGuiMapInfo
   {
       
      
      private var newsDef:NewsDef;
      
      private var index:int = 0;
      
      public var _textTitle:TextField;
      
      public var _textBody:TextField;
      
      public var _button_close:ButtonWithIndex;
      
      public var bodyCenterY:Number;
      
      private var cmd_close:Cmd;
      
      private var gp_b:GuiGpBitmap;
      
      private var gplayer:int;
      
      public function GuiMapInfo()
      {
         this.cmd_close = new Cmd("guimapinfo_cmd_close",this.func_cmd_close);
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         super();
         super.visible = false;
         this._textTitle = getChildByName("textTitle") as TextField;
         this._textBody = getChildByName("textBody") as TextField;
         this._button_close = getChildByName("button_close") as ButtonWithIndex;
         addChild(this.gp_b);
         this.onOperationModeChange(null);
      }
      
      public function cleanup() : void
      {
         GuiGp.releasePrimaryBitmap(this.gp_b);
         GpBinder.gpbinder.unbind(this.cmd_close);
         this.cmd_close.cleanup();
      }
      
      private function func_cmd_close(param1:CmdExec) : void
      {
         if(this._button_close)
         {
            this._button_close.press();
         }
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         this._textTitle.mouseEnabled = false;
         this._textBody.mouseEnabled = false;
         this.bodyCenterY = this._textBody.y + this._textBody.height / 2;
         this._button_close.setDownFunction(this.buttonDownHandler);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         var _loc2_:DisplayObject = null;
         if(param1 == super.visible)
         {
            return;
         }
         super.visible = param1;
         if(param1)
         {
            this.gplayer = GpBinder.gpbinder.createLayer("map info");
            GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_close);
            this.gp_b.gplayer = this.gplayer;
            if(PlatformStarling.instance)
            {
               _loc2_ = Starling.current.root;
               _loc2_.addEventListener(TouchEvent.TOUCH,this.touchHandler);
            }
            else
            {
               PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            }
            PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            this.onOperationModeChange(null);
         }
         else
         {
            PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            GpBinder.gpbinder.removeLayer(this.gplayer);
            GpBinder.gpbinder.unbind(this.cmd_close);
            if(PlatformStarling.instance)
            {
               _loc2_ = Starling.current.root;
               _loc2_.removeEventListener(TouchEvent.TOUCH,this.touchHandler);
            }
            else
            {
               PlatformFlash.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            }
         }
      }
      
      public function showMapInfo(param1:String, param2:String) : void
      {
         this._textTitle.htmlText = param1;
         _context.currentLocale.fixTextFieldFormat(this._textTitle);
         this._textBody.htmlText = param2;
         _context.currentLocale.fixTextFieldFormat(this._textBody);
         this._textBody.height = this._textBody.textHeight + 10;
         this._textBody.y = this.bodyCenterY - this._textBody.height / 2;
         GuiGp.placeIconRight(this._button_close,this.gp_b);
         this.visible = true;
      }
      
      public function buttonDownHandler(param1:*) : void
      {
         this.closeMapInfo();
      }
      
      public function closeMapInfo() : void
      {
         this.visible = false;
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      final private function touchHandler(param1:TouchEvent) : void
      {
         var _loc3_:Touch = null;
         if(!visible)
         {
            return;
         }
         var _loc2_:int = 0;
         for(; _loc2_ < param1.touches.length; _loc2_++)
         {
            _loc3_ = param1.touches[_loc2_];
            if(!_loc3_.target)
            {
               continue;
            }
            switch(_loc3_.phase)
            {
               case TouchPhase.BEGAN:
                  if(this._testTouch(_loc3_.globalX,_loc3_.globalY))
                  {
                     param1.stopPropagation();
                     param1.stopImmediatePropagation();
                  }
                  break;
            }
         }
      }
      
      final protected function mouseDownHandler(param1:MouseEvent) : void
      {
         if(!visible)
         {
            return;
         }
         if(this._testTouch(param1.stageX,param1.stageY))
         {
            param1.stopPropagation();
            param1.stopImmediatePropagation();
            param1.preventDefault();
         }
      }
      
      private function _testTouch(param1:Number, param2:Number) : Boolean
      {
         if(!visible)
         {
            return false;
         }
         if(!hitTestPoint(param1,param2))
         {
            this._button_close.press();
            return true;
         }
         return false;
      }
      
      private function onOperationModeChange(param1:Event) : void
      {
         this._button_close.visible = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
      }
   }
}
