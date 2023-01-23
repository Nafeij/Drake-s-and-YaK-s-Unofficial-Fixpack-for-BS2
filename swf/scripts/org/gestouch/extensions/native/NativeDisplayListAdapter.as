package org.gestouch.extensions.native
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.utils.Dictionary;
   import org.gestouch.core.IDisplayListAdapter;
   
   public final class NativeDisplayListAdapter implements IDisplayListAdapter
   {
       
      
      private var _targetWeekStorage:Dictionary;
      
      public function NativeDisplayListAdapter(param1:DisplayObject = null)
      {
         super();
         if(param1)
         {
            this._targetWeekStorage = new Dictionary(true);
            this._targetWeekStorage[param1] = true;
         }
      }
      
      public function get target() : Object
      {
         var _loc1_:* = null;
         var _loc2_:int = 0;
         var _loc3_:* = this._targetWeekStorage;
         for(_loc1_ in _loc3_)
         {
            return _loc1_;
         }
         return null;
      }
      
      public function contains(param1:Object) : Boolean
      {
         var _loc2_:DisplayObjectContainer = this.target as DisplayObjectContainer;
         if(_loc2_ is Stage)
         {
            return true;
         }
         var _loc3_:DisplayObject = param1 as DisplayObject;
         if(_loc3_)
         {
            return Boolean(_loc2_) && _loc2_.contains(_loc3_);
         }
         return false;
      }
      
      public function getHierarchy(param1:Object) : Vector.<Object>
      {
         var _loc2_:Vector.<Object> = new Vector.<Object>();
         var _loc3_:uint = 0;
         var _loc4_:DisplayObject = param1 as DisplayObject;
         while(_loc4_)
         {
            _loc2_[_loc3_] = _loc4_;
            _loc4_ = _loc4_.parent;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function reflect() : Class
      {
         return NativeDisplayListAdapter;
      }
   }
}
