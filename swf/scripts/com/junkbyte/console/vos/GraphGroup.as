package com.junkbyte.console.vos
{
   import com.junkbyte.console.console_internal;
   import com.junkbyte.console.core.CcCallbackDispatcher;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   [Event(name="close",type="flash.events.Event")]
   public class GraphGroup
   {
       
      
      public var name:String;
      
      public var freq:int = 0;
      
      public var fixedMin:Number;
      
      public var fixedMax:Number;
      
      public var inverted:Boolean;
      
      public var interests:Array;
      
      public var menus:Array;
      
      public var numberDisplayPrecision:uint = 4;
      
      public var alignRight:Boolean;
      
      public var rect:Rectangle;
      
      protected var _updateArgs:Array;
      
      protected var sinceLastUpdate:uint;
      
      protected var _onUpdate:CcCallbackDispatcher;
      
      protected var _onClose:CcCallbackDispatcher;
      
      protected var _onMenu:CcCallbackDispatcher;
      
      public function GraphGroup(param1:String)
      {
         this.interests = [];
         this.menus = [];
         this.rect = new Rectangle(0,0,80,40);
         this._updateArgs = new Array();
         this._onUpdate = new CcCallbackDispatcher();
         this._onClose = new CcCallbackDispatcher();
         this._onMenu = new CcCallbackDispatcher();
         super();
         this.name = param1;
      }
      
      public static function FromBytes(param1:ByteArray) : GraphGroup
      {
         var _loc2_:GraphGroup = null;
         _loc2_ = new GraphGroup(param1.readUTF());
         _loc2_.fixedMin = param1.readDouble();
         _loc2_.fixedMax = param1.readDouble();
         _loc2_.inverted = param1.readBoolean();
         _loc2_.alignRight = param1.readBoolean();
         var _loc3_:Rectangle = _loc2_.rect;
         _loc3_.x = param1.readFloat();
         _loc3_.y = param1.readFloat();
         _loc3_.width = param1.readFloat();
         _loc3_.height = param1.readFloat();
         _loc2_.numberDisplayPrecision = param1.readShort();
         var _loc4_:uint = param1.readShort();
         while(_loc4_ > 0)
         {
            _loc2_.interests.push(GraphInterest.FromBytes(param1));
            _loc4_--;
         }
         _loc4_ = param1.readShort();
         while(_loc4_ > 0)
         {
            _loc2_.menus.push(param1.readUTF());
            _loc4_--;
         }
         return _loc2_;
      }
      
      public function tick(param1:uint) : void
      {
         this.sinceLastUpdate += param1;
         if(this.sinceLastUpdate >= this.freq)
         {
            this.update();
         }
      }
      
      public function update() : void
      {
         this.sinceLastUpdate = 0;
         this.dispatchUpdates();
      }
      
      protected function dispatchUpdates() : void
      {
         var _loc2_:GraphInterest = null;
         var _loc3_:Number = NaN;
         var _loc1_:int = this.interests.length - 1;
         while(_loc1_ >= 0)
         {
            _loc2_ = this.interests[_loc1_];
            _loc3_ = _loc2_.getCurrentValue();
            this._updateArgs[_loc1_] = _loc3_;
            _loc1_--;
         }
         this.console_internal::applyUpdateDispather(this._updateArgs);
      }
      
      console_internal internal function applyUpdateDispather(param1:Array) : void
      {
         this._onUpdate.apply(param1);
      }
      
      public function close() : void
      {
         this._onClose.apply(this);
         this._onUpdate.clear();
         this._onClose.clear();
         this._onMenu.clear();
      }
      
      public function get onUpdate() : CcCallbackDispatcher
      {
         return this._onUpdate;
      }
      
      public function get onClose() : CcCallbackDispatcher
      {
         return this._onClose;
      }
      
      public function get onMenu() : CcCallbackDispatcher
      {
         return this._onMenu;
      }
      
      public function writeToBytes(param1:ByteArray) : void
      {
         var _loc2_:GraphInterest = null;
         var _loc3_:String = null;
         param1.writeUTF(this.name);
         param1.writeDouble(this.fixedMin);
         param1.writeDouble(this.fixedMax);
         param1.writeBoolean(this.inverted);
         param1.writeBoolean(this.alignRight);
         param1.writeFloat(this.rect.x);
         param1.writeFloat(this.rect.y);
         param1.writeFloat(this.rect.width);
         param1.writeFloat(this.rect.height);
         param1.writeShort(this.numberDisplayPrecision);
         param1.writeShort(this.interests.length);
         for each(_loc2_ in this.interests)
         {
            _loc2_.writeToBytes(param1);
         }
         param1.writeShort(this.menus.length);
         for each(_loc3_ in this.menus)
         {
            param1.writeUTF(_loc3_);
         }
      }
   }
}
