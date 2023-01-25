package starling.utils
{
   import flash.display3D.Context3D;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.Capabilities;
   import flash.utils.getDefinitionByName;
   import starling.errors.AbstractClassError;
   
   public class SystemUtil
   {
      
      private static var sInitialized:Boolean = false;
      
      private static var sApplicationActive:Boolean = true;
      
      private static var sWaitingCalls:Array = [];
      
      private static var sPlatform:String;
      
      private static var sVersion:String;
      
      private static var sAIR:Boolean;
      
      private static var sSupportsDepthAndStencil:Boolean = true;
       
      
      public function SystemUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function initialize() : void
      {
         var nativeAppClass:Object = null;
         var nativeApp:EventDispatcher = null;
         var appDescriptor:XML = null;
         var ns:Namespace = null;
         var ds:String = null;
         if(sInitialized)
         {
            return;
         }
         sInitialized = true;
         sPlatform = Capabilities.version.substr(0,3);
         sVersion = Capabilities.version.substr(4);
         try
         {
            nativeAppClass = getDefinitionByName("flash.desktop::NativeApplication");
            nativeApp = nativeAppClass["nativeApplication"] as EventDispatcher;
            nativeApp.addEventListener(Event.ACTIVATE,onActivate,false,0,true);
            nativeApp.addEventListener(Event.DEACTIVATE,onDeactivate,false,0,true);
            appDescriptor = nativeApp["applicationDescriptor"];
            ns = appDescriptor.namespace();
            ds = String(appDescriptor.ns::initialWindow.ns::depthAndStencil.toString().toLowerCase());
            sSupportsDepthAndStencil = ds == "true";
            sAIR = true;
         }
         catch(e:Error)
         {
            sAIR = false;
         }
      }
      
      private static function onActivate(param1:Object) : void
      {
         var _loc2_:Array = null;
         sApplicationActive = true;
         for each(_loc2_ in sWaitingCalls)
         {
            _loc2_[0].apply(null,_loc2_[1]);
         }
         sWaitingCalls = [];
      }
      
      private static function onDeactivate(param1:Object) : void
      {
         sApplicationActive = false;
      }
      
      public static function executeWhenApplicationIsActive(param1:Function, ... rest) : void
      {
         initialize();
         if(sApplicationActive)
         {
            param1.apply(null,rest);
         }
         else
         {
            sWaitingCalls.push([param1,rest]);
         }
      }
      
      public static function get isApplicationActive() : Boolean
      {
         initialize();
         return sApplicationActive;
      }
      
      public static function get isAIR() : Boolean
      {
         initialize();
         return sAIR;
      }
      
      public static function get isDesktop() : Boolean
      {
         initialize();
         return /(WIN|MAC|LNX)/.exec(sPlatform) != null;
      }
      
      public static function get platform() : String
      {
         initialize();
         return sPlatform;
      }
      
      public static function get version() : String
      {
         initialize();
         return sVersion;
      }
      
      public static function get supportsRelaxedTargetClearRequirement() : Boolean
      {
         return parseInt(/\d+/.exec(sVersion)[0]) >= 15;
      }
      
      public static function get supportsDepthAndStencil() : Boolean
      {
         return sSupportsDepthAndStencil;
      }
      
      public static function get supportsVideoTexture() : Boolean
      {
         return Context3D["supportsVideoTexture"];
      }
   }
}
