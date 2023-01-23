package engine.saga.vars
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class VariableDefVars extends VariableDef
   {
      
      public static const schema:Object = {
         "name":"VariableDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "type":{
               "type":"string",
               "optional":true
            },
            "min":{
               "type":"number",
               "optional":true
            },
            "max":{
               "type":"number",
               "optional":true
            },
            "start":{
               "type":"number",
               "optional":true
            },
            "start_str":{
               "type":"string",
               "optional":true
            },
            "scripted":{
               "type":"boolean",
               "optional":true
            },
            "bind":{
               "type":VariableDefBindVars.schema,
               "optional":true
            },
            "per_caravan":{
               "type":"boolean",
               "optional":true
            },
            "per_unit":{
               "type":"boolean",
               "optional":true
            },
            "transient":{
               "type":"boolean",
               "optional":true
            },
            "metrics_var":{
               "type":"boolean",
               "optional":true
            },
            "metrics_dim":{
               "type":"boolean",
               "optional":true
            },
            "ga_custom_dimension":{
               "type":"number",
               "optional":true
            },
            "ga_custom_metric":{
               "type":"number",
               "optional":true
            },
            "ga_report_event_add":{
               "type":"boolean",
               "optional":true
            },
            "ga_report_event_cur":{
               "type":"boolean",
               "optional":true
            },
            "accumulate":{
               "type":"boolean",
               "optional":true
            },
            "achievement_stat":{
               "type":"string",
               "optional":true
            },
            "platforms":{
               "type":"string",
               "optional":true
            }
         }
      };
      
      private static var _sagaVarsStartOverrides:Dictionary = new Dictionary();
       
      
      public function VariableDefVars()
      {
         super();
      }
      
      public static function setSagaVarStartOverride(param1:String, param2:int) : void
      {
         _sagaVarsStartOverrides[param1] = param2;
      }
      
      public static function save(param1:VariableDef) : Object
      {
         var _loc2_:Object = {"name":param1.name};
         if(Boolean(param1.type) && param1.type != VariableDef.DEFAULT_TYPE)
         {
            _loc2_.type = param1.type.name;
         }
         if(param1.lowerBound != VariableDef.DEFAULT_LOWER_BOUND)
         {
            _loc2_.min = param1.lowerBound;
         }
         if(param1.upperBound != VariableDef.DEFAULT_UPPER_BOUND)
         {
            _loc2_.max = param1.upperBound;
         }
         if(param1.bind)
         {
            _loc2_.bind = VariableDefBindVars.save(param1.bind);
         }
         if(param1.scripted)
         {
            _loc2_.scripted = true;
         }
         if(param1.perCaravan != VariableDef.DEFAULT_PER_CARAVAN)
         {
            _loc2_.per_caravan = param1.perCaravan;
         }
         if(param1.perUnit != VariableDef.DEFAULT_PER_CARAVAN)
         {
            _loc2_.per_unit = param1.perUnit;
         }
         if(param1.transient != VariableDef.DEFAULT_PER_CARAVAN)
         {
            _loc2_.transient = param1.transient;
         }
         if(param1.metrics_var != VariableDef.DEFAULT_METRICS_VAR)
         {
            _loc2_.metrics_var = param1.metrics_var;
         }
         if(param1.metrics_dim != VariableDef.DEFAULT_METRICS_DIM)
         {
            _loc2_.metrics_dim = param1.metrics_dim;
         }
         if(param1.ga_custom_dimension)
         {
            _loc2_.ga_custom_dimension = param1.ga_custom_dimension;
         }
         if(param1.ga_custom_metric)
         {
            _loc2_.ga_custom_metric = param1.ga_custom_metric;
         }
         if(param1.ga_report_event_add)
         {
            _loc2_.ga_report_event_add = param1.ga_report_event_add;
         }
         if(param1.ga_report_event_cur)
         {
            _loc2_.ga_report_event_cur = param1.ga_report_event_cur;
         }
         if(param1.achievement_stat)
         {
            _loc2_.achievement_stat = param1.achievement_stat;
         }
         if(param1.accumulate)
         {
            _loc2_.accumulate = param1.accumulate;
         }
         if(param1.start != 0)
         {
            _loc2_.start = param1.start;
         }
         if(param1.start_str)
         {
            _loc2_.start_str = param1.start_str;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : void
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.name = param1.name;
         this.name = StringUtil.stripSurroundingSpace(this.name);
         this.name = this.name.replace(/ /g,"_");
         if(param1.type != undefined)
         {
            type = Enum.parse(VariableType,String(param1.type).toUpperCase()) as VariableType;
         }
         if(param1.min != undefined)
         {
            lowerBound = param1.min;
         }
         if(param1.max != undefined)
         {
            upperBound = param1.max;
         }
         if(param1.start != undefined)
         {
            start = param1.start;
         }
         if(param1.start_str)
         {
            start_str = param1.start_str;
         }
         var _loc3_:* = _sagaVarsStartOverrides[this.name];
         if(_loc3_ != undefined)
         {
            start = _loc3_;
         }
         if(param1.bind != undefined)
         {
            bind = new VariableDefBindVars(this);
            (bind as VariableDefBindVars).fromJson(param1.bind,param2);
         }
         this.scripted = param1.scripted;
         perCaravan = BooleanVars.parse(param1.per_caravan,perCaravan);
         perUnit = BooleanVars.parse(param1.per_unit,perUnit);
         transient = BooleanVars.parse(param1.transient,transient);
         accumulate = BooleanVars.parse(param1.accumulate,accumulate);
         metrics_var = BooleanVars.parse(param1.metrics_var,metrics_var);
         metrics_dim = BooleanVars.parse(param1.metrics_dim,metrics_dim);
         ga_report_event_add = BooleanVars.parse(param1.ga_report_event_add,ga_report_event_add);
         ga_report_event_cur = BooleanVars.parse(param1.ga_report_event_cur,ga_report_event_cur);
         achievement_stat = param1.achievement_stat;
         if(param1.ga_custom_dimension != undefined)
         {
            ga_custom_dimension = param1.ga_custom_dimension;
         }
         if(param1.ga_custom_metric != undefined)
         {
            ga_custom_metric = param1.ga_custom_metric;
         }
         platforms = param1.platforms;
         this._cachePlatforms();
      }
      
      private function _cachePlatforms() : void
      {
         var _loc2_:String = null;
         if(!platforms)
         {
            return;
         }
         platformsDict = new Dictionary();
         var _loc1_:Array = platforms.split(",");
         for each(_loc2_ in _loc1_)
         {
            platformsDict[_loc2_] = true;
         }
      }
   }
}
