package com.google.analytics.debug
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class Panel extends UISprite
   {
       
      
      private var _name:String;
      
      private var _backgroundColor:uint;
      
      private var _borderColor:uint;
      
      private var _colapsed:Boolean;
      
      private var _savedW:uint;
      
      private var _savedH:uint;
      
      private var _background:Shape;
      
      private var _data:UISprite;
      
      private var _title:Label;
      
      private var _border:Shape;
      
      private var _mask:Sprite;
      
      protected var baseAlpha:Number;
      
      private var _stickToEdge:Boolean;
      
      public function Panel(param1:String, param2:uint, param3:uint, param4:uint = 0, param5:uint = 0, param6:Number = 0.3, param7:Align = null, param8:Boolean = false)
      {
         super();
         this._name = param1;
         this.name = param1;
         this.mouseEnabled = false;
         this._colapsed = false;
         forcedWidth = param2;
         forcedHeight = param3;
         this.baseAlpha = param6;
         this._background = new Shape();
         this._data = new UISprite();
         this._data.forcedWidth = param2;
         this._data.forcedHeight = param3;
         this._data.mouseEnabled = false;
         this._title = new Label(param1,"uiLabel",16777215,Align.topLeft,param8);
         this._title.buttonMode = true;
         this._title.margin.top = 0.6;
         this._title.margin.left = 0.6;
         this._title.addEventListener(MouseEvent.CLICK,this.onToggle);
         this._title.mouseChildren = false;
         this._border = new Shape();
         this._mask = new Sprite();
         this._mask.useHandCursor = false;
         this._mask.mouseEnabled = false;
         this._mask.mouseChildren = false;
         if(param7 == null)
         {
            param7 = Align.none;
         }
         this.alignement = param7;
         this.stickToEdge = param8;
         if(param4 == 0)
         {
            param4 = uint(Style.backgroundColor);
         }
         this._backgroundColor = param4;
         if(param5 == 0)
         {
            param5 = uint(Style.borderColor);
         }
         this._borderColor = param5;
      }
      
      public function addData(param1:DisplayObject) : void
      {
         this._data.addChild(param1);
      }
      
      override protected function layout() : void
      {
         this._update();
         addChild(this._background);
         addChild(this._data);
         addChild(this._title);
         addChild(this._border);
         addChild(this._mask);
         mask = this._mask;
      }
      
      override protected function dispose() : void
      {
         this._title.removeEventListener(MouseEvent.CLICK,this.onToggle);
         super.dispose();
      }
      
      private function _update() : void
      {
         this._draw();
         if(this.baseAlpha < 1)
         {
            this._background.alpha = this.baseAlpha;
            this._border.alpha = this.baseAlpha;
         }
      }
      
      private function _draw() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         if(Boolean(this._savedW) && Boolean(this._savedH))
         {
            forcedWidth = this._savedW;
            forcedHeight = this._savedH;
         }
         if(!this._colapsed)
         {
            _loc1_ = forcedWidth;
            _loc2_ = forcedHeight;
         }
         else
         {
            _loc1_ = this._title.width;
            _loc2_ = this._title.height;
            this._savedW = forcedWidth;
            this._savedH = forcedHeight;
            forcedWidth = _loc1_;
            forcedHeight = _loc2_;
         }
         var _loc3_:Graphics = this._background.graphics;
         _loc3_.clear();
         _loc3_.beginFill(this._backgroundColor);
         Background.drawRounded(this,_loc3_,_loc1_,_loc2_);
         _loc3_.endFill();
         var _loc4_:Graphics = this._data.graphics;
         _loc4_.clear();
         _loc4_.beginFill(this._backgroundColor,0);
         Background.drawRounded(this,_loc4_,_loc1_,_loc2_);
         _loc4_.endFill();
         var _loc5_:Graphics = this._border.graphics;
         _loc5_.clear();
         _loc5_.lineStyle(0.1,this._borderColor);
         Background.drawRounded(this,_loc5_,_loc1_,_loc2_);
         _loc5_.endFill();
         var _loc6_:Graphics = this._mask.graphics;
         _loc6_.clear();
         _loc6_.beginFill(this._backgroundColor);
         Background.drawRounded(this,_loc6_,_loc1_ + 1,_loc2_ + 1);
         _loc6_.endFill();
      }
      
      public function onToggle(param1:MouseEvent = null) : void
      {
         if(this._colapsed)
         {
            this._data.visible = true;
         }
         else
         {
            this._data.visible = false;
         }
         this._colapsed = !this._colapsed;
         this._update();
         resize();
      }
      
      public function get stickToEdge() : Boolean
      {
         return this._stickToEdge;
      }
      
      public function set stickToEdge(param1:Boolean) : void
      {
         this._stickToEdge = param1;
         this._title.stickToEdge = param1;
      }
      
      public function get title() : String
      {
         return this._title.text;
      }
      
      public function set title(param1:String) : void
      {
         this._title.text = param1;
      }
      
      public function close() : void
      {
         this.dispose();
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
   }
}
