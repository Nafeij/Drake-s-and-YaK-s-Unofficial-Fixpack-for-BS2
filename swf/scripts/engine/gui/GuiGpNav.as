package engine.gui
{
   import com.dncompute.graphics.GraphicsUtil;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpSource;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class GuiGpNav
   {
      
      public static var DEBUG_RENDER:Boolean;
      
      public static const ORIENTATION_VERTICAL:String = "ORIENTATION_VERTICAL";
      
      public static const ORIENTATION_ALL:String = "ORIENTATION_ALL";
      
      public static const ORIENTATION_HORIZONTAL:String = "ORIENTATION_HORIZONTAL";
      
      private static var mapElapsed:int;
       
      
      private var cmd_space:Cmd;
      
      private var cmd_alt:Cmd;
      
      private var buttons:Vector.<Object>;
      
      private var _selected:Object;
      
      private var _overlay:DisplayObjectContainer;
      
      private var infos:Dictionary;
      
      public var blockNav:Boolean;
      
      private var context:IEngineGuiContext;
      
      private var debugSprite:Sprite;
      
      private var _controlIcon:GuiGpBitmap;
      
      private var decoration:DisplayObject;
      
      public var _decorationScaleDefault:Number = 1;
      
      private var offset:Point;
      
      private var _altIcon:GuiGpBitmap = null;
      
      private var _alternateButton:GpControlButton;
      
      private var _alternateCallback:Function;
      
      private var _callbackNavigate:Function;
      
      private var _callbackPress:Function;
      
      private var _mapped:Boolean;
      
      public var orientation:String = "ORIENTATION_ALL";
      
      public var _alignHControlDefault:GuiGpAlignH;
      
      public var _alignVControlDefault:GuiGpAlignV;
      
      public var _alignHNavDefault:GuiGpAlignH;
      
      public var _alignVNavDefault:GuiGpAlignV;
      
      private var flicker:StickFlicker;
      
      private var addedComponents:int;
      
      private var _scale:Number = 1;
      
      public var pressOnNavigate:Boolean;
      
      private var _navIcons:Array;
      
      private var _navIcon:GuiGpBitmap;
      
      private var _alwaysHintControls:Boolean;
      
      public var doDebug:Boolean;
      
      public var name:String;
      
      private var _alwaysHintNav:Boolean;
      
      private var _dirty:Boolean;
      
      private var _activated:Boolean;
      
      private var gpbindid:int = 0;
      
      private var cleanedup:Boolean;
      
      private var control:DisplayObject;
      
      private var bound:Rectangle;
      
      private var test_direction_distance:Number;
      
      private var test_direction_overlap:Number;
      
      public function GuiGpNav(param1:IEngineGuiContext, param2:String, param3:DisplayObjectContainer, param4:Boolean = true)
      {
         this.buttons = new Vector.<Object>();
         this.infos = new Dictionary();
         this._controlIcon = GuiGp.ctorPrimaryBitmap(GpControlButton.A);
         this.offset = new Point();
         this._alignHControlDefault = GuiGpAlignH.E;
         this._alignVControlDefault = GuiGpAlignV.C;
         this._alignHNavDefault = GuiGpAlignH.W;
         this._alignVNavDefault = GuiGpAlignV.C;
         this._navIcons = [];
         super();
         this._overlay = param3;
         this.context = param1;
         this.name = param2;
         this.cmd_space = new Cmd("guigpnav_sel_" + param2,this.cmdGpSelect);
         this.cmd_alt = new Cmd("guigpnav_alt_" + param2,this.cmdGpAlt);
         var _loc5_:int = 0;
         while(_loc5_ <= 15)
         {
            this._navIcons.push(null);
            _loc5_++;
         }
         this._controlIcon.visible = false;
         if(DEBUG_RENDER)
         {
            this.debugSprite = new Sprite();
            this.debugSprite.mouseChildren = this.debugSprite.mouseEnabled = false;
            this._overlay.addChild(this.debugSprite);
            ++this.addedComponents;
         }
         this.flicker = new StickFlicker(this.flickHandler,param4,true,"gpnav_" + param2,param1.logger);
         this.setIconsVisible(false);
      }
      
      private static function isEnabled(param1:Object) : Boolean
      {
         var _loc2_:IGuiGpNavButton = param1 as IGuiGpNavButton;
         if(Boolean(_loc2_) && !_loc2_.enabled)
         {
            return false;
         }
         return isVisible(param1);
      }
      
      private static function getButtonString(param1:Object) : String
      {
         var _loc2_:DisplayObject = param1 as DisplayObject;
         if(_loc2_)
         {
            return _loc2_ + ": " + _loc2_.name;
         }
         return param1 as String;
      }
      
      private static function isVisible(param1:Object) : Boolean
      {
         var _loc2_:DisplayObject = param1 as DisplayObject;
         if(Boolean(_loc2_) && !_loc2_.visible)
         {
            return false;
         }
         return true;
      }
      
      private static function setHovering(param1:Object, param2:Boolean) : void
      {
         var _loc3_:IGuiGpNavButton = param1 as IGuiGpNavButton;
         if(_loc3_)
         {
            _loc3_.setHovering(param2);
         }
      }
      
      public function get alwaysHintControls() : Boolean
      {
         return this._alwaysHintControls;
      }
      
      public function set alwaysHintControls(param1:Boolean) : void
      {
         if(this._alwaysHintControls == param1)
         {
            return;
         }
         this._alwaysHintControls = param1;
         if(this._controlIcon)
         {
            this._controlIcon.alwaysHint = this._alwaysHintControls;
         }
         if(this._altIcon)
         {
            this._altIcon.alwaysHint = this._alwaysHintControls;
         }
      }
      
      public function get alwaysHintNav() : Boolean
      {
         return this._alwaysHintNav;
      }
      
      public function set alwaysHintNav(param1:Boolean) : void
      {
         var _loc2_:GuiGpBitmap = null;
         if(this._alwaysHintNav == param1)
         {
            return;
         }
         this._alwaysHintNav = param1;
         for each(_loc2_ in this._navIcons)
         {
            if(_loc2_)
            {
               _loc2_.alwaysHint = this._alwaysHintNav;
            }
         }
      }
      
      public function setDirty() : void
      {
         this._dirty = true;
      }
      
      public function update(param1:int) : void
      {
         if(Boolean(this.flicker) && !this.flicker.autoUpdate)
         {
            this.flicker.update(param1);
         }
      }
      
      private function showNavIcon(param1:int) : GuiGpBitmap
      {
         var _loc2_:GuiGpBitmap = null;
         var _loc4_:GuiGpBitmap = null;
         var _loc5_:GpControlButton = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._navIcons.length)
         {
            _loc4_ = this._navIcons[_loc3_];
            if(param1 != _loc3_)
            {
               if(_loc4_)
               {
                  _loc4_.visible = false;
               }
            }
            else
            {
               if(!_loc4_)
               {
                  _loc5_ = GpControlButton.dpad_bits(param1);
                  _loc4_ = GuiGp.ctorPrimaryBitmap(_loc5_,this._alwaysHintNav);
                  _loc4_.scale = this._scale;
                  this._navIcons[param1] = _loc4_;
               }
               if(!_loc4_.parent)
               {
                  this._overlay.addChild(_loc4_);
               }
               _loc4_.visible = this._activated;
               _loc4_.gplayer = this.gpbindid;
               _loc2_ = _loc4_;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function setAlternateButton(param1:GpControlButton, param2:Function) : GuiGpNav
      {
         this._alternateCallback = param2;
         this._alternateButton = param1;
         if(param1)
         {
            this._altIcon = GuiGp.ctorPrimaryBitmap(param1,this._alwaysHintControls);
            this._altIcon.visible = false;
         }
         return this;
      }
      
      public function setCallbackNavigate(param1:Function) : GuiGpNav
      {
         this._callbackNavigate = param1;
         return this;
      }
      
      public function setCallbackPress(param1:Function) : GuiGpNav
      {
         this._callbackPress = param1;
         return this;
      }
      
      public function get isActivated() : Boolean
      {
         return this._activated;
      }
      
      public function activate() : void
      {
         if(this._activated)
         {
            return;
         }
         this._activated = true;
         this.checkMap();
         GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_space,"nav");
         if(this._alternateCallback != null)
         {
            GpBinder.gpbinder.bindPress(this._alternateButton,this.cmd_alt,"nav");
         }
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         this.gpbindid = GpBinder.gpbinder.lastCmdId;
         this.flicker.enabled = true;
         this.setIconsVisible(true);
         if(this._selected)
         {
            setHovering(this._selected,true);
         }
         this.updateIconPlacement();
      }
      
      private function setIconsVisible(param1:Boolean) : void
      {
         this._controlIcon.visible = param1;
         this._controlIcon.gplayer = this.gpbindid;
         if(this._navIcon)
         {
            this._navIcon.visible = param1;
            this._navIcon.gplayer = this.gpbindid;
         }
         if(this._altIcon)
         {
            this._altIcon.visible = param1;
            this._altIcon.gplayer = this.gpbindid;
         }
         if(this.decoration)
         {
            this.decoration.visible = param1;
         }
         if(this.debugSprite)
         {
            this.debugSprite.visible = param1;
         }
      }
      
      public function deactivate() : void
      {
         this.flicker.enabled = false;
         if(!this._activated)
         {
            return;
         }
         this._activated = false;
         this.setIconsVisible(false);
         if(this._selected)
         {
            setHovering(this._selected,false);
         }
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         GpBinder.gpbinder.unbind(this.cmd_space);
         GpBinder.gpbinder.unbind(this.cmd_alt);
         this.setIconsVisible(false);
      }
      
      public function cleanup() : void
      {
         var _loc2_:GuiGpBitmap = null;
         if(this.cleanedup)
         {
            return;
         }
         this.cleanedup = true;
         this.deactivate();
         this.setDecoration(null,1);
         if(this.flicker)
         {
            this.flicker.cleanup();
            this.flicker = null;
         }
         if(this.debugSprite)
         {
            if(this.debugSprite.parent)
            {
               this.debugSprite.parent.removeChild(this.debugSprite);
            }
            this.debugSprite = null;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._navIcons.length)
         {
            _loc2_ = this._navIcons[_loc1_];
            if(_loc2_)
            {
               GuiGp.releasePrimaryBitmap(_loc2_);
            }
            _loc1_++;
         }
         this.buttons = null;
         GuiGp.releasePrimaryBitmap(this._controlIcon);
         GuiGp.releasePrimaryBitmap(this._altIcon);
         this.cmd_space.cleanup();
         this.cmd_alt.cleanup();
         this._callbackNavigate = null;
         this._callbackPress = null;
      }
      
      private function cmdGpSelect(param1:CmdExec) : void
      {
         if(this._controlIcon)
         {
            this._controlIcon.pulse();
         }
         this.press(false);
      }
      
      private function cmdGpAlt(param1:CmdExec) : void
      {
         if(this._selected && this._alternateCallback != null && this.getShowAlt(this._selected))
         {
            this._altIcon.pulse();
            this._alternateCallback(this._selected);
         }
      }
      
      public function getShowAlt(param1:Object) : Boolean
      {
         var _loc2_:Info = this.infos[param1];
         return Boolean(_loc2_) && _loc2_.showAlt;
      }
      
      public function getShowControl(param1:Object) : Boolean
      {
         var _loc2_:Info = this.infos[param1];
         return Boolean(_loc2_) && _loc2_.showControl;
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this.updateIconPlacement();
      }
      
      public function add(param1:Object, param2:Boolean = false, param3:Boolean = true, param4:Boolean = false) : Object
      {
         if(!param1)
         {
            return null;
         }
         this.buttons.push(param1);
         var _loc5_:Info = new Info(this,param1);
         _loc5_.showAlt = param2;
         _loc5_.showControl = param3;
         _loc5_.preventPressOnNavigate = param4;
         _loc5_.setRect(this.getNavBounds(param1));
         this.infos[param1] = _loc5_;
         return param1;
      }
      
      public function getIndexOfObject(param1:Object) : int
      {
         return this.buttons.indexOf(param1);
      }
      
      public function swap(param1:Object, param2:Object, param3:Boolean = false, param4:Boolean = true) : Object
      {
         var _loc7_:int = 0;
         var _loc8_:* = null;
         var _loc9_:Info = null;
         var _loc10_:int = 0;
         if(!param2)
         {
            if(param1)
            {
               _loc7_ = this.buttons.indexOf(param1);
               if(_loc7_ != -1)
               {
                  this.buttons.splice(_loc7_,1);
               }
               this.forceRemap();
            }
            return null;
         }
         var _loc5_:int = this.buttons.indexOf(param1);
         if(_loc5_ != -1)
         {
            this.buttons[_loc5_] = param2;
         }
         else if(this.buttons.indexOf(param2) == -1)
         {
            this.buttons.push(param2);
         }
         var _loc6_:Info = new Info(this,param2);
         _loc6_.showAlt = param3;
         _loc6_.showControl = param4;
         _loc6_.setRect(this.getNavBounds(param2));
         this.infos[param2] = _loc6_;
         if(this._selected == param1)
         {
            this.selected = param2;
         }
         if(param1)
         {
            for(_loc8_ in this.infos)
            {
               _loc9_ = this.infos[_loc8_];
               _loc10_ = 0;
               while(_loc10_ < 4)
               {
                  if(_loc9_.map[_loc10_] == param1)
                  {
                     _loc9_.map[_loc10_] = param2;
                  }
                  if(_loc9_.automap[_loc10_] == param1)
                  {
                     _loc9_.automap[_loc10_] = param2;
                  }
                  _loc10_++;
               }
            }
         }
         this.forceRemap();
         return param2;
      }
      
      public function forceRemap(param1:Boolean = false, param2:Boolean = true) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Info = null;
         this._mapped = false;
         var _loc3_:int = 0;
         while(_loc3_ < this.buttons.length)
         {
            _loc4_ = this.buttons[_loc3_];
            delete this.infos[_loc4_];
            _loc5_ = new Info(this,_loc4_);
            _loc5_.showAlt = param1;
            _loc5_.showControl = param2;
            _loc5_.setRect(this.getNavBounds(_loc4_));
            this.infos[_loc4_] = _loc5_;
            _loc3_++;
         }
         this.checkMap();
      }
      
      public function setAlignControlDefault(param1:GuiGpAlignH, param2:GuiGpAlignV) : void
      {
         var _loc3_:Boolean = false;
         if(Boolean(param1) && this._alignHControlDefault != param1)
         {
            this._alignHControlDefault = param1;
            _loc3_ = true;
         }
         if(Boolean(param2) && this._alignVControlDefault != param2)
         {
            this._alignVControlDefault = param2;
            _loc3_ = true;
         }
         if(_loc3_)
         {
            this.updateIconPlacement();
         }
      }
      
      public function setAlignNavDefault(param1:GuiGpAlignH, param2:GuiGpAlignV) : void
      {
         var _loc3_:Boolean = false;
         if(Boolean(param1) && this._alignHNavDefault != param1)
         {
            this._alignHNavDefault = param1;
            _loc3_ = true;
         }
         if(Boolean(param2) && this._alignVNavDefault != param2)
         {
            this._alignVNavDefault = param2;
            _loc3_ = true;
         }
         if(_loc3_)
         {
            this.updateIconPlacement();
         }
      }
      
      public function setDecorationScale(param1:Object, param2:Number) : Object
      {
         var _loc3_:Info = this.infos[param1];
         if(_loc3_)
         {
            _loc3_._decorationScale = param2;
            if(param1 == this._selected)
            {
               this.updateIconPlacement();
            }
         }
         return param1;
      }
      
      public function setAlignControl(param1:Object, param2:GuiGpAlignH, param3:GuiGpAlignV) : Object
      {
         var _loc4_:Info = this.infos[param1];
         if(_loc4_)
         {
            _loc4_.setAlignControl(param2,param3);
            if(param1 == this._selected)
            {
               this.updateIconPlacement();
            }
         }
         return param1;
      }
      
      public function setAlignNav(param1:Object, param2:GuiGpAlignH, param3:GuiGpAlignV) : Object
      {
         var _loc4_:Info = this.infos[param1];
         if(_loc4_)
         {
            _loc4_.setAlignNav(param2,param3);
            if(param1 == this._selected)
            {
               this.updateIconPlacement();
            }
         }
         return param1;
      }
      
      public function setShowControl(param1:Object, param2:Boolean) : Object
      {
         var _loc3_:Info = this.infos[param1];
         if(_loc3_)
         {
            _loc3_.showControl = param2;
            if(param1 == this._selected)
            {
               this.updateButtons();
               this.updateIconPlacement();
            }
         }
         return param1;
      }
      
      public function setShowAlt(param1:Object, param2:Boolean) : Object
      {
         var _loc3_:Info = this.infos[param1];
         if(_loc3_)
         {
            _loc3_.showAlt = param2;
            if(param1 == this._selected)
            {
               this.updateButtons();
               this.updateIconPlacement();
            }
         }
         return param1;
      }
      
      public function setCaptionTokenControl(param1:Object, param2:String) : Object
      {
         var _loc3_:Info = this.infos[param1];
         if(_loc3_)
         {
            _loc3_.captionTokenControl = param2;
            if(param1 == this._selected)
            {
               this.updateIconCaptions();
            }
         }
         return param1;
      }
      
      public function setCaptionTokenAlt(param1:Object, param2:String) : Object
      {
         var _loc3_:Info = this.infos[param1];
         if(_loc3_)
         {
            _loc3_.captionTokenAlt = param2;
            if(param1 == this._selected)
            {
               this.updateIconCaptions();
            }
         }
         return param1;
      }
      
      public function setSelectIndex(param1:int) : void
      {
         if(this.buttons.length > param1)
         {
            this.setSelected(this.buttons[param1],true);
         }
      }
      
      private function dSqr(param1:Point, param2:Point) : Number
      {
         var _loc3_:Number = param1.x - param2.x;
         var _loc4_:Number = param1.y - param2.y;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_;
      }
      
      public function autoSelect(param1:Boolean = false) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Info = null;
         var _loc4_:Info = null;
         var _loc5_:Info = null;
         var _loc6_:Info = null;
         var _loc7_:Info = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(!GpSource.primaryDevice)
         {
            return;
         }
         if(this._selected)
         {
            if(!isEnabled(this._selected))
            {
               _loc3_ = this.infos[this._selected];
               if(_loc3_)
               {
                  _loc4_ = this.probe(_loc3_,0);
                  _loc5_ = this.probe(_loc3_,1);
                  _loc6_ = this.probe(_loc3_,2);
                  _loc7_ = this.probe(_loc3_,3);
                  _loc8_ = !!_loc4_ ? this.dSqr(_loc3_.center,_loc4_.center) : Number.MAX_VALUE;
                  _loc9_ = !!_loc5_ ? this.dSqr(_loc3_.center,_loc5_.center) : Number.MAX_VALUE;
                  _loc10_ = !!_loc6_ ? this.dSqr(_loc3_.center,_loc6_.center) : Number.MAX_VALUE;
                  _loc11_ = !!_loc7_ ? this.dSqr(_loc3_.center,_loc7_.center) : Number.MAX_VALUE;
                  if(_loc8_ != Number.MAX_VALUE && _loc8_ <= _loc9_ && _loc8_ <= _loc10_ && _loc8_ <= _loc11_)
                  {
                     this.navigate(0);
                  }
                  else if(_loc9_ != Number.MAX_VALUE && _loc9_ <= _loc8_ && _loc9_ <= _loc10_ && _loc9_ <= _loc11_)
                  {
                     this.navigate(1);
                  }
                  else if(_loc10_ != Number.MAX_VALUE && _loc10_ <= _loc8_ && _loc10_ <= _loc9_ && _loc10_ <= _loc11_)
                  {
                     this.navigate(2);
                  }
                  else if(_loc11_ != Number.MAX_VALUE && _loc11_ <= _loc8_ && _loc11_ <= _loc9_ && _loc11_ <= _loc10_)
                  {
                     this.navigate(3);
                  }
               }
               if(Boolean(this._selected) && !isEnabled(this._selected))
               {
                  this.selected = null;
               }
            }
            return;
         }
         for each(_loc2_ in this.buttons)
         {
            if(isEnabled(_loc2_))
            {
               this.selected = _loc2_;
               if(this._selected)
               {
                  if(param1 && this.pressOnNavigate)
                  {
                     this.press(true);
                  }
               }
               return;
            }
         }
      }
      
      public function press(param1:Boolean) : void
      {
         var _loc2_:IGuiGpNavButton = null;
         if(this._selected)
         {
            if(this._callbackPress != null)
            {
               if(this._callbackPress(this._selected,param1))
               {
                  return;
               }
            }
            _loc2_ = this._selected as IGuiGpNavButton;
            if(_loc2_)
            {
               _loc2_.press();
            }
            this.autoSelect();
            setHovering(this._selected,true);
         }
      }
      
      public function navigate(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:Info = null;
         if(this.blockNav)
         {
            return false;
         }
         if(!this._selected)
         {
            this.autoSelect(true);
            return true;
         }
         if(this._callbackNavigate != null)
         {
            _loc3_ = this.buttons.indexOf(this._selected);
            if(this._callbackNavigate(param1,_loc3_,true))
            {
               return true;
            }
         }
         var _loc2_:Info = this.infos[this._selected];
         if(_loc2_)
         {
            _loc4_ = this.probe(_loc2_,param1);
            if(_loc4_)
            {
               this.selected = _loc4_.d;
               if(this._navIcon)
               {
                  this._navIcon.pulse();
               }
               if(this.pressOnNavigate && !_loc4_.preventPressOnNavigate)
               {
                  this.press(true);
               }
               return true;
            }
         }
         return false;
      }
      
      private function probe(param1:Info, param2:int) : Info
      {
         var _loc3_:Dictionary = null;
         var _loc4_:Object = null;
         var _loc5_:Info = null;
         while(param1)
         {
            _loc4_ = param1.map[param2];
            _loc5_ = this.infos[_loc4_];
            if(Boolean(_loc4_) && isEnabled(_loc4_))
            {
               return _loc5_;
            }
            if(!_loc3_)
            {
               _loc3_ = new Dictionary();
            }
            _loc3_[param1] = true;
            param1 = _loc5_;
         }
         return null;
      }
      
      public function down() : Boolean
      {
         return this.navigate(2);
      }
      
      public function up() : Boolean
      {
         return this.navigate(0);
      }
      
      public function left() : Boolean
      {
         return this.navigate(3);
      }
      
      public function right() : Boolean
      {
         return this.navigate(1);
      }
      
      public function get selected() : Object
      {
         return this._selected;
      }
      
      public function get selectedDisplayObject() : DisplayObject
      {
         return this._selected as DisplayObject;
      }
      
      public function playSound() : void
      {
         if(this._selected)
         {
            if(this.context)
            {
               this.context.playSound("ui_movement_button");
            }
         }
      }
      
      public function canSelect(param1:Object) : Boolean
      {
         return this.buttons.indexOf(param1) >= 0 && isEnabled(param1);
      }
      
      private function updateButtons() : void
      {
         var _loc1_:Info = this.infos[this._selected];
         var _loc2_:Boolean = this._selected != null && isVisible(this._selected) && Boolean(_loc1_);
         this._controlIcon.visible = _loc2_ && _loc1_.showControl;
         if(this._altIcon)
         {
            this._altIcon.visible = _loc2_ && _loc1_.showAlt;
         }
         this.cmd_alt.enabled = _loc2_ && _loc1_.showAlt;
      }
      
      public function set selected(param1:Object) : void
      {
         this.setSelected(param1,false);
      }
      
      public function set forceSelected(param1:Object) : void
      {
         this.setSelected(param1,true);
      }
      
      public function setSelected(param1:Object, param2:Boolean = false) : void
      {
         var _loc3_:Object = null;
         if(this._selected == param1 && !param2)
         {
            return;
         }
         this.checkMap();
         this.playSound();
         this._selected = param1;
         this.updateButtons();
         for each(_loc3_ in this.buttons)
         {
            setHovering(_loc3_,_loc3_ == this._selected && isVisible(_loc3_));
         }
         if(this.decoration)
         {
            this.decoration.visible = this._selected != null && isVisible(this._selected);
         }
         if(!this._selected)
         {
            this.setIconsVisible(false);
         }
         this.updateIconPlacement();
      }
      
      final public function updateIconCaptions() : void
      {
         var _loc1_:Info = this.infos[this._selected];
         this.updateCaption(this.context,this._selected,_loc1_,this._controlIcon,!!_loc1_ ? _loc1_.captionTokenControl : null,_loc1_.alignHControl.w ? GuiGpBitmap.CAPTION_LEFT : GuiGpBitmap.CAPTION_RIGHT);
         this.updateCaption(this.context,this._selected,_loc1_,this._altIcon,!!_loc1_ ? _loc1_.captionTokenAlt : null,_loc1_.alignHControl.e ? GuiGpBitmap.CAPTION_RIGHT : GuiGpBitmap.CAPTION_LEFT);
      }
      
      private function updateCaption(param1:IEngineGuiContext, param2:Object, param3:Info, param4:GuiGpBitmap, param5:String, param6:String) : void
      {
         var _loc7_:String = param2 && param4 && param4.visible ? param5 : null;
         if(_loc7_)
         {
            if(!param4.caption)
            {
               ++this.addedComponents;
            }
            param4.createCaption(param1,param6);
            param4.caption.setToken(_loc7_);
            param4.updateCaptionPlacement();
         }
         else if(Boolean(param4) && Boolean(param4.caption))
         {
            param4.caption.setToken(null);
         }
      }
      
      final public function updateIconPlacement() : void
      {
         var _loc1_:Info = null;
         var _loc2_:Rectangle = null;
         var _loc3_:GuiGpAlignH = null;
         var _loc4_:GuiGpAlignV = null;
         var _loc5_:GuiGpAlignH = null;
         var _loc6_:GuiGpAlignV = null;
         if(this._selected)
         {
            _loc1_ = this.infos[this._selected];
            if(!_loc1_)
            {
               return;
            }
            _loc2_ = _loc1_.rect;
            if(this.decoration)
            {
               this.decoration.scaleX = this.decoration.scaleY = _loc1_.decorationScale;
               this.decoration.x = _loc2_.x + _loc2_.width / 4;
               this.decoration.y = _loc2_.y + _loc2_.height / 4;
               this.decoration.visible = true;
               _loc2_ = this.getNavBounds(this.decoration);
            }
            _loc3_ = _loc1_.alignHControl;
            _loc4_ = _loc1_.alignVControl;
            this.placeIcon(this._selected,_loc2_,this._controlIcon,_loc3_,_loc4_);
            this.placeIcon(this._selected,_loc2_,this._altIcon,_loc3_,_loc4_);
            if(this._controlIcon && this._altIcon && this._controlIcon.visible && this._altIcon.visible)
            {
               if(_loc3_.w || _loc3_.e)
               {
                  this._controlIcon.y -= int(this._controlIcon.height / 2);
                  this._altIcon.y += int(this._altIcon.height / 2);
               }
               else
               {
                  this._altIcon.x -= int(this._controlIcon.width / 2);
                  this._controlIcon.x += int(this._altIcon.width / 2);
               }
            }
            this.updateIconCaptions();
            _loc5_ = _loc1_.alignHNav;
            _loc6_ = _loc1_.alignVNav;
            this.placeNavIcons(_loc2_,_loc5_,_loc6_);
         }
      }
      
      private function placeNavIcons(param1:Rectangle, param2:GuiGpAlignH, param3:GuiGpAlignV) : void
      {
         var _loc7_:int = 0;
         if(!this._mapped)
         {
            return;
         }
         var _loc4_:Info = this.infos[this._selected];
         if(!_loc4_)
         {
            this._navIcon = this.showNavIcon(0);
            return;
         }
         this.control = null;
         if(Boolean(this._controlIcon) && this._controlIcon.visible)
         {
            this.control = this._controlIcon;
         }
         else if(Boolean(this._altIcon) && this._altIcon.visible)
         {
            this.control = this._altIcon;
         }
         var _loc5_:Boolean = isVisible(this._selected);
         var _loc6_:uint = 0;
         if(_loc5_)
         {
            _loc7_ = 0;
            while(_loc7_ < 4)
            {
               if(_loc4_.map[_loc7_])
               {
                  _loc6_ |= 1 << _loc7_;
               }
               _loc7_++;
            }
         }
         this._navIcon = this.showNavIcon(_loc6_);
         if(this._navIcon)
         {
            this.placeIcon(this._selected,param1,this._navIcon,param2,param3);
         }
      }
      
      private function getNavBounds(param1:Object) : Rectangle
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:IGuiGpNavButton = param1 as IGuiGpNavButton;
         if(_loc2_)
         {
            return _loc2_.getNavRectangle(this._overlay);
         }
         var _loc3_:DisplayObject = param1 as DisplayObject;
         if(_loc3_)
         {
            return _loc3_.getBounds(this._overlay);
         }
         return null;
      }
      
      private function checkIconShowing(param1:Object, param2:GuiGpBitmap) : Boolean
      {
         var _loc3_:Boolean = GpBinder.gpbinder.topLayer <= this.gpbindid && this._activated;
         if(_loc3_)
         {
            if(param2 == this._altIcon)
            {
               _loc3_ = this.getShowAlt(param1);
            }
            else if(param2 == this._controlIcon)
            {
               _loc3_ = this.getShowControl(param1);
            }
         }
         param2.visible = _loc3_;
         return _loc3_;
      }
      
      private function placeIcon(param1:Object, param2:Rectangle, param3:GuiGpBitmap, param4:GuiGpAlignH, param5:GuiGpAlignV) : void
      {
         if(!param3)
         {
            return;
         }
         if(!this.checkIconShowing(param1,param3))
         {
            return;
         }
         if(param3.visible && !param3.parent)
         {
            this._overlay.addChild(param3);
            ++this.addedComponents;
         }
         if(param1 is DisplayObject)
         {
            GuiGp.placeIcon(param1 as DisplayObject,param2,param3,param4,param5);
         }
         else if(!param2)
         {
            param2 = this.getNavBounds(param1);
            if(param2)
            {
               GuiGp.placeIcon(null,param2,param3,param4,param5);
            }
         }
      }
      
      private function computeBound() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Info = null;
         var _loc4_:Rectangle = null;
         this.bound = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.buttons.length)
         {
            _loc2_ = this.buttons[_loc1_];
            if(isVisible(_loc2_))
            {
               _loc3_ = this.infos[_loc2_];
               _loc4_ = _loc3_.rect;
               if(_loc1_ == 0 || !this.bound)
               {
                  this.bound = _loc4_.clone();
               }
               else
               {
                  this.bound.left = Math.min(this.bound.left,_loc4_.left);
                  this.bound.right = Math.max(this.bound.right,_loc4_.right);
                  this.bound.top = Math.min(this.bound.top,_loc4_.top);
                  this.bound.bottom = Math.max(this.bound.bottom,_loc4_.bottom);
               }
            }
            _loc1_++;
         }
         if(!this.bound)
         {
            this.bound = new Rectangle();
         }
         if(DEBUG_RENDER)
         {
            this.debugSprite.graphics.lineStyle(4,16777215,1);
            this.debugSprite.graphics.drawRect(this.bound.x,this.bound.y,this.bound.width,this.bound.height);
         }
      }
      
      private function expandButtonRects() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         this.computeBound();
         _loc1_ = 0;
         while(_loc1_ < this.buttons.length)
         {
            _loc2_ = this.buttons[_loc1_];
            if(isVisible(_loc2_))
            {
               this.renderRect(_loc2_);
            }
            _loc1_++;
         }
      }
      
      private function renderRect(param1:Object) : void
      {
         var _loc2_:Info = null;
         var _loc3_:Rectangle = null;
         var _loc4_:uint = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(DEBUG_RENDER)
         {
            _loc2_ = this.infos[param1];
            _loc3_ = !!_loc2_ ? _loc2_.rect : null;
            if(_loc3_)
            {
               if(this.doDebug)
               {
                  this.context.logger.info("GuiGpNav [" + this.name + "] renderRect " + getButtonString(param1));
               }
               _loc4_ = 0;
               _loc4_ |= Math.random() * 50 << 8;
               _loc4_ |= 55 + Math.random() * 200 << 16;
               _loc4_ |= 55 + Math.random() * 200 << 0;
               this.debugSprite.graphics.beginFill(_loc4_,0.5);
               this.debugSprite.graphics.lineStyle(1,_loc4_,0.8);
               _loc5_ = (_loc3_.left + _loc3_.right) / 2;
               _loc6_ = (_loc3_.top + _loc3_.bottom) / 2;
               this.debugSprite.graphics.drawRect(_loc3_.x,_loc3_.y,_loc3_.width,_loc3_.height);
               this.debugSprite.graphics.drawCircle(_loc5_,_loc6_,20);
               this.debugSprite.graphics.endFill();
            }
         }
      }
      
      private function shrinkButtonRect(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc6_:Info = null;
         var _loc7_:Rectangle = null;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc2_:Info = this.infos[param1];
         var _loc3_:Rectangle = _loc2_.rect;
         var _loc4_:int = 0;
         while(_loc4_ < this.buttons.length)
         {
            _loc5_ = this.buttons[_loc4_];
            if(param1 != _loc5_)
            {
               _loc6_ = this.infos[_loc5_];
               _loc7_ = _loc6_.rect;
               _loc8_ = _loc7_.top <= _loc3_.top && _loc7_.bottom > _loc3_.top;
               _loc9_ = _loc7_.top <= _loc3_.bottom && _loc7_.bottom > _loc3_.bottom;
               _loc10_ = _loc7_.left <= _loc3_.left && _loc7_.right > _loc3_.left;
               _loc11_ = _loc7_.left <= _loc3_.right && _loc7_.right > _loc3_.right;
               _loc12_ = _loc8_ ? Math.max(0,Math.min(_loc3_.bottom,_loc7_.bottom) - Math.max(_loc3_.top,_loc7_.top)) : 0;
               _loc13_ = _loc9_ ? Math.max(0,Math.min(_loc3_.bottom,_loc7_.bottom) - Math.max(_loc3_.top,_loc7_.top)) : 0;
               _loc14_ = _loc10_ ? Math.max(0,Math.min(_loc3_.right,_loc7_.right) - Math.max(_loc3_.left,_loc7_.left)) : 0;
               _loc15_ = _loc11_ ? Math.max(0,Math.min(_loc3_.right,_loc7_.right) - Math.max(_loc3_.left,_loc7_.left)) : 0;
               if(!(_loc12_ == 0 && _loc13_ == 0))
               {
                  if(!(_loc15_ == 0 && _loc14_ == 0))
                  {
                     if(Boolean(_loc12_) && Boolean(_loc13_))
                     {
                        if(Boolean(_loc14_) && Boolean(_loc15_))
                        {
                           if(_loc7_.x + _loc7_.width / 2 < _loc3_.x + _loc3_.width / 2)
                           {
                              _loc15_ = 0;
                           }
                           else
                           {
                              _loc14_ = 0;
                           }
                           if(_loc7_.y + _loc7_.height / 2 < _loc3_.x + _loc3_.height / 2)
                           {
                              _loc13_ = 0;
                           }
                           else
                           {
                              _loc12_ = 0;
                           }
                        }
                        else
                        {
                           _loc12_ = _loc13_ = 0;
                        }
                     }
                     else if(Boolean(_loc14_) && Boolean(_loc15_))
                     {
                        _loc14_ = _loc15_ = 0;
                     }
                     if(_loc12_)
                     {
                        if(_loc15_ >= _loc12_ || _loc14_ >= _loc12_)
                        {
                           _loc12_ = 0;
                        }
                        else
                        {
                           _loc15_ = _loc14_ = 0;
                        }
                     }
                     else if(_loc13_)
                     {
                        if(_loc15_ >= _loc13_ || _loc14_ >= _loc13_)
                        {
                           _loc13_ = 0;
                        }
                        else
                        {
                           _loc15_ = _loc14_ = 0;
                        }
                     }
                     if(_loc14_)
                     {
                        _loc17_ = Math.ceil(_loc14_ / 2);
                        _loc3_.left += _loc17_;
                        _loc7_.right -= _loc17_ + 1;
                     }
                     else if(_loc15_)
                     {
                        _loc17_ = Math.ceil(_loc15_ / 2);
                        _loc7_.left += _loc17_;
                        _loc3_.right -= _loc17_ + 1;
                     }
                     else if(_loc12_)
                     {
                        _loc17_ = Math.ceil(_loc12_ / 2);
                        _loc3_.top += _loc17_;
                        _loc7_.bottom -= _loc17_ + 1;
                     }
                     else if(_loc13_)
                     {
                        _loc17_ = Math.ceil(_loc13_ / 2);
                        _loc7_.top += _loc17_;
                        _loc3_.bottom -= _loc17_ + 1;
                     }
                     _loc6_.rect.copyFrom(_loc7_);
                  }
               }
            }
            _loc4_++;
         }
         _loc2_.rect.copyFrom(_loc3_);
      }
      
      public function remap() : void
      {
         this.unmap();
         this.checkMap();
      }
      
      public function unmap() : void
      {
         var _loc1_:Info = null;
         if(this.doDebug)
         {
            this.context.logger.info("GuiGpNav [" + this.name + "] unmap");
         }
         this._mapped = false;
         if(this.debugSprite)
         {
            this.debugSprite.graphics.clear();
         }
         this.bound = null;
         for each(_loc1_ in this.infos)
         {
            _loc1_.unmap();
         }
      }
      
      private function checkMap() : void
      {
         var _loc3_:Info = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         if(this._mapped)
         {
            return;
         }
         this._mapped = true;
         var _loc1_:int = getTimer();
         if(this.doDebug)
         {
            this.context.logger.info("GuiGpNav [" + this.name + "] checkMap or=" + this.orientation);
         }
         this.expandButtonRects();
         var _loc2_:int = 0;
         while(_loc2_ < this.buttons.length)
         {
            _loc5_ = this.buttons[_loc2_];
            if(isVisible(_loc5_))
            {
               if(this.orientation == ORIENTATION_HORIZONTAL)
               {
                  this.createLinearMappingFor(_loc2_,1,3);
               }
               else if(this.orientation == ORIENTATION_VERTICAL)
               {
                  this.createLinearMappingFor(_loc2_,0,2);
               }
               else if(this.orientation == ORIENTATION_ALL)
               {
                  this.createMappingFor(_loc5_);
               }
            }
            _loc2_++;
         }
         for each(_loc3_ in this.infos)
         {
            _loc6_ = 0;
            while(_loc6_ < 4)
            {
               if(!_loc3_.map[_loc6_])
               {
                  _loc3_.map[_loc6_] = _loc3_.automap[_loc6_];
               }
               _loc6_++;
            }
         }
         _loc4_ = getTimer();
         mapElapsed += _loc4_ - _loc1_;
         if(Boolean(this._selected) && !isVisible(this._selected))
         {
            if(this.doDebug)
            {
               this.context.logger.info("GuiGpNav [" + this.name + "] checkMap UNSELECTING " + this._selected);
            }
            this.selected = null;
         }
      }
      
      private function createLinearMappingFor(param1:int, param2:int, param3:int) : void
      {
         var _loc6_:Object = null;
         var _loc7_:Info = null;
         var _loc8_:Object = null;
         var _loc9_:Info = null;
         var _loc4_:Object = this.buttons[param1];
         var _loc5_:Info = this.infos[_loc4_];
         if(this.doDebug)
         {
            this.context.logger.info("GuiGpNav [" + this.name + "] createLinearMappingFor index=" + param1 + " b=" + getButtonString(_loc4_) + " info=" + _loc5_);
         }
         if(param1 > 0)
         {
            _loc6_ = this.buttons[param1 - 1];
            if(_loc6_)
            {
               _loc7_ = this.infos[_loc6_];
               if(_loc7_)
               {
                  _loc7_.map[param3] = _loc4_;
                  _loc5_.map[param2] = _loc6_;
               }
            }
         }
         if(param1 < this.buttons.length - 1)
         {
            _loc8_ = this.buttons[param1 + 1];
            if(_loc8_)
            {
               _loc9_ = this.infos[_loc8_];
               if(_loc9_)
               {
                  _loc9_.map[param2] = _loc4_;
                  _loc5_.map[param3] = _loc8_;
               }
            }
         }
      }
      
      private function createMappingFor(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Info = null;
         var _loc7_:int = 0;
         if(this.doDebug)
         {
            this.context.logger.info("GuiGpNav [" + this.name + "] createMappingFor b=" + getButtonString(param1));
         }
         var _loc2_:Info = this.infos[param1];
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            if(!_loc2_.map[_loc3_])
            {
               _loc4_ = this.findMap(param1,_loc3_);
               if(_loc4_)
               {
                  _loc2_.map[_loc3_] = _loc4_;
               }
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            _loc5_ = _loc2_.map[_loc3_];
            if(_loc5_)
            {
               _loc6_ = this.infos[_loc5_];
               _loc7_ = (_loc3_ + 2) % 4;
               _loc6_.automap[_loc7_] = param1;
            }
            _loc3_++;
         }
         if(DEBUG_RENDER)
         {
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               this.drawArrow(param1,_loc3_);
               _loc3_++;
            }
         }
      }
      
      private function drawArrow(param1:Object, param2:int) : void
      {
         var _loc8_:Point = null;
         var _loc11_:Point = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc3_:Info = this.infos[param1];
         var _loc4_:Object = _loc3_.map[param2];
         var _loc5_:Info = this.infos[param1];
         var _loc6_:Info = this.infos[_loc4_];
         var _loc7_:Rectangle = _loc5_.rect;
         var _loc9_:Number = (_loc7_.left + _loc7_.right) / 2;
         var _loc10_:Number = (_loc7_.top + _loc7_.bottom) / 2;
         switch(param2)
         {
            case 0:
               _loc8_ = new Point(_loc9_,_loc10_);
               _loc11_ = new Point(_loc8_.x,_loc8_.y - 20);
               break;
            case 1:
               _loc8_ = new Point(_loc9_,_loc10_);
               _loc11_ = new Point(_loc8_.x + 20,_loc8_.y);
               break;
            case 2:
               _loc8_ = new Point(_loc9_,_loc10_);
               _loc11_ = new Point(_loc8_.x,_loc8_.y + 20);
               break;
            case 3:
               _loc8_ = new Point(_loc9_,_loc10_);
               _loc11_ = new Point(_loc8_.x - 20,_loc8_.y);
         }
         var _loc12_:uint = 16777215;
         var _loc13_:Rectangle = !!_loc6_ ? _loc6_.rect : null;
         var _loc14_:Object = !!_loc6_ ? _loc6_.d : null;
         if(Boolean(_loc13_) && isVisible(_loc14_))
         {
            _loc12_ = 7864183;
            _loc15_ = (_loc13_.left + _loc13_.right) / 2;
            _loc16_ = (_loc13_.top + _loc13_.bottom) / 2;
            switch(param2)
            {
               case 0:
                  _loc12_ = 16711680;
                  _loc11_ = new Point(_loc15_,_loc16_ + 20);
                  break;
               case 1:
                  _loc12_ = 16776960;
                  _loc11_ = new Point(_loc15_ - 20,_loc16_);
                  break;
               case 2:
                  _loc12_ = 65280;
                  _loc11_ = new Point(_loc15_,_loc16_ - 20);
                  break;
               case 3:
                  _loc12_ = 65535;
                  _loc11_ = new Point(_loc15_ + 20,_loc16_);
            }
         }
         this.debugSprite.graphics.beginFill(_loc12_,0.3);
         this.debugSprite.graphics.lineStyle(1,_loc12_,0.5);
         GraphicsUtil.drawArrow(this.debugSprite.graphics,_loc8_,_loc11_);
         this.debugSprite.graphics.endFill();
      }
      
      private function testDirection(param1:Info, param2:Info, param3:int) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         this.test_direction_distance = 0;
         if(param3 == 0 || param3 == 2)
         {
            if(param3 == 0)
            {
               if(param1.top > param2.top + 1 && param1.bottom > param2.bottom + 1)
               {
                  this.test_direction_distance = Math.max(1,param1.top - param2.bottom);
               }
            }
            else if(param2.bottom > param1.bottom + 1 && param2.top > param1.top + 1)
            {
               this.test_direction_distance = Math.max(1,param2.top - param1.bottom);
            }
            if(this.test_direction_distance < 1)
            {
               return false;
            }
            _loc4_ = Math.max(param1.left,param2.left);
            _loc5_ = Math.min(param1.right,param2.right);
            this.test_direction_overlap = _loc5_ - _loc4_;
         }
         else
         {
            if(param3 == 1)
            {
               if(param2.right > param1.right + 1 && param2.left > param1.left + 1)
               {
                  this.test_direction_distance = Math.max(1,param2.left - param1.right);
               }
            }
            else if(param1.left > param2.left + 1 && param1.right > param2.right + 1)
            {
               this.test_direction_distance = Math.max(1,param1.left - param2.right);
            }
            if(this.test_direction_distance < 1)
            {
               return false;
            }
            _loc6_ = Math.max(param1.top,param2.top);
            _loc7_ = Math.min(param1.bottom,param2.bottom);
            this.test_direction_overlap = _loc7_ - _loc6_;
         }
         return true;
      }
      
      private function modDirection(param1:Number, param2:Number, param3:int) : Number
      {
         switch(param3)
         {
            case 1:
            case 3:
               return (1 + Math.abs(param2)) / (1 + Math.abs(param1));
            case 0:
            case 2:
               return (1 + Math.abs(param1)) / (1 + Math.abs(param2));
            default:
               return 0;
         }
      }
      
      private function findMap(param1:Object, param2:int) : Object
      {
         var _loc4_:Object = null;
         var _loc7_:Object = null;
         var _loc11_:Object = null;
         var _loc12_:Info = null;
         var _loc3_:Info = this.infos[param1];
         var _loc5_:Number = Number.MAX_VALUE;
         var _loc6_:Number = 0;
         var _loc8_:Number = Number.MAX_VALUE;
         var _loc9_:Number = -Number.MAX_VALUE;
         var _loc10_:int = 0;
         while(_loc10_ < this.buttons.length)
         {
            _loc11_ = this.buttons[_loc10_];
            if(_loc11_ != param1)
            {
               if(isVisible(_loc11_))
               {
                  _loc12_ = this.infos[_loc11_];
                  if(this.testDirection(_loc3_,_loc12_,param2))
                  {
                     if(this.test_direction_overlap < 0)
                     {
                        if(_loc8_ - _loc9_ > this.test_direction_distance - this.test_direction_overlap)
                        {
                           _loc9_ = this.test_direction_overlap;
                           _loc8_ = this.test_direction_distance;
                           _loc7_ = _loc11_;
                        }
                     }
                     else if(this.test_direction_distance > 0)
                     {
                        if(_loc5_ > this.test_direction_distance || _loc5_ == this.test_direction_distance && this.test_direction_overlap > _loc6_)
                        {
                           _loc5_ = this.test_direction_distance;
                           _loc6_ = this.test_direction_overlap;
                           _loc4_ = _loc11_;
                        }
                     }
                  }
               }
            }
            _loc10_++;
         }
         return !!_loc4_ ? _loc4_ : _loc7_;
      }
      
      private function flickHandler(param1:StickFlicker, param2:int) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         if(Math.abs(param2) > 135)
         {
            if(this.left())
            {
               return;
            }
            _loc3_ = true;
         }
         else if(Math.abs(param2) < 45)
         {
            if(this.right())
            {
               return;
            }
            _loc3_ = true;
         }
         else if(param2 < 0)
         {
            if(this.up())
            {
               return;
            }
            _loc4_ = true;
         }
         else
         {
            if(this.down())
            {
               return;
            }
            _loc4_ = true;
         }
         if(_loc3_)
         {
            if(param2 < -30 && param2 >= -150 && this.up() || param2 >= 30 && param2 <= 150 && this.down())
            {
               return;
            }
         }
         else if(_loc3_)
         {
            if(param2 > -60 && param2 < 60 && this.right() || (param2 < -120 || param2 > 120) && this.left())
            {
               return;
            }
         }
         this.context.playSound("ui_error");
      }
      
      public function setDecoration(param1:DisplayObject, param2:Number) : void
      {
         if(Boolean(this.decoration) && this.decoration != param1)
         {
            if(this.decoration.parent == this._overlay)
            {
               this._overlay.removeChild(this.decoration);
            }
         }
         this.decoration = param1;
         this._decorationScaleDefault = param2;
         if(this.decoration)
         {
            if(Boolean(this.decoration.parent) && this.decoration.parent != this._overlay)
            {
               this.decoration.parent.removeChild(this.decoration);
            }
            if(this.decoration.parent == null)
            {
               this._overlay.addChildAt(this.decoration,this._overlay.numChildren - this.addedComponents);
            }
            if(Boolean(this._navIcon) && Boolean(this._navIcon.parent))
            {
               this._navIcon.parent.removeChild(this._navIcon);
            }
            if(Boolean(this._controlIcon) && Boolean(this._controlIcon.parent))
            {
               this._controlIcon.parent.removeChild(this._controlIcon);
            }
            if(Boolean(this._altIcon) && Boolean(this._altIcon.parent))
            {
               this._altIcon.parent.removeChild(this._altIcon);
            }
            this.updateIconPlacement();
         }
      }
      
      public function get scale() : Number
      {
         return this._scale;
      }
      
      public function set scale(param1:Number) : void
      {
         var _loc3_:GuiGpBitmap = null;
         this._scale = param1;
         if(this._controlIcon)
         {
            this._controlIcon.scale = this._scale;
         }
         if(this._altIcon)
         {
            this._altIcon.scale = this._scale;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._navIcons.length)
         {
            _loc3_ = this._navIcons[_loc2_];
            if(_loc3_)
            {
               _loc3_.scale = this._scale;
            }
            _loc2_++;
         }
      }
      
      public function reactivate() : void
      {
         if(this.isActivated)
         {
            this.deactivate();
            this.activate();
         }
      }
   }
}

import engine.gui.GuiGpAlignH;
import engine.gui.GuiGpAlignV;
import engine.gui.GuiGpNav;
import flash.geom.Point;
import flash.geom.Rectangle;

class Info
{
    
   
   private var nav:GuiGpNav;
   
   public var d:Object;
   
   public var showAlt:Boolean;
   
   public var showControl:Boolean;
   
   public var captionTokenAlt:String;
   
   public var captionTokenControl:String;
   
   public var rect:Rectangle;
   
   public var center:Point;
   
   public var top:Number;
   
   public var left:Number;
   
   public var right:Number;
   
   public var bottom:Number;
   
   public var _alignHControl:GuiGpAlignH;
   
   public var _alignVControl:GuiGpAlignV;
   
   public var _alignHNav:GuiGpAlignH;
   
   public var _alignVNav:GuiGpAlignV;
   
   public var _decorationScale:Number = 1;
   
   public var map:Array;
   
   public var automap:Array;
   
   public var preventPressOnNavigate:Boolean;
   
   public function Info(param1:GuiGpNav, param2:Object)
   {
      this.map = [null,null,null,null];
      this.automap = [null,null,null,null];
      super();
      this.nav = param1;
      this.d = param2;
   }
   
   public function unmap() : void
   {
      this.map = [null,null,null,null];
      this.automap = [null,null,null,null];
   }
   
   public function setRect(param1:Rectangle) : Info
   {
      this.rect = param1;
      this.center = new Point(this.rect.x + Number(this.rect.width) / 2,this.rect.y + Number(this.rect.height) / 2);
      this.left = this.rect.left;
      this.right = this.rect.right;
      this.top = this.rect.top;
      this.bottom = this.rect.bottom;
      return this;
   }
   
   public function setAlignControl(param1:GuiGpAlignH, param2:GuiGpAlignV) : void
   {
      this._alignHControl = param1;
      this._alignVControl = param2;
   }
   
   public function setAlignNav(param1:GuiGpAlignH, param2:GuiGpAlignV) : void
   {
      this._alignHNav = param1;
      this._alignVNav = param2;
   }
   
   public function get alignHControl() : GuiGpAlignH
   {
      return !!this._alignHControl ? this._alignHControl : this.nav._alignHControlDefault;
   }
   
   public function get alignVControl() : GuiGpAlignV
   {
      return !!this._alignVControl ? this._alignVControl : this.nav._alignVControlDefault;
   }
   
   public function get alignHNav() : GuiGpAlignH
   {
      return !!this._alignHNav ? this._alignHNav : this.nav._alignHNavDefault;
   }
   
   public function get alignVNav() : GuiGpAlignV
   {
      return !!this._alignVNav ? this._alignVNav : this.nav._alignVNavDefault;
   }
   
   public function get decorationScale() : Number
   {
      return !isNaN(this._decorationScale) ? Number(this._decorationScale) : Number(this.nav._decorationScaleDefault);
   }
}

class TestData
{
    
   
   public var overlap:Number = 1.7976931348623157e+308;
   
   public var distance:Number = 1.7976931348623157e+308;
   
   public var info:Info;
   
   public function TestData()
   {
      super();
   }
}
