package engine.talent
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class TalentDefs
   {
      
      public static const schema:Object = {
         "name":"TalentDefs",
         "properties":{
            "defs":{
               "type":"array",
               "items":TalentDef.schema
            },
            "maxAvailableRanks":{"type":"number"},
            "sounds":{
               "type":"array",
               "items":{"properties":{
                  "stat":{"type":"string"},
                  "sound_ui":{"type":"string"},
                  "sound_combat":{"type":"string"}
               }}
            }
         }
      };
       
      
      public var defs:Vector.<TalentDef>;
      
      private var _defsById:Dictionary;
      
      private var _defsByParentStatType:Dictionary;
      
      private var _soundsUiByParentStatType:Dictionary;
      
      private var _soundsCombatByParentStatType:Dictionary;
      
      public var maxAvailableRanks:int;
      
      public function TalentDefs()
      {
         this.defs = new Vector.<TalentDef>();
         this._defsById = new Dictionary();
         this._defsByParentStatType = new Dictionary();
         this._soundsUiByParentStatType = new Dictionary();
         this._soundsCombatByParentStatType = new Dictionary();
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : TalentDefs
      {
         var _loc3_:Object = null;
         var _loc4_:TalentDef = null;
         var _loc5_:String = null;
         var _loc6_:StatType = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.defs)
         {
            _loc4_ = new TalentDef(this).fromJson(_loc3_,param2);
            this.addDef(_loc4_);
         }
         this.maxAvailableRanks = param1.maxAvailableRanks;
         for each(_loc3_ in param1.sounds)
         {
            _loc5_ = String(_loc3_.stat);
            _loc6_ = Enum.parse(StatType,_loc5_) as StatType;
            _loc7_ = String(_loc3_.sound_ui);
            _loc8_ = String(_loc3_.sound_combat);
            this._soundsUiByParentStatType[_loc6_] = _loc7_;
            this._soundsCombatByParentStatType[_loc6_] = _loc8_;
         }
         return this;
      }
      
      public function getSoundUiByParentStatType(param1:StatType) : String
      {
         return this._soundsUiByParentStatType[param1];
      }
      
      public function getSoundCombatByParentStatType(param1:StatType) : String
      {
         return this._soundsCombatByParentStatType[param1];
      }
      
      private function addDef(param1:TalentDef) : void
      {
         this.defs.push(param1);
         if(this._defsById[param1.id])
         {
            throw new ArgumentError("Talent [" + param1.id + "] already exists");
         }
         this._defsById[param1.id] = param1;
         var _loc2_:Vector.<TalentDef> = this.getDefsByParentStatType(param1.parentStatType);
         _loc2_.push(param1);
      }
      
      public function getDefById(param1:String) : TalentDef
      {
         return this._defsById[param1];
      }
      
      public function getDefsByParentStatType(param1:StatType) : Vector.<TalentDef>
      {
         var _loc2_:Vector.<TalentDef> = null;
         _loc2_ = this._defsByParentStatType[param1];
         if(!_loc2_)
         {
            _loc2_ = new Vector.<TalentDef>();
            this._defsByParentStatType[param1] = _loc2_;
         }
         return _loc2_;
      }
   }
}
