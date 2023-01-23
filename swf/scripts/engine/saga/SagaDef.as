package engine.saga
{
   import engine.achievement.AchievementListDef;
   import engine.battle.board.model.BattleScenarioDefList;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.EntityListDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ITitleDef;
   import engine.entity.def.ITitleListDef;
   import engine.entity.def.ItemListDef;
   import engine.entity.def.ShitlistDef;
   import engine.entity.def.ShitlistDefs;
   import engine.landscape.travel.def.CartListDef;
   import engine.saga.action.ActionDef;
   import engine.saga.convo.def.audio.ConvoAudioListDef;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.HappeningDefBag;
   import engine.saga.happening.RenameVariableInfo;
   import engine.saga.save.SagaSave;
   import engine.saga.vars.IBattleEntityProvider;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableDef;
   import engine.saga.vars.VariableFactory;
   import engine.scene.def.SceneDef;
   import engine.sound.def.SoundLibrary;
   import engine.talent.TalentDefs;
   import flash.utils.Dictionary;
   
   public class SagaDef implements ISagaDef
   {
      
      public static const CARAVAN_BAGNAME:String = "caravan";
      
      public static var START_HAPPENING:String = "start";
      
      public static var START_TUTORIAL_HAPPENING:String = "start_tutorial";
      
      public static var STRIP_MARKET_ITEMS_BY_RANK:Boolean = true;
      
      public static var PREVIEW_BUILD:Boolean;
      
      public static var SURVIVAL_ENABLED:Boolean;
       
      
      public var tamperchecks:Array;
      
      public var survival:SagaSurvivalDef;
      
      public var url:String;
      
      public var id:String;
      
      public var title_id:String;
      
      public var fmodSku:String;
      
      public var caravans:Vector.<CaravanDef>;
      
      public var caravansByName:Dictionary;
      
      private var _cast:IEntityListDef;
      
      public var buckets:SagaBuckets;
      
      public var variables:Vector.<VariableDef>;
      
      public var variablesByName:Dictionary;
      
      public var scenesUrl:String;
      
      public var castUrl:String;
      
      public var classesUrl:String;
      
      public var musicUrl:String;
      
      public var music:SoundLibrary;
      
      public var voUrl:String;
      
      public var vo:SoundLibrary;
      
      public var roster:Vector.<String>;
      
      public var party:Vector.<String>;
      
      public var classes:EntityClassDefList;
      
      public var unitStatCosts:UnitStatCosts;
      
      public var unitStatCostsUrl:String;
      
      public var convoAudioUrl:String;
      
      public var itemDefsUrl:String;
      
      public var titleDefsUrl:String;
      
      public var cartDefsUrl:String;
      
      public var scenarioDefsUrl:String;
      
      public var talentDefsUrl:String;
      
      public var itemDefs:ItemListDef;
      
      public var cartDefs:CartListDef;
      
      public var convoAudio:ConvoAudioListDef;
      
      public var _startUrl:String;
      
      public var _startCaravan:String;
      
      public var dlcs:SagaDlcs;
      
      public var dlcsUrl:String;
      
      public var achievementsUrl:String;
      
      public var locale:Locale;
      
      public var happenings:HappeningDefBag;
      
      public var fmodProjectInfos:Array;
      
      public var fmodPreloadUrl:String;
      
      public var audioVoDuckingMultiplier:Number;
      
      public var audioVoDuckingSpeed:Number;
      
      public var audioPopDuckingMultiplier:Number;
      
      public var abilityParamsUrl:String;
      
      public var achievements:AchievementListDef;
      
      public var master_store_achievements:Boolean;
      
      public var mapSceneUrl:String;
      
      public var mapScene:SceneDef;
      
      public var campMusic:SagaCampMusicDef;
      
      public var difficulties:Vector.<SagaDifficultyDef>;
      
      public var caravanAnimBaseUrl:String;
      
      public var caravanClosePoleUrl:String;
      
      public var scenarioDefs:BattleScenarioDefList;
      
      public var importDef:SagaImportDef;
      
      public var minPlayerUnitRank:int;
      
      public var talentDefs:TalentDefs;
      
      public var campUrls:Array;
      
      internal var creditses:Vector.<SagaCreditsDef>;
      
      public var shitlistDefs:ShitlistDefs;
      
      public var warPoppeningContinueUrl:String;
      
      public var warPoppeningUrl:String;
      
      public var warPoppeningImpl:String;
      
      public var banners:Vector.<SagaBannerDef>;
      
      public var battleMusicUrl:String;
      
      public var scenePreprocessorDef:SagaScenePreprocessorDef;
      
      private var _titleDefs:ITitleListDef;
      
      private var _consumedTitles:Vector.<String>;
      
      public var recap:SagaRecapDef;
      
      public function SagaDef(param1:Locale, param2:ILogger)
      {
         this.caravans = new Vector.<CaravanDef>();
         this.caravansByName = new Dictionary();
         this.variables = new Vector.<VariableDef>();
         this.variablesByName = new Dictionary();
         this.roster = new Vector.<String>();
         this.party = new Vector.<String>();
         this.fmodProjectInfos = [];
         this.difficulties = new Vector.<SagaDifficultyDef>();
         this.creditses = new Vector.<SagaCreditsDef>();
         this.banners = new Vector.<SagaBannerDef>();
         this._consumedTitles = new Vector.<String>();
         super();
         this.happenings = new HappeningDefBag(this.id,this);
         this.locale = param1;
         this._cast = new EntityListDef(param1,this.classes,param2);
         this.buckets = new SagaBuckets(this);
      }
      
      public function get titleDefs() : ITitleListDef
      {
         return this._titleDefs;
      }
      
      public function set titleDefs(param1:ITitleListDef) : void
      {
         this._titleDefs = param1;
      }
      
      public function get consumedTitles() : Vector.<String>
      {
         return this._consumedTitles;
      }
      
      public function getVariableDefByName(param1:String) : VariableDef
      {
         return this.variablesByName[param1];
      }
      
      public function getShitlistDefById(param1:String) : ShitlistDef
      {
         return !!this.shitlistDefs ? this.shitlistDefs.getShitlistDefById(param1) : null;
      }
      
      public function getVariables() : Vector.<VariableDef>
      {
         return this.variables;
      }
      
      public function cleanup() : void
      {
         if(this.mapScene)
         {
            this.mapScene.cleanup();
            this.mapScene = null;
         }
         this.happenings = null;
         this._cast = null;
         this.buckets = null;
         this.locale = null;
         this.difficulties = null;
         this.achievements = null;
         this.convoAudio = null;
         this.roster = null;
         this.party = null;
         this.classes = null;
         this.itemDefs = null;
         this.music = null;
         this.vo = null;
         this.unitStatCosts = null;
         this.dlcs = null;
         this.variables = null;
         this.variablesByName = null;
         this.caravans = null;
         this.caravansByName = null;
         this.banners = null;
      }
      
      public function changeLocale(param1:Locale) : void
      {
         this.locale = param1;
         this._cast.changeLocale(param1);
         if(this.achievements)
         {
            this.achievements.localizeAchievementDefs(param1);
         }
      }
      
      public function getCaravanDef(param1:String) : CaravanDef
      {
         return this.caravansByName[param1] as CaravanDef;
      }
      
      public function removeCaravan(param1:CaravanDef) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            delete this.caravansByName[param1.name];
            _loc2_ = this.caravans.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.caravans.splice(_loc2_,1);
            }
         }
      }
      
      public function addCaravan(param1:CaravanDef) : void
      {
         if(param1)
         {
            this.caravans.push(param1);
            this.caravansByName[param1.name] = param1;
         }
      }
      
      public function renameCaravan(param1:CaravanDef, param2:String) : void
      {
         var _loc3_:String = null;
         if(param1)
         {
            _loc3_ = param1.name;
            delete this.caravansByName[param1.name];
            param1.name = param2;
            this.caravansByName[param1.name] = param1;
            this.happenings.handleRenameCaravan(_loc3_,param1.name);
         }
      }
      
      public function createNewCaravan() : CaravanDef
      {
         var _loc2_:String = null;
         var _loc3_:CaravanDef = null;
         var _loc1_:int = this.caravans.length;
         while(_loc1_ < 1000)
         {
            _loc2_ = "New Caravan " + _loc1_;
            if(!this.caravansByName[_loc2_])
            {
               _loc3_ = new CaravanDef(this);
               _loc3_.name = _loc2_;
               this.addCaravan(_loc3_);
               return _loc3_;
            }
            _loc1_++;
         }
         return null;
      }
      
      public function addVariable(param1:VariableDef) : void
      {
         this.variables.push(param1);
         this.variablesByName[param1.name] = param1;
      }
      
      public function renameVariable(param1:VariableDef, param2:String, param3:RenameVariableInfo) : void
      {
         param2 = param2.replace(/ /g,"_");
         if(this.variablesByName[param2])
         {
            return;
         }
         var _loc4_:String = param1.name;
         delete this.variablesByName[param1.name];
         param1.name = param2;
         this.variablesByName[param1.name] = param1;
         this.happenings.handleRenameVariable(_loc4_,param1.name,param3);
      }
      
      public function removeVariable(param1:VariableDef) : void
      {
         var _loc3_:VariableDef = null;
         var _loc2_:int = this.variables.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.variables.splice(_loc2_,1);
         }
         delete this.variablesByName[param1.name];
         for each(_loc3_ in this.variables)
         {
            _loc3_.handleRemoved(param1);
         }
      }
      
      public function createNewVariable(param1:String) : VariableDef
      {
         var _loc3_:int = 0;
         var _loc4_:VariableDef = null;
         if(!param1)
         {
            param1 = "New Variable ";
         }
         var _loc2_:String = param1;
         if(this.variablesByName[_loc2_])
         {
            _loc2_ = null;
            _loc3_ = this.variables.length;
            while(_loc3_ < 1000)
            {
               _loc2_ = param1 + " " + _loc3_;
               if(!this.variablesByName[_loc2_])
               {
                  break;
               }
               _loc2_ = null;
               _loc3_++;
            }
         }
         if(_loc2_)
         {
            _loc4_ = new VariableDef();
            _loc4_.name = _loc2_;
            this.addVariable(_loc4_);
            return _loc4_;
         }
         return null;
      }
      
      public function get cast() : IEntityListDef
      {
         return this._cast;
      }
      
      public function setCast(param1:IEntityListDef, param2:IBattleEntityProvider) : void
      {
         var _loc3_:int = 0;
         var _loc4_:IEntityDef = null;
         var _loc5_:IVariableBag = null;
         var _loc6_:VariableDef = null;
         if(this._cast == param1)
         {
            return;
         }
         this._cast = param1;
         if(this._cast)
         {
            _loc3_ = 0;
            while(_loc3_ < this._cast.numEntityDefs)
            {
               _loc4_ = this._cast.getEntityDef(_loc3_);
               if(!(!_loc4_.entityClass || !_loc4_.entityClass.playerClass))
               {
                  _loc5_ = _loc4_.vars;
                  if(_loc5_)
                  {
                     for each(_loc6_ in this.variables)
                     {
                        if(_loc6_.perUnit && !_loc5_.fetch(_loc6_.name,null))
                        {
                           _loc5_.add(VariableFactory.factory(param2,_loc6_,param1.logger));
                        }
                     }
                     _loc4_.synchronizeToVars();
                  }
               }
               _loc3_++;
            }
         }
      }
      
      public function getBannerLengthDef(param1:Boolean, param2:int, param3:int) : SagaBannerLengthDef
      {
         if(param2 < 0 || param2 >= this.banners.length)
         {
            return null;
         }
         return this.banners[param2].getBannerLength(param1,param3);
      }
      
      public function getBannerHudName(param1:int) : String
      {
         if(param1 < 0 || param1 >= this.banners.length)
         {
            return null;
         }
         return this.banners[param1].hud_name;
      }
      
      public function getBannerLengthUrl(param1:Boolean, param2:int, param3:int) : String
      {
         var _loc4_:SagaBannerLengthDef = this.getBannerLengthDef(param1,param2,param3);
         return !!_loc4_ ? _loc4_.url : null;
      }
      
      public function getDifficultyDef(param1:int) : SagaDifficultyDef
      {
         var _loc2_:int = param1 - 1;
         if(_loc2_ < 0 || _loc2_ >= this.difficulties.length)
         {
            return null;
         }
         return this.difficulties[_loc2_];
      }
      
      public function getCampUrlForBiome(param1:int) : String
      {
         if(Boolean(this.campUrls) && this.campUrls.length > param1)
         {
            return this.campUrls[param1];
         }
         switch(param1)
         {
            case 1:
               return this.id + "/scene/camp/cmp_snow/cmp_snow.json.z";
            case 2:
               return this.id + "/scene/camp/cmp_forest/cmp_forest.json.z";
            default:
               return this.id + "/scene/camp/cmp_snow/cmp_snow.json.z";
         }
      }
      
      public function findActionsForSceneUrl(param1:String, param2:Vector.<ActionDef>) : void
      {
         if(this.happenings)
         {
            this.happenings.findActionsForSceneUrl(param1,param2);
         }
      }
      
      public function findActionsForHappening(param1:HappeningDef, param2:Vector.<ActionDef>) : void
      {
         if(this.happenings)
         {
            this.happenings.findActionsForHappening(param1,param2);
         }
      }
      
      public function get linkString() : String
      {
         return this.id;
      }
      
      public function finishLoading() : void
      {
         if(this.itemDefs)
         {
            if(this.importDef)
            {
               if(STRIP_MARKET_ITEMS_BY_RANK)
               {
                  this.itemDefs.removeMarketItemsBelowRank(this.importDef.minRank);
               }
            }
         }
      }
      
      public function determineWho(param1:SagaSave) : String
      {
         if(param1.globalVars)
         {
            if(param1.globalVars["hero_alette"])
            {
               return "alette";
            }
            if(param1.globalVars["hero_rook"])
            {
               return "rook";
            }
            if(param1.globalVars["hero_oddleif"])
            {
               return "oddleif";
            }
         }
         return null;
      }
      
      public function consumeTitle(param1:ITitleDef) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._consumedTitles.length)
         {
            if(this._consumedTitles[_loc2_] == param1.id)
            {
               return;
            }
            _loc2_++;
         }
         this._consumedTitles.push(param1.id);
      }
      
      public function isTitleValid(param1:IEntityDef, param2:ITitleDef) : Boolean
      {
         if(param1 == null || param2 == null)
         {
            return false;
         }
         if(param2.minRank > param1.stats.rank)
         {
            return false;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.consumedTitles.length)
         {
            if(this.consumedTitles[_loc3_] == param2.id)
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function addCredits(param1:SagaCreditsDef) : void
      {
         this.creditses.push(param1);
      }
      
      public function getCreditsDef(param1:int) : SagaCreditsDef
      {
         return Boolean(this.creditses) && this.creditses.length > param1 ? this.creditses[param1] : null;
      }
   }
}
