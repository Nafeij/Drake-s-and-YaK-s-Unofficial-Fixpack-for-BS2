package lib.fmodstudio
{
   import air.fmodstudio.ane.FmodEventId;
   import engine.sound.ISoundEventId;
   
   public class FmodStudioSoundEventId implements ISoundEventId
   {
       
      
      private var _eventId:FmodEventId = null;
      
      public function FmodStudioSoundEventId(param1:FmodEventId)
      {
         super();
         this._eventId = param1;
      }
      
      public static function createFromDesc(param1:String) : FmodStudioSoundEventId
      {
         var _loc2_:FmodEventId = FmodEventId.createFromDesc(param1);
         return _loc2_ != null ? new FmodStudioSoundEventId(_loc2_) : null;
      }
      
      public function get eventId() : FmodEventId
      {
         return this._eventId;
      }
      
      public function equals(param1:ISoundEventId) : Boolean
      {
         var _loc2_:FmodStudioSoundEventId = param1 as FmodStudioSoundEventId;
         if(_loc2_ == null)
         {
            return false;
         }
         if(this._eventId == null)
         {
            return _loc2_.eventId == null;
         }
         return this._eventId.equals(_loc2_.eventId);
      }
      
      public function toString() : String
      {
         return this._eventId != null ? this._eventId.toString() : "<null>";
      }
   }
}
