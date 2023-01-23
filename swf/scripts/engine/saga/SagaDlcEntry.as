package engine.saga
{
   import engine.core.util.AppInfo;
   import engine.math.Hash;
   import flash.events.EventDispatcher;
   
   public class SagaDlcEntry extends EventDispatcher
   {
      
      public static const DLC_OWNED:int = 0;
      
      public static const DLC_NOT_OWNED:int = 1;
      
      public static const DLC_STATUS_UNKNOWN:int = 2;
      
      public static const DLC_CHECKING:int = 3;
      
      public static const DLC_NEEDS_INSTALL:int = 4;
      
      public static var dlcCheck:ISagaDlc;
       
      
      public var id:String;
      
      public var platform_id_steam_appid:int;
      
      public var platform_id_gog_appid:int;
      
      public var platform_id_apple_productid:String;
      
      public var platform_id_google_android_productid:String;
      
      public var platform_id_amazon_productid:String;
      
      public var platform_id_xbl_productid:String;
      
      public var platform_id_psn_productid:String;
      
      public var platform_id_nx_productid:String;
      
      public var vars:Vector.<SagaDlcVariableData>;
      
      public var ownedDefault:Boolean;
      
      public function SagaDlcEntry()
      {
         this.vars = new Vector.<SagaDlcVariableData>();
         super();
      }
      
      public static function computeEntryKey(param1:String) : String
      {
         var _loc2_:uint = Hash.DJBHash(param1);
         return _loc2_.toString(16);
      }
      
      public static function getEntry(param1:String) : SagaDlcEntry
      {
         var _loc3_:SagaDlcEntry = null;
         var _loc2_:Saga = Saga.instance;
         if(_loc2_ && _loc2_.def && _loc2_.def.dlcs && Boolean(_loc2_.def.dlcs.entries))
         {
            for each(_loc3_ in _loc2_.def.dlcs.entries)
            {
               if(_loc3_.id == param1)
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      public static function getEntryByProductId(param1:String, param2:String) : SagaDlcEntry
      {
         var _loc4_:SagaDlcEntry = null;
         var _loc3_:Saga = Saga.instance;
         if(_loc3_ && _loc3_.def && _loc3_.def.dlcs && Boolean(_loc3_.def.dlcs.entries))
         {
            for each(_loc4_ in _loc3_.def.dlcs.entries)
            {
               if(_loc4_[param2] == param1)
               {
                  return _loc4_;
               }
            }
         }
         return null;
      }
      
      public function conditionallyApplyDlc(param1:Saga, param2:AppInfo) : void
      {
         var _loc3_:int = this.checkDlc(param1,param2,this.handleDlcCheck);
         if(_loc3_ != DLC_CHECKING)
         {
            this.handleDlcCheck(_loc3_);
         }
      }
      
      private function handleDlcCheck(param1:int) : void
      {
         if(param1 == DLC_OWNED || param1 == DLC_NEEDS_INSTALL)
         {
            this.internalApplyDlc(Saga.instance);
         }
         dispatchEvent(new SagaDlcEvent(SagaDlcEvent.DLC_CHECK_COMPLETE,this.id,param1));
      }
      
      private function checkDlc(param1:Saga, param2:AppInfo, param3:Function = null) : int
      {
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc4_:int = dlcCheck.ownsDlc(this,param3);
         if(_loc4_ == DLC_STATUS_UNKNOWN)
         {
            _loc5_ = computeEntryKey(this.id);
            _loc6_ = param2.checkFileExists(AppInfo.DIR_APPLICATION,"dlc/" + _loc5_);
            _loc4_ = _loc6_ ? DLC_OWNED : DLC_NOT_OWNED;
         }
         return _loc4_;
      }
      
      private function internalApplyDlc(param1:Saga) : void
      {
         var _loc2_:SagaDlcVariableData = null;
         param1.logger.info("SagaDlcEntry applying [" + this.id + "]");
         for each(_loc2_ in this.vars)
         {
            _loc2_.applyVariable(param1);
         }
      }
   }
}
