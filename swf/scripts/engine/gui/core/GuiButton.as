package engine.gui.core
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuiButton extends GuiSprite
   {
       
      
      private var _label:GuiLabel;
      
      private var _bgNormal:GuiImage;
      
      private var _rolledOver:Boolean;
      
      private var _mouseDown:Boolean;
      
      private var _state:DebugGuiButtonState = null;
      
      private var _skin:GuiButtonSkin;
      
      public var popupMouseDownMode:Boolean;
      
      private var eventStage:DisplayObject;
      
      public function GuiButton(param1:GuiButtonSkin)
      {
         super();
         width = 100;
         height = 40;
         this._skin = param1;
         this.state = DebugGuiButtonState.NORMAL;
         mouseEnabled = true;
         addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
         addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,false);
         var _loc2_:Number = this._skin.getTextSize(this._state);
         height = _loc2_ + 2;
         this.debugRender = true;
      }
      
      public function get mouseDown() : Boolean
      {
         return this._mouseDown;
      }
      
      public function set mouseDown(param1:Boolean) : void
      {
         this._mouseDown = param1;
         this.updateState();
      }
      
      public function get rolledOver() : Boolean
      {
         return this._rolledOver;
      }
      
      public function setRolledOver(param1:Boolean, param2:MouseEvent) : void
      {
         this._rolledOver = param1;
         if(this.popupMouseDownMode)
         {
            if(!this._rolledOver)
            {
               this.mouseDown = false;
            }
            else
            {
               stage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
               this.mouseDown = true;
            }
         }
         this.updateState();
         dispatchEvent(new GuiButtonEvent(GuiButtonEvent.ROLLOVER,param2));
      }
      
      public function get state() : DebugGuiButtonState
      {
         return this._state;
      }
      
      public function set state(param1:DebugGuiButtonState) : void
      {
         if(this._state != param1)
         {
            this._state = param1;
            this.updateFromSkin();
         }
      }
      
      private function updateFromSkin() : void
      {
         var _loc1_:BitmapData = null;
         if(!this._skin)
         {
            return;
         }
         if(this._label)
         {
            this._label.textColor = this._skin.getTextColor(this._state);
            this._label.textFormatSize = this._skin.getTextSize(this._state);
         }
         if(this._bgNormal)
         {
            _loc1_ = this._skin.getBitmap(this._state);
            this._bgNormal.bitmapData = _loc1_;
         }
      }
      
      override protected function updateState() : void
      {
         alpha = enabled ? 1 : 0.5;
         if(!enabled)
         {
            this.state = DebugGuiButtonState.DISABLED;
         }
         else if(this._mouseDown)
         {
            this.state = DebugGuiButtonState.PRESSED;
         }
         else if(this._rolledOver)
         {
            this.state = DebugGuiButtonState.HOVER;
         }
         else
         {
            this.state = DebugGuiButtonState.NORMAL;
         }
      }
      
      protected function mouseUpHandler(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = this._mouseDown;
         this.mouseDown = false;
         this.updateState();
         if(this.eventStage)
         {
            this.eventStage.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         }
         if(this._rolledOver && _loc2_)
         {
            if(enabled)
            {
               dispatchEvent(new GuiButtonEvent(GuiButtonEvent.CLICKED,param1));
            }
         }
      }
      
      protected function removedFromStageHandler(param1:Event) : void
      {
         if(this.eventStage)
         {
            this.eventStage.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            this.eventStage = null;
         }
      }
      
      protected function mouseDownHandler(param1:MouseEvent) : void
      {
         this.eventStage = stage;
         this.eventStage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         this.mouseDown = true;
         this.updateState();
      }
      
      protected function rollOutHandler(param1:MouseEvent) : void
      {
         this.setRolledOver(false,param1);
      }
      
      protected function rollOverHandler(param1:MouseEvent) : void
      {
         this.setRolledOver(true,param1);
      }
      
      public function get bgNormal() : GuiImage
      {
         if(!this._bgNormal)
         {
            this._bgNormal = new GuiImage();
            this._bgNormal.anchor.percentWidth = 100;
            this._bgNormal.anchor.percentHeight = 100;
            addChildAt(this._bgNormal,0);
            this.updateFromSkin();
         }
         return this._bgNormal;
      }
      
      public function set bgNormal(param1:GuiImage) : void
      {
         this._bgNormal = param1;
      }
      
      public function get label() : GuiLabel
      {
         if(!this._label)
         {
            this._label = new GuiLabel();
            this._label.anchor.percentWidth = 100;
            this._label.anchor.percentHeight = 100;
            this._label.name = "label";
            addChild(this._label);
            this.updateFromSkin();
         }
         return this._label;
      }
      
      public function set label(param1:GuiLabel) : void
      {
         this._label = param1;
      }
   }
}
