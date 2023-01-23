package engine.saga
{
   import engine.achievement.AchievementListDefVars;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.BattleAbilityDefFactoryVars;
   import engine.battle.board.model.BattleScenarioDefList;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.ItemListDefWrangler;
   import engine.entity.TitleListDefWrangler;
   import engine.entity.UnitStatCosts;
   import engine.entity.UnitStatCostsWrangler;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.EntityClassDefWrangler;
   import engine.entity.def.EntityListDef;
   import engine.entity.def.EntityListDefVars;
   import engine.fmod.FmodProjectInfo;
   import engine.landscape.travel.def.CartListDefWrangler;
   import engine.resource.IResource;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   import engine.resource.def.DefWrangler;
   import engine.resource.def.DefWranglerWrangler;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.action.Action_War;
   import engine.saga.action.Action_War_Impl_1;
   import engine.saga.action.Action_War_Impl_2;
   import engine.saga.convo.def.audio.ConvoAudioListDef;
   import engine.saga.vars.IBattleEntityProvider;
   import engine.scene.def.SceneDefVars;
   import engine.sound.ISoundPreloader;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.SoundLibrary;
   import engine.sound.def.SoundLibraryResource;
   import engine.talent.TalentDefs;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   
   public class SagaDefLoader
   {
       
      
      public var sagaDef:SagaDef;
      
      public var callback:Function;
      
      public var logger:ILogger;
      
      public var locale:Locale;
      
      public var classes:EntityClassDefList;
      
      public var abilities:BattleAbilityDefFactory;
      
      public var resman:ResourceManager;
      
      public var wranglers:DefWranglerWrangler;
      
      public var mlr:SoundLibraryResource;
      
      public var volr:SoundLibraryResource;
      
      public var sound:ISoundSystem;
      
      private var wranglersComplete:Boolean;
      
      public var unitStatCosts:UnitStatCosts;
      
      public var stripHappenings:Boolean;
      
      public var scenarios:BattleScenarioDefList;
      
      public var bbp:IBattleEntityProvider;
      
      private var voPreloadComplete:Boolean;
      
      private var soundPreloadComplete:Boolean;
      
      private var isComplete:Boolean;
      
      public function SagaDefLoader(param1:ResourceManager, param2:ILogger, param3:Locale, param4:EntityClassDefList, param5:IBattleEntityProvider, param6:BattleAbilityDefFactory, param7:ISoundSystem, param8:Boolean)
      {
         super();
         this.bbp = param5;
         this.logger = param2;
         this.locale = param3;
         this.classes = param4;
         this.abilities = param6;
         this.resman = param1;
         this.sound = param7;
         this.stripHappenings = param8;
         if(!param4 || !param6 || !param3 || !param1)
         {
            throw new ArgumentError("illegal SagaDefLoader");
         }
      }
      
      public function cleanup() : void
      {
         if(this.wranglers)
         {
            this.wranglers.cleanup();
            this.wranglers = null;
         }
      }
      
      public function load(param1:String, param2:Function) : void
      {
         this.callback = param2;
         var _loc3_:IResource = this.resman.getResource(param1,DefResource);
         _loc3_.addResourceListener(this.resourceHandler);
      }
      
      private function resourceHandler(param1:ResourceLoadedEvent) : void
      {
         var soundPreloader:ISoundPreloader = null;
         var projInfo:FmodProjectInfo = null;
         var event:ResourceLoadedEvent = param1;
         var dr:DefResource = event.resource as DefResource;
         var drjo:Object = dr.jo;
         var drurl:String = dr.url;
         var drok:Boolean = dr.ok;
         dr.removeResourceListener(this.resourceHandler);
         dr.release();
         dr = null;
         if(!drok)
         {
            this.callback(this);
            return;
         }
         try
         {
            this.sagaDef = new SagaDefVars(drurl,this.locale,this.logger);
            (this.sagaDef as SagaDefVars).fromJson(drjo,this.logger,this.stripHappenings);
         }
         catch(err:Error)
         {
            sagaDef = null;
            logger.error("Unable to load saga def:");
            logger.error(err.getStackTrace());
            callback(this);
            return;
         }
         this.wranglers = new DefWranglerWrangler("SagaDef",this.resman,this.logger);
         this.wranglers.addEventListener(Event.COMPLETE,this.wranglersHandler);
         if(this.sagaDef.scenesUrl)
         {
            this.wranglers.wrangle(this.sagaDef.scenesUrl);
         }
         if(this.sagaDef.castUrl)
         {
            this.wranglers.wrangle(this.sagaDef.castUrl);
         }
         if(this.sagaDef.classesUrl)
         {
            this.wranglers.add(new EntityClassDefWrangler(this.sagaDef.classesUrl,this.logger,this.resman,this.locale,null));
         }
         if(this.sagaDef.unitStatCostsUrl)
         {
            this.wranglers.add(new UnitStatCostsWrangler(this.sagaDef.unitStatCostsUrl,this.logger,this.resman,null));
         }
         if(this.sagaDef.dlcsUrl)
         {
            this.wranglers.wrangle(this.sagaDef.dlcsUrl);
         }
         if(this.sagaDef.achievementsUrl)
         {
            this.wranglers.wrangle(this.sagaDef.achievementsUrl);
         }
         if(this.sagaDef.mapSceneUrl)
         {
            this.wranglers.wrangle(this.sagaDef.mapSceneUrl);
         }
         if(this.sagaDef.itemDefsUrl)
         {
            this.wranglers.add(new ItemListDefWrangler(this.sagaDef.itemDefsUrl,this.logger,this.locale,this.abilities,this.resman,null));
         }
         if(this.sagaDef.titleDefsUrl)
         {
            this.wranglers.add(new TitleListDefWrangler(this.sagaDef.titleDefsUrl,this.logger,this.locale,this.abilities,this.resman,null));
         }
         if(this.sagaDef.cartDefsUrl)
         {
            this.wranglers.add(new CartListDefWrangler(this.sagaDef.cartDefsUrl,this.logger,this.resman,null));
         }
         if(this.sagaDef.scenarioDefsUrl)
         {
            this.wranglers.wrangle(this.sagaDef.scenarioDefsUrl);
         }
         if(this.sagaDef.talentDefsUrl)
         {
            this.wranglers.wrangle(this.sagaDef.talentDefsUrl);
         }
         if(this.sagaDef.convoAudioUrl)
         {
            this.wranglers.wrangle(this.sagaDef.convoAudioUrl);
         }
         if(Boolean(this.sagaDef.musicUrl) && Boolean(this.sound))
         {
            this.mlr = this.resman.getResource(this.sagaDef.musicUrl,SoundLibraryResource) as SoundLibraryResource;
            this.mlr.addResourceListener(this.mlrComplete);
         }
         else
         {
            this.sagaDef.music = new SoundLibrary("null saga music library",this.logger);
         }
         if(Boolean(this.sagaDef.voUrl) && Boolean(this.sound))
         {
            this.volr = this.resman.getResource(this.sagaDef.voUrl,SoundLibraryResource) as SoundLibraryResource;
            this.volr.addResourceListener(this.volrComplete);
         }
         else
         {
            this.volrComplete(null);
         }
         if(this.sound)
         {
            if(this.sagaDef.fmodProjectInfos.length > 0 || Boolean(this.sagaDef.fmodPreloadUrl))
            {
               soundPreloader = this.sound.driver.preloader;
               for each(projInfo in this.sagaDef.fmodProjectInfos)
               {
                  soundPreloader.addProjectInfo(projInfo);
               }
               if(this.sagaDef.fmodPreloadUrl)
               {
                  soundPreloader.setPreloadUrl(this.sagaDef.fmodPreloadUrl);
               }
               this.soundPreloadComplete = false;
               soundPreloader.load(this.soundPreloaderCompleteHandler);
            }
            else
            {
               this.soundPreloaderCompleteHandler(null);
            }
            if(!isNaN(this.sagaDef.audioVoDuckingMultiplier))
            {
               this.sound.voDuckingMultiplier = this.sagaDef.audioVoDuckingMultiplier;
            }
            if(!isNaN(this.sagaDef.audioVoDuckingSpeed))
            {
               this.sound.voDuckingSpeed = this.sagaDef.audioVoDuckingSpeed;
            }
            if(!isNaN(this.sagaDef.audioPopDuckingMultiplier))
            {
               this.sound.popDuckingMultiplier = this.sagaDef.audioPopDuckingMultiplier;
            }
         }
         else
         {
            this.soundPreloaderCompleteHandler(null);
         }
         if(this.sagaDef.abilityParamsUrl)
         {
            this.wranglers.wrangle(this.sagaDef.abilityParamsUrl);
         }
         Action_War.POPPENING_CONTINUE_URL = this.sagaDef.warPoppeningContinueUrl;
         Action_War.POPPENING_URL = this.sagaDef.warPoppeningUrl;
         if(this.sagaDef.warPoppeningImpl)
         {
            switch(this.sagaDef.warPoppeningImpl)
            {
               case "Action_War_Impl_1":
                  Action_War.IMPL_CLASS = Action_War_Impl_1;
                  break;
               case "Action_War_Impl_2":
                  Action_War.IMPL_CLASS = Action_War_Impl_2;
                  break;
               default:
                  throw new IllegalOperationError("unknown ActionWar.IMPL_CLASS " + this.sagaDef.warPoppeningImpl);
            }
         }
         else
         {
            this.logger.info("No Action_War.IMPL_CLASS specified, I hope you have no wars...");
         }
         this.wranglers.load();
      }
      
      private function voPreload() : void
      {
         var _loc1_:ISoundPreloader = null;
         var _loc2_:FmodProjectInfo = null;
         if(!this.sound)
         {
            this.voPreloadCompleteHandler(null);
            return;
         }
         if(this.sagaDef.vo.fmodProjectInfos.length > 0)
         {
            this.voPreloadComplete = false;
            _loc1_ = this.sound.driver.preloader;
            for each(_loc2_ in this.sagaDef.vo.fmodProjectInfos)
            {
               _loc1_.addProjectInfo(_loc2_);
            }
            _loc1_.load(this.voPreloadCompleteHandler);
         }
         else
         {
            this.voPreloadCompleteHandler(null);
         }
      }
      
      private function voPreloadCompleteHandler(param1:ISoundPreloader) : void
      {
         this.voPreloadComplete = true;
         this.checkComplete();
      }
      
      private function soundPreloaderCompleteHandler(param1:ISoundPreloader) : void
      {
         this.soundPreloadComplete = true;
         this.checkComplete();
      }
      
      private function finishScenarios() : void
      {
         var _loc1_:DefWrangler = null;
         if(this.sagaDef.scenarioDefsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.scenarioDefsUrl);
            this.sagaDef.scenarioDefs = new BattleScenarioDefList().fromJson(_loc1_.vars,this.logger);
         }
      }
      
      private function finishTalentDefs() : void
      {
         var _loc1_:DefWrangler = null;
         if(this.sagaDef.talentDefsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.talentDefsUrl);
            this.sagaDef.talentDefs = new TalentDefs().fromJson(_loc1_.vars,this.logger);
         }
      }
      
      private function finishCast() : void
      {
         var _loc1_:DefWrangler = null;
         var _loc2_:EntityListDef = null;
         var _loc3_:String = null;
         if(this.sagaDef.castUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.castUrl);
            _loc2_ = new EntityListDefVars(this.locale,this.logger).fromJson(_loc1_.vars,this.logger,this.abilities,this.sagaDef.classes,this.bbp,true,this.sagaDef.itemDefs,this.sagaDef.unitStatCosts);
            this.sagaDef.setCast(_loc2_,this.bbp);
            for each(_loc3_ in this.sagaDef.roster)
            {
               if(!this.sagaDef.cast.getEntityDefById(_loc3_))
               {
                  this.logger.error("Saga no such roster cast: " + _loc3_);
               }
            }
         }
      }
      
      private function finishConvoAudio() : void
      {
         var _loc1_:DefWrangler = null;
         if(this.sagaDef.convoAudioUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.convoAudioUrl);
            this.sagaDef.convoAudio = new ConvoAudioListDef().fromJson(_loc1_.vars,this.logger);
         }
      }
      
      private function finishClasses() : void
      {
         var _loc1_:EntityClassDefWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishClasses " + this.sagaDef.classesUrl);
         }
         if(this.sagaDef.classesUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.classesUrl) as EntityClassDefWrangler;
            this.sagaDef.classes = _loc1_.manager;
            this.sagaDef.classes.parent = this.classes;
         }
      }
      
      private function finishAbilityParams() : void
      {
         var _loc1_:DefWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishAbilityParams " + this.sagaDef.abilityParamsUrl);
         }
         if(this.sagaDef.abilityParamsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.abilityParamsUrl);
            if(_loc1_.vars)
            {
               BattleAbilityDefFactoryVars.parseParams(this.abilities.params,_loc1_.vars as Array,this.logger);
               this.abilities.updateAbilityDefDescriptions();
            }
         }
      }
      
      private function mlrComplete(param1:ResourceLoadedEvent) : void
      {
         this.mlr.removeResourceListener(this.mlrComplete);
         if(this.mlr.ok)
         {
            this.sagaDef.music = this.mlr.library;
         }
         else
         {
            this.sagaDef.music = new SoundLibrary("null saga music library",this.logger);
         }
      }
      
      private function volrComplete(param1:ResourceLoadedEvent) : void
      {
         if(this.volr)
         {
            this.volr.removeResourceListener(this.volrComplete);
         }
         if(Boolean(this.volr) && this.volr.ok)
         {
            this.sagaDef.vo = this.volr.library;
         }
         else
         {
            this.sagaDef.vo = new SoundLibrary("null saga vo library",this.logger);
         }
         this.voPreload();
      }
      
      private function finishUnitStatCosts() : void
      {
         var _loc1_:UnitStatCostsWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishUnitStatCosts " + this.sagaDef.unitStatCostsUrl);
         }
         if(this.sagaDef.unitStatCostsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.unitStatCostsUrl) as UnitStatCostsWrangler;
            this.sagaDef.unitStatCosts = _loc1_.statCosts;
         }
      }
      
      private function finishDlcs() : void
      {
         var _loc1_:DefWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishDlcs " + this.sagaDef.dlcsUrl);
         }
         if(this.sagaDef.dlcsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.dlcsUrl) as DefWrangler;
            this.sagaDef.dlcs = new SagaDlcsVars().fromJson(_loc1_.vars,this.logger,false);
         }
      }
      
      private function finishAchievements() : void
      {
         var _loc1_:DefWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishAchievements " + this.sagaDef.achievementsUrl);
         }
         if(this.sagaDef.achievementsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.achievementsUrl) as DefWrangler;
            this.sagaDef.achievements = new AchievementListDefVars(_loc1_.vars,this.logger,this.locale);
         }
      }
      
      private function finishMapScene() : void
      {
         var _loc1_:DefWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishMapScene " + this.sagaDef.mapSceneUrl);
         }
         if(this.sagaDef.mapSceneUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.mapSceneUrl) as DefWrangler;
            if(!_loc1_.vars)
            {
               this.logger.error("Proceeding without map scene: " + this.sagaDef.mapSceneUrl);
            }
            else
            {
               this.sagaDef.mapScene = new SceneDefVars(this.sagaDef.mapSceneUrl).fromJson(_loc1_.vars,this.locale,this.classes,this.abilities,null,this.logger,this.stripHappenings);
            }
         }
      }
      
      private function finishItemDefs() : void
      {
         var _loc1_:ItemListDefWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishItemDefs " + this.sagaDef.itemDefsUrl);
         }
         if(this.sagaDef.itemDefsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.itemDefsUrl) as ItemListDefWrangler;
            this.sagaDef.itemDefs = _loc1_.itemDefs;
         }
      }
      
      private function finishTitleDefs() : void
      {
         var _loc1_:TitleListDefWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishTitleDefs " + this.sagaDef.titleDefsUrl);
         }
         if(this.sagaDef.titleDefsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.titleDefsUrl) as TitleListDefWrangler;
            this.sagaDef.titleDefs = _loc1_.titleDefs;
         }
      }
      
      private function finishCartDefs() : void
      {
         var _loc1_:CartListDefWrangler = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.finishCartDefs " + this.sagaDef.cartDefsUrl);
         }
         if(this.sagaDef.cartDefsUrl)
         {
            _loc1_ = this.wranglers.wrangled(this.sagaDef.cartDefsUrl) as CartListDefWrangler;
            this.sagaDef.cartDefs = _loc1_.cartDefs;
         }
      }
      
      private function wranglersHandler(param1:Event) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.wranglersHandler START");
         }
         this.finishClasses();
         this.finishAbilityParams();
         this.finishUnitStatCosts();
         this.finishDlcs();
         this.finishItemDefs();
         this.finishTitleDefs();
         this.finishCartDefs();
         this.finishCast();
         this.finishConvoAudio();
         this.finishAchievements();
         this.finishMapScene();
         this.finishScenarios();
         this.finishTalentDefs();
         this.wranglers.removeEventListener(Event.COMPLETE,this.wranglersHandler);
         this.wranglers.cleanup();
         this.wranglers = null;
         this.wranglersComplete = true;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("SagaDefLoader.wranglersHandler END");
         }
         this.checkComplete();
      }
      
      private function checkComplete() : void
      {
         if(!this.wranglersComplete)
         {
            return;
         }
         if(!this.soundPreloadComplete)
         {
            return;
         }
         if(!this.voPreloadComplete)
         {
            return;
         }
         if(!this.isComplete)
         {
            if(this.sagaDef)
            {
               this.sagaDef.finishLoading();
            }
            this.isComplete = true;
            this.resman = null;
            this.callback(this);
         }
      }
   }
}
