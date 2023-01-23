package com.junkbyte.console.core
{
   public class CcCallbackDispatcher
   {
       
      
      private var _list:Array;
      
      public function CcCallbackDispatcher()
      {
         this._list = new Array();
         super();
      }
      
      public function add(param1:Function) : void
      {
         this.remove(param1);
         this._list.push(param1);
      }
      
      public function remove(param1:Function) : void
      {
         var _loc2_:int = this._list.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this._list.splice(_loc2_,1);
         }
      }
      
      public function apply(param1:Object) : void
      {
         var _loc2_:uint = this._list.length;
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_)
         {
            this._list[_loc3_](param1);
            _loc3_++;
         }
      }
      
      public function clear() : void
      {
         this._list.splice(0,this._list.length);
      }
   }
}
