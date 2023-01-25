package game.view
{
   import engine.core.util.MemoryReporter;
   import engine.gui.core.GuiSprite;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class PerfSprite extends GuiSprite
   {
       
      
      private var dragging:Boolean;
      
      private var startDragPoint:Point;
      
      private var startedAt:Point;
      
      private var dragStage:Stage;
      
      private var container:GuiSprite;
      
      private var dfps:DisplayFps;
      
      private var dmem:DisplayMem;
      
      public var mr:MemoryReporter;
      
      public function PerfSprite(param1:GuiSprite, param2:MemoryReporter)
      {
         this.startDragPoint = new Point();
         this.startedAt = new Point();
         this.dfps = new DisplayFps();
         this.dmem = new DisplayMem();
         super();
         this.container = param1;
         name = "perf";
         this.mr = param2;
         mouseEnabled = true;
         opaqueBackground = 4473924;
         this.dfps.name = "fps";
         this.dmem.name = "dmem";
         addChild(this.dfps);
         addChild(this.dmem);
         this.dfps.anchor.percentHeight = 50;
         this.dfps.anchor.percentWidth = 100;
         this.dmem.anchor.bottom = 0;
         this.dmem.anchor.percentHeight = 50;
         this.dmem.anchor.percentWidth = 100;
         this.check();
         this.draw();
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         if(this.dragging)
         {
            this.dragging = false;
            opaqueBackground = 4473924;
            this.dragStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
            this.dragStage = null;
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this.dragStage = stage;
         opaqueBackground = 6710886;
         this.dragging = true;
         this.dragStage.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         this.startedAt.setTo(x,y);
         this.startDragPoint.setTo(param1.stageX,param1.stageY);
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.dragging)
         {
            _loc2_ = param1.stageX - this.startDragPoint.x;
            _loc3_ = param1.stageY - this.startDragPoint.y;
            setPosition(this.startedAt.x + _loc2_,this.startedAt.y + _loc3_);
         }
      }
      
      public function update(param1:int) : void
      {
         this.dfps.update(param1);
         this.dmem.tickx = this.dfps.tickx;
         if(this.mr)
         {
            this.dmem.update(param1,this.mr.currentMb);
         }
      }
      
      public function draw() : void
      {
         this.dfps.draw();
         this.dmem.draw();
      }
      
      public function set perfEnabled(param1:Boolean) : void
      {
         visible = param1;
         if(visible)
         {
            this.container.addChild(this);
         }
         else
         {
            this.container.removeChild(this);
         }
         this.check();
      }
      
      public function get perfEnabled() : Boolean
      {
         return visible;
      }
      
      public function toggle() : void
      {
         this.perfEnabled = !this.perfEnabled;
      }
      
      public function check() : void
      {
         if(visible)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
         }
         mouseEnabled = visible;
      }
   }
}

import engine.gui.core.GuiSprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.Dictionary;

class DisplayFps extends GuiSprite
{
    
   
   public var tickx:int = 0;
   
   private var label:TextField;
   
   private var slabel:TextField;
   
   private var lastDelta:int = 0;
   
   private var avg:Number = 0;
   
   private var avgInt:int = 0;
   
   private var lastAvgInt:int = 0;
   
   private var low_ints:Array;
   
   private var high_ints:Dictionary;
   
   private var scratch:String;
   
   public function DisplayFps()
   {
      this.label = new TextField();
      this.slabel = new TextField();
      this.high_ints = new Dictionary();
      super();
      this.label.name = "label";
      addChild(this.label);
      this.slabel.name = "static_label";
      addChild(this.slabel);
      this.slabel.text = "MS: ";
      setupLabel(this.slabel);
      setupLabel(this.label);
      this.label.x = 25;
   }
   
   private static function setupLabel(param1:TextField) : void
   {
      param1.textColor = 16777215;
      param1.mouseEnabled = false;
      param1.height = 10;
      param1.defaultTextFormat = new TextFormat(null,12,16777215,true);
   }
   
   public function draw() : void
   {
      var _loc1_:int = 0;
      var _loc2_:int = 0;
      if(this.label.height != height)
      {
         this.label.height = height;
         this.slabel.height = height;
      }
      if(this.tickx > width)
      {
         this.tickx = 0;
      }
      if(this.tickx == 0)
      {
         graphics.clear();
         graphics.lineStyle(1,16777215);
         graphics.moveTo(0,height);
         graphics.lineTo(width,height);
      }
      _loc1_ = 100;
      _loc2_ = 20;
      var _loc3_:int = Math.max(0,Math.min(255,(this.lastDelta - _loc2_) * 255 / (_loc1_ - _loc2_)));
      var _loc4_:* = 0;
      _loc4_ |= _loc3_ << 16;
      _loc4_ |= 255 - _loc3_ << 8;
      graphics.lineStyle(1,_loc4_);
      var _loc5_:int = height - int(_loc3_ * height / 255);
      var _loc6_:int = 0;
      while(_loc6_ < this.lastDelta)
      {
         graphics.moveTo(this.tickx,height);
         graphics.lineTo(this.tickx,_loc5_);
         ++this.tickx;
         if(this.tickx > width)
         {
            break;
         }
         _loc6_ += 30;
      }
   }
   
   public function update(param1:int) : void
   {
      var _loc3_:int = 0;
      if(!visible || !parent || !parent.visible)
      {
         return;
      }
      if(!this.low_ints)
      {
         this.low_ints = new Array(100);
         _loc3_ = 0;
         while(_loc3_ < this.low_ints.length)
         {
            this.low_ints[_loc3_] = _loc3_.toString();
            _loc3_++;
         }
      }
      this.lastDelta = param1;
      var _loc2_:int = 50;
      this.avg = (this.avg * _loc2_ + param1) / (_loc2_ + 1);
      this.avgInt = this.avg;
      if(this.lastAvgInt != this.avgInt)
      {
         this.lastAvgInt = this.avgInt;
         if(this.avgInt >= 0 && this.avgInt < this.low_ints.length)
         {
            this.label.text = this.low_ints[this.avgInt];
         }
         else
         {
            this.scratch = this.high_ints[this.avgInt];
            if(!this.scratch)
            {
               this.scratch = this.avgInt.toString();
               this.high_ints[this.avgInt] = this.scratch;
            }
            this.label.text = this.scratch;
         }
      }
      this.draw();
   }
}

import engine.gui.core.GuiSprite;
import engine.math.MathUtil;
import flash.text.TextField;
import flash.text.TextFormat;

class DisplayMem extends GuiSprite
{
    
   
   public var tickx:int = 0;
   
   private var label:TextField;
   
   private var slabel:TextField;
   
   private var lastDelta:int = 0;
   
   private var lastM:int = 0;
   
   private var m:int = 0;
   
   private var lastX:int = 0;
   
   public function DisplayMem()
   {
      this.label = new TextField();
      this.slabel = new TextField();
      super();
      this.label.name = "label";
      addChild(this.label);
      this.slabel.name = "slabel";
      this.slabel.text = "MB: ";
      addChild(this.slabel);
      setupLabel(this.slabel);
      setupLabel(this.label);
      this.label.x = 25;
   }
   
   private static function setupLabel(param1:TextField) : void
   {
      param1.textColor = 16777215;
      param1.mouseEnabled = false;
      param1.height = 10;
      param1.defaultTextFormat = new TextFormat(null,12,16777215,true);
   }
   
   public function draw() : void
   {
      if(this.label.height != height)
      {
         this.label.height = height;
         this.slabel.height = height;
      }
      if(this.tickx > width)
      {
         this.tickx = 0;
      }
      if(this.tickx < this.lastX)
      {
         this.lastX = 0;
         graphics.clear();
         graphics.lineStyle(1,16777215);
         graphics.moveTo(0,height);
         graphics.lineTo(width,height);
      }
      var _loc1_:int = 500;
      var _loc2_:int = 900;
      var _loc3_:int = 1300;
      var _loc4_:Number = MathUtil.unlerp(_loc1_,_loc2_,this.m);
      var _loc5_:Number = 1 - MathUtil.unlerp(_loc2_,_loc3_,this.m);
      var _loc6_:int = 255 * _loc4_;
      var _loc7_:int = 255 * _loc5_;
      var _loc8_:* = _loc6_ << 16 | _loc7_ << 8;
      graphics.lineStyle(1,_loc8_);
      var _loc9_:Number = 1600;
      var _loc10_:Number = height - height * this.lastM / _loc9_;
      var _loc11_:Number = height - height * this.m / _loc9_;
      graphics.moveTo(this.lastX,_loc10_);
      graphics.lineTo(this.tickx,_loc11_);
      this.lastM = this.m;
      this.lastX = this.tickx;
   }
   
   public function update(param1:int, param2:int) : void
   {
      if(!visible || !parent || !parent.visible)
      {
         return;
      }
      this.m = param2;
      if(this.lastM != this.m)
      {
         this.label.text = this.m.toString();
      }
      this.draw();
   }
}
