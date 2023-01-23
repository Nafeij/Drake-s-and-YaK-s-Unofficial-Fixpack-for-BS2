package engine.battle.music
{
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleMusicPreloader extends EventDispatcher implements ISoundDefBundleListener
   {
       
      
      public var ok:Boolean;
      
      private var music:BattleMusic;
      
      private var bundle:ISoundDefBundle;
      
      public function BattleMusicPreloader(param1:BattleMusic)
      {
         super();
         this.music = param1;
      }
      
      public function preload() : void
      {
         var _loc2_:BattleMusicStateDef = null;
         var _loc3_:SoundDef = null;
         var _loc1_:Vector.<ISoundDef> = new Vector.<ISoundDef>();
         for each(_loc2_ in this.music.def.states)
         {
            _loc3_ = new SoundDef().setup(_loc2_.sku,_loc2_.event,_loc2_.event);
            _loc1_.push(_loc3_);
         }
         if(this.music.driver)
         {
            this.bundle = this.music.driver.preloadSoundDefData(this.music.def.url,_loc1_);
            this.bundle.addListener(this);
         }
         else
         {
            this.soundDefBundleComplete(null);
         }
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         this.ok = Boolean(param1) && param1.ok;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function cleanup() : void
      {
         if(this.bundle)
         {
            this.bundle.removeListener(this);
         }
      }
   }
}
