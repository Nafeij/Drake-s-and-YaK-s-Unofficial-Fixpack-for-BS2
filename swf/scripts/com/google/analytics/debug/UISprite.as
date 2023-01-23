package com.google.analytics.debug
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   
   public class UISprite extends Sprite
   {
       
      
      private var _forcedWidth:uint;
      
      private var _forcedHeight:uint;
      
      protected var alignTarget:DisplayObject;
      
      protected var listenResize:Boolean;
      
      public var alignement:Align;
      
      public var margin:Margin;
      
      public function UISprite(param1:DisplayObject = null)
      {
         super();
         this.listenResize = false;
         this.alignement = Align.none;
         this.alignTarget = param1;
         this.margin = new Margin();
         addEventListener(Event.ADDED_TO_STAGE,this._onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this._onRemovedFromStage);
      }
      
      private function _onAddedToStage(param1:Event) : void
      {
         this.layout();
         this.resize();
      }
      
      private function _onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this._onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this._onRemovedFromStage);
         this.dispose();
      }
      
      protected function layout() : void
      {
      }
      
      protected function dispose() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:int = 0;
         while(_loc2_ < numChildren)
         {
            _loc1_ = getChildAt(_loc2_);
            if(_loc1_)
            {
               removeChild(_loc1_);
            }
            _loc2_++;
         }
      }
      
      protected function onResize(param1:Event) : void
      {
         this.resize();
      }
      
      public function get forcedWidth() : uint
      {
         if(this._forcedWidth)
         {
            return this._forcedWidth;
         }
         return width;
      }
      
      public function set forcedWidth(param1:uint) : void
      {
         this._forcedWidth = param1;
      }
      
      public function get forcedHeight() : uint
      {
         if(this._forcedHeight)
         {
            return this._forcedHeight;
         }
         return height;
      }
      
      public function set forcedHeight(param1:uint) : void
      {
         this._forcedHeight = param1;
      }
      
      public function alignTo(param1:Align, param2:DisplayObject = null) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:UISprite = null;
         if(param2 == null)
         {
            if(parent is Stage)
            {
               param2 = this.stage;
            }
            else
            {
               param2 = parent;
            }
         }
         if(param2 == this.stage)
         {
            if(this.stage == null)
            {
               return;
            }
            _loc3_ = this.stage.stageHeight;
            _loc4_ = this.stage.stageWidth;
            _loc5_ = 0;
            _loc6_ = 0;
         }
         else
         {
            _loc7_ = param2 as UISprite;
            if(_loc7_.forcedHeight)
            {
               _loc3_ = _loc7_.forcedHeight;
            }
            else
            {
               _loc3_ = _loc7_.height;
            }
            if(_loc7_.forcedWidth)
            {
               _loc4_ = _loc7_.forcedWidth;
            }
            else
            {
               _loc4_ = _loc7_.width;
            }
            _loc5_ = 0;
            _loc6_ = 0;
         }
         switch(param1)
         {
            case Align.top:
               x = _loc4_ / 2 - this.forcedWidth / 2;
               y = _loc6_ + this.margin.top;
               break;
            case Align.bottom:
               x = _loc4_ / 2 - this.forcedWidth / 2;
               y = _loc6_ + _loc3_ - this.forcedHeight - this.margin.bottom;
               break;
            case Align.left:
               x = _loc5_ + this.margin.left;
               y = _loc3_ / 2 - this.forcedHeight / 2;
               break;
            case Align.right:
               x = _loc5_ + _loc4_ - this.forcedWidth - this.margin.right;
               y = _loc3_ / 2 - this.forcedHeight / 2;
               break;
            case Align.center:
               x = _loc4_ / 2 - this.forcedWidth / 2;
               y = _loc3_ / 2 - this.forcedHeight / 2;
               break;
            case Align.topLeft:
               x = _loc5_ + this.margin.left;
               y = _loc6_ + this.margin.top;
               break;
            case Align.topRight:
               x = _loc5_ + _loc4_ - this.forcedWidth - this.margin.right;
               y = _loc6_ + this.margin.top;
               break;
            case Align.bottomLeft:
               x = _loc5_ + this.margin.left;
               y = _loc6_ + _loc3_ - this.forcedHeight - this.margin.bottom;
               break;
            case Align.bottomRight:
               x = _loc5_ + _loc4_ - this.forcedWidth - this.margin.right;
               y = _loc6_ + _loc3_ - this.forcedHeight - this.margin.bottom;
         }
         if(!this.listenResize && param1 != Align.none)
         {
            param2.addEventListener(Event.RESIZE,this.onResize,false,0,true);
            this.listenResize = true;
         }
         this.alignement = param1;
         this.alignTarget = param2;
      }
      
      public function resize() : void
      {
         if(this.alignement != Align.none)
         {
            this.alignTo(this.alignement,this.alignTarget);
         }
      }
   }
}
