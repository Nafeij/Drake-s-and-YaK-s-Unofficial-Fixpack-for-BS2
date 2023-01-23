package engine.battle.wave.def
{
   import engine.battle.board.model.BattleBoard_SpawnConstants;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   
   public class BattleWaveBucketDef
   {
      
      public static const EVENT_BUCKETS:String = "BattleWaveBucketDef.EVENT_BUCKETS";
      
      public static const schema:Object = {
         "name":"BattleWaveBucketDef",
         "type":"object",
         "properties":{
            "bucketId":{"type":"string"},
            "lossBucketOverride":{
               "type":"string",
               "optional":true
            },
            "suppressBucketOnLoss":{
               "type":"boolean",
               "optional":true
            },
            "deploymentId":{"type":"string"},
            "dangerMod":{
               "type":"number",
               "optional":true
            },
            "dangerMin":{
               "type":"number",
               "optional":true
            },
            "dangerMax":{
               "type":"number",
               "optional":true
            },
            "guaranteedSpawns":{
               "type":"array",
               "items":GuaranteedSpawnDef.schema,
               "optional":true
            }
         }
      };
       
      
      public var bucketId:String;
      
      public var lossBucketOverride:String;
      
      public var suppressBucketOnLoss:Boolean = false;
      
      public var guaranteedSpawns:Vector.<GuaranteedSpawnDef>;
      
      public var deploymentId:String;
      
      public var dangerMod:int;
      
      public var dangerMin:int;
      
      public var dangerMax:int = 20;
      
      public function BattleWaveBucketDef()
      {
         this.guaranteedSpawns = new Vector.<GuaranteedSpawnDef>();
         super();
      }
      
      public static function vctor() : Vector.<BattleWaveBucketDef>
      {
         return new Vector.<BattleWaveBucketDef>();
      }
      
      public function clone(param1:BattleWaveBucketDef) : BattleWaveBucketDef
      {
         if(!param1)
         {
            return null;
         }
         this.guaranteedSpawns.length = 0;
         this.bucketId = param1.bucketId;
         this.lossBucketOverride = param1.lossBucketOverride;
         this.suppressBucketOnLoss = param1.suppressBucketOnLoss;
         this.deploymentId = param1.deploymentId;
         this.dangerMod = param1.dangerMod;
         this.dangerMin = param1.dangerMin;
         this.dangerMax = param1.dangerMax;
         var _loc2_:int = 0;
         while(_loc2_ < param1.guaranteedSpawns.length)
         {
            this.guaranteedSpawns.push(new GuaranteedSpawnDef().clone(param1.guaranteedSpawns[_loc2_]));
            _loc2_++;
         }
         return this;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleWaveBucketDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.bucketId = param1.bucketId;
         this.deploymentId = param1.deploymentId;
         if(param1.lossBucketOverride)
         {
            this.lossBucketOverride = param1.lossBucketOverride;
         }
         if(param1.suppressBucketOnLoss)
         {
            this.suppressBucketOnLoss = param1.suppressBucketOnLoss;
         }
         if(param1.dangerMod)
         {
            this.dangerMod = param1.dangerMod;
         }
         if(param1.dangerMin)
         {
            this.dangerMin = param1.dangerMin;
         }
         if(param1.dangerMax)
         {
            this.dangerMax = param1.dangerMax;
         }
         if(param1.guaranteedSpawns)
         {
            this.guaranteedSpawns = ArrayUtil.arrayToDefVector(param1.guaranteedSpawns,GuaranteedSpawnDef,param2,this.guaranteedSpawns) as Vector.<GuaranteedSpawnDef>;
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "bucketId":this.bucketId,
            "suppressBucketOnLoss":this.suppressBucketOnLoss,
            "deploymentId":(!!this.deploymentId ? this.deploymentId : "")
         };
         if(Boolean(this.lossBucketOverride) && this.lossBucketOverride.length > 0)
         {
            _loc1_.lossBucketOverride = this.lossBucketOverride;
         }
         if(this.guaranteedSpawns)
         {
            _loc1_.guaranteedSpawns = ArrayUtil.defVectorToArray(this.guaranteedSpawns,false);
         }
         if(this.dangerMod != 0)
         {
            _loc1_.dangerMod = this.dangerMod;
         }
         if(this.dangerMin > 0)
         {
            _loc1_.dangerMin = this.dangerMin;
         }
         if(this.dangerMax < BattleBoard_SpawnConstants.MAX_DANGER)
         {
            _loc1_.dangerMax = this.dangerMax;
         }
         return _loc1_;
      }
   }
}
