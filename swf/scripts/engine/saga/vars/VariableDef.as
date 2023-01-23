package engine.saga.vars
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import flash.utils.Dictionary;
   
   public class VariableDef
   {
      
      public static const DEFAULT_LOWER_BOUND:int = 0;
      
      public static const DEFAULT_UPPER_BOUND:int = 100;
      
      public static const DEFAULT_PER_CARAVAN:Boolean = false;
      
      public static const DEFAULT_TRANSIENT:Boolean = false;
      
      public static const DEFAULT_PER_UNIT:Boolean = false;
      
      public static const DEFAULT_TYPE:VariableType = VariableType.BOOLEAN;
      
      public static const DEFAULT_METRICS_VAR:Boolean = false;
      
      public static const DEFAULT_METRICS_DIM:Boolean = false;
       
      
      public var name:String = "";
      
      public var type:VariableType;
      
      public var lowerBound:Number = 0;
      
      public var upperBound:Number = 100;
      
      public var start:Number = 0;
      
      public var start_str:String;
      
      public var bind:VariableDefBind;
      
      public var scripted:Boolean;
      
      public var perCaravan:Boolean = false;
      
      public var perUnit:Boolean = false;
      
      public var transient:Boolean = false;
      
      public var metrics_var:Boolean = false;
      
      public var metrics_dim:Boolean = false;
      
      public var ga_custom_dimension:int = 0;
      
      public var ga_custom_metric:int = 0;
      
      public var ga_report_event_add:Boolean = false;
      
      public var ga_report_event_cur:Boolean = false;
      
      public var accumulate:Boolean = false;
      
      public var achievement_stat:String;
      
      public var platforms:String;
      
      public var platformsDict:Dictionary;
      
      public function VariableDef()
      {
         this.type = DEFAULT_TYPE;
         super();
      }
      
      public function toString() : String
      {
         return this.type + " " + this.name;
      }
      
      public function setup(param1:String, param2:VariableType) : void
      {
         this.name = param1;
         this.name = StringUtil.stripSurroundingSpace(this.name);
         this.name = this.name.replace(/ /g,"_");
         this.type = param2;
      }
      
      public function copyFrom(param1:VariableDef) : VariableDef
      {
         this.type = param1.type;
         this.lowerBound = param1.lowerBound;
         this.upperBound = param1.upperBound;
         this.perCaravan = param1.perCaravan;
         this.perUnit = param1.perUnit;
         this.start = param1.start;
         this.start_str = param1.start_str;
         this.transient = param1.transient;
         this.metrics_var = param1.metrics_var;
         this.metrics_dim = param1.metrics_dim;
         this.ga_custom_dimension = param1.ga_custom_dimension;
         this.ga_custom_metric = param1.ga_custom_metric;
         this.ga_report_event_add = param1.ga_report_event_add;
         this.ga_report_event_cur = param1.ga_report_event_cur;
         this.accumulate = param1.accumulate;
         this.achievement_stat = param1.achievement_stat;
         if(param1.bind)
         {
            this.bind = param1.bind.clone();
         }
         this.scripted = false;
         return this;
      }
      
      public function clamp(param1:Number, param2:ILogger) : Number
      {
         var _loc3_:Error = null;
         if(isNaN(param1))
         {
            _loc3_ = new Error();
            param2.error("Attempt to clamp-a-nan for " + this + "\n" + _loc3_.getStackTrace());
            param1 = 0;
         }
         if(this.type == VariableType.BOOLEAN)
         {
            param1 = int(Math.max(0,Math.min(1,param1)));
         }
         else if(this.type == VariableType.INTEGER)
         {
            param1 = Math.max(this.lowerBound,Math.min(this.upperBound,param1));
            param1 = Math.round(param1);
         }
         else if(this.type == VariableType.DECIMAL)
         {
            param1 = Math.max(this.lowerBound,Math.min(this.upperBound,param1));
         }
         return param1;
      }
      
      public function renameVariable(param1:String, param2:String) : void
      {
         if(this.scripted)
         {
            return;
         }
         if(this.bind)
         {
            if(this.bind.src == param1)
            {
               this.bind.src = param2;
            }
         }
      }
      
      public function handleRemoved(param1:VariableDef) : void
      {
         if(Boolean(this.bind) && this.bind.src == param1.name)
         {
            this.bind = null;
         }
      }
   }
}
