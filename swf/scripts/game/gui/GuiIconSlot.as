package game.gui
{
   import engine.gui.GuiUtil;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.text.TextField;
   
   public class GuiIconSlot extends MovieClip implements IGuiIconSlot
   {
      
      public static var draggedIconClone:GuiIcon;
      
      public static var draggedSourceIconSlot:GuiIconSlot;
      
      public static var draggedTargetIconSlot:GuiIconSlot;
      
      private static const CLICK_DIST:Number = 4;
       
      
      public var _icon:GuiIcon;
      
      public var iconIndex:int;
      
      public var iconRect:Rectangle;
      
      public var iconCenter:Point;
      
      public var nameTextField:TextField;
      
      public var maxNameTextWidth:Number;
      
      public var rankTextField:TextField;
      
      public var powerTextField:TextField;
      
      public var _injury:GuiIconInjury;
      
      public var _powerCircle:MovieClip;
      
      public var _rim:MovieClip;
      
      public var _enabledBlocker:DisplayObject;
      
      public var _iconEnabled:Boolean = false;
      
      public var _context:IGuiContext;
      
      public var _mouseDown:Boolean = false;
      
      public var _dragEnabled:Boolean = true;
      
      public var _guiIconMouseEnabled:Boolean = true;
      
      public var mouseDownPoint:Point = null;
      
      public var _glow:MovieClip;
      
      public var _dropglow:MovieClip;
      
      protected var _injuryDays:int;
      
      private var _dragStartPos:Point;
      
      private var _mouseMovePos:Point;
      
      private var _didDrag:Boolean;
      
      private var _glowVisible:Boolean;
      
      private var _dropglowVisible:Boolean;
      
      protected var rolledOver:Boolean;
      
      private var theStage:Stage;
      
      private var _cachedRect:Rectangle;
      
      public function GuiIconSlot()
      {
         this._dragStartPos = new Point(0,0);
         this._mouseMovePos = new Point(0,0);
         super();
         GuiUtil.attemptStopAllMovieClips(this);
         this._enabledBlocker = getChildByName("enabledBlocker") as DisplayObject;
         this._injury = getChildByName("injury") as GuiIconInjury;
         this._powerCircle = getChildByName("powerCircle") as GuiIconInjury;
         this._rim = getChildByName("rim") as MovieClip;
      }
      
      public static function cancelAllDrags() : void
      {
         if(draggedSourceIconSlot)
         {
            draggedSourceIconSlot.cancelDrag();
         }
      }
      
      public function cleanup() : void
      {
         this.icon = null;
         this.mouseDown = false;
         if(this._injury)
         {
            this._injury.cleanupGuiBase();
            this._injury = null;
         }
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         removeEventListener(MouseEvent.ROLL_OVER,this.onMouseRollOver);
         removeEventListener(MouseEvent.ROLL_OUT,this.onMouseRollOut);
         this.iconRect = null;
         this.iconCenter = null;
         this.powerTextField = null;
         this.nameTextField = null;
         this.rankTextField = null;
         this._powerCircle = null;
         this._rim = null;
      }
      
      private function checkMouseEnabled() : void
      {
         this.mouseEnabled = this._guiIconMouseEnabled;
         if(!this.mouseEnabled)
         {
            this.mouseDown = false;
         }
      }
      
      public function set blockerVisible(param1:Boolean) : void
      {
         if(this._enabledBlocker)
         {
            this._enabledBlocker.visible = param1;
         }
      }
      
      public function get blockerVisible() : Boolean
      {
         return Boolean(this._enabledBlocker) && this._enabledBlocker.visible;
      }
      
      public function set rimVisible(param1:Boolean) : void
      {
         if(this._rim)
         {
            this._rim.visible = param1;
         }
      }
      
      public function set powerVisible(param1:Boolean) : void
      {
         if(this.powerTextField)
         {
            this.powerTextField.visible = param1;
            if(param1)
            {
            }
         }
         if(this._powerCircle)
         {
            this._powerCircle.visible = param1;
         }
      }
      
      public function get dragEnabled() : Boolean
      {
         return this._dragEnabled;
      }
      
      public function set dragEnabled(param1:Boolean) : void
      {
         this._dragEnabled = param1;
      }
      
      public function init(param1:IGuiContext) : void
      {
         var _loc2_:MovieClip = null;
         this._context = param1;
         this._glow = getChildByName("glow") as MovieClip;
         this._dropglow = getChildByName("dropglow") as MovieClip;
         _loc2_ = getChildByName("placeholderIcon") as MovieClip;
         this._enabledBlocker = getChildByName("enabledBlocker");
         if(_loc2_)
         {
            this.iconIndex = getChildIndex(_loc2_);
            this.iconRect = _loc2_.getBounds(this);
            this.iconCenter = new Point((this.iconRect.x + this.iconRect.width) / 2,(this.iconRect.y + this.iconRect.height) / 2);
            _loc2_.mouseEnabled = false;
            _loc2_.mouseChildren = false;
            _loc2_.visible = false;
         }
         this.powerTextField = getChildByName("textPower") as TextField;
         this.nameTextField = getChildByName("textName") as TextField;
         if(this.nameTextField)
         {
            this.nameTextField.cacheAsBitmap = true;
            this.nameTextField.selectable = false;
            this.nameTextField.mouseEnabled = false;
            this.nameTextField.text = "";
            this.maxNameTextWidth = this.nameTextField.width;
         }
         this.rankTextField = getChildByName("textRank") as TextField;
         if(this.rankTextField)
         {
            this.rankTextField.cacheAsBitmap = true;
            this.rankTextField.mouseEnabled = false;
         }
         this._powerCircle = getChildByName("powerCircle") as MovieClip;
         this._rim = getChildByName("rim") as MovieClip;
         if(this._glow)
         {
            this._glow.mouseEnabled = this._glow.mouseChildren = false;
         }
         if(this._dropglow)
         {
            this._dropglow.mouseEnabled = this._dropglow.mouseChildren = false;
         }
         this.iconEnabled = true;
         this.glowVisible = false;
         this.dropglowVisible = false;
         this.powerVisible = false;
         buttonMode = false;
         this.checkMouseEnabled();
         this.mouseChildren = false;
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseRollOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onMouseRollOut);
         if(this._injury)
         {
            this._injury.init(param1);
            this._injury.mouseEnabled = false;
         }
      }
      
      public function get context() : IGuiContext
      {
         return this._context;
      }
      
      public function set context(param1:IGuiContext) : void
      {
         this._context = param1;
      }
      
      public function get icon() : GuiIcon
      {
         return this._icon;
      }
      
      public function set icon(param1:GuiIcon) : void
      {
         if(this._icon == param1)
         {
            return;
         }
         if(this._icon)
         {
            this._icon.release();
            removeChild(this._icon);
         }
         this._icon = param1;
         if(this._icon)
         {
            this._icon.name = "icon";
            buttonMode = true;
            addChildAt(this._icon,this.iconIndex);
            this._icon.x = this.iconRect.x;
            this._icon.y = this.iconRect.y;
            this._icon.setTargetSize(this.iconRect.width,this.iconRect.height);
            this.blockerVisible = !this.iconEnabled;
            this.powerVisible = this.iconEnabled;
            this.rimVisible = false;
         }
         else
         {
            this.powerVisible = false;
            buttonMode = false;
            this.rimVisible = true;
            this.nameText = null;
            this.blockerVisible = false;
         }
      }
      
      public function get powerText() : String
      {
         return !!this.powerTextField ? this.powerTextField.text : null;
      }
      
      public function set powerText(param1:String) : void
      {
         if(this.powerTextField)
         {
            this.powerTextField.text = !!param1 ? param1 : "";
         }
      }
      
      public function set injuryDays(param1:int) : void
      {
         this._injuryDays = param1;
         if(this._injury)
         {
            this._injury.days = param1;
         }
      }
      
      public function get nameText() : String
      {
         return !!this.nameTextField ? this.nameTextField.text : null;
      }
      
      public function set nameText(param1:String) : void
      {
         if(this.nameTextField)
         {
            this.nameTextField.text = !!param1 ? param1 : "";
            if(this.context)
            {
               this.context.currentLocale.fixTextFieldFormat(this.nameTextField);
            }
            GuiUtil.scaleTextToFit(this.nameTextField,this.maxNameTextWidth);
         }
      }
      
      public function get rankText() : String
      {
         return !!this.rankTextField ? this.nameTextField.text : null;
      }
      
      public function set rankText(param1:String) : void
      {
         if(this.rankTextField)
         {
            this.rankTextField.text = !!param1 ? param1 : "";
         }
      }
      
      public function get iconEnabled() : Boolean
      {
         return this._iconEnabled;
      }
      
      public function set iconEnabled(param1:Boolean) : void
      {
         if(this._iconEnabled == param1)
         {
            return;
         }
         this._iconEnabled = param1;
         this.blockerVisible = !this._iconEnabled;
         this.powerVisible = this._iconEnabled;
      }
      
      public function onMouseDown(param1:MouseEvent) : void
      {
         this.mouseDown = true;
         if(this._icon)
         {
            this._dragStartPos.setTo(param1.stageX,param1.stageY);
         }
      }
      
      public function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!this._dragEnabled)
         {
            return;
         }
         if(this._icon && this.mouseDown && !draggedIconClone)
         {
            this._mouseMovePos.setTo(param1.stageX,param1.stageY);
            _loc2_ = 0.125;
            _loc3_ = stage.stageWidth * Capabilities.screenDPI * _loc2_ / Capabilities.screenResolutionX;
            if(Point.distance(this._dragStartPos,this._mouseMovePos) > _loc3_)
            {
               this._didDrag = true;
               draggedSourceIconSlot = this;
               draggedIconClone = this.createClone(null);
               stage.addChild(draggedIconClone);
               draggedIconClone.startDrag();
               this.dispatchEvent(new GuiIconSlotEvent(GuiIconSlotEvent.DRAG_START));
            }
         }
      }
      
      public function createClone(param1:DisplayObjectContainer) : GuiIcon
      {
         if(!this._icon)
         {
            return null;
         }
         var _loc2_:GuiIcon = this._icon.clone(param1);
         _loc2_.x = this._mouseMovePos.x;
         _loc2_.y = this._mouseMovePos.y;
         _loc2_.mouseChildren = false;
         _loc2_.mouseEnabled = false;
         return _loc2_;
      }
      
      public function mouseUpHandler(param1:MouseEvent) : void
      {
         var _loc4_:Event = null;
         var _loc2_:Point = this.mouseDownPoint;
         var _loc3_:Boolean = this._didDrag;
         this.mouseDown = false;
         if(draggedIconClone)
         {
            this.removeDraggedClone();
            _loc4_ = new GuiIconSlotEvent(GuiIconSlotEvent.DROP);
            if(draggedTargetIconSlot)
            {
               draggedTargetIconSlot.dispatchEvent(_loc4_);
            }
            else
            {
               this.dispatchEvent(_loc4_);
            }
            draggedSourceIconSlot = null;
            this.dispatchEvent(new GuiIconSlotEvent(GuiIconSlotEvent.DRAG_END));
         }
         else if(this.rolledOver && Boolean(_loc2_))
         {
            if(!_loc3_)
            {
               this.press();
            }
         }
      }
      
      public function press() : void
      {
         if(this._context)
         {
            this._context.playSound("ui_generic");
         }
         this.dispatchEvent(new GuiIconSlotEvent(GuiIconSlotEvent.CLICKED));
      }
      
      public function cancelDrag() : void
      {
         if(this == draggedSourceIconSlot)
         {
            this.removeDraggedClone();
            draggedSourceIconSlot = null;
            this.dispatchEvent(new GuiIconSlotEvent(GuiIconSlotEvent.DRAG_END));
         }
      }
      
      private function removeDraggedClone() : void
      {
         if(draggedIconClone)
         {
            this.mouseDown = false;
            draggedIconClone.stopDrag();
            draggedIconClone.release();
            if(draggedIconClone.parent)
            {
               draggedIconClone.parent.removeChild(draggedIconClone);
            }
            draggedIconClone = null;
         }
      }
      
      public function get glowVisible() : Boolean
      {
         return this._glowVisible;
      }
      
      public function set glowVisible(param1:Boolean) : void
      {
         this._glowVisible = param1;
         if(this._glow)
         {
            this._glow.visible = param1;
         }
      }
      
      public function get dropglowVisible() : Boolean
      {
         return this._dropglowVisible;
      }
      
      public function set dropglowVisible(param1:Boolean) : void
      {
         this._dropglowVisible = param1;
         if(this._dropglow)
         {
            this._dropglow.visible = param1;
         }
      }
      
      protected function handleRolledOver() : void
      {
      }
      
      public function onMouseRollOver(param1:MouseEvent) : void
      {
         this.rolledOver = true;
         draggedTargetIconSlot = this;
         this.glowVisible = true;
         this.handleRolledOver();
      }
      
      public function onMouseRollOut(param1:MouseEvent) : void
      {
         this.rolledOver = false;
         if(draggedTargetIconSlot == this)
         {
            draggedTargetIconSlot = null;
         }
         this.glowVisible = false;
         this.handleRolledOver();
      }
      
      public function get guiIconMouseEnabled() : Boolean
      {
         return this._guiIconMouseEnabled;
      }
      
      public function set guiIconMouseEnabled(param1:Boolean) : void
      {
         this._guiIconMouseEnabled = param1;
         this.checkMouseEnabled();
      }
      
      public function get mouseDown() : Boolean
      {
         return this._mouseDown;
      }
      
      public function set mouseDown(param1:Boolean) : void
      {
         if(this._mouseDown == param1)
         {
            return;
         }
         this._didDrag = false;
         this._mouseDown = param1;
         if(!this._mouseDown)
         {
            if(this.theStage)
            {
               this.theStage.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            }
            this.mouseDownPoint = null;
         }
         else if(stage)
         {
            this.theStage = stage;
            stage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            this.mouseDownPoint = new Point(stage.mouseX,stage.mouseY);
         }
      }
      
      public function handleLocaleChange() : void
      {
      }
      
      public function setHovering(param1:Boolean) : void
      {
         this.glowVisible = param1;
      }
      
      public function getNavRectangle(param1:DisplayObject) : Rectangle
      {
         var _loc2_:Point = null;
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc7_:Point = null;
         var _loc8_:Rectangle = null;
         if(Boolean(this.iconRect) && Boolean(param1))
         {
            _loc2_ = new Point(this.iconRect.x,this.iconRect.y);
            _loc3_ = new Point(this.iconRect.right,this.iconRect.bottom);
            _loc4_ = this.localToGlobal(_loc2_);
            _loc5_ = this.localToGlobal(_loc3_);
            _loc6_ = param1.globalToLocal(_loc4_);
            _loc7_ = param1.globalToLocal(_loc5_);
            return new Rectangle(_loc6_.x,_loc6_.y,_loc7_.x - _loc6_.x,_loc7_.y - _loc6_.y);
         }
         if(this._rim)
         {
            return this._rim.getRect(param1);
         }
         if(this._glow)
         {
            return this._glow.getRect(param1);
         }
         return this.getRect(param1);
      }
      
      public function get movieClip() : MovieClip
      {
         return this;
      }
      
      public function get talkieCenterPoint_g() : Point
      {
         if(!this._cachedRect)
         {
            this._cachedRect = getRect(null);
         }
         return localToGlobal(new Point(this._cachedRect.x + this._cachedRect.width / 2,this._cachedRect.y + this._cachedRect.height / 2));
      }
      
      public function set showStatsTooltip(param1:Boolean) : void
      {
      }
      
      public function get showStatsTooltip() : Boolean
      {
         return false;
      }
   }
}
