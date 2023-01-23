package starling.events
{
   import flash.utils.getQualifiedClassName;
   import starling.core.starling_internal;
   import starling.utils.formatString;
   
   public class Event
   {
      
      public static const ADDED:String = "added";
      
      public static const ADDED_TO_STAGE:String = "addedToStage";
      
      public static const ENTER_FRAME:String = "enterFrame";
      
      public static const REMOVED:String = "removed";
      
      public static const REMOVED_FROM_STAGE:String = "removedFromStage";
      
      public static const TRIGGERED:String = "triggered";
      
      public static const FLATTEN:String = "flatten";
      
      public static const RESIZE:String = "resize";
      
      public static const COMPLETE:String = "complete";
      
      public static const CONTEXT3D_CREATE:String = "context3DCreate";
      
      public static const RENDER:String = "render";
      
      public static const ROOT_CREATED:String = "rootCreated";
      
      public static const REMOVE_FROM_JUGGLER:String = "removeFromJuggler";
      
      public static const TEXTURES_RESTORED:String = "texturesRestored";
      
      public static const IO_ERROR:String = "ioError";
      
      public static const SECURITY_ERROR:String = "securityError";
      
      public static const PARSE_ERROR:String = "parseError";
      
      public static const FATAL_ERROR:String = "fatalError";
      
      public static const CHANGE:String = "change";
      
      public static const CANCEL:String = "cancel";
      
      public static const SCROLL:String = "scroll";
      
      public static const OPEN:String = "open";
      
      public static const CLOSE:String = "close";
      
      public static const SELECT:String = "select";
      
      public static const READY:String = "ready";
      
      private static var sEventPool:Vector.<Event> = new Vector.<Event>(0);
       
      
      private var mTarget:EventDispatcher;
      
      private var mCurrentTarget:EventDispatcher;
      
      private var mType:String;
      
      private var mBubbles:Boolean;
      
      private var mStopsPropagation:Boolean;
      
      private var mStopsImmediatePropagation:Boolean;
      
      private var mData:Object;
      
      public function Event(param1:String, param2:Boolean = false, param3:Object = null)
      {
         super();
         this.mType = param1;
         this.mBubbles = param2;
         this.mData = param3;
      }
      
      starling_internal internal static function fromPool(param1:String, param2:Boolean = false, param3:Object = null) : Event
      {
         if(sEventPool.length)
         {
            return sEventPool.pop().reset(param1,param2,param3);
         }
         return new Event(param1,param2,param3);
      }
      
      starling_internal internal static function toPool(param1:Event) : void
      {
         param1.mData = param1.mTarget = param1.mCurrentTarget = null;
         sEventPool[sEventPool.length] = param1;
      }
      
      public function stopPropagation() : void
      {
         this.mStopsPropagation = true;
      }
      
      public function stopImmediatePropagation() : void
      {
         this.mStopsPropagation = this.mStopsImmediatePropagation = true;
      }
      
      public function toString() : String
      {
         return formatString("[{0} type=\"{1}\" bubbles={2}]",getQualifiedClassName(this).split("::").pop(),this.mType,this.mBubbles);
      }
      
      public function get bubbles() : Boolean
      {
         return this.mBubbles;
      }
      
      public function get target() : EventDispatcher
      {
         return this.mTarget;
      }
      
      public function get currentTarget() : EventDispatcher
      {
         return this.mCurrentTarget;
      }
      
      public function get type() : String
      {
         return this.mType;
      }
      
      public function get data() : Object
      {
         return this.mData;
      }
      
      internal function setTarget(param1:EventDispatcher) : void
      {
         this.mTarget = param1;
      }
      
      internal function setCurrentTarget(param1:EventDispatcher) : void
      {
         this.mCurrentTarget = param1;
      }
      
      internal function setData(param1:Object) : void
      {
         this.mData = param1;
      }
      
      internal function get stopsPropagation() : Boolean
      {
         return this.mStopsPropagation;
      }
      
      internal function get stopsImmediatePropagation() : Boolean
      {
         return this.mStopsImmediatePropagation;
      }
      
      starling_internal internal function reset(param1:String, param2:Boolean = false, param3:Object = null) : Event
      {
         this.mType = param1;
         this.mBubbles = param2;
         this.mData = param3;
         this.mTarget = this.mCurrentTarget = null;
         this.mStopsPropagation = this.mStopsImmediatePropagation = false;
         return this;
      }
   }
}
