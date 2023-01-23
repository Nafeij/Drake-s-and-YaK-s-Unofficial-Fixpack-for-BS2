package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemList;
   import engine.saga.Caravan;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   
   public class Action_CaravanMerge extends Action
   {
       
      
      public function Action_CaravanMerge(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc7_:IEntityListDef = null;
         var _loc8_:IEntityListDef = null;
         var _loc9_:int = 0;
         var _loc10_:IEntityDef = null;
         var _loc11_:ItemList = null;
         var _loc12_:ItemList = null;
         var _loc13_:Item = null;
         var _loc14_:IPartyDef = null;
         var _loc15_:IPartyDef = null;
         var _loc16_:int = 0;
         var _loc1_:Caravan = saga.getCaravan(def.id) as Caravan;
         var _loc2_:Caravan = saga.getCaravan(def.speaker) as Caravan;
         var _loc3_:Boolean = !def.param || def.param.indexOf("renown") >= 0;
         var _loc4_:Boolean = !def.param || def.param.indexOf("items") >= 0;
         var _loc5_:Boolean = !def.param || def.param.indexOf("roster") >= 0;
         var _loc6_:Boolean = !def.param || def.param.indexOf("party") >= 0;
         if(!_loc1_)
         {
            logger.error("No such caravan id=[" + def.id + "]");
         }
         else if(!_loc2_)
         {
            logger.error("No such caravan speaker=[" + def.speaker + "]");
         }
         else
         {
            if(_loc3_)
            {
               this.transferVarInt(_loc1_,_loc2_,SagaVar.VAR_RENOWN);
            }
            _loc7_ = _loc1_._legend.roster;
            _loc8_ = _loc2_._legend.roster;
            if(_loc5_)
            {
               _loc9_ = 0;
               while(_loc9_ < _loc7_.numEntityDefs)
               {
                  _loc10_ = _loc7_.getEntityDef(_loc9_);
                  if(!_loc8_.getEntityDefById(_loc10_.id))
                  {
                     _loc8_.addEntityDef(_loc10_);
                  }
                  _loc9_++;
               }
            }
            if(_loc4_)
            {
               _loc11_ = _loc1_._legend._items;
               _loc12_ = _loc2_._legend._items;
               for each(_loc13_ in _loc11_.items)
               {
                  _loc12_.addItem(_loc13_);
               }
               _loc11_.clearItems();
            }
            if(_loc6_)
            {
               _loc14_ = _loc1_._legend.party;
               _loc15_ = _loc2_._legend.party;
               _loc16_ = 0;
               while(_loc16_ < _loc14_.numMembers && _loc15_.numMembers < 6)
               {
                  _loc10_ = _loc14_.getMember(_loc16_);
                  _loc15_.addMember(_loc10_.id);
                  _loc16_++;
               }
            }
         }
         end();
      }
      
      private function transferVarInt(param1:Caravan, param2:Caravan, param3:String) : void
      {
         var _loc4_:IVariable = param1.vars.fetch(param3,VariableType.INTEGER);
         var _loc5_:IVariable = param2.vars.fetch(param3,VariableType.INTEGER);
         if(Boolean(_loc4_) && Boolean(_loc5_))
         {
            saga.suppressVariableFlytext = true;
            _loc5_.asInteger += _loc4_.asInteger;
            _loc4_.asInteger = 0;
            saga.suppressVariableFlytext = false;
         }
      }
   }
}
