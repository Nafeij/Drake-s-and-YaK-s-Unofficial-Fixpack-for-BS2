package engine.battle.ability.def
{
   import engine.ability.def.AbilityDef;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class BattleAbilityDefFactoryVars extends BattleAbilityDefFactory
   {
       
      
      private var index:DefResource;
      
      private var resman:ResourceManager;
      
      private var completeCallback:Function;
      
      public var ready:Boolean;
      
      private var localizer:Localizer;
      
      protected var shouldLink:Boolean = true;
      
      private var refs:Vector.<BattleAbilityDefFactoryVars>;
      
      private var waitingRefs:int = 0;
      
      private var url:String;
      
      private var embeddedFinished:Boolean;
      
      private var isRoot:Boolean;
      
      public var allowLoadRefs:Boolean = true;
      
      private var jsonRefs:Array;
      
      private var jsonParams:Object;
      
      public function BattleAbilityDefFactoryVars(param1:Boolean, param2:ResourceManager, param3:ILogger, param4:Localizer, param5:Function, param6:String = null, param7:Boolean = true)
      {
         this.refs = new Vector.<BattleAbilityDefFactoryVars>();
         super();
         this.isRoot = param1;
         this.resman = param2;
         this._logger = param3;
         this.completeCallback = param5;
         this.localizer = param4;
         if(!param6)
         {
            param6 = "common/ability/_ability_index.json.z";
         }
         this.url = param6;
         if(param7)
         {
            this.load();
         }
      }
      
      public static function parseParams(param1:Dictionary, param2:Array, param3:ILogger) : void
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         for each(_loc4_ in param2)
         {
            _loc5_ = _loc4_.split(" ");
            if(_loc5_.length != 2)
            {
               param3.error("Malformed param line: [" + _loc4_ + "]");
            }
            else
            {
               _loc6_ = String(_loc5_[0]);
               _loc7_ = int(_loc5_[1]);
               param1[_loc6_] = _loc7_;
            }
         }
      }
      
      public function load() : void
      {
         if(this.ready)
         {
            throw new IllegalOperationError("Already ready, already.  Don\'t load now.");
         }
         if(this.resman)
         {
            this.index = this.resman.getResource(this.url,DefResource) as DefResource;
            this.index.addResourceListener(this.indexCompleteHandler);
         }
      }
      
      private function refCompleteCallback(param1:BattleAbilityDefFactoryVars) : void
      {
         var _loc2_:BattleAbilityDef = null;
         var _loc3_:int = 0;
         errors += param1.errors;
         for each(_loc2_ in param1.abilityDefs)
         {
            register(_loc2_);
         }
         _loc3_ = this.refs.indexOf(param1);
         if(_loc3_ < 0)
         {
            throw new IllegalOperationError("Ref not found in parent: " + param1);
         }
         --this.waitingRefs;
         this.checkReady();
      }
      
      private function checkReady() : void
      {
         if(this.ready)
         {
            return;
         }
         if(this.waitingRefs == 0 && this.embeddedFinished)
         {
            if(this.shouldLink)
            {
               link();
            }
            this.ready = true;
            if(this.isRoot)
            {
               updateAbilityDefDescriptions();
            }
            this.completeCallback(this);
         }
      }
      
      private function loadRefs() : void
      {
         var _loc1_:BattleAbilityDefFactoryVars = null;
         for each(_loc1_ in this.refs)
         {
            _loc1_.load();
         }
      }
      
      public function save() : Object
      {
         var _loc2_:Array = null;
         var _loc3_:AbilityDef = null;
         var _loc4_:Object = null;
         var _loc1_:Object = {};
         if(Boolean(this.jsonRefs) && this.jsonRefs.length > 0)
         {
            _loc1_.refs = this.jsonRefs;
         }
         if(this.jsonParams)
         {
            _loc1_.params = this.jsonParams;
         }
         if(abilityDefList.length)
         {
            _loc2_ = [];
            _loc1_.abilities = _loc2_;
            for each(_loc3_ in abilityDefList)
            {
               _loc4_ = BattleAbilityDefVars.save(_loc3_ as BattleAbilityDef);
               _loc2_.push(_loc4_);
            }
         }
         return _loc1_;
      }
      
      protected function indexCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:BattleAbilityDefFactoryVars = null;
         var _loc4_:Object = null;
         if(this.ready)
         {
            throw new IllegalOperationError("Already ready, already");
         }
         if(param1.resource != this.index)
         {
            throw new ArgumentError("Bogus event resource " + param1.resource + ", expected " + this.index);
         }
         this.index.removeResourceListener(this.indexCompleteHandler);
         if(!this.index.jo)
         {
            logger.error("failed to get json for " + this.index);
         }
         else
         {
            this.jsonRefs = this.index.jo.refs;
            if(this.allowLoadRefs)
            {
               if(this.index.jo.refs != undefined)
               {
                  for each(_loc2_ in this.index.jo.refs)
                  {
                     _loc3_ = new BattleAbilityDefFactoryVars(false,this.resman,logger,this.localizer,this.refCompleteCallback,_loc2_,false);
                     this.refs.push(_loc3_);
                     _loc3_.shouldLink = false;
                     ++this.waitingRefs;
                  }
               }
            }
            this.jsonParams = this.index.jo.params;
            if(this.index.jo.params != undefined)
            {
               parseParams(params,this.index.jo.params,logger);
            }
            this.loadRefs();
            if(this.index.jo.abilities != undefined)
            {
               for each(_loc4_ in this.index.jo.abilities)
               {
                  this.registerVars(_loc4_,logger,this.localizer);
               }
            }
         }
         this.index.release();
         this.index = null;
         this.embeddedFinished = true;
         this.checkReady();
      }
      
      private function registerVars(param1:Object, param2:ILogger, param3:Localizer) : void
      {
         var vars:Object = param1;
         var logger:ILogger = param2;
         var localizer:Localizer = param3;
         try
         {
            register(new BattleAbilityDef(null,localizer).init(vars,logger));
         }
         catch(e:Error)
         {
            logger.error("Failed to register " + vars.id + " : " + e.getStackTrace());
            ++errors;
         }
      }
      
      public function changeLocale(param1:Localizer, param2:ILogger) : void
      {
         var _loc3_:BattleAbilityDefFactoryVars = null;
         var _loc4_:AbilityDef = null;
         var _loc5_:int = 0;
         var _loc6_:AbilityDef = null;
         this.localizer = param1;
         for each(_loc3_ in this.refs)
         {
            _loc3_.changeLocale(param1,param2);
         }
         for each(_loc4_ in abilityDefs)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.maxLevel)
            {
               _loc6_ = _loc4_.getAbilityDefForLevel(_loc5_ + 1) as AbilityDef;
               _loc6_.changeLocale(param1,param2);
               _loc5_++;
            }
         }
      }
   }
}
