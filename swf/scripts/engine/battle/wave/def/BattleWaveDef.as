package engine.battle.wave.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   import flash.events.EventDispatcher;
   
   public class BattleWaveDef extends EventDispatcher
   {
      
      public static const EVENT_GSPAWN:String = "BattleWavesDef.EVENT_GSPAWN";
      
      public static const EVENT_DEPLOYMENT:String = "BattleWavesDef.EVENT_DEPLOYMENT";
      
      public static const schema:Object = {
         "name":"BattleWaveDef",
         "type":"object",
         "properties":{
            "name":{
               "type":"string",
               "optional":true
            },
            "playerDeployment":{
               "type":"string",
               "optional":true
            },
            "buckets":{
               "type":"array",
               "items":BattleWaveBucketDef.schema
            },
            "turnsPerWave":{
               "type":"number",
               "optional":true
            },
            "lowTurnWarning":{
               "type":"number",
               "optional":true
            },
            "lowTurnColor":{
               "type":"string",
               "optional":true
            },
            "loseDangerAdjustment":{
               "type":"number",
               "optional":true
            },
            "forceFight":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public var name:String = "new_wave";
      
      public var playerDeployment:String;
      
      public var forceFight:Boolean;
      
      private var _lowTurnWarning:int;
      
      private var _lowTurnWarningOverridden:Boolean = false;
      
      private var _lowTurnColor:String;
      
      private var _lowTurnColorOverridden:Boolean = false;
      
      private var _turnsPerWave:int;
      
      private var _turnsPerWaveOverridden:Boolean = false;
      
      private var _loseDangerAdjustment:int;
      
      private var _loseDangerAdjustmentOverridden:Boolean = false;
      
      private var buckets:Vector.<BattleWaveBucketDef>;
      
      public function BattleWaveDef()
      {
         this.buckets = new Vector.<BattleWaveBucketDef>();
         super();
      }
      
      public static function vctor() : Vector.<BattleWaveDef>
      {
         return new Vector.<BattleWaveDef>();
      }
      
      public function get bucket() : BattleWaveBucketDef
      {
         if(this.buckets == null)
         {
            this.buckets = new Vector.<BattleWaveBucketDef>();
         }
         if(this.buckets.length <= 0)
         {
            this.buckets.push(new BattleWaveBucketDef());
         }
         return this.buckets[0];
      }
      
      public function clone(param1:BattleWaveDef) : BattleWaveDef
      {
         if(!param1)
         {
            return null;
         }
         this.buckets.length = 0;
         this.name = param1.name + "_copy";
         this.playerDeployment = param1.playerDeployment;
         this.forceFight = param1.forceFight;
         this._lowTurnWarning = param1._lowTurnWarning;
         this._lowTurnWarningOverridden = param1._lowTurnColorOverridden;
         this._lowTurnColor = param1._lowTurnColor;
         this._lowTurnColorOverridden = param1._lowTurnColorOverridden;
         this._turnsPerWave = param1._turnsPerWave;
         this._turnsPerWaveOverridden = param1._turnsPerWaveOverridden;
         this._loseDangerAdjustment = param1._loseDangerAdjustment;
         this._loseDangerAdjustmentOverridden = param1._loseDangerAdjustmentOverridden;
         var _loc2_:int = 0;
         while(_loc2_ < param1.buckets.length)
         {
            this.buckets.push(new BattleWaveBucketDef().clone(param1.buckets[_loc2_]));
            _loc2_++;
         }
         return this;
      }
      
      override public function toString() : String
      {
         return this.name;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleWaveDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(param1.lowTurnWarning)
         {
            this.lowTurnWarning = param1.lowTurnWarning;
            this._lowTurnWarningOverridden = true;
         }
         if(param1.lowTurnColor)
         {
            this.lowTurnColor = param1.lowTurnColor;
            this._lowTurnColorOverridden = true;
         }
         if(param1.turnsPerWave)
         {
            this.turnsPerWave = param1.turnsPerWave;
            this._turnsPerWaveOverridden = true;
         }
         if(param1.loseDangerAdjustment)
         {
            this.loseDangerAdjustment = param1.loseDangerAdjustment;
            this._loseDangerAdjustmentOverridden = true;
         }
         this.name = param1.name;
         this.playerDeployment = param1.playerDeployment;
         this.forceFight = param1.forceFight;
         this.buckets = ArrayUtil.arrayToDefVector(param1.buckets,BattleWaveBucketDef,param2,this.buckets) as Vector.<BattleWaveBucketDef>;
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {"buckets":ArrayUtil.defVectorToArray(this.buckets,true)};
         if(this.turnsPerWaveOverridden)
         {
            _loc1_.turnsPerWave = this.turnsPerWave;
         }
         if(this.lowTurnWarningOverridden)
         {
            _loc1_.lowTurnWarning = this.lowTurnWarning;
         }
         if(this.lowTurnColorOverridden)
         {
            _loc1_.lowTurnColor = this.lowTurnColor;
         }
         if(this.loseDangerAdjustmentOverridden)
         {
            _loc1_.loseDangerAdjustment = this.loseDangerAdjustment;
         }
         if(this.forceFight)
         {
            _loc1_.forceFight = this.forceFight;
         }
         if(this.playerDeployment)
         {
            _loc1_.playerDeployment = this.playerDeployment;
         }
         if(this.name)
         {
            _loc1_.name = this.name;
         }
         return _loc1_;
      }
      
      public function get turnsPerWave() : int
      {
         return this._turnsPerWave;
      }
      
      public function set turnsPerWave(param1:int) : void
      {
         this._turnsPerWave = param1;
         this._turnsPerWaveOverridden = true;
      }
      
      public function get turnsPerWaveOverridden() : Boolean
      {
         return this._turnsPerWaveOverridden;
      }
      
      public function resetTurnsPerWave() : void
      {
         this._turnsPerWave = -1;
         this._turnsPerWaveOverridden = false;
      }
      
      public function get lowTurnWarning() : int
      {
         return this._lowTurnWarning;
      }
      
      public function set lowTurnWarning(param1:int) : void
      {
         this._lowTurnWarning = param1;
         this._lowTurnWarningOverridden = true;
      }
      
      public function get lowTurnWarningOverridden() : Boolean
      {
         return this._lowTurnWarningOverridden;
      }
      
      public function resetLowTurnWarning() : void
      {
         this._lowTurnWarning = -1;
         this._lowTurnWarningOverridden = false;
      }
      
      public function get lowTurnColor() : String
      {
         return this._lowTurnColor;
      }
      
      public function set lowTurnColor(param1:String) : void
      {
         this._lowTurnColor = param1;
         this._lowTurnColorOverridden = true;
      }
      
      public function get lowTurnColorOverridden() : Boolean
      {
         return this._lowTurnColorOverridden;
      }
      
      public function resetLowTurnColor() : void
      {
         this._lowTurnColor = "";
         this._lowTurnColorOverridden = false;
      }
      
      public function get loseDangerAdjustment() : int
      {
         return this._loseDangerAdjustment;
      }
      
      public function set loseDangerAdjustment(param1:int) : void
      {
         this._loseDangerAdjustment = param1;
         this._loseDangerAdjustmentOverridden = true;
      }
      
      public function get loseDangerAdjustmentOverridden() : Boolean
      {
         return this._loseDangerAdjustmentOverridden;
      }
      
      public function resetloseDangerAdjustment() : void
      {
         this._loseDangerAdjustment = 0;
         this._loseDangerAdjustmentOverridden = false;
      }
   }
}
