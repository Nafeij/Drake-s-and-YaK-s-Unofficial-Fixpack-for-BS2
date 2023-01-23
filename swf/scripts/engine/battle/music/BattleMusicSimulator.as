package engine.battle.music
{
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.sound.config.ISoundSystem;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleMusicSimulator
   {
       
      
      public var defResource:DefResource;
      
      public var def:BattleMusicDef;
      
      public var url:String;
      
      public var music:BattleMusic;
      
      public var resman:ResourceManager;
      
      public var logger:ILogger;
      
      public var system:ISoundSystem;
      
      public var animDispatcher:EventDispatcher;
      
      private var _started:Boolean;
      
      public function BattleMusicSimulator(param1:ResourceManager, param2:ISoundSystem, param3:EventDispatcher)
      {
         super();
         this.resman = param1;
         this.logger = param1.logger;
         this.system = param2;
         this.animDispatcher = param3;
      }
      
      public function cleanup() : void
      {
         if(this.music)
         {
            if(this.music.preloader)
            {
               this.music.preloader.removeEventListener(Event.COMPLETE,this.battleMusicCompleteHandler);
            }
            this.music.stop();
            this.music.cleanup();
         }
         if(this.def)
         {
            this.def.cleanup();
            this.def = null;
         }
         if(this.defResource)
         {
            this.defResource.release();
            this.defResource = null;
         }
      }
      
      public function load(param1:String) : void
      {
         this.defResource = this.resman.getResource(param1,DefResource) as DefResource;
         this.defResource.addResourceListener(this.resourceCompleteHandler);
      }
      
      private function resourceCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         this.defResource.removeResourceListener(this.resourceCompleteHandler);
         if(!this.defResource.ok)
         {
            this.logger.error("Failed to load BattleMusicSimulator " + this.url);
            return;
         }
         this._setup();
      }
      
      private function _setup() : void
      {
         this.def = new BattleMusicDef().fromJson(this.defResource.jo,this.logger);
         this.music = new BattleMusic(this.def,this.system,this.logger,this.animDispatcher);
         this.music.preloader.addEventListener(Event.COMPLETE,this.battleMusicCompleteHandler);
         this.music.preloader.preload();
      }
      
      private function battleMusicCompleteHandler(param1:Event) : void
      {
         if(Boolean(this.music) && Boolean(this.music.preloader))
         {
            this.music.preloader.removeEventListener(Event.COMPLETE,this.battleMusicCompleteHandler);
            this._started = true;
            this.music.start();
         }
      }
      
      public function update() : void
      {
         if(!this._started || !this.music)
         {
            return;
         }
         this.music.updateBattleMusic();
      }
   }
}
