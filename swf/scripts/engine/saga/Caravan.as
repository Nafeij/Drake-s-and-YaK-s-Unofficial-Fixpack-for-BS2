package engine.saga
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ILegend;
   import engine.entity.def.IPartyDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.saga.save.CaravanSave;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.Variable;
   import engine.saga.vars.VariableBag;
   import engine.saga.vars.VariableDef;
   import engine.saga.vars.VariableFactory;
   import engine.saga.vars.VariableType;
   
   public class Caravan implements ICaravan, IVariableDefProvider
   {
       
      
      public var _vars:VariableBag;
      
      public var def:CaravanDef;
      
      public var _saga:Saga;
      
      public var _legend:SagaLegend;
      
      public var map_spline_id:String;
      
      public var map_spline_key:String;
      
      public var map_spline_t:Number = 0;
      
      public var leader:String;
      
      public var logger:ILogger;
      
      public var travel_locator:TravelLocator;
      
      public function Caravan(param1:Saga, param2:CaravanDef, param3:BattleAbilityDefFactory)
      {
         var _loc4_:VariableDef = null;
         var _loc5_:Variable = null;
         super();
         this.logger = param1.logger;
         this._saga = param1;
         this.def = param2;
         this._legend = new SagaLegend(param1,param3);
         this._vars = new VariableBag(param2.name,this,param1,this.logger);
         this._vars.disable_metrics = param2.disable_metrics;
         this.leader = param2.leader;
         for each(_loc4_ in param1.def.variables)
         {
            if(_loc4_.perCaravan)
            {
               _loc5_ = VariableFactory.factory(param1,_loc4_,this.logger);
               this._vars.add(_loc5_);
            }
         }
         this.initVars();
         this.setupStartingRoster();
      }
      
      public function get legend() : ILegend
      {
         return this._legend;
      }
      
      public function set legend(param1:ILegend) : void
      {
         this._legend = param1 as SagaLegend;
      }
      
      public function get animBaseUrl() : String
      {
         if(Boolean(this.def) && Boolean(this.def.animBaseUrl))
         {
            return this.def.animBaseUrl;
         }
         return this.saga.caravanAnimBaseUrl;
      }
      
      public function get closePoleUrl() : String
      {
         if(Boolean(this.def) && Boolean(this.def.closePoleUrl))
         {
            return this.def.closePoleUrl;
         }
         return this.saga.caravanClosePoleUrl;
      }
      
      public function toString() : String
      {
         return this.def.name;
      }
      
      public function initVars() : void
      {
         this._vars.fetch(SagaVar.VAR_HERALDRY_ENABLED,VariableType.BOOLEAN).asBoolean = this.def.heraldryEnabled;
         this._vars.fetch(SagaVar.VAR_BANNER,VariableType.INTEGER).asInteger = this.def.banner;
         this._vars.fetch(SagaVar.VAR_CARAVAN_NAME,VariableType.INTEGER).asString = this.def.name;
      }
      
      public function setMapSpline(param1:String, param2:String, param3:Number) : void
      {
         param3 = int(param3 * 100) / 100;
         if(this.map_spline_id == param1 && this.map_spline_key == param2 && this.map_spline_t == param3)
         {
            return;
         }
         this.map_spline_id = param1;
         this.map_spline_key = param2;
         this.map_spline_t = param3;
         this._saga.notifyMapSplineChanged();
      }
      
      public function set mapSplineT(param1:Number) : void
      {
         if(this.map_spline_t == param1)
         {
            return;
         }
         this.map_spline_t = param1;
         this._saga.notifyMapSplineChanged();
      }
      
      public function get mapSplineT() : Number
      {
         return this.map_spline_t;
      }
      
      public function cleanup() : void
      {
         this._legend.cleanup();
         this._vars.cleanup();
         this._legend = null;
         this._vars = null;
         this.def = null;
      }
      
      public function loadFromSave(param1:CaravanSave) : void
      {
         if(param1.vars)
         {
            this._vars.fromDictionary(param1.vars,this._saga.logger);
         }
         this._legend.loadFromSave(param1.legend,true);
         this.leader = param1.leader;
         this.setMapSpline(param1.map_spline_id,param1.map_spline_key,param1.map_spline_t);
         if(param1.travel_locator)
         {
            this.travel_locator = param1.travel_locator.clone();
         }
      }
      
      public function setupStartingRoster() : void
      {
         var _loc1_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:IEntityDef = null;
         var _loc5_:IEntityDef = null;
         this._legend.roster.clear();
         for each(_loc1_ in this.def.roster)
         {
            _loc4_ = this._saga.def.cast.getEntityDefById(_loc1_);
            if(!_loc4_)
            {
               this._saga.logger.error("Caravan " + this.def + " roster no such cast member " + _loc1_);
            }
            else
            {
               this._legend.roster.addEntityDef(_loc4_);
            }
         }
         this._legend.party.clear();
         for each(_loc3_ in this.def.party)
         {
            this._legend.party.addMember(_loc3_);
            _loc5_ = this._legend.party.getMemberById(_loc3_);
            if(_loc5_)
            {
               _loc5_.isSurvivalRecruited = true;
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
            this._legend.roster.sortEntities();
         }
         this._legend.computeRosterRowCount();
      }
      
      public function ensureUnitInParty(param1:IEntityDef) : void
      {
         this._legend.ensureUnitInParty(param1);
      }
      
      public function get vars() : IVariableBag
      {
         return this._vars;
      }
      
      public function get saga() : ISaga
      {
         return this._saga;
      }
      
      public function get mapSplineIdShort() : String
      {
         if(this.map_spline_id)
         {
            return this.map_spline_id + "/" + this.map_spline_key;
         }
         return "unknown";
      }
      
      public function getVariableDefByName(param1:String) : VariableDef
      {
         return this._saga.def.getVariableDefByName(param1);
      }
      
      public function getVariables() : Vector.<VariableDef>
      {
         return this._saga.def.getVariables();
      }
      
      public function get roster() : IEntityListDef
      {
         return !!this._legend ? this._legend.roster : null;
      }
      
      public function get party() : IPartyDef
      {
         return !!this._legend ? this._legend.party : null;
      }
   }
}
