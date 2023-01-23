package engine.saga
{
   import engine.saga.happening.HappeningDef;
   import flash.utils.Dictionary;
   
   public class SagaTriggerDef
   {
      
      private static var propsByType:Dictionary = null;
       
      
      public var type:SagaTriggerType;
      
      public var unit:String;
      
      public var click:String;
      
      public var location:String;
      
      public var varname:String;
      
      public var varvalue:Number = 0;
      
      public var player_only:Boolean;
      
      public var enemy_only:Boolean;
      
      public var bag:SagaTriggerDefBag;
      
      public var happening:HappeningDef;
      
      public function SagaTriggerDef(param1:HappeningDef, param2:SagaTriggerDefBag)
      {
         this.type = SagaTriggerType.NONE;
         super();
         this.bag = param2;
         this.happening = param1;
      }
      
      public static function getPropsByType(param1:SagaTriggerType) : Array
      {
         if(!propsByType)
         {
            propsByType = new Dictionary();
            propsByType[SagaTriggerType.CLICK] = ["click"];
            propsByType[SagaTriggerType.DEPLOYED] = [];
            propsByType[SagaTriggerType.LOCATION] = ["location"];
            propsByType[SagaTriggerType.VARIABLE_INCREMENT] = ["varname","varvalue"];
            propsByType[SagaTriggerType.VARIABLE_THRESHOLD] = ["varname","varvalue"];
            propsByType[SagaTriggerType.VARIABLE_THRESHOLD_UP] = ["varname","varvalue"];
            propsByType[SagaTriggerType.VARIABLE_THRESHOLD_DOWN] = ["varname","varvalue"];
            propsByType[SagaTriggerType.TALK] = ["unit"];
            propsByType[SagaTriggerType.MAP_CAMP_ENTER] = [];
            propsByType[SagaTriggerType.MAP_CAMP_EXIT] = [];
            propsByType[SagaTriggerType.TALK] = ["unit"];
            propsByType[SagaTriggerType.NONE] = [];
            propsByType[SagaTriggerType.BATTLE_ALLY_KILLED] = ["unit"];
            propsByType[SagaTriggerType.BATTLE_ENEMY_KILLED] = ["unit"];
            propsByType[SagaTriggerType.BATTLE_OTHER_KILLED] = ["unit"];
            propsByType[SagaTriggerType.BATTLE_ABILITY_COMPLETED] = ["unit","location","player_only","enemy_only"];
            propsByType[SagaTriggerType.BATTLE_ABILITY_EXECUTED] = ["unit","location","player_only","enemy_only"];
            propsByType[SagaTriggerType.BATTLE_TURN] = ["unit","player_only"];
            propsByType[SagaTriggerType.BATTLE_UNIT_REMOVED] = ["unit","player_only","enemy_only"];
            propsByType[SagaTriggerType.BATTLE_WIN] = [];
            propsByType[SagaTriggerType.BATTLE_LOSE] = [];
            propsByType[SagaTriggerType.BATTLE_NEXT_TURN_BEGIN] = ["unit","player_only","enemy_only"];
            propsByType[SagaTriggerType.BATTLE_REMAINING_ENEMIES] = ["varvalue"];
            propsByType[SagaTriggerType.BATTLE_REMAINING_PLAYERS] = ["varvalue"];
            propsByType[SagaTriggerType.BATTLE_KILL_STOP] = ["unit","player_only","enemy_only"];
            propsByType[SagaTriggerType.BATTLE_IMMORTAL_STOPPED] = ["unit","player_only","enemy_only"];
            propsByType[SagaTriggerType.BATTLE_WAVE_SPAWNED] = [];
            propsByType[SagaTriggerType.BATTLE_WAVE_LOW_TURN_WARNING] = [];
            propsByType[SagaTriggerType.BATTLE_NO_ENEMIES_REMAIN_PRE_VICTORY] = [];
         }
         return propsByType[param1];
      }
      
      public function clone() : SagaTriggerDef
      {
         var _loc1_:SagaTriggerDef = new SagaTriggerDef(this.happening,this.bag);
         _loc1_.type = this.type;
         _loc1_.unit = this.unit;
         _loc1_.click = this.click;
         _loc1_.location = this.location;
         _loc1_.varname = this.varname;
         _loc1_.varvalue = this.varvalue;
         _loc1_.player_only = this.player_only;
         _loc1_.enemy_only = this.enemy_only;
         return _loc1_;
      }
      
      public function toString() : String
      {
         var _loc3_:String = null;
         var _loc1_:Array = getPropsByType(this.type);
         var _loc2_:String = "";
         for each(_loc3_ in _loc1_)
         {
            _loc2_ += " " + this[_loc3_];
         }
         return this.type.name + _loc2_;
      }
   }
}
