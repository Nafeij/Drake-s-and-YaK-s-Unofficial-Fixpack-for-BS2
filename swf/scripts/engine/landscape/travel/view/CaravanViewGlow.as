package engine.landscape.travel.view
{
   import as3isolib.utils.IsoUtil;
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapResource;
   import engine.resource.IResourceManager;
   import engine.resource.Resource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.CaravanViewGlowDef;
   
   public class CaravanViewGlow
   {
       
      
      public var dow:DisplayObjectWrapper;
      
      public var def:CaravanViewGlowDef;
      
      public var rs:Vector.<Resource>;
      
      public var br_glow_rim:BitmapResource;
      
      public var br_glow_fill:BitmapResource;
      
      public var br_glow_sparkle:BitmapResource;
      
      public var br_glow_outer:BitmapResource;
      
      public var bmp_rim:Rim = null;
      
      public var bmp_sparkles:Vector.<CaravanViewGlow_SparkleGroup>;
      
      public var bmp_fill:Fill = null;
      
      public var bmp_glow_outer:Glow = null;
      
      public var target_diameter:int = 900;
      
      public var logger:ILogger;
      
      public function CaravanViewGlow(param1:CaravanViewGlowDef, param2:IResourceManager)
      {
         this.rs = new Vector.<Resource>();
         this.bmp_sparkles = new Vector.<CaravanViewGlow_SparkleGroup>();
         super();
         this.def = param1;
         this.logger = param2.logger;
         this.dow = IsoUtil.createDisplayObjectWrapper(false);
         this.target_diameter = param1.target_diameter;
         this.br_glow_rim = param2.getResource(param1.bmp_rim,BitmapResource) as BitmapResource;
         this.br_glow_fill = param2.getResource(param1.bmp_fill,BitmapResource) as BitmapResource;
         this.br_glow_sparkle = param2.getResource(param1.bmp_sparkle,BitmapResource) as BitmapResource;
         this.br_glow_outer = param2.getResource(param1.bmp_outer,BitmapResource) as BitmapResource;
         this.br_glow_rim.addResourceListener(this.brLoadedHandler);
         this.br_glow_fill.addResourceListener(this.brLoadedHandler);
         this.br_glow_sparkle.addResourceListener(this.brLoadedHandler);
         this.br_glow_outer.addResourceListener(this.brLoadedHandler);
      }
      
      public function cleanup() : void
      {
         var _loc1_:Resource = null;
         for each(_loc1_ in this.rs)
         {
            _loc1_.release();
         }
      }
      
      private function brLoadedHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:CaravanViewGlow_SparkleGroup = null;
         param1.resource.removeResourceListener(this.brLoadedHandler);
         var _loc2_:BitmapResource = param1.resource as BitmapResource;
         if(!_loc2_.ok)
         {
            return;
         }
         if(_loc2_ == this.br_glow_rim && !this.bmp_rim)
         {
            this.bmp_rim = new Rim(_loc2_,this.def.rim_rects,this.def.rimscale,125);
            this.dow.addChild(this.bmp_rim.dow);
         }
         else if(_loc2_ == this.br_glow_fill && !this.bmp_fill)
         {
            this.bmp_fill = new Fill(this.br_glow_fill,new FillVars());
            this.dow.addChild(this.bmp_fill.dow);
         }
         else if(_loc2_ == this.br_glow_outer && !this.bmp_glow_outer)
         {
            this.bmp_glow_outer = new Glow(this.br_glow_outer,new GlowVars(),this.def.glowrimscale);
            this.dow.addChild(this.bmp_glow_outer.dow);
         }
         else
         {
            if(_loc2_ != this.br_glow_sparkle)
            {
               throw new ArgumentError("unexpected...");
            }
            _loc3_ = 24;
            _loc4_ = 1;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc6_ = new CaravanViewGlow_SparkleGroup(_loc2_,new CaravanViewGlow_SparkleGroupVars(_loc4_));
               this.bmp_sparkles.push(_loc6_);
               this.dow.addChild(_loc6_.dow);
               _loc5_++;
            }
         }
         this.rs.push(_loc2_);
         this.checkLayering();
      }
      
      private function checkLayering() : void
      {
         if(this.bmp_fill && this.bmp_sparkles.length && this.bmp_rim && Boolean(this.bmp_glow_outer))
         {
            this.dow.setChildIndex(this.bmp_fill.dow,0);
            if(!this.bmp_glow_outer)
            {
               this.logger.error("CaravnViewGlow.checkLayering cannot layer bmp_glow_outer");
            }
            else
            {
               this.dow.setChildIndex(this.bmp_glow_outer.dow,this.dow.numChildren - 1);
            }
            this.dow.setChildIndex(this.bmp_rim.dow,this.dow.numChildren - 1);
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:CaravanViewGlow_SparkleGroup = null;
         if(this.bmp_fill)
         {
            this.bmp_fill.update(param1,this.target_diameter);
         }
         if(this.bmp_glow_outer)
         {
            this.bmp_glow_outer.update(param1,this.target_diameter);
         }
         if(this.bmp_rim)
         {
            this.bmp_rim.update(param1,this.target_diameter);
         }
         for each(_loc2_ in this.bmp_sparkles)
         {
            _loc2_.update(param1,this.target_diameter * 0.9);
         }
      }
      
      public function setPos(param1:Number, param2:Number) : void
      {
         this.dow.x = param1;
         this.dow.y = param2;
      }
   }
}

class FillVars
{
    
   
   public var BASE_PULSE_PERIOD_MS:int = 1000;
   
   public var BASE_PULSE_PERIOD_VARIANCE_MS:int = 2000;
   
   public var PULSE_SCALE:Number = 1.02;
   
   public var FILL_SCALE_BIAS:Number = 1.1;
   
   public var ALPHA_BASE:Number = 0.9;
   
   public var ALPHA_PULSE:Number = 1;
   
   public function FillVars(param1:int = 1000, param2:int = 2000, param3:Number = 1.02, param4:Number = 1.1, param5:Number = 0.9, param6:Number = 1)
   {
      super();
      this.BASE_PULSE_PERIOD_MS = param1;
      this.BASE_PULSE_PERIOD_VARIANCE_MS = param2;
      this.PULSE_SCALE = param3;
      this.FILL_SCALE_BIAS = param4;
      this.ALPHA_BASE = param5;
      this.ALPHA_PULSE = param6;
   }
}

import as3isolib.utils.IsoUtil;
import engine.landscape.view.DisplayObjectWrapper;
import engine.math.MathUtil;
import engine.resource.BitmapResource;

class Fill
{
    
   
   public var dow:DisplayObjectWrapper;
   
   public var pulseMs:int = 0;
   
   public var pulsePeriodMs:int;
   
   public var vars:FillVars;
   
   public var fill:DisplayObjectWrapper;
   
   public var baseWidth:Number = 0;
   
   public function Fill(param1:BitmapResource, param2:FillVars)
   {
      super();
      this.vars = param2;
      this.pulsePeriodMs = this.vars.BASE_PULSE_PERIOD_MS;
      this.fill = param1.getWrapper();
      this.baseWidth = this.fill.width;
      this.dow = IsoUtil.createDisplayObjectWrapper(false);
      this.dow.addChild(this.fill);
      this.fill.blendMode = "add";
      this.fill.alpha = this.vars.ALPHA_BASE;
   }
   
   public function update(param1:int, param2:int) : void
   {
      this.pulseMs += param1;
      if(this.pulseMs > this.pulsePeriodMs)
      {
         this.pulseMs %= this.pulsePeriodMs;
         this.pulsePeriodMs = this.vars.BASE_PULSE_PERIOD_MS + Math.random() * Number(this.vars.BASE_PULSE_PERIOD_VARIANCE_MS);
      }
      var _loc3_:Number = Number(this.pulseMs) / Number(this.pulsePeriodMs) * 2;
      if(_loc3_ > 1)
      {
         _loc3_ = 2 - _loc3_;
      }
      var _loc4_:Number = MathUtil.lerp(1,this.vars.PULSE_SCALE,_loc3_);
      var _loc5_:Number = param2 / Number(this.baseWidth) * _loc4_ * Number(this.vars.FILL_SCALE_BIAS);
      this.fill.alpha = MathUtil.lerp(this.vars.ALPHA_BASE,this.vars.ALPHA_PULSE,_loc3_);
      this.fill.scale = _loc5_;
      this.fill.x = -Number(this.fill.width) / 2;
      this.fill.y = -Number(this.fill.height) / 2;
   }
}

class GlowVars
{
    
   
   public var ALPHA_DEFAULT:Number;
   
   public var ALPHA_IN_OUT_FADE_VARIANCE:Number;
   
   public var SCALE_DEFAULT:Number;
   
   public var SCALE_VARIANCE:Number;
   
   public var SCALE_MAXIMUM:Number;
   
   public var SCALE_SPEED:Number;
   
   public var ROTATION_DEFAULT_VARIANCE:Number;
   
   public var ROTATION_SPEED:Number;
   
   public var ROTATION_SPEED_VARIANCE:Number;
   
   public var NUM_RINGS:int;
   
   public function GlowVars(param1:Number = 0.15, param2:Number = 0.4, param3:Number = 3.65, param4:Number = 0.05, param5:Number = 3.75, param6:Number = 0.025, param7:int = 5, param8:Number = 180, param9:Number = 2.5, param10:Number = 1)
   {
      super();
      this.ALPHA_DEFAULT = param1;
      this.ALPHA_IN_OUT_FADE_VARIANCE = param2;
      this.SCALE_DEFAULT = param3;
      this.SCALE_VARIANCE = param4;
      this.SCALE_MAXIMUM = param5;
      this.SCALE_SPEED = param6;
      this.NUM_RINGS = param7;
      this.ROTATION_DEFAULT_VARIANCE = param8;
      this.ROTATION_SPEED = param9;
      this.ROTATION_SPEED_VARIANCE = param10;
   }
}

import engine.landscape.view.DisplayObjectWrapper;
import engine.math.MathUtil;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class GlowRing
{
    
   
   public var glow:DisplayObjectWrapper;
   
   public var startingScale:Number;
   
   public var maxScaleLifetime:Number;
   
   public var scale:Number;
   
   public var rotationSpeed:Number;
   
   public var scaleMultiplier:Number;
   
   public var vars:GlowVars;
   
   public function GlowRing(param1:DisplayObjectWrapper, param2:GlowVars, param3:Number)
   {
      super();
      this.glow = param1;
      this.vars = param2;
      this.scaleMultiplier = param3;
      this.resetGlow();
   }
   
   public function update(param1:Number, param2:Number) : void
   {
      var _loc4_:Matrix = null;
      this.scale += param1 * Number(this.scaleMultiplier);
      var _loc3_:Number = Math.min(1,(Number(this.scale) - Number(this.startingScale)) / Number(this.maxScaleLifetime));
      if(_loc3_ < 1)
      {
         _loc4_ = this.glow.transformMatrix;
         _loc4_.scale(1 + param1,1 + param1);
         _loc4_.rotate(param2);
         this.glow.transformMatrix = _loc4_;
      }
      else
      {
         this.resetGlow();
      }
      if(_loc3_ < this.vars.ALPHA_IN_OUT_FADE_VARIANCE)
      {
         this.glow.alpha = Math.min(_loc3_ / Number(this.vars.ALPHA_IN_OUT_FADE_VARIANCE),this.vars.ALPHA_DEFAULT);
      }
      else if(_loc3_ > 1 - Number(this.vars.ALPHA_IN_OUT_FADE_VARIANCE))
      {
         this.glow.alpha = Math.min((1 - _loc3_) / (1 - (1 - Number(this.vars.ALPHA_IN_OUT_FADE_VARIANCE))),this.vars.ALPHA_DEFAULT);
      }
      else
      {
         this.glow.alpha = this.vars.ALPHA_DEFAULT;
      }
   }
   
   public function resetGlow() : void
   {
      this.startingScale = MathUtil.randomInt(Math.max(Number(this.vars.SCALE_DEFAULT) - Number(this.vars.SCALE_VARIANCE),0) * 1000,Math.max(this.vars.SCALE_DEFAULT + this.vars.SCALE_VARIANCE,0) * 1000) / 1000 * Number(this.scaleMultiplier);
      this.scale = this.startingScale;
      this.maxScaleLifetime = Number(this.vars.SCALE_MAXIMUM) * Number(this.scaleMultiplier) - Number(this.startingScale);
      this.rotationSpeed = MathUtil.randomInt(Math.max(Number(this.vars.ROTATION_SPEED) - Number(this.vars.ROTATION_SPEED_VARIANCE),0) * 1000,Math.max(this.vars.ROTATION_SPEED + this.vars.ROTATION_SPEED_VARIANCE,0) * 1000) / 1000;
      this.rotationSpeed = Number(this.rotationSpeed) / 180 * Math.PI;
      this.glow.blendMode = "add";
      this.glow.alpha = 0;
      var _loc1_:Matrix = new Matrix();
      var _loc2_:Rectangle = this.glow.getMyBounds();
      _loc1_.translate(-(_loc2_.left + _loc2_.width / 2),-(_loc2_.top + _loc2_.height / 2));
      _loc1_.rotate(MathUtil.randomInt(0,this.vars.ROTATION_DEFAULT_VARIANCE) / 180 * Math.PI);
      _loc1_.scale(this.scale,this.scale);
      this.glow.transformMatrix = _loc1_;
   }
}

import as3isolib.utils.IsoUtil;
import engine.landscape.view.DisplayObjectWrapper;
import engine.resource.BitmapResource;

class Glow
{
    
   
   public var dow:DisplayObjectWrapper;
   
   public var glowRings:Vector.<GlowRing>;
   
   public var vars:GlowVars;
   
   public function Glow(param1:BitmapResource, param2:GlowVars, param3:Number)
   {
      var _loc5_:DisplayObjectWrapper = null;
      var _loc6_:GlowRing = null;
      this.glowRings = new Vector.<GlowRing>();
      super();
      this.vars = param2;
      this.dow = IsoUtil.createDisplayObjectWrapper(false);
      var _loc4_:int = 0;
      while(_loc4_ < this.vars.NUM_RINGS)
      {
         _loc5_ = param1.getWrapper();
         _loc6_ = new GlowRing(_loc5_,this.vars,param3);
         this.dow.addChild(_loc5_);
         this.glowRings.push(_loc6_);
         _loc4_++;
      }
   }
   
   public function update(param1:int, param2:int) : void
   {
      var _loc5_:Number = NaN;
      var _loc3_:Number = param1 / 1000 * Number(this.vars.SCALE_SPEED);
      var _loc4_:int = 0;
      while(_loc4_ < this.glowRings.length)
      {
         _loc5_ = param1 / 1000 * Number(this.glowRings[_loc4_].rotationSpeed);
         this.glowRings[_loc4_].update(_loc3_,_loc5_);
         _loc4_++;
      }
   }
}

import as3isolib.utils.IsoUtil;
import engine.landscape.view.DisplayObjectWrapper;
import engine.math.MathUtil;
import engine.resource.BitmapResource;
import flash.geom.Rectangle;

class Rim
{
    
   
   public var dow:DisplayObjectWrapper;
   
   public var streaks:Vector.<RimStreak>;
   
   public var started:Boolean;
   
   public var rects:Array;
   
   public var br:BitmapResource;
   
   private var rimscale:Number = 1;
   
   public var countRequired:int = 0;
   
   public function Rim(param1:BitmapResource, param2:Array, param3:Number, param4:int)
   {
      this.streaks = new Vector.<RimStreak>();
      super();
      this.br = param1;
      this.rimscale = param3;
      this.dow = IsoUtil.createDisplayObjectWrapper(false);
      this.rects = param2;
      this.ensureCountRequired(param4);
   }
   
   public function ensureCountRequired(param1:int) : void
   {
      var _loc3_:Rectangle = null;
      var _loc4_:DisplayObjectWrapper = null;
      var _loc5_:RimStreak = null;
      this.countRequired = param1;
      var _loc2_:int = int(this.streaks.length);
      while(_loc2_ < this.countRequired)
      {
         _loc3_ = this.rects[MathUtil.randomInt(0,this.rects.length - 1)];
         _loc4_ = this.br.getWrapperRect(_loc3_);
         _loc5_ = new RimStreak(_loc4_,this.rimscale);
         this.streaks.push(_loc5_);
         this.dow.addChild(_loc4_);
         _loc2_++;
      }
   }
   
   public function update(param1:int, param2:int) : void
   {
      var _loc4_:RimStreak = null;
      var _loc3_:Number = param2 / 2;
      for each(_loc4_ in this.streaks)
      {
         _loc4_.update(param1,_loc3_);
      }
   }
}

import engine.landscape.view.DisplayObjectWrapper;
import engine.math.MathUtil;

class RimStreak
{
    
   
   public var b:DisplayObjectWrapper;
   
   public var angleRadians:Number = 0;
   
   public var t:Number = 0;
   
   public var lifespan_ms:int = 0;
   
   public var elapsed_ms:int = 0;
   
   public var BASE_LIFESPAN_MS:int = 2750;
   
   public var BASE_LIFESPAN_VARIANCE_MS:int = 750;
   
   public var RADIUS_LIFESPAN_START:Number = 0.95;
   
   public var RADIUS_LIFESPAN_END:Number = 1.05;
   
   public var ANGLE_DELTA_DEGREES_PER_S:Number = 0;
   
   public var ANGLE_BIAS_DEGREES:Number = 90;
   
   public var ALPHA_T_IN:Number = 0.4;
   
   public var ALPHA_T_OUT:Number = 0.6;
   
   public var MAX_ALPHA:Number = 0.6;
   
   public var acos:Number = 0;
   
   public var asin:Number = 0;
   
   public function RimStreak(param1:DisplayObjectWrapper, param2:Number)
   {
      super();
      this.b = param1;
      param1.scale = param2;
      this.respawn();
      this.elapsed_ms = (this.BASE_LIFESPAN_MS + this.BASE_LIFESPAN_VARIANCE_MS) * Math.random();
   }
   
   public function reset(param1:Number) : void
   {
      this.angleRadians = param1;
      this.b.rotationRadians = param1 + Number(this.ANGLE_BIAS_DEGREES) * MathUtil.PI_OVER_180;
      this.acos = Math.cos(param1);
      this.asin = Math.sin(param1);
      this.t = 0;
      this.elapsed_ms = 0;
      this.lifespan_ms = this.BASE_LIFESPAN_MS + Math.random() * Number(this.BASE_LIFESPAN_VARIANCE_MS);
      this.b.alpha = 0;
   }
   
   public function respawn() : void
   {
      var _loc1_:Number = Math.random() * Math.PI * 2;
      this.reset(_loc1_);
   }
   
   public function update(param1:int, param2:Number) : void
   {
      this.elapsed_ms += param1;
      this.t = Number(this.elapsed_ms) / Number(this.lifespan_ms);
      this.t = Math.min(1,this.t);
      param2 *= MathUtil.lerp(this.RADIUS_LIFESPAN_START,this.RADIUS_LIFESPAN_END,this.t);
      if(this.ANGLE_DELTA_DEGREES_PER_S)
      {
         this.angleRadians += param1 * Number(this.ANGLE_DELTA_DEGREES_PER_S) * 0.001 * MathUtil.PI_OVER_180;
         this.b.rotationRadians = this.angleRadians + Number(this.ANGLE_BIAS_DEGREES) * MathUtil.PI_OVER_180;
         this.acos = Math.cos(this.angleRadians);
         this.asin = Math.sin(this.angleRadians);
      }
      var _loc3_:Number = param2 * Number(this.acos);
      var _loc4_:Number = param2 * Number(this.asin);
      this.b.x = _loc3_;
      this.b.y = _loc4_;
      var _loc5_:Number = 1;
      if(this.t < this.ALPHA_T_IN)
      {
         _loc5_ = Math.min(Number(this.t) / Number(this.ALPHA_T_IN),this.MAX_ALPHA);
      }
      else if(this.t > this.ALPHA_T_OUT)
      {
         _loc5_ = Math.min((1 - Number(this.t)) / (1 - Number(this.ALPHA_T_OUT)),this.MAX_ALPHA);
      }
      else
      {
         _loc5_ = Number(this.MAX_ALPHA);
      }
      this.b.alpha = _loc5_;
      if(this.elapsed_ms > this.lifespan_ms)
      {
         this.respawn();
      }
   }
}
