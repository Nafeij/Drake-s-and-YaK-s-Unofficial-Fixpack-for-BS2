package engine.saga.action
{
   import engine.saga.ISagaSound;
   import engine.saga.Saga;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.def.ISoundDef;
   
   public class BaseAction_Sound extends Action implements ISoundDefBundleListener
   {
       
      
      protected var bundle:ISoundDefBundle;
      
      protected var param:String;
      
      protected var value:Number;
      
      protected var event:String;
      
      protected var sku:String;
      
      public function BaseAction_Sound(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      public static function getSoundDefsForActionDef(param1:ActionDef, param2:ISagaSound, param3:Vector.<ISoundDef>) : Vector.<ISoundDef>
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:ISoundDef = null;
         if(param1.type == ActionType.SOUND_PLAY_EVENT || param1.type == ActionType.MUSIC_ONESHOT || param1.type == ActionType.MUSIC_START || param1.type == ActionType.MUSIC_OUTRO || param1.type == ActionType.MUSIC_PARAM || param1.type == ActionType.VO)
         {
            _loc4_ = param1.id;
            _loc5_ = param1.location;
            if(!_loc5_)
            {
               _loc5_ = param2.system.driver.inferSkuFromEventPath(_loc4_);
            }
            _loc6_ = param2.getSoundDef(_loc5_,_loc4_);
            if(!param3)
            {
               param3 = new Vector.<ISoundDef>();
               param3.push(_loc6_);
            }
            return param3;
         }
         if(param1.type == ActionType.VIDEO)
         {
            return Action_Video.getSoundDefsForActionDef(param1,param2,param3);
         }
         return param3;
      }
      
      final protected function startLoadingSound(param1:String, param2:String, param3:String, param4:Number) : Boolean
      {
         if(!param2)
         {
            return false;
         }
         if(!param1)
         {
            param1 = saga.sound.system.driver.inferSkuFromEventPath(param2);
         }
         this.event = param2;
         this.sku = param1;
         this.param = param3;
         this.value = param4;
         this.bundle = saga.sound.prepareEventBundle(param1,param2);
         if(this.bundle)
         {
            this.bundle.addListener(this);
         }
         else
         {
            logger.error("No bundle available for " + this);
            end();
         }
         return true;
      }
      
      final public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         var bundle:ISoundDefBundle = param1;
         try
         {
            if(saga.cleanedup)
            {
               if(bundle)
               {
                  bundle.removeListener(this);
                  bundle = null;
               }
               return;
            }
            if(Boolean(bundle) && bundle.ok)
            {
               if(this.handlePlaySound())
               {
                  return;
               }
            }
            if(!ended)
            {
               end();
            }
         }
         catch(e:Error)
         {
            logger.error("soundDefBundleComplete for " + bundle + " in [" + this + "] " + e.getStackTrace());
            if(logger.isDebugEnabled)
            {
               bundle.debugPrint(logger);
            }
         }
      }
      
      override protected function handleEnded() : void
      {
         if(this.bundle)
         {
            this.bundle.removeListener(this);
         }
      }
      
      protected function handlePlaySound() : Boolean
      {
         return false;
      }
   }
}
