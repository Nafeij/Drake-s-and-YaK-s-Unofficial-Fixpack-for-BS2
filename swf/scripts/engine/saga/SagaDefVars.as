package engine.saga
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   import engine.entity.def.ShitlistDef;
   import engine.entity.def.ShitlistDefs;
   import engine.fmod.FmodProjectInfo;
   import engine.saga.happening.HappeningDefBagVars;
   import engine.saga.happening.HappeningDefVars;
   import engine.saga.vars.VariableDef;
   import engine.saga.vars.VariableDefVars;
   
   public class SagaDefVars extends SagaDef
   {
      
      public static const schema:Object = {
         "name":"SagaDefVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "title_id":{"type":"string"},
            "fmodProjectInfos":{
               "type":"array",
               "items":FmodProjectInfo.schema,
               "optional":true
            },
            "variables":{
               "type":"array",
               "items":VariableDefVars.schema
            },
            "caravans":{
               "type":"array",
               "items":CaravanDefVars.schema
            },
            "fmodSku":{
               "type":"string",
               "optional":true
            },
            "fmodPreloadUrl":{
               "type":"string",
               "optional":true
            },
            "audioVoDuckingMultiplier":{
               "type":"number",
               "optional":true
            },
            "audioVoDuckingSpeed":{
               "type":"number",
               "optional":true
            },
            "audioPopDuckingMultiplier":{
               "type":"number",
               "optional":true
            },
            "buckets":{
               "type":"array",
               "items":SagaBucketVars.schema,
               "optional":true
            },
            "happenings":{
               "type":"array",
               "items":HappeningDefVars.schema,
               "optional":true
            },
            "scenesUrl":{
               "type":"string",
               "optional":true
            },
            "dlcsUrl":{
               "type":"string",
               "optional":true
            },
            "musicUrl":{
               "type":"string",
               "optional":true
            },
            "voUrl":{
               "type":"string",
               "optional":true
            },
            "abilityParamsUrl":{
               "type":"string",
               "optional":true
            },
            "startUrl":{
               "type":"string",
               "optional":true
            },
            "startCaravan":{
               "type":"string",
               "optional":true
            },
            "scenarioDefsUrl":{
               "type":"string",
               "optional":true
            },
            "talentDefsUrl":{
               "type":"string",
               "optional":true
            },
            "castUrl":{"type":"string"},
            "unitStatCostsUrl":{"type":"string"},
            "campMusic":{
               "type":SagaCampMusicDef.schema,
               "optional":true
            },
            "classesUrl":{"type":"string"},
            "convoAudioUrl":{"type":"string"},
            "achievementsUrl":{
               "type":"string",
               "optional":true
            },
            "banners":{
               "type":"array",
               "items":SagaBannerDefVars.schema,
               "optional":true
            },
            "itemDefsUrl":{"type":"string"},
            "titleDefsUrl":{
               "type":"string",
               "optional":true
            },
            "cartDefsUrl":{
               "type":"string",
               "optional":true
            },
            "mapSceneUrl":{"type":"string"},
            "battleMusicUrls":{
               "type":"array",
               "optional":true
            },
            "difficulties":{
               "type":"array",
               "items":SagaDifficultyDef.schema
            },
            "battleMusicUrl":{
               "type":"string",
               "optional":true
            },
            "trainingBattleUrl":{
               "type":"string",
               "optional":true
            },
            "caravanAnimBaseUrl":{
               "type":"string",
               "optional":true
            },
            "caravanClosePoleUrl":{
               "type":"string",
               "optional":true
            },
            "importDef":{
               "type":SagaImportDef.schema,
               "optional":true
            },
            "minPlayerUnitRank":{
               "type":"number",
               "optional":true
            },
            "campUrls":{
               "type":"array",
               "items":"string"
            },
            "split_happenings":{
               "type":"boolean",
               "optional":true
            },
            "survival":{
               "type":"boolean",
               "optional":true
            },
            "tamperchecks":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "credits":{
               "type":SagaCreditsDef.schema,
               "optional":true
            },
            "creditses":{
               "type":"array",
               "items":SagaCreditsDef.schema,
               "optional":true
            },
            "master_store_achievements":{
               "type":"boolean",
               "optional":true
            },
            "shitlists":{
               "type":"array",
               "items":ShitlistDef.schema,
               "optional":true
            },
            "consumedTitles":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "scenePreprocessor":{
               "type":SagaScenePreprocessorDef.schema,
               "optional":true
            },
            "recap":{
               "type":SagaRecapDef.schema,
               "optional":true
            },
            "warPoppeningContinueUrl":{
               "type":"string",
               "optional":true
            },
            "warPoppeningUrl":{
               "type":"string",
               "optional":true
            },
            "warPoppeningImpl":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function SagaDefVars(param1:String, param2:Locale, param3:ILogger)
      {
         super(param2,param3);
         this.url = param1;
      }
      
      public static function save(param1:SagaDef) : SagaDefSaveInfo
      {
         var sdsi:SagaDefSaveInfo = null;
         var rhs:SagaDef = param1;
         try
         {
            sdsi = new SagaDefSaveInfo(rhs);
            return sdsi;
         }
         catch(e:Error)
         {
            throw new ArgumentError("Failed to save saga: " + rhs.url + "\n" + e.getStackTrace());
         }
      }
      
      public static function toJson(param1:SagaDef) : Object
      {
         var _loc3_:SagaDifficultyDef = null;
         var _loc4_:SagaBucket = null;
         var _loc5_:VariableDef = null;
         var _loc6_:CaravanDef = null;
         var _loc7_:SagaBannerDef = null;
         var _loc8_:FmodProjectInfo = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         var _loc2_:Object = {
            "id":param1.id,
            "title_id":param1.title_id,
            "variables":[],
            "caravans":[],
            "fmodProjectInfos":[],
            "campUrls":[],
            "castUrl":(!!param1.castUrl ? param1.castUrl : ""),
            "classesUrl":(!!param1.classesUrl ? param1.classesUrl : ""),
            "unitStatCostsUrl":(!!param1.unitStatCostsUrl ? param1.unitStatCostsUrl : ""),
            "dlcsUrl":(!!param1.dlcsUrl ? param1.dlcsUrl : ""),
            "itemDefsUrl":(!!param1.itemDefsUrl ? param1.itemDefsUrl : ""),
            "titleDefsUrl":(!!param1.titleDefsUrl ? param1.titleDefsUrl : ""),
            "cartDefsUrl":(!!param1.cartDefsUrl ? param1.cartDefsUrl : ""),
            "convoAudioUrl":(!!param1.convoAudioUrl ? param1.convoAudioUrl : ""),
            "achievementsUrl":(!!param1.achievementsUrl ? param1.achievementsUrl : ""),
            "musicUrl":(!!param1.musicUrl ? param1.musicUrl : ""),
            "voUrl":(!!param1.voUrl ? param1.voUrl : ""),
            "startUrl":(!!param1._startUrl ? param1._startUrl : ""),
            "startCaravan":(!!param1._startCaravan ? param1._startCaravan : ""),
            "scenarioDefsUrl":(!!param1.scenarioDefsUrl ? param1.scenarioDefsUrl : ""),
            "talentDefsUrl":(!!param1.talentDefsUrl ? param1.talentDefsUrl : ""),
            "abilityParamsUrl":(!!param1.abilityParamsUrl ? param1.abilityParamsUrl : ""),
            "mapSceneUrl":(!!param1.mapSceneUrl ? param1.mapSceneUrl : ""),
            "battleMusicUrl":(!!param1.battleMusicUrl ? param1.battleMusicUrl : ""),
            "battleMusicUrls":[],
            "buckets":[],
            "banners":[],
            "difficulties":[],
            "caravanAnimBaseUrl":(!!param1.caravanAnimBaseUrl ? param1.caravanAnimBaseUrl : ""),
            "caravanClosePoleUrl":(!!param1.caravanClosePoleUrl ? param1.caravanClosePoleUrl : ""),
            "split_happenings":true,
            "warPoppeningContinueUrl":(!!param1.warPoppeningContinueUrl ? param1.warPoppeningContinueUrl : ""),
            "warPoppeningUrl":(!!param1.warPoppeningUrl ? param1.warPoppeningUrl : ""),
            "warPoppeningImpl":(!!param1.warPoppeningImpl ? param1.warPoppeningImpl : "")
         };
         if(param1.shitlistDefs)
         {
            _loc2_.shitlists = param1.shitlistDefs.toJson();
         }
         if(Boolean(param1.consumedTitles) && param1.consumedTitles.length > 0)
         {
            _loc9_ = new Array();
            for each(_loc10_ in param1.consumedTitles)
            {
               _loc9_.push(_loc10_);
            }
            _loc2_.consumedTitles = _loc9_;
         }
         if(Boolean(param1.creditses) && Boolean(param1.creditses.length))
         {
            _loc2_.creditses = ArrayUtil.defVectorToArray(param1.creditses,false);
         }
         if(param1.fmodSku)
         {
            _loc2_.fmodSku = param1.fmodSku;
         }
         if(param1.fmodPreloadUrl)
         {
            _loc2_.fmodPreloadUrl = param1.fmodPreloadUrl;
         }
         if(!isNaN(param1.audioVoDuckingMultiplier))
         {
            _loc2_.audioVoDuckingMultiplier = param1.audioVoDuckingMultiplier;
         }
         if(!isNaN(param1.audioVoDuckingSpeed))
         {
            _loc2_.audioVoDuckingSpeed = param1.audioVoDuckingSpeed;
         }
         if(!isNaN(param1.audioPopDuckingMultiplier))
         {
            _loc2_.audioPopDuckingMultiplier = param1.audioPopDuckingMultiplier;
         }
         if(param1.survival)
         {
            _loc2_.survival = param1.survival;
         }
         if(param1.tamperchecks)
         {
            _loc2_.tamperchecks = param1.tamperchecks;
         }
         if(param1.master_store_achievements)
         {
            _loc2_.master_store_achievements = param1.master_store_achievements;
         }
         for each(_loc3_ in param1.difficulties)
         {
            _loc2_.difficulties.push(_loc3_.toJson());
         }
         for each(_loc4_ in param1.buckets.buckets)
         {
            _loc2_.buckets.push(SagaBucketVars.save(_loc4_));
         }
         for each(_loc5_ in param1.variables)
         {
            _loc2_.variables.push(VariableDefVars.save(_loc5_));
         }
         for each(_loc6_ in param1.caravans)
         {
            _loc2_.caravans.push(CaravanDefVars.save(_loc6_));
         }
         for each(_loc7_ in param1.banners)
         {
            _loc2_.banners.push(SagaBannerDefVars.save(_loc7_));
         }
         if(param1.campMusic)
         {
            _loc2_.campMusic = param1.campMusic.toJson();
         }
         if(param1.importDef)
         {
            _loc2_.importDef = param1.importDef.toJson();
         }
         if(param1.scenePreprocessorDef)
         {
            _loc2_.scenePreprocessor = param1.scenePreprocessorDef.toJson();
         }
         if(param1.recap)
         {
            _loc2_.recap = param1.recap.toJson();
         }
         if(param1.minPlayerUnitRank)
         {
            _loc2_.minPlayerUnitRank = param1.minPlayerUnitRank;
         }
         if(param1.campUrls)
         {
            _loc2_.campUrls = param1.campUrls;
         }
         for each(_loc8_ in param1.fmodProjectInfos)
         {
            _loc2_.fmodProjectInfos.push(_loc8_.toJson());
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:Boolean) : SagaDefVars
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:VariableDefVars = null;
         var _loc8_:CaravanDefVars = null;
         var _loc9_:Object = null;
         var _loc10_:SagaBucket = null;
         var _loc11_:Object = null;
         var _loc12_:SagaDifficultyDef = null;
         var _loc13_:String = null;
         var _loc14_:Object = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.title_id = param1.title_id;
         Locale.APP_TITLE_TOKEN = this.title_id;
         if(param1.credits)
         {
            addCredits(new SagaCreditsDef().fromJson(param1.credits,param2));
         }
         else if(param1.creditses)
         {
            creditses = ArrayUtil.arrayToDefVector(param1.creditses,SagaCreditsDef,param2,creditses,null) as Vector.<SagaCreditsDef>;
         }
         if(param1.survival)
         {
            survival = new SagaSurvivalDef(param2);
            if(survival)
            {
               param2.info("SagaDef Forcing [" + id + "] into SURVIVAL MODE");
            }
         }
         tamperchecks = param1.tamperchecks;
         master_store_achievements = param1.master_store_achievements;
         this.minPlayerUnitRank = param1.minPlayerUnitRank;
         for each(_loc4_ in param1.variables)
         {
            _loc7_ = new VariableDefVars();
            _loc7_.fromJson(_loc4_,param2);
            addVariable(_loc7_);
         }
         for each(_loc5_ in param1.caravans)
         {
            _loc8_ = new CaravanDefVars(this);
            _loc8_.fromJson(_loc5_,param2);
            addCaravan(_loc8_);
         }
         if(param1.buckets)
         {
            for each(_loc9_ in param1.buckets)
            {
               _loc10_ = new SagaBucketVars().fromJson(_loc9_,param2);
               buckets.addBucket(_loc10_);
            }
         }
         this.campUrls = param1.campUrls;
         if(param1.banners)
         {
            for each(_loc11_ in param1.banners)
            {
               banners.push(new SagaBannerDefVars().fromJson(_loc11_,param2));
            }
         }
         if(param1.campMusic)
         {
            campMusic = new SagaCampMusicDef().fromJson(param1.campMusic,param2);
         }
         else
         {
            campMusic = new SagaCampMusicDef();
         }
         for each(_loc6_ in param1.difficulties)
         {
            _loc12_ = new SagaDifficultyDef().fromJson(_loc6_,param2);
            difficulties.push(_loc12_);
         }
         if(Boolean(param1.happenings) && Boolean(param1.happenings.length))
         {
            happenings = new HappeningDefBagVars(id,this).fromJson(param1.happenings,param2,param3);
         }
         if(param1.shitlists)
         {
            shitlistDefs = new ShitlistDefs().fromJson(param1.shitlists,param2);
         }
         if(param1.consumedTitles)
         {
            for each(_loc13_ in param1.consumedTitles)
            {
               consumedTitles.push(_loc13_);
            }
         }
         scenesUrl = param1.scenesUrl;
         castUrl = param1.castUrl;
         classesUrl = param1.classesUrl;
         unitStatCostsUrl = param1.unitStatCostsUrl;
         dlcsUrl = param1.dlcsUrl;
         itemDefsUrl = param1.itemDefsUrl;
         titleDefsUrl = param1.titleDefsUrl;
         cartDefsUrl = param1.cartDefsUrl;
         convoAudioUrl = param1.convoAudioUrl;
         achievementsUrl = param1.achievementsUrl;
         mapSceneUrl = param1.mapSceneUrl;
         battleMusicUrl = param1.battleMusicUrl;
         musicUrl = param1.musicUrl;
         fmodSku = param1.fmodSku;
         fmodPreloadUrl = param1.fmodPreloadUrl;
         audioVoDuckingMultiplier = param1.audioVoDuckingMultiplier;
         audioVoDuckingSpeed = param1.audioVoDuckingSpeed;
         audioPopDuckingMultiplier = param1.audioPopDuckingMultiplier;
         voUrl = param1.voUrl;
         abilityParamsUrl = param1.abilityParamsUrl;
         _startUrl = param1.startUrl;
         _startCaravan = param1.startCaravan;
         scenarioDefsUrl = param1.scenarioDefsUrl;
         talentDefsUrl = param1.talentDefsUrl;
         caravanAnimBaseUrl = param1.caravanAnimBaseUrl;
         caravanClosePoleUrl = param1.caravanClosePoleUrl;
         if(param1.fmodProjectInfos)
         {
            for each(_loc14_ in param1.fmodProjectInfos)
            {
               fmodProjectInfos.push(new FmodProjectInfo().fromJson(_loc14_,param2));
            }
         }
         if(param1.importDef)
         {
            importDef = new SagaImportDef().fromJson(param1.importDef,param2);
         }
         if(param1.scenePreprocessor)
         {
            scenePreprocessorDef = new SagaScenePreprocessorDef().fromJson(param1.scenePreprocessor,param2);
         }
         if(param1.recap)
         {
            recap = new SagaRecapDef().fromJson(param1.recap,param2);
         }
         warPoppeningContinueUrl = param1.warPoppeningContinueUrl;
         warPoppeningUrl = param1.warPoppeningUrl;
         warPoppeningImpl = param1.warPoppeningImpl;
         return this;
      }
   }
}
