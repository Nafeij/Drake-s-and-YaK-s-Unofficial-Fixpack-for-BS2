package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.scene.model.SceneLoaderBattleInfo;
   
   public class BattleScenarioDef
   {
      
      public static const schema:Object = {
         "name":"BattleScenarioDef",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "objectives":{
               "type":"array",
               "items":BattleObjectiveDef.schema
            },
            "hints":{
               "type":"array",
               "items":BattleObjectiveDef.schema,
               "optional":true
            },
            "clearParty":{
               "type":"boolean",
               "optional":true
            },
            "castMembers":{
               "type":"array",
               "optional":true
            },
            "rosterMembers":{
               "type":"array",
               "optional":true
            },
            "board":{
               "type":"string",
               "optional":true
            },
            "bucket":{
               "type":"string",
               "optional":true
            },
            "bucket_deployment":{
               "type":"string",
               "optional":true
            },
            "bucket_quota":{
               "type":"number",
               "optional":true
            },
            "spawn_tags":{
               "type":"string",
               "optional":true
            },
            "achievement":{
               "type":"string",
               "optional":true
            },
            "renown":{
               "type":"number",
               "optional":true
            },
            "music":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var id:String;
      
      public var clearParty:Boolean;
      
      public var castMembers:Vector.<String>;
      
      public var rosterMembers:Vector.<String>;
      
      public var objectives:Vector.<BattleObjectiveDef>;
      
      public var hints:Vector.<BattleObjectiveDef>;
      
      public var requiresPartyMembers:Boolean;
      
      public var url:String;
      
      public var happening:String;
      
      public var board:String;
      
      public var bucket:String;
      
      public var bucket_deployment:String;
      
      public var bucket_quota:int = 0;
      
      public var spawn_tags:String;
      
      public var achievement:String;
      
      public var renown:int;
      
      public var music:String;
      
      public function BattleScenarioDef()
      {
         this.castMembers = new Vector.<String>();
         this.rosterMembers = new Vector.<String>();
         this.objectives = new Vector.<BattleObjectiveDef>();
         this.hints = new Vector.<BattleObjectiveDef>();
         super();
      }
      
      public function toString() : String
      {
         return this.id;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleScenarioDef
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:BattleObjectiveDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.board = param1.board;
         this.bucket = param1.bucket;
         this.bucket_quota = param1.bucket_quota;
         this.bucket_deployment = param1.bucket_deployment;
         this.spawn_tags = param1.spawn_tags;
         this.achievement = param1.achievement;
         this.renown = param1.renown;
         this.music = param1.music;
         for each(_loc3_ in param1.objectives)
         {
            _loc5_ = new BattleObjectiveDef(this).fromJson(_loc3_,param2);
            this.objectives.push(_loc5_);
         }
         for each(_loc3_ in param1.hints)
         {
            _loc5_ = new BattleObjectiveDef(this).fromJson(_loc3_,param2);
            this.hints.push(_loc5_);
         }
         this.clearParty = BooleanVars.parse(param1.clearParty,this.clearParty);
         if(param1.rosterMembers)
         {
            for each(_loc4_ in param1.rosterMembers)
            {
               this.rosterMembers.push(_loc4_);
            }
         }
         if(param1.castMembers)
         {
            for each(_loc4_ in param1.castMembers)
            {
               this.castMembers.push(_loc4_);
            }
         }
         return this;
      }
      
      public function allowPartyMember(param1:String) : Boolean
      {
         return false;
      }
      
      public function updateBattleInfo(param1:SceneLoaderBattleInfo) : void
      {
         if(this.url)
         {
            param1.url = this.url;
         }
         if(this.happening)
         {
            param1.happening = this.happening;
         }
         if(this.board)
         {
            param1.battle_board_id = this.board;
         }
         if(this.bucket)
         {
            param1.battle_bucket = this.bucket;
         }
         if(this.bucket_quota)
         {
            param1.battle_bucket_quota = this.bucket_quota;
         }
         if(this.bucket_deployment)
         {
            param1.battle_bucket_deployment = this.bucket_deployment;
         }
         if(this.spawn_tags)
         {
            param1.battle_spawn_tags = this.spawn_tags;
         }
         if(this.music)
         {
            param1.music_override = true;
            param1.music_url = this.music;
         }
      }
   }
}
