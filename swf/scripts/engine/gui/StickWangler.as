package engine.gui
{
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import engine.math.MathUtil;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class StickWangler
   {
       
      
      private var last_stick_angle:Number = 0;
      
      private var valid_stick_angle:Boolean;
      
      private var stick_hover_button:IGuiGpNavButton;
      
      private var gp_cross:GuiGpBitmap;
      
      private var buttons2Angle:Dictionary;
      
      private var buttons:Vector.<IGuiGpNavButton>;
      
      private var owner:Sprite;
      
      public var gpButtonPressed:Boolean;
      
      private var _stickResetRequired:Boolean;
      
      private var gp_stick:GuiGpBitmap;
      
      private var _displayDirty:Boolean = true;
      
      private var _visible:Boolean;
      
      private var buttons2PosGlobal:Dictionary;
      
      private var zero:Point;
      
      private var _stickResetWakeCallback:Function;
      
      public function StickWangler(param1:Sprite)
      {
         this.gp_cross = GuiGp.ctorPrimaryBitmap(GpControlButton.A);
         this.buttons2Angle = new Dictionary();
         this.buttons = new Vector.<IGuiGpNavButton>();
         this.gp_stick = GuiGp.ctorPrimaryBitmap(GpControlButton.LSTICK);
         this.buttons2PosGlobal = new Dictionary();
         this.zero = new Point();
         super();
         this.owner = param1;
         this.gp_stick.scale = 1;
         this.gp_cross.scale = 0.75;
         param1.addChild(this.gp_stick);
         param1.addChild(this.gp_cross);
         this.gp_cross.visible = false;
         this.gp_stick.visible = false;
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
      }
      
      public function cleanup() : void
      {
         this._stickResetWakeCallback = null;
         this.owner = null;
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         GuiGp.releasePrimaryBitmap(this.gp_cross);
         GuiGp.releasePrimaryBitmap(this.gp_stick);
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(this._visible == param1)
         {
            return;
         }
         this._displayDirty = true;
         this._visible = param1;
         this.gp_stick.visible = param1;
         this.hoverButton(null);
         if(!this._visible)
         {
            this.gp_cross.visible = false;
         }
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this._displayDirty = true;
      }
      
      public function requireStickReset(param1:Function) : void
      {
         this._stickResetWakeCallback = param1;
         this._stickResetRequired = true;
         this.gp_stick.visible = false;
         this.gp_cross.visible = false;
         this.setStickAngle(false,0);
      }
      
      public function addButton(param1:IGuiGpNavButton) : void
      {
         if(!param1)
         {
            return;
         }
         if(this.buttons2Angle[param1] != undefined)
         {
            return;
         }
         this.buttons.push(param1);
         this.cacheButtonAngle(param1,null);
         if(!this.gp_cross.parent)
         {
            this.owner.addChild(this.gp_cross);
         }
         this._displayDirty = true;
      }
      
      private function cacheButtonAngle(param1:IGuiGpNavButton, param2:Point) : void
      {
         if(!param2)
         {
            param2 = param1.localToGlobal(this.zero);
         }
         var _loc3_:Point = this.owner.globalToLocal(param2);
         var _loc4_:Point = new Point(_loc3_.x,_loc3_.y);
         _loc4_.normalize(1);
         var _loc5_:Number = Math.atan2(_loc4_.x,-_loc4_.y) * 180 / Math.PI;
         _loc5_ -= 90;
         _loc5_ = MathUtil.mungeDegrees(_loc5_);
         this.buttons2Angle[param1] = _loc5_;
         this.buttons2PosGlobal[param1] = param2;
      }
      
      public function clear() : void
      {
         this.buttons = new Vector.<IGuiGpNavButton>();
         this.buttons2Angle = new Dictionary();
         this.buttons2PosGlobal = new Dictionary();
         this._stickResetWakeCallback = null;
         this._displayDirty = true;
         if(this.gp_cross.parent)
         {
            this.gp_cross.parent.removeChild(this.gp_cross);
         }
      }
      
      private function hoverButton(param1:IGuiGpNavButton) : void
      {
         var _loc2_:* = null;
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc5_:IGuiGpNavButton = null;
         if(param1 == this.stick_hover_button)
         {
            return;
         }
         this.stick_hover_button = param1;
         if(param1)
         {
            if(!param1.visible || !param1.enabled)
            {
               param1 = null;
            }
         }
         this.gp_cross.visible = param1 != null;
         if(param1)
         {
            _loc3_ = param1.localToGlobal(new Point(0,0));
            _loc3_ = this.owner.globalToLocal(_loc3_);
            _loc4_ = new Point(_loc3_.x,_loc3_.y);
            _loc4_.normalize(1);
            this.gp_cross.x = _loc3_.x - _loc4_.x * 40 - this.gp_cross.width / 2;
            this.gp_cross.y = _loc3_.y - _loc4_.y * 40 - this.gp_cross.height / 2;
         }
         for(_loc2_ in this.buttons2Angle)
         {
            _loc5_ = _loc2_ as IGuiGpNavButton;
            this.checkHoverStateButton(param1,_loc5_);
         }
      }
      
      private function checkHoverStateButton(param1:IGuiGpNavButton, param2:IGuiGpNavButton) : void
      {
         param2.setHovering(param2 == param1);
      }
      
      public function setStickAngle(param1:Boolean, param2:Number) : void
      {
         var _loc3_:IGuiGpNavButton = null;
         var _loc5_:IGuiGpNavButton = null;
         var _loc6_:* = null;
         var _loc7_:IGuiGpNavButton = null;
         var _loc8_:Point = null;
         var _loc9_:Point = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(this.buttons.length == 1)
         {
            this.hoverButton(this.buttons[0]);
         }
         if(!param1)
         {
            this.valid_stick_angle = false;
            return;
         }
         if(param2 == this.last_stick_angle && this.valid_stick_angle == param1)
         {
            return;
         }
         this.valid_stick_angle = true;
         if(this._stickResetWakeCallback != null)
         {
            this._stickResetWakeCallback(this);
            this._stickResetWakeCallback = null;
         }
         this.last_stick_angle = param2;
         if(this.buttons.length == 1)
         {
            return;
         }
         var _loc4_:Number = 100000;
         for(_loc6_ in this.buttons2Angle)
         {
            _loc7_ = _loc6_ as IGuiGpNavButton;
            if(_loc7_.visible)
            {
               _loc8_ = _loc7_.localToGlobal(this.zero);
               _loc9_ = this.buttons2PosGlobal[_loc6_];
               if(!_loc9_ || !_loc9_.equals(_loc8_))
               {
                  this.cacheButtonAngle(_loc7_,_loc8_);
               }
               _loc10_ = Number(this.buttons2Angle[_loc6_]);
               _loc11_ = MathUtil.mungeDegrees(_loc10_ - this.last_stick_angle);
               _loc11_ = Math.abs(_loc11_);
               if(_loc11_ < _loc4_)
               {
                  _loc4_ = _loc11_;
                  _loc5_ = _loc7_;
               }
            }
         }
         this.hoverButton(_loc5_);
      }
      
      public function handleGpButton() : Boolean
      {
         if(this._stickResetRequired || this._stickResetWakeCallback != null)
         {
            return false;
         }
         if(this.stick_hover_button)
         {
            this.gpButtonPressed = true;
            this.stick_hover_button.press();
            this.gpButtonPressed = false;
         }
         return true;
      }
      
      public function update(param1:int) : void
      {
         if(!this._visible)
         {
            return;
         }
         if(this._displayDirty)
         {
            this.resetDisplay();
         }
         var _loc2_:GpDevice = GpSource.primaryDevice;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:Number = GuiGp.computeStickAngle(0.5);
         if(this._stickResetRequired)
         {
            if(isNaN(_loc3_))
            {
               this._stickResetRequired = false;
               this._displayDirty = true;
            }
            return;
         }
         this.setStickAngle(!isNaN(_loc3_),_loc3_);
      }
      
      private function resetDisplay() : void
      {
         this._displayDirty = false;
         if(this._stickResetRequired || this._stickResetWakeCallback != null)
         {
            this.gp_stick.visible = false;
         }
         else
         {
            this.gp_stick.visible = true;
            this.gp_stick.x = -this.gp_stick.width / 2;
            this.gp_stick.y = -this.gp_stick.height;
         }
      }
   }
}
