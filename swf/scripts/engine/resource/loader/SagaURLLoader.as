package engine.resource.loader
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class SagaURLLoader extends URLLoader
   {
      
      private static var resourceSchemas:Dictionary = new Dictionary();
       
      
      private var _isLoadingViaSchema:Boolean = false;
      
      public function SagaURLLoader(param1:URLRequest = null)
      {
         super(param1);
      }
      
      public static function registerSchema(param1:String, param2:IResourceScheme) : void
      {
         resourceSchemas[param1] = param2;
      }
      
      public static function getSchema(param1:String) : IResourceScheme
      {
         return resourceSchemas[param1];
      }
      
      public static function hasCustomSchema(param1:String) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc2_:int = param1.indexOf(":");
         if(_loc2_ != -1)
         {
            _loc3_ = param1.substr(0,_loc2_);
            _loc4_ = param1.substr(_loc2_ + 1);
            return resourceSchemas.hasOwnProperty(_loc3_);
         }
         return false;
      }
      
      override public function close() : void
      {
         if(!this._isLoadingViaSchema)
         {
            super.close();
         }
      }
      
      override public function load(param1:URLRequest) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc2_:int = param1.url.indexOf(":");
         if(_loc2_ != -1 && param1.url.charAt(0) != "f")
         {
            _loc3_ = param1.url.substr(0,_loc2_);
            _loc4_ = param1.url.substr(_loc2_ + 1);
            _loc5_ = resourceSchemas.hasOwnProperty(_loc3_);
            if(_loc5_)
            {
               this._isLoadingViaSchema = true;
               resourceSchemas[_loc3_].load(_loc4_,this);
               return;
            }
         }
         super.load(param1);
      }
      
      public function schemaLoadComplete() : void
      {
         var _loc1_:Event = new Event(Event.COMPLETE);
         dispatchEvent(_loc1_);
      }
      
      public function schemaLoadError(param1:String) : void
      {
         var _loc2_:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,param1);
         dispatchEvent(_loc2_);
      }
   }
}
