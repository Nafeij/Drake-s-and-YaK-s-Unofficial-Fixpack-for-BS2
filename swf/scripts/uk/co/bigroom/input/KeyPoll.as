package uk.co.bigroom.input
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.utils.ByteArray;
   
   public class KeyPoll extends EventDispatcher
   {
       
      
      private var states:ByteArray;
      
      private var dispObj:DisplayObject;
      
      public function KeyPoll(param1:DisplayObject)
      {
         super();
         this.states = new ByteArray();
         this.states.writeUnsignedInt(0);
         this.states.writeUnsignedInt(0);
         this.states.writeUnsignedInt(0);
         this.states.writeUnsignedInt(0);
         this.states.writeUnsignedInt(0);
         this.states.writeUnsignedInt(0);
         this.states.writeUnsignedInt(0);
         this.states.writeUnsignedInt(0);
         this.dispObj = param1;
         this.dispObj.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
         this.dispObj.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
         this.dispObj.addEventListener(Event.ACTIVATE,this.activateListener,false,0,true);
         this.dispObj.addEventListener(Event.DEACTIVATE,this.deactivateListener,false,0,true);
      }
      
      public function cleanup() : void
      {
         this.dispObj.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
         this.dispObj.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
         this.dispObj.removeEventListener(Event.ACTIVATE,this.activateListener);
         this.dispObj.removeEventListener(Event.DEACTIVATE,this.deactivateListener);
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         var _loc2_:uint = uint(param1.keyCode >>> 3);
         var _loc3_:uint = uint(this.states[_loc2_]);
         this.states[_loc2_] |= 1 << (param1.keyCode & 7);
         if(this.states[_loc2_] != _loc3_)
         {
            dispatchEvent(new KeyPollEvent(KeyPollEvent.CHANGED,param1.keyCode,true));
         }
      }
      
      private function keyUpListener(param1:KeyboardEvent) : void
      {
         var _loc2_:uint = uint(param1.keyCode >>> 3);
         var _loc3_:uint = uint(this.states[_loc2_]);
         this.states[_loc2_] &= ~(1 << (param1.keyCode & 7));
         if(this.states[_loc2_] != _loc3_)
         {
            dispatchEvent(new KeyPollEvent(KeyPollEvent.CHANGED,param1.keyCode,false));
         }
      }
      
      private function activateListener(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < 32)
         {
            this.states[_loc2_] = 0;
            _loc2_++;
         }
      }
      
      private function deactivateListener(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < 32)
         {
            this.states[_loc2_] = 0;
            _loc2_++;
         }
      }
      
      public function isDown(param1:uint) : Boolean
      {
         return (this.states[param1 >>> 3] & 1 << (param1 & 7)) != 0;
      }
      
      public function isUp(param1:uint) : Boolean
      {
         return (this.states[param1 >>> 3] & 1 << (param1 & 7)) == 0;
      }
   }
}
