package com.stoicstudio.platform.gog
{
   import air.gog.ane.GogAne;
   import engine.saga.ISagaDlc;
   import engine.saga.SagaDlcEntry;
   
   public final class GogSagaDlc implements ISagaDlc
   {
       
      
      private var gog:GogAne;
      
      public function GogSagaDlc(param1:GogAne)
      {
         super();
         this.gog = param1;
      }
      
      public function ownsDlc(param1:SagaDlcEntry, param2:Function = null) : int
      {
         var _loc3_:Boolean = false;
         if(Boolean(this.gog) && this.gog.enabled)
         {
            if(param1.platform_id_gog_appid < 0)
            {
               return SagaDlcEntry.DLC_OWNED;
            }
            if(param1.platform_id_gog_appid)
            {
               _loc3_ = this.gog.GalaxyAPI_IsDLCInstalled(param1.platform_id_gog_appid);
               return _loc3_ ? SagaDlcEntry.DLC_OWNED : SagaDlcEntry.DLC_NOT_OWNED;
            }
         }
         return SagaDlcEntry.DLC_STATUS_UNKNOWN;
      }
   }
}
