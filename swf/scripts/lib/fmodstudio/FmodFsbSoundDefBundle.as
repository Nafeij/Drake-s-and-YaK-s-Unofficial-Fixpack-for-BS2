package lib.fmodstudio
{
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import engine.sound.def.ISoundDef;
   import lib.engine.sound.fmod.FmodSoundDefBundle;
   import lib.engine.sound.fmod.IFmodSoundDriver;
   
   public class FmodFsbSoundDefBundle extends FmodSoundDefBundle
   {
       
      
      public function FmodFsbSoundDefBundle(param1:String, param2:IFmodSoundDriver, param3:ILogger, param4:ResourceManager, param5:Vector.<ISoundDef>)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      override protected function loadBanks() : void
      {
         var _loc1_:* = null;
         var _loc2_:ISoundDef = null;
         var _loc3_:String = null;
         var _loc4_:FmodFsbResource = null;
         for(_loc1_ in banks)
         {
            _loc2_ = banks[_loc1_];
            _loc3_ = soundDriver.getResourcePath(_loc2_.sku,_loc1_);
            _loc4_ = resman.getResource(_loc3_,FmodFsbResource) as FmodFsbResource;
            _loc4_.bankName = _loc1_;
            _loc4_.streaming = _loc2_.isStream;
            _loc4_.soundDriver = soundDriver;
            resources.push(_loc4_);
         }
         super.loadBanks();
      }
   }
}
