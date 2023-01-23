package engine.landscape.def
{
   import engine.anim.view.ColorPulsatorDef;
   import engine.core.BoxString;
   import engine.landscape.travel.def.LandscapeParamDef;
   import engine.landscape.view.LandscapeViewConfig;
   import engine.saga.ISaga;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.IHappening;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class LandscapeSpriteDef implements ILandscapeSpriteDef
   {
      
      private static var _prereqReason:BoxString = new BoxString();
       
      
      public var nameId:String;
      
      public var _offset:Point;
      
      public var _scale:Point;
      
      public var _reductionScale:Point;
      
      public var rotation:Number = 0;
      
      public var bmp:String;
      
      public var anim:String;
      
      public var clickable:Boolean;
      
      public var hover:String;
      
      public var help:Boolean;
      
      public var label:String;
      
      public var labelOffset:Point;
      
      public var blendMode:String;
      
      public var smoothing:Boolean = true;
      
      public var guidepost:String;
      
      public var layer:LandscapeLayerDef;
      
      public var animPath:LandscapeAnimPathDef;
      
      public var debug:Boolean;
      
      public var happening:String;
      
      public var anchor:Boolean;
      
      public var frame:int = -1;
      
      public var frameVar:String;
      
      public var visible:Boolean = true;
      
      public var autoplay:Boolean = true;
      
      public var popin:Boolean;
      
      public var loops:int = 0;
      
      public var localrect:Rectangle;
      
      public var clickMask:ClickMask;
      
      public var ifCondition:String;
      
      public var colorPulse:ColorPulsatorDef;
      
      public var linked:LandscapeSpriteDef;
      
      public var linkedId:String;
      
      public var linkedFrom:Vector.<LandscapeSpriteDef>;
      
      public var landscapeParams:Vector.<LandscapeParamDef>;
      
      public var langs:String;
      
      public var langsDict:Dictionary;
      
      public var tooltip:LandscapeClickableTooltipDef;
      
      public var landscape:LandscapeDef;
      
      public function LandscapeSpriteDef(param1:LandscapeLayerDef)
      {
         this.localrect = new Rectangle();
         super();
         this.layer = param1;
         this.landscape = param1.landscape;
      }
      
      public function toString() : String
      {
         return (!!this.layer ? this.layer.nameId : "NULL") + "." + this.nameId;
      }
      
      public function createLinkTo(param1:LandscapeSpriteDef) : void
      {
         if(param1 == this)
         {
            throw new IllegalOperationError("no self linking");
         }
         if(param1.linkedId)
         {
            throw new IllegalOperationError("cannot chain links");
         }
         this.linked = param1;
         if(!param1.linkedFrom)
         {
            param1.linkedFrom = new Vector.<LandscapeSpriteDef>();
         }
         param1.linkedFrom.push(this);
      }
      
      public function getScaledRect_o() : Rectangle
      {
         var _loc1_:Number = this.scaleX;
         var _loc2_:Number = this.scaleY;
         return new Rectangle(Math.min(this.localrect.x * _loc1_,this.localrect.right * _loc1_),Math.min(this.localrect.y * _loc2_,this.localrect.right * _loc2_),Math.abs(_loc1_) * this.localrect.width,Math.abs(_loc2_) * this.localrect.height);
      }
      
      public function getScaledRect_p() : Rectangle
      {
         var _loc1_:Rectangle = this.getScaledRect_o();
         _loc1_.x += this.offsetX;
         _loc1_.y += this.offsetY;
         return _loc1_;
      }
      
      public function triggerClick(param1:ISaga) : Boolean
      {
         var _loc2_:HappeningDef = null;
         var _loc3_:IHappening = null;
         if(Boolean(this.happening) && Boolean(param1))
         {
            _loc2_ = param1.getHappeningDefById(this.happening,null);
            if(_loc2_)
            {
               if(_loc2_.checkPrereq(param1,_prereqReason))
               {
                  _loc3_ = param1.executeHappeningDef(_loc2_,this);
                  return _loc3_ != null;
               }
               param1.logger.info("Skipping sprite triggerClick for " + this + " happening " + this.happening + " fails prereq " + _prereqReason[0]);
            }
         }
         return false;
      }
      
      public function cleanup() : void
      {
         this._scale = null;
         this._offset = null;
         this.labelOffset = null;
         this.animPath = null;
         this.layer = null;
         this.localrect = null;
         if(this.clickMask)
         {
            this.clickMask.cleanup();
            this.clickMask = null;
         }
      }
      
      public function checkLang(param1:String) : Boolean
      {
         if(LandscapeViewConfig.EDITOR_MODE)
         {
            return true;
         }
         if(Boolean(this.langsDict) && !this.langsDict[param1])
         {
            return false;
         }
         return true;
      }
      
      public function get parentRect() : Rectangle
      {
         return new Rectangle(this.offsetX,this.offsetY,this.localrect.width * this.scaleX,this.localrect.height * this.scaleY);
      }
      
      public function clone() : LandscapeSpriteDef
      {
         var _loc1_:LandscapeSpriteDef = new LandscapeSpriteDef(this.layer);
         _loc1_.nameId = this.nameId;
         _loc1_._offset = !!this._offset ? this._offset.clone() : null;
         _loc1_._scale = !!this._scale ? this._scale.clone() : null;
         _loc1_.rotation = this.rotation;
         _loc1_.bmp = this.bmp;
         _loc1_.anim = this.anim;
         _loc1_.clickable = this.clickable;
         _loc1_.hover = this.hover;
         _loc1_.help = this.help;
         _loc1_.label = this.label;
         _loc1_.labelOffset = !!this.labelOffset ? this.labelOffset.clone() : null;
         _loc1_.blendMode = this.blendMode;
         _loc1_.smoothing = this.smoothing;
         _loc1_.guidepost = this.guidepost;
         _loc1_.layer = this.layer;
         _loc1_.animPath = !!this.animPath ? this.animPath.clone(_loc1_) : this.animPath;
         _loc1_.debug = this.debug;
         _loc1_.happening = this.happening;
         _loc1_.anchor = this.anchor;
         _loc1_.frame = this.frame;
         _loc1_.visible = this.visible;
         _loc1_.autoplay = this.autoplay;
         _loc1_.popin = this.popin;
         _loc1_.loops = this.loops;
         _loc1_.localrect = !!this.localrect ? this.localrect.clone() : this.localrect;
         _loc1_.linked = this.linked;
         _loc1_.linkedId = this.linkedId;
         if(this.clickMask)
         {
            _loc1_.clickMask = this.clickMask.clone();
         }
         return _loc1_;
      }
      
      public function testClickMask(param1:int, param2:int) : Boolean
      {
         if(!this.clickMask)
         {
            return false;
         }
         return this.clickMask.testClickMask(param1,param2);
      }
      
      public function setClickMask(param1:ClickMask) : void
      {
         this.clickMask = param1;
      }
      
      public function get isAnchor() : Boolean
      {
         return this.anchor;
      }
      
      public function getNameId() : String
      {
         return this.nameId;
      }
      
      public function get scaleX() : Number
      {
         return !!this._scale ? this._scale.x : 1;
      }
      
      public function get scaleY() : Number
      {
         return !!this._scale ? this._scale.y : 1;
      }
      
      public function set scaleX(param1:Number) : void
      {
         if(!this._scale)
         {
            if(param1 == 1)
            {
               return;
            }
            this._scale = new Point(1,1);
         }
         this._scale.x = param1;
      }
      
      public function set scaleY(param1:Number) : void
      {
         if(!this._scale)
         {
            if(param1 == 1)
            {
               return;
            }
            this._scale = new Point(1,1);
         }
         this._scale.y = param1;
      }
      
      public function offsetCopyFrom(param1:Point) : void
      {
         this.offsetSet(param1.x,param1.y);
      }
      
      public function offsetSet(param1:Number, param2:Number) : void
      {
         this.offsetX = param1;
         this.offsetY = param2;
      }
      
      public function offsetAdd(param1:Number, param2:Number) : void
      {
         this.offsetX += param1;
         this.offsetY += param2;
      }
      
      public function offsetAddPt(param1:Point) : void
      {
         this.offsetAdd(param1.x,param1.y);
      }
      
      public function get offsetClone() : Point
      {
         return !!this._offset ? this._offset.clone() : new Point();
      }
      
      public function get offsetX() : Number
      {
         return !!this._offset ? this._offset.x : 0;
      }
      
      public function get offsetY() : Number
      {
         return !!this._offset ? this._offset.y : 0;
      }
      
      public function set offsetX(param1:Number) : void
      {
         if(!this._offset)
         {
            if(param1 == 0)
            {
               return;
            }
            this._offset = new Point();
         }
         this._offset.x = param1;
      }
      
      public function set offsetY(param1:Number) : void
      {
         if(!this._offset)
         {
            if(param1 == 0)
            {
               return;
            }
            this._offset = new Point();
         }
         this._offset.y = param1;
      }
      
      public function get reductionScaleX() : Number
      {
         return !!this._reductionScale ? this._reductionScale.x : 1;
      }
      
      public function get reductionScaleY() : Number
      {
         return !!this._reductionScale ? this._reductionScale.y : 1;
      }
      
      public function set reductionScaleX(param1:Number) : void
      {
         if(!this._reductionScale)
         {
            if(param1 == 1)
            {
               return;
            }
            this._reductionScale = new Point(1,1);
         }
         this._reductionScale.x = param1;
      }
      
      public function set reductionScaleY(param1:Number) : void
      {
         if(!this._reductionScale)
         {
            if(param1 == 1)
            {
               return;
            }
            this._reductionScale = new Point(1,1);
         }
         this._reductionScale.y = param1;
      }
   }
}
