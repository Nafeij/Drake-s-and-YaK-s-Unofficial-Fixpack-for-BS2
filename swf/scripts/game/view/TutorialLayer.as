package game.view
{
   import com.stoicstudio.platform.PlatformFlash;
   import engine.battle.board.view.BattleBoardView;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.gui.IGuiButton;
   import engine.gui.page.Page;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.LandscapeViewBase;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import game.gui.IGuiContext;
   
   public class TutorialLayer extends Page
   {
      
      public static const READY:String = "TutorialLayer.READY";
      
      public static var mcTutArrow:Class;
      
      public static var mcTutCheckButton:Class;
      
      public static var mcTutBlock:Class;
      
      public static var mcTutEyeball:Class;
      
      private static const CLICK_THRESHOLD:Number = 10;
       
      
      public var tooltips:Dictionary;
      
      public var context:IGuiContext;
      
      public var pm:GamePageManagerAdapter;
      
      private var dpiScale:Number = 0;
      
      private var _mouseDownPt:Point;
      
      private var _numTooltips:int;
      
      public function TutorialLayer(param1:ILogger, param2:GamePageManagerAdapter)
      {
         this.tooltips = new Dictionary();
         super("tutorial",param1);
         this.manager = param2;
         this.pm = param2;
         name = "tutorial";
         this.logger = param1;
         anchor.percentHeight = 100;
         anchor.percentWidth = 100;
         this.mouseEnabled = false;
         this.dpiScale = Math.min(1.5,BoundedCamera.dpiFingerScale);
         PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,true);
         PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
      }
      
      public static function findRootObject(param1:Object, param2:String, param3:ILogger, param4:Boolean) : Object
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         if(!param1)
         {
            throw new ArgumentError("Null root");
         }
         if(!param2 || param2 == ".")
         {
            return {
               "object":param1,
               "name":param2
            };
         }
         var _loc5_:int = param2.indexOf("|");
         if(_loc5_ > 0)
         {
            _loc6_ = param2.substring(0,_loc5_);
            _loc7_ = param2.substring(_loc5_ + 1);
            _loc8_ = findChild(param1,_loc6_,param3,param4);
            if(Boolean(_loc8_) && Boolean(_loc8_.object))
            {
               return findRootObject(_loc8_.object,_loc7_,param3,param4);
            }
            return null;
         }
         return findChild(param1,param2,param3,param4);
      }
      
      public static function findChild(param1:Object, param2:String, param3:ILogger, param4:Boolean) : Object
      {
         var _loc7_:DisplayObject = null;
         var _loc8_:DisplayObjectWrapper = null;
         var _loc9_:Object = null;
         if(param1 is DisplayObjectContainer)
         {
            _loc7_ = (param1 as DisplayObjectContainer).getChildByName(param2);
            if(_loc7_)
            {
               return {
                  "object":_loc7_,
                  "name":param2
               };
            }
         }
         if(param2 in param1)
         {
            return {
               "object":param1[param2],
               "name":param2
            };
         }
         var _loc5_:LandscapeViewBase = param1 as LandscapeViewBase;
         if(_loc5_)
         {
            if(param2.charAt(0) == ":")
            {
               param2 = param2.substring(1);
            }
            _loc8_ = _loc5_.getSpriteDisplayFromPath(param2,false);
            if(_loc8_)
            {
               return {
                  "object":_loc8_,
                  "name":param2
               };
            }
         }
         var _loc6_:BattleBoardView = param1 as BattleBoardView;
         if(_loc6_)
         {
            _loc9_ = _loc6_.findBattleBoardObject(param2);
            if(_loc9_)
            {
               return {
                  "object":_loc9_,
                  "name":param2
               };
            }
         }
         if(param4)
         {
            param3.error("No such child [" + param2 + "]");
         }
         return null;
      }
      
      public static function getFullPath(param1:DisplayObject, param2:DisplayObject) : String
      {
         if(param2 == param1)
         {
            return "";
         }
         if(Boolean(param2.parent) && param2.parent != param1)
         {
            return getFullPath(param1,param2.parent) + "|" + param2.name;
         }
         return param2.name;
      }
      
      public static function printDisplayListStatic(param1:DisplayObject, param2:String, param3:int, param4:ILogger, param5:Boolean) : void
      {
         var _loc6_:Object = findRootObject(param1,param2,param4,true);
         if(_loc6_)
         {
            printDisplayListInternal(_loc6_.object,_loc6_.name,"",0,param3,param4,param5);
         }
         else
         {
            param4.info("NOT FOUND");
         }
      }
      
      public static function printDisplayListInternal(param1:Object, param2:String, param3:String, param4:int, param5:int, param6:ILogger, param7:Boolean) : void
      {
         var _loc12_:String = null;
         var _loc13_:* = null;
         var _loc14_:EventDispatcher = null;
         var _loc15_:int = 0;
         var _loc16_:DisplayObject = null;
         var _loc17_:Object = null;
         if(param2 == "console")
         {
            return;
         }
         if(!param1)
         {
            throw new ArgumentError("fail");
         }
         if(param5 > 0 && param4 > param5)
         {
            return;
         }
         var _loc8_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         var _loc9_:InteractiveObject = param1 as InteractiveObject;
         var _loc10_:DisplayObject = param1 as DisplayObject;
         if(!param7 || _loc9_ && _loc9_.mouseEnabled || _loc8_ && _loc8_.mouseChildren)
         {
            _loc13_ = !!param2 ? param3 + param2 + "            " + getQualifiedClassName(param1) : "";
            if(_loc8_)
            {
               _loc13_ += " DOCONT vi=" + _loc8_.visible + " me=" + _loc8_.mouseEnabled + " mc=" + _loc8_.mouseChildren;
            }
            else if(_loc9_)
            {
               _loc13_ += " TEXTFI me=" + _loc9_.mouseEnabled;
            }
            else if(_loc10_)
            {
               _loc13_ += " DISPLA vi=" + _loc10_.visible;
            }
            _loc14_ = param1 as EventDispatcher;
            if(Boolean(_loc14_) && _loc14_.hasEventListener(MouseEvent.MOUSE_DOWN))
            {
               _loc13_ += " LISTENS";
            }
            param6.info(_loc13_);
         }
         var _loc11_:* = param3 + "  ";
         if(_loc8_)
         {
            if(param7)
            {
               if(!_loc8_.mouseChildren)
               {
                  return;
               }
            }
            _loc15_ = 0;
            while(_loc15_ < _loc8_.numChildren)
            {
               _loc16_ = _loc8_.getChildAt(_loc15_);
               printDisplayListInternal(_loc16_,_loc16_.name,_loc11_,param4 + 1,param5,param6,param7);
               _loc15_++;
            }
         }
         for(_loc12_ in param1)
         {
            _loc17_ = param1[_loc12_];
            if(_loc17_)
            {
               printDisplayListInternal(_loc17_,"[" + _loc12_ + "]",_loc11_,param4 + 1,param5,param6,param7);
            }
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         if(this._numTooltips <= 0)
         {
            return;
         }
         var _loc2_:IGuiButton = param1.target as IGuiButton;
         var _loc3_:MovieClip = _loc2_ as MovieClip;
         if(_loc3_ && _loc3_.parent && Boolean(_loc3_.parent.parent))
         {
            if(_loc3_.parent.parent is TutorialTooltip)
            {
               this._mouseDownPt = null;
               return;
            }
         }
         this._mouseDownPt = new Point(param1.stageX,param1.stageY);
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         if(this._numTooltips <= 0)
         {
            return;
         }
         if(!this._mouseDownPt)
         {
            return;
         }
         var _loc2_:Number = Math.abs(param1.stageX - this._mouseDownPt.x);
         var _loc3_:Number = Math.abs(param1.stageY - this._mouseDownPt.y);
         if(_loc2_ > CLICK_THRESHOLD * this.dpiScale || _loc3_ > CLICK_THRESHOLD * this.dpiScale)
         {
            return;
         }
         this.pulseButtons();
         this._mouseDownPt = null;
      }
      
      private function pulseButtons() : void
      {
         var _loc1_:TutorialTooltip = null;
         for each(_loc1_ in this.tooltips)
         {
            _loc1_.pulseButton();
         }
      }
      
      public function get arrow() : MovieClip
      {
         return new mcTutArrow() as MovieClip;
      }
      
      public function get eyeball() : MovieClip
      {
         return new mcTutEyeball() as MovieClip;
      }
      
      public function get button() : IGuiButton
      {
         return new mcTutCheckButton() as IGuiButton;
      }
      
      public function get block() : MovieClip
      {
         return new mcTutBlock() as MovieClip;
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:TutorialTooltip = null;
         super.resizeHandler();
         for each(_loc1_ in this.tooltips)
         {
            _loc1_.handleParentResize();
         }
      }
      
      public function setTooltipVisibleById(param1:int, param2:Boolean) : void
      {
         var _loc3_:TutorialTooltip = this.getTooltipVisibleById(param1);
         if(_loc3_)
         {
            _loc3_.canVisible = param2;
            if(!param2)
            {
               _loc3_.visible = false;
            }
         }
      }
      
      public function getTooltipVisibleById(param1:int) : TutorialTooltip
      {
         var _loc2_:TutorialTooltip = null;
         for each(_loc2_ in this.tooltips)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function get hasTooltips() : Boolean
      {
         return this._numTooltips > 0;
      }
      
      public function createTooltip(param1:String, param2:TutorialTooltipAlign, param3:TutorialTooltipAnchor, param4:Number, param5:String, param6:Boolean, param7:Boolean, param8:Number, param9:Function = null) : TutorialTooltip
      {
         this.pm.showTutorialLayer();
         if(Boolean(param5) && param5.charAt(0) == "$")
         {
            param5 = this.pm.context.locale.translateEncodedToken(param5.substr(1),false);
         }
         var _loc10_:TutorialTooltip = new TutorialTooltip(this,param1,param2,param3,param4,param5,param6,param7,param8,param9);
         addChild(_loc10_);
         _loc10_.update();
         this.tooltips[_loc10_] = _loc10_;
         ++this._numTooltips;
         logger.info("TutorialLayer.createTooltip " + _loc10_);
         this.update(0);
         return _loc10_;
      }
      
      public function removeTooltip(param1:TutorialTooltip) : void
      {
         if(!param1)
         {
            return;
         }
         logger.info("TutorialLayer.removeTooltip " + param1);
         if(param1.parent == this)
         {
            removeChild(param1);
         }
         if(this.tooltips[param1])
         {
            delete this.tooltips[param1];
            --this._numTooltips;
         }
         param1.notifyClosed();
         param1.cleanup();
      }
      
      public function setTooltipNeverClamp(param1:int, param2:Boolean) : void
      {
         var _loc3_:TutorialTooltip = this.getTooltipVisibleById(param1);
         if(_loc3_)
         {
            _loc3_.neverClamp = param2;
         }
      }
      
      public function removeTooltipByHandle(param1:int) : void
      {
         var _loc2_:TutorialTooltip = this.getTooltipVisibleById(param1);
         this.removeTooltip(_loc2_);
      }
      
      public function removeAllTooltips() : void
      {
         var _loc2_:TutorialTooltip = null;
         var _loc1_:Vector.<TutorialTooltip> = new Vector.<TutorialTooltip>();
         for each(_loc2_ in this.tooltips)
         {
            _loc1_.push(_loc2_);
         }
         for each(_loc2_ in _loc1_)
         {
            this.removeTooltip(_loc2_);
         }
      }
      
      override public function update(param1:int) : void
      {
         var _loc2_:TutorialTooltip = null;
         super.update(param1);
         for each(_loc2_ in this.tooltips)
         {
            _loc2_.update();
         }
      }
      
      public function findObject(param1:String, param2:Boolean) : Object
      {
         return findRootObject(parent,param1,logger,param2);
      }
      
      public function updateTutorialTooltipById(param1:int, param2:String) : void
      {
         var _loc3_:TutorialTooltip = null;
         for each(_loc3_ in this.tooltips)
         {
            if(_loc3_.id == param1)
            {
               _loc3_.updateTooltipText(param2);
            }
         }
      }
      
      public function printDisplayList(param1:String, param2:int, param3:Boolean) : void
      {
         var _loc4_:Object = this.findObject(param1,true);
         if(_loc4_)
         {
            printDisplayListInternal(_loc4_.object,_loc4_.name,"",0,param2,logger,param3);
         }
         else
         {
            logger.info("NOT FOUND");
         }
      }
   }
}
