package engine.saga.vars
{
   import com.stoicstudio.platform.Platform;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.saga.ICaravan;
   import engine.saga.SagaVar;
   import flash.utils.Dictionary;
   
   public class ScriptedVariable extends Variable
   {
      
      private static var _setters:Dictionary;
      
      private static var _getters:Dictionary;
       
      
      private var bbp:IBattleEntityProvider;
      
      public function ScriptedVariable(param1:IBattleEntityProvider, param2:VariableDef, param3:ILogger)
      {
         _isScripted = true;
         this.bbp = param1;
         if(!_setters)
         {
            cacheFuncs();
         }
         super(param2,param3);
      }
      
      private static function cacheFuncs() : void
      {
         if(_setters)
         {
            return;
         }
         _setters = new Dictionary();
         _getters = new Dictionary();
         _getters[SagaVar.VAR_UNIT_BATTLE] = _func_get_battle;
         _getters[SagaVar.VAR_UNIT_ROSTER] = _func_get_roster;
         _getters[SagaVar.VAR_UNIT_PARTY] = _func_get_party;
         _getters[SagaVar.VAR_UNIT_INCORPOREAL] = _func_get_incorporeal;
         _getters[SagaVar.PLATFORM_ID] = _func_get_platform_id;
         _getters["cur_units_10"] = _func_get_units;
         _getters["cur_units_09"] = _func_get_units;
         _getters["cur_units_08"] = _func_get_units;
         _getters["cur_units_07"] = _func_get_units;
         _getters["cur_units_06"] = _func_get_units;
         _getters["cur_units_05"] = _func_get_units;
         _getters["cur_units_04"] = _func_get_units;
         _getters["cur_units_03"] = _func_get_units;
         _getters[SagaVar.VAR_ROSTER_COUNT] = _func_get_roster_count;
      }
      
      private static function _func_get_battle(param1:ScriptedVariable) : Boolean
      {
         var _loc2_:IEntityDef = param1.getOwnerEntityDef();
         if(!param1.bbp || !_loc2_)
         {
            return false;
         }
         return param1.bbp.getEntityByDefId(_loc2_.id,null,true) != null;
      }
      
      private static function _func_get_roster(param1:ScriptedVariable) : Boolean
      {
         var _loc2_:IEntityDef = param1.getOwnerEntityDef();
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:ICaravan = param1.getOwnerCaravan();
         var _loc4_:IEntityListDef = !!_loc3_ ? _loc3_.roster : null;
         if(_loc4_)
         {
            return _loc4_.getEntityDefById(_loc2_.id) != null;
         }
         return false;
      }
      
      private static function _func_get_roster_count(param1:ScriptedVariable) : int
      {
         var _loc2_:ICaravan = param1.getOwnerCaravan();
         if(!_loc2_)
         {
            return 0;
         }
         var _loc3_:IEntityListDef = !!_loc2_ ? _loc2_.roster : null;
         if(_loc3_)
         {
            return _loc3_.numCombatants;
         }
         return 0;
      }
      
      private static function _func_get_party(param1:ScriptedVariable) : Boolean
      {
         var _loc2_:IEntityDef = param1.getOwnerEntityDef();
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:ICaravan = param1.getOwnerCaravan();
         var _loc4_:IPartyDef = !!_loc3_ ? _loc3_.party : null;
         if(_loc4_)
         {
            return _loc4_.hasMemberId(_loc2_.id);
         }
         return false;
      }
      
      private static function _func_get_incorporeal(param1:ScriptedVariable) : Boolean
      {
         var _loc2_:IEntityDef = param1.getOwnerEntityDef();
         if(!param1.bbp || !_loc2_)
         {
            return false;
         }
         var _loc3_:IBattleEntity = param1.bbp.getEntityByDefId(_loc2_.id,null,true);
         return Boolean(_loc3_) && _loc3_.incorporeal;
      }
      
      private static function _func_get_units(param1:ScriptedVariable) : int
      {
         var _loc2_:int = 0;
         var _loc6_:String = null;
         var _loc3_:int = param1.def.name.lastIndexOf("_");
         if(_loc3_ > 0)
         {
            _loc6_ = param1.def.name.substr(_loc3_ + 1);
            if(_loc6_)
            {
               if(_loc6_.charAt(0) == "0")
               {
                  _loc6_ = _loc6_.substr(1);
               }
               _loc2_ = int(_loc6_);
            }
         }
         var _loc4_:ICaravan = param1.getOwnerCaravan();
         if(!_loc4_)
         {
            return 0;
         }
         var _loc5_:IEntityListDef = !!_loc4_ ? _loc4_.roster : null;
         if(_loc5_)
         {
            return _loc5_.countCombatantAtRank(_loc2_ + 1);
         }
         return 0;
      }
      
      private static function _func_get_platform_id(param1:ScriptedVariable) : String
      {
         return Platform.id;
      }
      
      override protected function handleAccessGet() : void
      {
         var _loc2_:* = undefined;
         var _loc1_:Function = _getters[this.def.name];
         if(_loc1_ != null)
         {
            _loc2_ = _loc1_(this);
            _value = convertToString(_loc2_);
         }
      }
      
      override protected function handleAccessSet() : void
      {
         var _loc1_:Function = _setters[this.def.name];
         if(_loc1_ != null)
         {
            _loc1_(this);
         }
      }
   }
}
