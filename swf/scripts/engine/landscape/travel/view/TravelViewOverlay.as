package engine.landscape.travel.view
{
   import engine.core.math.spline.CatmullRomSpline2d;
   import engine.core.render.BoundedCamera;
   import engine.gui.core.GuiSprite;
   import engine.landscape.travel.def.TravelDefLocationEvent;
   import engine.landscape.travel.def.TravelDefLocationsEvent;
   import engine.landscape.travel.def.TravelDefPointEvent;
   import engine.landscape.travel.def.TravelDefSplineEvent;
   import engine.landscape.travel.def.TravelLocationDef;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import engine.landscape.view.LandscapeViewBase;
   import engine.math.MathUtil;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class TravelViewOverlay extends GuiSprite
   {
      
      public static const EVENT_SELECTED_POINT:String = "TravelViewOverlay.EVENT_SELECTED_POINT";
      
      public static const EVENT_SELECTED_LOCATION:String = "TravelViewOverlay.EVENT_SELECTED_LOCATION";
       
      
      public var travel:Travel;
      
      public var landscapeView:LandscapeViewBase;
      
      public var splineSprite:Sprite;
      
      public var splineShapes:Vector.<Shape>;
      
      private var _showSpline:Boolean;
      
      private var _showPoints:Boolean;
      
      private var _showLimits:Boolean;
      
      private var _showLocations:Boolean;
      
      private var _selectedPointIndex:int = -1;
      
      private var _hoverPointIndex:int = -1;
      
      private var _selectedLocationIndex:int = -1;
      
      private var _hoverLocationIndex:int = -1;
      
      private var _hoverT:Number = 0.5;
      
      private var hoverTSprite:Sprite;
      
      public var travelView:TravelView;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      public var _spline:CatmullRomSpline2d;
      
      private var hoverColor:int = 6749952;
      
      private var selectColor:int = 16776960;
      
      private var textsPoints:Vector.<TextField>;
      
      private var textsLocations:Vector.<TextField>;
      
      public function TravelViewOverlay(param1:TravelView)
      {
         this.splineSprite = new Sprite();
         this.splineShapes = new Vector.<Shape>();
         this.hoverTSprite = new Sprite();
         this.textsPoints = new Vector.<TextField>();
         this.textsLocations = new Vector.<TextField>();
         super();
         this.displayObjectWrapper = new DisplayObjectWrapperFlash(this);
         name = "travelView";
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.travelView = param1;
         this.travel = param1.travel;
         this.updateActiveSpline();
         this.travel.def.addEventListener(TravelDefSplineEvent.TYPE,this.splineHandler);
         this.travel.def.addEventListener(TravelDefPointEvent.TYPE,this.splineHandler);
         this.travel.def.addEventListener(TravelDefLocationEvent.TYPE,this.splineHandler);
         this.travel.def.addEventListener(TravelDefLocationsEvent.TYPE,this.splineHandler);
         this.landscapeView = param1.landscapeView;
         addChild(this.splineSprite);
         this.drawSpline();
         if(this.landscapeView.camera.drift)
         {
            this.landscapeView.camera.drift.CAMERA_SNAP_THRESHOLD = 10;
         }
         this.hoverTSprite.graphics.lineStyle(3,16711680);
         this.hoverTSprite.graphics.moveTo(0,0);
         this.hoverTSprite.graphics.lineTo(-10,-30);
         this.hoverTSprite.graphics.lineTo(0,-20);
         this.hoverTSprite.graphics.lineTo(10,-30);
         this.hoverTSprite.graphics.lineTo(0,0);
      }
      
      public function get hoverT() : Number
      {
         return this._hoverT;
      }
      
      public function set hoverT(param1:Number) : void
      {
         var _loc2_:Point = null;
         if(this._hoverT == param1)
         {
            return;
         }
         this._hoverT = param1;
         if(this.hoverTSprite.parent)
         {
            _loc2_ = new Point();
            this._spline.sample(this._hoverT,_loc2_);
            this.hoverTSprite.x = _loc2_.x;
            this.hoverTSprite.y = _loc2_.y;
         }
      }
      
      override public function cleanup() : void
      {
         removeAllChildren();
         this.travel.def.removeEventListener(TravelDefSplineEvent.TYPE,this.splineHandler);
         this.travel.def.removeEventListener(TravelDefPointEvent.TYPE,this.splineHandler);
         this.travel.def.removeEventListener(TravelDefLocationEvent.TYPE,this.splineHandler);
         this.travel.def.removeEventListener(TravelDefLocationsEvent.TYPE,this.splineHandler);
         this.travel = null;
         this.landscapeView = null;
         super.cleanup();
      }
      
      private function splineHandler(param1:Event) : void
      {
         this.draw();
      }
      
      public function get hoverPointIndex() : int
      {
         return this._hoverPointIndex;
      }
      
      public function set hoverPointIndex(param1:int) : void
      {
         if(this._hoverPointIndex == param1)
         {
            return;
         }
         this._hoverPointIndex = param1;
         if(this._hoverPointIndex >= 0)
         {
            this.hoverLocationIndex = -1;
         }
         this.draw();
      }
      
      public function get hoverLocationIndex() : int
      {
         return this._hoverLocationIndex;
      }
      
      public function set hoverLocationIndex(param1:int) : void
      {
         if(this._hoverLocationIndex == param1)
         {
            return;
         }
         this._hoverLocationIndex = param1;
         if(this._hoverLocationIndex >= 0)
         {
            this.hoverPointIndex = -1;
         }
         this.draw();
      }
      
      private function drawSplineSegments() : void
      {
         var _loc1_:int = 0;
         var _loc3_:TextField = null;
         if(!this._showPoints && this._selectedPointIndex < 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this.textsPoints.length)
            {
               this.textsPoints[_loc1_].visible = false;
               _loc1_++;
            }
            return;
         }
         var _loc2_:Point = null;
         graphics.lineStyle(2,16737792);
         _loc1_ = 0;
         while(_loc1_ < this._spline.points.length)
         {
            _loc2_ = this._spline.points[_loc1_];
            graphics.drawRect(_loc2_.x - 3,_loc2_.y - 3,7,7);
            if(_loc1_ == this._selectedPointIndex)
            {
               graphics.lineStyle(3,this.selectColor);
               graphics.drawRect(_loc2_.x - 6,_loc2_.y - 6,13,13);
               graphics.lineStyle(2,16737792);
            }
            if(_loc1_ == this._hoverPointIndex)
            {
               graphics.lineStyle(3,this.hoverColor);
               graphics.drawCircle(_loc2_.x,_loc2_.y,7);
               graphics.lineStyle(2,16737792);
            }
            _loc3_ = null;
            if(_loc1_ < this.textsPoints.length)
            {
               _loc3_ = this.textsPoints[_loc1_];
               _loc3_.visible = true;
            }
            else
            {
               _loc3_ = new TextField();
               this.textsPoints.push(_loc3_);
               _loc3_.defaultTextFormat = new TextFormat(null,12,0,true);
               _loc3_.width = 200;
               _loc3_.mouseEnabled = false;
               _loc3_.text = _loc1_.toString();
               _loc3_.width = _loc3_.textWidth + 10;
               _loc3_.height = _loc3_.textHeight + 2;
               _loc3_.opaqueBackground = 16772812;
               _loc3_.cacheAsBitmap = true;
               addChild(_loc3_);
            }
            _loc3_.x = _loc2_.x;
            _loc3_.y = _loc2_.y + 15;
            _loc3_.visible = true;
            _loc1_++;
         }
         while(_loc1_ < this.textsPoints.length)
         {
            this.textsPoints[_loc1_].visible = false;
            _loc1_++;
         }
      }
      
      private function drawLocations() : void
      {
         var _loc1_:int = 0;
         var _loc3_:TextField = null;
         var _loc4_:TravelLocationDef = null;
         var _loc5_:Number = NaN;
         var _loc6_:TextField = null;
         if(!this._showLocations && this._selectedLocationIndex < 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this.textsLocations.length)
            {
               this.textsLocations[_loc1_].visible = false;
               _loc1_++;
            }
            return;
         }
         var _loc2_:Point = new Point();
         _loc1_ = 0;
         while(_loc1_ < this.travel.def.locations.length)
         {
            _loc4_ = this.travel.def.locations[_loc1_];
            _loc5_ = _loc4_.position / this._spline.totalLength;
            this._spline.sample(_loc5_,_loc2_);
            if(_loc4_.loadBarrier)
            {
               graphics.lineStyle(1,11206536,0.5);
               graphics.moveTo(_loc2_.x,_loc2_.y - 500);
               graphics.lineTo(_loc2_.x,_loc2_.y + 500);
            }
            graphics.lineStyle(2,16711816,1);
            graphics.moveTo(_loc2_.x,_loc2_.y - 20);
            graphics.lineTo(_loc2_.x,_loc2_.y + 20);
            if(_loc4_.mapkey)
            {
               graphics.lineStyle(5,16755336);
               graphics.moveTo(_loc2_.x,_loc2_.y - 20);
               graphics.lineTo(_loc2_.x,_loc2_.y - 60);
            }
            if(_loc1_ == this._selectedLocationIndex)
            {
               graphics.lineStyle(3,this.selectColor);
               graphics.drawRect(_loc2_.x - 3,_loc2_.y - 25 - 3,7,25 + 25 + 3 + 3);
               graphics.lineStyle(2,16711816);
            }
            else if(_loc1_ == this._hoverLocationIndex)
            {
               graphics.lineStyle(3,this.hoverColor);
               graphics.drawRect(_loc2_.x - 6,_loc2_.y - 25 - 6,6 + 6,25 + 25 + 6 + 6);
               graphics.lineStyle(2,16711816);
            }
            _loc6_ = null;
            if(_loc1_ < this.textsLocations.length)
            {
               _loc6_ = this.textsLocations[_loc1_];
               _loc6_.visible = true;
            }
            else
            {
               _loc6_ = new TextField();
               this.textsLocations.push(_loc6_);
               _loc6_.defaultTextFormat = new TextFormat(null,16,0,true);
               _loc6_.width = 200;
               _loc6_.mouseEnabled = false;
               _loc6_.cacheAsBitmap = true;
               _loc6_.opaqueBackground = 16764142;
               addChild(_loc6_);
            }
            _loc6_.text = _loc1_.toString() + " " + _loc4_.id;
            _loc6_.width = _loc6_.textWidth + 10;
            _loc6_.height = _loc6_.textHeight + 2;
            _loc6_.x = _loc2_.x - _loc6_.width / 2;
            _loc6_.y = _loc2_.y - 40;
            if(Boolean(_loc3_) && _loc6_.hitTestObject(_loc3_))
            {
               _loc6_.y = _loc3_.y - _loc6_.height - 5;
            }
            _loc3_ = _loc6_;
            _loc1_++;
         }
         while(_loc1_ < this.textsLocations.length)
         {
            this.textsLocations[_loc1_].visible = false;
            _loc1_++;
         }
      }
      
      private function drawEndMarkers() : void
      {
         var _loc1_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!this._showLimits)
         {
            return;
         }
         _loc1_ = this.travel.def.spline_start / this._spline.totalLength;
         var _loc2_:Point = this._spline.sample(_loc1_,new Point());
         _loc3_ = this.travel.def.spline_end / this._spline.totalLength;
         var _loc4_:Point = this._spline.sample(_loc3_,new Point());
         graphics.lineStyle(3,4521898);
         graphics.moveTo(_loc2_.x,_loc2_.y - 50);
         graphics.lineTo(_loc2_.x,_loc2_.y + 50);
         graphics.moveTo(_loc2_.x + 20,_loc2_.y - 20);
         graphics.lineTo(_loc2_.x,_loc2_.y + 0);
         graphics.lineTo(_loc2_.x + 20,_loc2_.y + 20);
         graphics.lineStyle(3,2271999);
         graphics.moveTo(_loc4_.x,_loc4_.y - 50);
         graphics.lineTo(_loc4_.x,_loc4_.y + 50);
         graphics.moveTo(_loc4_.x - 20,_loc4_.y - 20);
         graphics.lineTo(_loc4_.x,_loc4_.y + 0);
         graphics.lineTo(_loc4_.x - 20,_loc4_.y + 20);
      }
      
      public function draw() : void
      {
         this.hoverTSprite.visible = this._selectedLocationIndex < 1 && this._selectedPointIndex < 1;
         graphics.clear();
         this.drawSpline();
         this.drawSplineSegments();
         this.drawEndMarkers();
         this.drawLocations();
      }
      
      private function drawControl(param1:Graphics, param2:Point, param3:Point) : void
      {
         param1.lineStyle(2,16711680,0.7);
         var _loc4_:Point = new Point(param3.x - param2.x,param3.y - param2.y);
         var _loc5_:Point = _loc4_.clone();
         _loc5_.normalize(1);
         param1.moveTo(param2.x - _loc5_.x * 100,param2.y - _loc5_.y * 100);
         param1.lineTo(param3.x + _loc5_.x * 100,param3.y + _loc5_.y * 100);
      }
      
      public function drawSpline() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Point = null;
         var _loc6_:Shape = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Boolean = false;
         var _loc10_:Number = NaN;
         var _loc1_:Graphics = this.splineSprite.graphics;
         var _loc2_:int = 0;
         _loc1_.clear();
         if(this._showSpline)
         {
            this.drawControl(_loc1_,this._spline.points[0],this._spline.points[1]);
            this.drawControl(_loc1_,this._spline.points[this._spline.points.length - 1],this._spline.points[this._spline.points.length - 2]);
            _loc3_ = 20 / this._spline.totalLength;
            _loc4_ = -1;
            _loc5_ = new Point();
            _loc2_ = 0;
            while(_loc2_ < this._spline.points.length - 1)
            {
               if(_loc2_ >= this.splineShapes.length)
               {
                  _loc6_ = new Shape();
                  this.splineShapes.push(_loc6_);
               }
               else
               {
                  _loc6_ = this.splineShapes[_loc2_];
               }
               if(!_loc6_.parent)
               {
                  this.splineSprite.addChild(_loc6_);
                  _loc6_.visible = true;
               }
               _loc6_.graphics.clear();
               _loc6_.graphics.lineStyle(2,6749952);
               _loc7_ = _loc4_ >= 0 ? _loc4_ : this._spline.getPointParameter(_loc2_);
               _loc8_ = this._spline.getPointParameter(_loc2_ + 1);
               _loc9_ = false;
               _loc10_ = _loc7_;
               while(_loc10_ <= _loc8_)
               {
                  if(_loc4_ < 0)
                  {
                     this._spline.sample(_loc10_,_loc5_);
                  }
                  else
                  {
                     _loc4_ = -1;
                  }
                  if(_loc9_)
                  {
                     _loc6_.graphics.lineTo(_loc5_.x,_loc5_.y);
                  }
                  else
                  {
                     _loc9_ = true;
                     _loc6_.graphics.moveTo(_loc5_.x,_loc5_.y);
                  }
                  if(_loc10_ >= _loc8_)
                  {
                     break;
                  }
                  _loc10_ = Math.min(_loc8_,_loc10_ + _loc3_);
               }
               _loc6_.cacheAsBitmap = true;
               _loc4_ = _loc8_;
               _loc2_++;
            }
         }
         while(_loc2_ < this.splineShapes.length)
         {
            _loc6_ = this.splineShapes[_loc2_];
            _loc6_.graphics.clear();
            if(this.splineSprite == _loc6_.parent)
            {
               this.splineSprite.removeChild(_loc6_);
            }
            _loc6_.visible = false;
            _loc2_++;
         }
      }
      
      public function get showSpline() : Boolean
      {
         return this._showSpline;
      }
      
      public function set showSpline(param1:Boolean) : void
      {
         if(this._showSpline == param1)
         {
            return;
         }
         this._showSpline = param1;
         if(this._showSpline)
         {
            if(this.hoverTSprite.parent == null)
            {
               addChild(this.hoverTSprite);
            }
            this.onHover();
         }
         else if(this.hoverTSprite.parent == this)
         {
            this.removeChild(this.hoverTSprite);
         }
         this.draw();
      }
      
      public function get showPoints() : Boolean
      {
         return this._showPoints;
      }
      
      public function set showPoints(param1:Boolean) : void
      {
         var _loc2_:TextField = null;
         if(this._showPoints == param1)
         {
            return;
         }
         this._showPoints = param1;
         if(!this._showPoints)
         {
            this.hoverPointIndex = -1;
            this.selectedPointIndex = -1;
            for each(_loc2_ in this.textsPoints)
            {
               _loc2_.visible = false;
            }
         }
         this.draw();
      }
      
      public function get showLimits() : Boolean
      {
         return this._showLimits;
      }
      
      public function set showLimits(param1:Boolean) : void
      {
         if(this._showLimits == param1)
         {
            return;
         }
         this._showLimits = param1;
         this.draw();
      }
      
      private function updateActiveSpline() : void
      {
         if(this.travel)
         {
            this._spline = this.travel.def.spline;
         }
         else
         {
            this._spline = null;
         }
      }
      
      public function get showLocations() : Boolean
      {
         return this._showLocations;
      }
      
      public function set showLocations(param1:Boolean) : void
      {
         if(this._showLocations == param1)
         {
            return;
         }
         this._showLocations = param1;
         if(!this._showLocations)
         {
            this.hoverLocationIndex = -1;
            this.selectedLocationIndex = -1;
         }
         this.draw();
      }
      
      public function get selectedPointIndex() : int
      {
         return this._selectedPointIndex;
      }
      
      public function set selectedPointIndex(param1:int) : void
      {
         if(this._selectedPointIndex == param1)
         {
            return;
         }
         this._selectedPointIndex = param1;
         if(this._selectedPointIndex >= 0)
         {
            this.hoverPointIndex = -1;
            this.selectedLocationIndex = -1;
            this.hoverLocationIndex = -1;
         }
         dispatchEvent(new Event(EVENT_SELECTED_POINT));
         this.draw();
      }
      
      public function get selectedLocationIndex() : int
      {
         return this._selectedLocationIndex;
      }
      
      public function set selectedLocationIndex(param1:int) : void
      {
         if(this._selectedLocationIndex == param1)
         {
            return;
         }
         this._selectedLocationIndex = param1;
         if(this._selectedLocationIndex >= 0)
         {
            this.hoverLocationIndex = -1;
            this.hoverPointIndex = -1;
            this.selectedPointIndex = -1;
         }
         dispatchEvent(new Event(EVENT_SELECTED_LOCATION));
         this.draw();
      }
      
      public function onDrag() : void
      {
         var _loc1_:int = 0;
         this.onHover();
         if(this.showPoints && this._selectedPointIndex >= 0)
         {
            this.travel.def.changePoint(this._selectedPointIndex,mouseX,mouseY);
         }
         else if(this.showLocations && this._selectedLocationIndex >= 0)
         {
            _loc1_ = this.travel.def.changeLocation(this._selectedLocationIndex,this._hoverT * this._spline.totalLength);
            this.selectedLocationIndex = _loc1_;
         }
      }
      
      public function onPick(param1:Number, param2:Number) : void
      {
         if(this.showPoints && this._hoverPointIndex >= 0)
         {
            this.selectedPointIndex = this._hoverPointIndex;
         }
         else if(this.showLocations && this._hoverLocationIndex >= 0)
         {
            this.selectedLocationIndex = this._hoverLocationIndex;
         }
         else
         {
            this.selectedLocationIndex = -1;
            this.selectedPointIndex = -1;
         }
      }
      
      public function onHover() : void
      {
         var _loc7_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:Point = null;
         var _loc11_:int = 0;
         var _loc12_:TravelLocationDef = null;
         var _loc13_:Number = NaN;
         if(!this._showSpline)
         {
            return;
         }
         var _loc1_:int = -1;
         var _loc2_:Number = Number.MAX_VALUE;
         var _loc3_:Number = Number.MAX_VALUE;
         var _loc4_:Number = 20 / this.travel.landscape.camera.scale;
         var _loc5_:Point = new Point(mouseX,mouseY);
         this.hoverT = this._spline.findClosestPosition(_loc5_);
         var _loc6_:Number = 0;
         if(this.showPoints)
         {
            _loc9_ = 0;
            while(_loc9_ < this._spline.points.length)
            {
               _loc10_ = this._spline.points[_loc9_];
               _loc6_ = MathUtil.manhattanDistance(_loc5_.x,_loc5_.y,_loc10_.x,_loc10_.y);
               if(_loc6_ < _loc4_)
               {
                  if(_loc6_ < _loc2_)
                  {
                     _loc2_ = _loc6_;
                     _loc1_ = _loc9_;
                  }
               }
               if(_loc3_ < _loc6_)
               {
                  break;
               }
               _loc3_ = _loc6_;
               _loc9_++;
            }
         }
         _loc10_ = new Point();
         _loc3_ = Number.MAX_VALUE;
         var _loc8_:Number = 20;
         if(this.showLocations)
         {
            _loc11_ = 0;
            while(_loc11_ < this.travel.def.locations.length)
            {
               _loc12_ = this.travel.def.locations[_loc11_];
               _loc13_ = _loc12_.position / this._spline.totalLength;
               this._spline.sample(_loc13_,_loc10_);
               _loc6_ = Math.abs(_loc5_.x - _loc10_.x);
               if(_loc5_.x > _loc10_.x - _loc8_ && _loc5_.y < _loc10_.y + _loc8_ && _loc5_.y > _loc10_.y - _loc8_)
               {
                  if(_loc6_ < _loc4_)
                  {
                     if(_loc6_ < _loc2_)
                     {
                        _loc7_ = true;
                        _loc2_ = _loc6_;
                        _loc1_ = _loc11_;
                     }
                  }
               }
               if(_loc3_ < _loc6_)
               {
                  break;
               }
               _loc3_ = _loc6_;
               _loc11_++;
            }
         }
         if(_loc7_)
         {
            this.hoverPointIndex = -1;
            this.hoverLocationIndex = _loc1_;
         }
         else
         {
            this.hoverPointIndex = _loc1_;
            this.hoverLocationIndex = -1;
         }
      }
      
      public function centerOnLocation(param1:int) : void
      {
         var _loc2_:Point = this.travel.def.getPointAtLocation(param1);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:BoundedCamera = this.landscapeView.camera;
         _loc3_.enableDrift = true;
         _loc3_.drift.anchorSpeed = 5000;
         _loc3_.drift.anchor = new Point(_loc2_.x,_loc3_.y);
      }
   }
}
