package engine.landscape.def
{
   import engine.core.util.ArrayUtil;
   import engine.core.util.StringUtil;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class LandscapeLayerDef extends EventDispatcher implements ILandscapeLayerDef
   {
      
      public static var LAYER_ID_ACTORS_BACK:String = "layer_actors_back";
      
      public static var LAYER_ID_ACTORS_FACING:String = "layer_actors_facing";
       
      
      public var nameId:String;
      
      public var offset:Point;
      
      public var speed:Number = 0;
      
      public var layerSprites:Vector.<LandscapeSpriteDef>;
      
      public var always:Boolean;
      
      public var randomGroup:String;
      
      public var ifCondition:String;
      
      public var viewIndex:int = -1;
      
      public var notCondition:String;
      
      public var transitory:Point;
      
      public var splines:Vector.<LandscapeSplineDef>;
      
      public var occludes:Array;
      
      public var requireLayer:String;
      
      public var includeLayer:String;
      
      public var editorHidden:Boolean;
      
      public var clickBlocker:Boolean;
      
      public var disableBoundaryAdjust:Boolean;
      
      public var hasTooltips:Boolean;
      
      public var landscape:LandscapeDef;
      
      public var blockInvertLayer:LandscapeLayerDef;
      
      public var blockInvertLayerId:String;
      
      public var blockInvertPrefix:String;
      
      public var _clickBlockerMask:ClickMask;
      
      public var _clickBlockerBlocks:Dictionary;
      
      public function LandscapeLayerDef(param1:LandscapeDef)
      {
         this.offset = new Point();
         this.layerSprites = new Vector.<LandscapeSpriteDef>();
         this.transitory = new Point();
         super();
         this.landscape = param1;
      }
      
      public function cleanup() : void
      {
         var _loc1_:LandscapeSpriteDef = null;
         for each(_loc1_ in this.layerSprites)
         {
            _loc1_.cleanup();
         }
         if(this._clickBlockerMask)
         {
            this._clickBlockerMask.cleanup();
            this._clickBlockerMask = null;
         }
      }
      
      public function resolveLayer() : void
      {
         this.blockInvertLayer = this.landscape.getLayer(this.blockInvertLayerId) as LandscapeLayerDef;
      }
      
      override public function toString() : String
      {
         return this.nameId;
      }
      
      public function get numSplines() : int
      {
         return !!this.splines ? this.splines.length : 0;
      }
      
      public function getPoint(param1:String) : Point
      {
         var _loc2_:LandscapeSpriteDef = this.getSprite(param1);
         if(_loc2_)
         {
            return _loc2_._offset;
         }
         return null;
      }
      
      public function getSplineDef(param1:String) : LandscapeSplineDef
      {
         var _loc2_:LandscapeSplineDef = null;
         if(this.splines)
         {
            for each(_loc2_ in this.splines)
            {
               if(_loc2_.id == param1)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      public function getSprite(param1:String) : LandscapeSpriteDef
      {
         var _loc2_:LandscapeSpriteDef = null;
         for each(_loc2_ in this.layerSprites)
         {
            if(_loc2_.nameId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function createNewAnchor(param1:Number, param2:Number) : LandscapeSpriteDef
      {
         var _loc3_:String = null;
         var _loc4_:int = 1;
         while(_loc4_ < 100)
         {
            _loc3_ = "anchor_" + _loc4_;
            if(!this.getSprite(_loc3_))
            {
               break;
            }
            _loc3_ = null;
            _loc4_++;
         }
         if(!_loc3_)
         {
            return null;
         }
         var _loc5_:LandscapeSpriteDef = new LandscapeSpriteDef(this);
         _loc5_.nameId = _loc3_;
         _loc5_.anchor = true;
         _loc5_.layer = this;
         _loc5_.offsetX = param1;
         _loc5_.offsetY = param2;
         this.layerSprites.push(_loc5_);
         return _loc5_;
      }
      
      public function get occludesString() : String
      {
         if(!this.occludes || this.occludes.length == 0)
         {
            return null;
         }
         return ArrayUtil.toString(this.occludes,",");
      }
      
      public function set occludesString(param1:String) : void
      {
         if(!param1)
         {
            this.occludes = null;
         }
         this.occludes = param1.split(",");
      }
      
      public function cropToBoundary(param1:String, param2:Rectangle, param3:Dictionary) : void
      {
         var _loc9_:LandscapeSpriteDef = null;
         var _loc10_:Rectangle = null;
         var _loc11_:Rectangle = null;
         var _loc12_:int = 0;
         var _loc13_:String = null;
         var _loc14_:* = null;
         var _loc15_:String = null;
         var _loc16_:String = null;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = Math.floor(param2.x);
         var _loc6_:int = Math.floor(param2.y);
         var _loc7_:int = Math.ceil(param2.right);
         var _loc8_:int = Math.ceil(param2.bottom);
         param2.setTo(_loc5_,_loc6_,_loc7_ - _loc5_,_loc8_ - _loc6_);
         for each(_loc9_ in this.layerSprites)
         {
            if(_loc9_.bmp)
            {
               _loc10_ = _loc9_.parentRect;
               _loc11_ = null;
               _loc12_ = 0;
               _loc13_ = this.nameId + "." + _loc9_.nameId;
               _loc14_ = null;
               _loc15_ = _loc9_.bmp;
               _loc16_ = StringUtil.padLeft(_loc4_.toString(),"0",3);
               _loc4_++;
               _loc14_ = param1 + "_" + _loc9_.nameId + "_" + _loc16_ + ".png";
               if(_loc9_.rotation == 0 && !_loc10_.isEmpty() && !_loc9_.animPath && !_loc9_.clickable)
               {
                  _loc11_ = _loc10_.intersection(param2);
                  _loc17_ = _loc9_.localrect.width * _loc9_.localrect.height;
                  if(!_loc11_ || _loc11_.equals(_loc10_))
                  {
                     _loc11_ = null;
                     _loc9_.bmp = _loc14_;
                  }
                  else
                  {
                     if(!_loc11_.isEmpty())
                     {
                        _loc11_.width /= _loc9_.scaleX;
                        _loc11_.height /= _loc9_.scaleY;
                        _loc11_.x -= _loc9_.offsetX;
                        _loc11_.y -= _loc9_.offsetY;
                        _loc9_.offsetX += _loc11_.x;
                        _loc9_.offsetY += _loc11_.y;
                        _loc9_.localrect.setTo(0,0,_loc11_.width,_loc11_.height);
                        _loc9_.bmp = _loc14_;
                     }
                     else
                     {
                        _loc9_.localrect.setTo(0,0,0,0);
                        _loc9_.bmp = "";
                     }
                     _loc18_ = _loc9_.localrect.width * _loc9_.localrect.height;
                     _loc12_ = _loc17_ - _loc18_;
                  }
               }
               param3[_loc13_] = {
                  "resultid":_loc13_,
                  "url":_loc15_,
                  "savings":_loc12_,
                  "newurl":_loc14_,
                  "section":_loc11_
               };
            }
         }
      }
      
      public function reduceTextures(param1:String, param2:Number, param3:Dictionary) : void
      {
         var _loc5_:LandscapeSpriteDef = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:* = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc4_:int = 0;
         for each(_loc5_ in this.layerSprites)
         {
            if(_loc5_.bmp)
            {
               _loc6_ = 0;
               _loc7_ = this.nameId + "." + _loc5_.nameId;
               _loc8_ = null;
               _loc9_ = _loc5_.bmp;
               _loc10_ = StringUtil.padLeft(_loc4_.toString(),"0",3);
               _loc4_++;
               _loc8_ = param1 + "_" + _loc5_.nameId + "_" + _loc10_ + ".png";
               if(_loc5_.bmp)
               {
                  _loc11_ = _loc5_.localrect.width * _loc5_.localrect.height;
                  _loc12_ = Math.max(1,_loc5_.localrect.height * param2);
                  _loc13_ = Math.max(1,_loc5_.localrect.width * param2);
                  _loc5_.scaleX *= _loc5_.localrect.width / _loc13_;
                  _loc5_.scaleY *= _loc5_.localrect.height / _loc12_;
                  _loc5_.bmp = _loc8_;
                  _loc14_ = _loc5_.localrect.width * _loc5_.localrect.height;
                  _loc6_ = _loc11_ - _loc14_;
                  param3[_loc7_] = {
                     "resultid":_loc7_,
                     "url":_loc9_,
                     "savings":_loc6_,
                     "newurl":_loc8_,
                     "newWidth":_loc13_,
                     "newHeight":_loc12_
                  };
               }
            }
         }
      }
      
      public function tileLayerBitmaps(param1:String, param2:Array) : void
      {
         var _loc6_:LandscapeSpriteDef = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc3_:int = 2048;
         var _loc4_:Vector.<LandscapeSpriteDef> = new Vector.<LandscapeSpriteDef>();
         var _loc5_:String = StringUtil.getFolder(param1);
         for each(_loc6_ in this.layerSprites)
         {
            if(!_loc6_.bmp)
            {
               _loc4_.push(_loc6_);
            }
            else
            {
               if(!_loc6_.animPath && !_loc6_.clickable)
               {
                  _loc7_ = _loc6_.localrect.width;
                  _loc8_ = _loc6_.localrect.height;
                  _loc9_ = _loc7_ > _loc3_ || _loc8_ > _loc3_;
                  if(_loc9_)
                  {
                     this.tileOneSprite(_loc6_,_loc7_,_loc8_,_loc3_,_loc4_,param2,_loc5_);
                     continue;
                  }
               }
               _loc4_.push(_loc6_);
            }
         }
         this.layerSprites = _loc4_;
      }
      
      private function tileOneSprite(param1:LandscapeSpriteDef, param2:int, param3:int, param4:int, param5:Vector.<LandscapeSpriteDef>, param6:Array, param7:String) : void
      {
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:LandscapeSpriteDef = null;
         var _loc17_:Rectangle = null;
         var _loc18_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = param1.bmp;
         var _loc10_:String = StringUtil.getBasename(param1.bmp);
         _loc8_ = StringUtil.stripSuffix(param1.bmp,".png");
         var _loc11_:String = this.nameId + "." + param1.nameId;
         var _loc12_:int = 0;
         while(_loc12_ < param2)
         {
            _loc13_ = 0;
            while(_loc13_ < param3)
            {
               _loc14_ = Math.min(param4,param2 - _loc12_);
               _loc15_ = Math.min(param4,param3 - _loc13_);
               _loc16_ = param1.clone();
               _loc17_ = new Rectangle(_loc12_,_loc13_,_loc14_,_loc15_);
               _loc16_.offsetX += _loc17_.x * _loc16_.scaleX;
               _loc16_.offsetY += _loc17_.y * _loc16_.scaleY;
               _loc16_.localrect.setTo(0,0,_loc14_,_loc15_);
               _loc18_ = "_" + _loc12_.toString() + "x" + _loc13_.toString();
               _loc16_.bmp = _loc8_ + _loc18_ + ".png";
               _loc16_.nameId += _loc18_;
               param5.push(_loc16_);
               param6.push({
                  "resultid":_loc11_,
                  "url":_loc9_,
                  "newurl":_loc16_.bmp,
                  "section":_loc17_
               });
               _loc13_ += param4;
            }
            _loc12_ += param4;
         }
      }
      
      public function testClickBlockerMaskContains(param1:LandscapeSpriteDef, param2:ClickMaskTestResult) : void
      {
         param2.reset();
         if(!this._clickBlockerMask || !param1 || !param1.clickMask)
         {
            return;
         }
         var _loc3_:int = param1.layer.offset.x + param1.offsetX - this.offset.x - this._clickBlockerMask.x;
         var _loc4_:int = param1.layer.offset.y + param1.offsetY - this.offset.y - this._clickBlockerMask.y;
         this._clickBlockerMask.testClickMaskContains(param1.clickMask,_loc3_,_loc4_,param2);
      }
      
      public function testClickBlockerMask(param1:int, param2:int) : Boolean
      {
         if(!this._clickBlockerMask)
         {
            return false;
         }
         var _loc3_:int = param1 - this._clickBlockerMask.x;
         var _loc4_:int = param2 - this._clickBlockerMask.y;
         return this._clickBlockerMask.testClickMask(_loc3_,_loc4_);
      }
      
      public function getOffset() : Point
      {
         return this.offset;
      }
      
      public function setClickBlockerMask(param1:ClickMask, param2:Dictionary) : void
      {
         this._clickBlockerMask = param1;
         this._clickBlockerBlocks = param2;
      }
      
      public function get numSprites() : int
      {
         return this.layerSprites.length;
      }
      
      public function getSpriteAt(param1:int) : ILandscapeSpriteDef
      {
         return this.layerSprites[param1];
      }
      
      public function getNameId() : String
      {
         return this.nameId;
      }
      
      public function removeSprite(param1:LandscapeSpriteDef) : void
      {
         var _loc2_:int = this.layerSprites.indexOf(param1);
         if(_loc2_ >= 0)
         {
            param1.layer = null;
            ArrayUtil.removeAt(this.layerSprites,_loc2_);
         }
      }
      
      public function addSprite(param1:LandscapeSpriteDef) : void
      {
         this.layerSprites.push(param1);
         param1.layer = this;
      }
   }
}
