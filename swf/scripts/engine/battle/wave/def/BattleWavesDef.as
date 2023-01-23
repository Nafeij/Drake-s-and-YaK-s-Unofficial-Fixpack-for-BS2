package engine.battle.wave.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   
   public class BattleWavesDef
   {
      
      public static const schema:Object = {
         "name":"BattleWavesDef",
         "type":"object",
         "properties":{
            "turnsPerWave":{"type":"number"},
            "lowTurnWarning":{"type":"number"},
            "lowTurnColor":{"type":"string"},
            "loseDangerAdjustment":{
               "type":"number",
               "optional":true
            },
            "turnsToPreserveBodies":{
               "type":"number",
               "optional":true
            },
            "waves":{
               "type":"array",
               "items":BattleWaveDef.schema
            }
         }
      };
       
      
      public var waves:Vector.<BattleWaveDef>;
      
      public var lowTurnWarning:int;
      
      public var lowTurnColor:String;
      
      public var loseDangerAdjustment:int;
      
      public var turnsPerWave:int;
      
      public var turnsToPreserveBodies:int;
      
      public function BattleWavesDef()
      {
         this.waves = new Vector.<BattleWaveDef>();
         super();
         ArrayUtil.insertAt(this.waves,0,new BattleWaveDef());
      }
      
      public function get numWaves() : int
      {
         return this.waves.length;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleWavesDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.lowTurnWarning = param1.lowTurnWarning;
         this.lowTurnColor = param1.lowTurnColor;
         this.turnsPerWave = param1.turnsPerWave;
         if(param1.turnsToPreserveBodies)
         {
            this.turnsToPreserveBodies = param1.turnsToPreserveBodies;
         }
         else
         {
            this.turnsToPreserveBodies = 0;
         }
         if(param1.loseDangerAdjustment)
         {
            this.loseDangerAdjustment = param1.loseDangerAdjustment;
         }
         this.waves = ArrayUtil.arrayToDefVector(param1.waves,BattleWaveDef,param2,this.waves) as Vector.<BattleWaveDef>;
         return this;
      }
      
      public function toJson() : Object
      {
         ArrayUtil.removeAt(this.waves,0);
         var _loc1_:Object = {
            "turnsPerWave":this.turnsPerWave,
            "lowTurnWarning":this.lowTurnWarning,
            "lowTurnColor":(!!this.lowTurnColor ? this.lowTurnColor : ""),
            "turnsToPreserveBodies":(!!this.turnsToPreserveBodies ? this.turnsToPreserveBodies : 0),
            "waves":ArrayUtil.defVectorToArray(this.waves,true)
         };
         if(this.loseDangerAdjustment)
         {
            _loc1_.loseDangerAdjustment = this.loseDangerAdjustment;
         }
         ArrayUtil.insertAt(this.waves,0,new BattleWaveDef());
         return _loc1_;
      }
   }
}
