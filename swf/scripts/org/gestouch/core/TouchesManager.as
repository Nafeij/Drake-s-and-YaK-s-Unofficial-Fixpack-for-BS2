package org.gestouch.core
{
   import flash.display.Stage;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class TouchesManager
   {
       
      
      protected var _gesturesManager:GesturesManager;
      
      protected var _touchesMap:Object;
      
      protected var _hitTesters:Vector.<ITouchHitTester>;
      
      protected var _hitTesterPrioritiesMap:Dictionary;
      
      protected var _activeTouchesCount:uint;
      
      public function TouchesManager(param1:GesturesManager)
      {
         this._touchesMap = {};
         this._hitTesters = new Vector.<ITouchHitTester>();
         this._hitTesterPrioritiesMap = new Dictionary(true);
         super();
         this._gesturesManager = param1;
      }
      
      public function get activeTouchesCount() : uint
      {
         return this._activeTouchesCount;
      }
      
      public function getTouches(param1:Object = null) : Array
      {
         var _loc3_:uint = 0;
         var _loc4_:Touch = null;
         var _loc2_:Array = [];
         if(!param1 || param1 is Stage)
         {
            _loc3_ = 0;
            for each(_loc4_ in this._touchesMap)
            {
               var _loc7_:* = _loc3_++;
               _loc2_[_loc7_] = _loc4_;
            }
         }
         return _loc2_;
      }
      
      gestouch_internal function addTouchHitTester(param1:ITouchHitTester, param2:int = 0) : void
      {
         if(!param1)
         {
            throw new ArgumentError("Argument must be non null.");
         }
         if(this._hitTesters.indexOf(param1) == -1)
         {
            this._hitTesters.push(param1);
         }
         this._hitTesterPrioritiesMap[param1] = param2;
         this._hitTesters.sort(this.hitTestersSorter);
      }
      
      gestouch_internal function removeInputAdapter(param1:ITouchHitTester) : void
      {
         if(!param1)
         {
            throw new ArgumentError("Argument must be non null.");
         }
         var _loc2_:int = this._hitTesters.indexOf(param1);
         if(_loc2_ == -1)
         {
            throw new Error("This touchHitTester is not registered.");
         }
         this._hitTesters.splice(_loc2_,1);
         delete this._hitTesterPrioritiesMap[param1];
      }
      
      gestouch_internal function onTouchBegin(param1:uint, param2:Number, param3:Number, param4:Object = null) : Boolean
      {
         var _loc6_:Touch = null;
         var _loc7_:Touch = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:ITouchHitTester = null;
         if(param1 in this._touchesMap)
         {
            return false;
         }
         var _loc5_:Point = new Point(param2,param3);
         for each(_loc6_ in this._touchesMap)
         {
            if(Point.distance(_loc6_.location,_loc5_) < 2)
            {
               return false;
            }
         }
         _loc7_ = this.createTouch();
         _loc7_.id = param1;
         for each(_loc10_ in this._hitTesters)
         {
            _loc8_ = _loc10_.hitTest(_loc5_,param4);
            if(_loc8_)
            {
               if(!(_loc8_ is Stage))
               {
                  break;
               }
               _loc9_ = _loc8_;
            }
         }
         if(!_loc8_ && !_loc9_)
         {
            throw new Error("Not touch target found (hit test)." + "Something is wrong, at least flash.display::Stage should be found." + "See Gestouch#addTouchHitTester() and Gestouch#inputAdapter.");
         }
         _loc7_.target = _loc8_ || _loc9_;
         _loc7_.gestouch_internal::setLocation(param2,param3,getTimer());
         this._touchesMap[param1] = _loc7_;
         ++this._activeTouchesCount;
         this._gesturesManager.gestouch_internal::onTouchBegin(_loc7_);
         return true;
      }
      
      gestouch_internal function onTouchMove(param1:uint, param2:Number, param3:Number) : void
      {
         var _loc4_:Touch = this._touchesMap[param1] as Touch;
         if(!_loc4_)
         {
            return;
         }
         if(_loc4_.gestouch_internal::updateLocation(param2,param3,getTimer()))
         {
            this._gesturesManager.gestouch_internal::onTouchMove(_loc4_);
         }
      }
      
      gestouch_internal function onTouchEnd(param1:uint, param2:Number, param3:Number) : void
      {
         var _loc4_:Touch = this._touchesMap[param1] as Touch;
         if(!_loc4_)
         {
            return;
         }
         _loc4_.gestouch_internal::updateLocation(param2,param3,getTimer());
         delete this._touchesMap[param1];
         --this._activeTouchesCount;
         this._gesturesManager.gestouch_internal::onTouchEnd(_loc4_);
         _loc4_.target = null;
      }
      
      gestouch_internal function onTouchCancel(param1:uint, param2:Number, param3:Number) : void
      {
         var _loc4_:Touch = this._touchesMap[param1] as Touch;
         if(!_loc4_)
         {
            return;
         }
         _loc4_.gestouch_internal::updateLocation(param2,param3,getTimer());
         delete this._touchesMap[param1];
         --this._activeTouchesCount;
         this._gesturesManager.gestouch_internal::onTouchCancel(_loc4_);
         _loc4_.target = null;
      }
      
      protected function createTouch() : Touch
      {
         return new Touch();
      }
      
      protected function hitTestersSorter(param1:ITouchHitTester, param2:ITouchHitTester) : Number
      {
         var _loc3_:int = int(this._hitTesterPrioritiesMap[param1]) - int(this._hitTesterPrioritiesMap[param2]);
         if(_loc3_ > 0)
         {
            return -1;
         }
         if(_loc3_ < 0)
         {
            return 1;
         }
         return this._hitTesters.indexOf(param1) > this._hitTesters.indexOf(param2) ? 1 : -1;
      }
   }
}
