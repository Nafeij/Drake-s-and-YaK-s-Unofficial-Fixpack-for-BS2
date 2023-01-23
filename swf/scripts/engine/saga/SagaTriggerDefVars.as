package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.def.EngineJsonDef;
   import engine.saga.happening.HappeningDef;
   
   public class SagaTriggerDefVars extends SagaTriggerDef
   {
      
      public static const schema:Object = {
         "name":"SagaTriggerDefVars",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "click":{
               "type":"string",
               "optional":true
            },
            "unit":{
               "type":"string",
               "optional":true
            },
            "location":{
               "type":"string",
               "optional":true
            },
            "varname":{
               "type":"string",
               "optional":true
            },
            "happening":{
               "type":"string",
               "optional":true
            },
            "varvalue":{
               "type":"number",
               "optional":true
            },
            "player_only":{
               "type":"boolean",
               "optional":true
            },
            "enemy_only":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function SagaTriggerDefVars(param1:HappeningDef, param2:SagaTriggerDefBag)
      {
         super(param1,param2);
      }
      
      public static function save(param1:SagaTriggerDef) : Object
      {
         var _loc2_:Object = {"type":param1.type.name};
         switch(param1.type)
         {
            case SagaTriggerType.TALK:
               _loc2_.unit = !!param1.unit ? param1.unit : "";
               break;
            case SagaTriggerType.BATTLE_TURN:
               _loc2_.unit = !!param1.unit ? param1.unit : "";
               _loc2_.player_only = param1.player_only;
               break;
            case SagaTriggerType.BATTLE_NEXT_TURN_BEGIN:
            case SagaTriggerType.BATTLE_KILL_STOP:
            case SagaTriggerType.BATTLE_IMMORTAL_STOPPED:
            case SagaTriggerType.BATTLE_UNIT_REMOVED:
               _loc2_.unit = !!param1.unit ? param1.unit : "";
               _loc2_.player_only = param1.player_only;
               _loc2_.enemy_only = param1.enemy_only;
               break;
            case SagaTriggerType.CLICK:
               _loc2_.click = !!param1.click ? param1.click : "";
               break;
            case SagaTriggerType.LOCATION:
            case SagaTriggerType.DEPLOYED:
               _loc2_.location = !!param1.location ? StringUtil.trim(param1.location) : "";
               break;
            case SagaTriggerType.BATTLE_ABILITY_COMPLETED:
            case SagaTriggerType.BATTLE_ABILITY_EXECUTED:
               _loc2_.location = !!param1.location ? param1.location : "";
               _loc2_.unit = !!param1.unit ? param1.unit : "";
               _loc2_.player_only = param1.player_only;
               break;
            case SagaTriggerType.VARIABLE_INCREMENT:
            case SagaTriggerType.VARIABLE_THRESHOLD:
            case SagaTriggerType.VARIABLE_THRESHOLD_UP:
            case SagaTriggerType.VARIABLE_THRESHOLD_DOWN:
               _loc2_.varname = !!param1.varname ? param1.varname : "";
               _loc2_.varvalue = param1.varvalue;
               break;
            case SagaTriggerType.BATTLE_WAVE_SPAWNED:
            case SagaTriggerType.BATTLE_WAVE_LOW_TURN_WARNING:
            case SagaTriggerType.BATTLE_NO_ENEMIES_REMAIN_PRE_VICTORY:
            case SagaTriggerType.MAP_CAMP_ENTER:
            case SagaTriggerType.MAP_CAMP_EXIT:
            case SagaTriggerType.BATTLE_WIN:
            case SagaTriggerType.BATTLE_LOSE:
            case SagaTriggerType.BATTLE_FINISHING_WIN:
            case SagaTriggerType.BATTLE_FINISHING_LOSE:
               break;
            case SagaTriggerType.BATTLE_ALLY_KILLED:
            case SagaTriggerType.BATTLE_ENEMY_KILLED:
            case SagaTriggerType.BATTLE_OTHER_KILLED:
               _loc2_.unit = !!param1.unit ? param1.unit : "";
               break;
            case SagaTriggerType.BATTLE_REMAINING_ENEMIES:
            case SagaTriggerType.BATTLE_REMAINING_PLAYERS:
               _loc2_.varvalue = param1.varvalue;
               break;
            default:
               throw new ArgumentError("SagaTriggerDefVars.save() unsupported type: " + param1.type);
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaTriggerDefVars
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         SagaTriggerType.BATTLE_REMAINING_ENEMIES;
         type = Enum.parse(SagaTriggerType,param1.type) as SagaTriggerType;
         switch(type)
         {
            case SagaTriggerType.BATTLE_ALLY_KILLED:
            case SagaTriggerType.BATTLE_ENEMY_KILLED:
            case SagaTriggerType.BATTLE_OTHER_KILLED:
               unit = param1.unit;
               break;
            case SagaTriggerType.TALK:
               unit = param1.unit;
               break;
            case SagaTriggerType.BATTLE_TURN:
               unit = param1.unit;
               player_only = param1.player_only;
               break;
            case SagaTriggerType.BATTLE_NEXT_TURN_BEGIN:
            case SagaTriggerType.BATTLE_KILL_STOP:
            case SagaTriggerType.BATTLE_IMMORTAL_STOPPED:
            case SagaTriggerType.BATTLE_UNIT_REMOVED:
               unit = param1.unit;
               player_only = param1.player_only;
               enemy_only = param1.enemy_only;
               break;
            case SagaTriggerType.CLICK:
               click = param1.click;
               break;
            case SagaTriggerType.LOCATION:
            case SagaTriggerType.DEPLOYED:
               location = param1.location;
               break;
            case SagaTriggerType.BATTLE_ABILITY_EXECUTED:
            case SagaTriggerType.BATTLE_ABILITY_COMPLETED:
               location = param1.location;
               unit = param1.unit;
               player_only = param1.player_only;
               break;
            case SagaTriggerType.VARIABLE_INCREMENT:
            case SagaTriggerType.VARIABLE_THRESHOLD:
            case SagaTriggerType.VARIABLE_THRESHOLD_UP:
            case SagaTriggerType.VARIABLE_THRESHOLD_DOWN:
               varname = param1.varname;
               varvalue = param1.varvalue;
               break;
            case SagaTriggerType.BATTLE_REMAINING_ENEMIES:
            case SagaTriggerType.BATTLE_REMAINING_PLAYERS:
               varvalue = param1.varvalue;
               break;
            case SagaTriggerType.BATTLE_WAVE_SPAWNED:
            case SagaTriggerType.BATTLE_WAVE_LOW_TURN_WARNING:
            case SagaTriggerType.BATTLE_NO_ENEMIES_REMAIN_PRE_VICTORY:
            case SagaTriggerType.MAP_CAMP_ENTER:
            case SagaTriggerType.MAP_CAMP_EXIT:
            case SagaTriggerType.BATTLE_WIN:
            case SagaTriggerType.BATTLE_FINISHING_WIN:
            case SagaTriggerType.BATTLE_LOSE:
            case SagaTriggerType.BATTLE_FINISHING_LOSE:
               break;
            default:
               throw new ArgumentError("SagaTriggerDefVars.fromJson() unsupported type: " + type);
         }
         return this;
      }
   }
}
