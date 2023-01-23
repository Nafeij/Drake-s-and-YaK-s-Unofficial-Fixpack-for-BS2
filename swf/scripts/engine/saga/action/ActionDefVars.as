package engine.saga.action
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.expression.Parser;
   import engine.saga.happening.HappeningDef;
   import engine.saga.vars.VariableKey;
   import engine.saga.vars.VariableKeyVars;
   
   public class ActionDefVars extends ActionDef
   {
      
      public static const schema:Object = {
         "name":"ActionDefVars",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "prereqs":{
               "type":"array",
               "items":VariableKeyVars.schema,
               "optional":true
            },
            "weights":{
               "type":"array",
               "items":VariableKeyVars.schema,
               "optional":true
            },
            "url":{
               "type":"string",
               "optional":true
            },
            "scene":{
               "type":"string",
               "optional":true
            },
            "varname":{
               "type":"string",
               "optional":true
            },
            "varvalue":{
               "type":"number",
               "optional":true
            },
            "varother":{
               "type":"string",
               "optional":true
            },
            "id":{
               "type":"string",
               "optional":true
            },
            "enabled":{
               "type":"boolean",
               "optional":true
            },
            "msg":{
               "type":"string",
               "optional":true
            },
            "speaker":{
               "type":"string",
               "optional":true
            },
            "anchor":{
               "type":"string",
               "optional":true
            },
            "subtitle":{
               "type":"string",
               "optional":true
            },
            "time":{
               "type":"number",
               "optional":true
            },
            "location":{
               "type":"string",
               "optional":true
            },
            "instant":{
               "type":"boolean",
               "optional":true
            },
            "happening":{
               "type":"string",
               "optional":true
            },
            "also_party":{
               "type":"boolean",
               "optional":true
            },
            "restore_scene":{
               "type":"boolean",
               "optional":true
            },
            "bucket":{
               "type":"string",
               "optional":true
            },
            "spawn_tags":{
               "type":"string",
               "optional":true
            },
            "board_id":{
               "type":"string",
               "optional":true
            },
            "suppress_flytext":{
               "type":"boolean",
               "optional":true
            },
            "param":{
               "type":"string",
               "optional":true
            },
            "loops":{
               "type":"number",
               "optional":true
            },
            "frame":{
               "type":"number",
               "optional":true
            },
            "assemble_heroes":{
               "type":"boolean",
               "optional":true
            },
            "battle_vitalities":{
               "type":"string",
               "optional":true
            },
            "battle_skip_finished":{
               "type":"boolean",
               "optional":true
            },
            "battle_scenario_id":{
               "type":"string",
               "optional":true
            },
            "makesave":{
               "type":"boolean",
               "optional":true
            },
            "makesave_id":{
               "type":"string",
               "optional":true
            },
            "war":{
               "type":"boolean",
               "optional":true
            },
            "poppening_top":{
               "type":"number",
               "optional":true
            },
            "expression":{
               "type":"string",
               "optional":true
            },
            "prereq":{
               "type":"string",
               "optional":true
            },
            "battle_music":{
               "type":"string",
               "optional":true
            },
            "battle_music_override":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function ActionDefVars(param1:HappeningDef)
      {
         super(param1);
      }
      
      public static function save(param1:ActionDef) : Object
      {
         var _loc3_:VariableKey = null;
         var _loc4_:VariableKey = null;
         var _loc2_:Object = {};
         if(param1.type)
         {
            _loc2_.type = StringUtil.trim(param1.type.name);
         }
         if(param1.battle_scenario_id)
         {
            _loc2_.battle_scenario_id = param1.battle_scenario_id;
         }
         if(param1.battle_music)
         {
            _loc2_.battle_music = param1.battle_music;
         }
         if(param1.battle_music_override)
         {
            _loc2_.battle_music_override = param1.battle_music_override;
         }
         if(Boolean(param1.prereqs) && param1.prereqs.length > 0)
         {
            _loc2_.prereqs = [];
            for each(_loc3_ in param1.prereqs)
            {
               _loc2_.prereqs.push(VariableKeyVars.save(_loc3_));
            }
         }
         if(Boolean(param1.weights) && param1.weights.length > 0)
         {
            _loc2_.weights = [];
            for each(_loc4_ in param1.weights)
            {
               _loc2_.weights.push(VariableKeyVars.save(_loc4_));
            }
         }
         if(param1.url)
         {
            _loc2_.url = StringUtil.trim(param1.url);
         }
         if(param1.scene)
         {
            _loc2_.scene = StringUtil.trim(param1.scene);
         }
         if(param1.varname)
         {
            _loc2_.varname = StringUtil.trim(param1.varname).replace(/ /g,"_");
         }
         if(param1.varvalue)
         {
            _loc2_.varvalue = param1.varvalue;
         }
         if(param1.varother)
         {
            _loc2_.varother = StringUtil.trim(param1.varother).replace(/ /g,"_");
         }
         if(param1.id)
         {
            _loc2_.id = StringUtil.trim(param1.id);
         }
         if(!param1.enabled)
         {
            _loc2_.enabled = param1.enabled;
         }
         if(param1.msg)
         {
            _loc2_.msg = param1.msg;
         }
         if(param1.anchor)
         {
            _loc2_.anchor = StringUtil.trim(param1.anchor);
         }
         if(param1.subtitle)
         {
            _loc2_.subtitle = StringUtil.trim(param1.subtitle);
         }
         if(param1.location)
         {
            _loc2_.location = StringUtil.trim(param1.location);
         }
         if(param1.instant)
         {
            _loc2_.instant = param1.instant;
         }
         if(param1.happeningId)
         {
            _loc2_.happening = StringUtil.trim(param1.happeningId);
         }
         if(param1.also_party)
         {
            _loc2_.also_party = param1.also_party;
         }
         if(param1.time)
         {
            _loc2_.time = param1.time;
         }
         if(param1.speaker)
         {
            _loc2_.speaker = StringUtil.trim(param1.speaker);
         }
         if(!param1.restore_scene)
         {
            _loc2_.restore_scene = param1.restore_scene;
         }
         if(param1.bucket)
         {
            _loc2_.bucket = param1.bucket;
         }
         if(param1.spawn_tags)
         {
            _loc2_.spawn_tags = param1.spawn_tags;
         }
         if(param1.board_id)
         {
            _loc2_.board_id = param1.board_id;
         }
         if(param1.suppress_flytext)
         {
            _loc2_.suppress_flytext = param1.suppress_flytext;
         }
         if(!param1.assemble_heroes)
         {
            _loc2_.assemble_heroes = param1.assemble_heroes;
         }
         if(param1.param)
         {
            _loc2_.param = param1.param;
         }
         if(param1.frame)
         {
            _loc2_.frame = param1.frame;
         }
         if(param1.poppening_top)
         {
            _loc2_.poppening_top = param1.poppening_top;
         }
         if(param1.war)
         {
            _loc2_.war = param1.war;
         }
         if(param1.loops)
         {
            _loc2_.loops = param1.loops;
         }
         if(param1.battle_vitalities)
         {
            _loc2_.battle_vitalities = param1.battle_vitalities;
         }
         if(param1.expression)
         {
            _loc2_.expression = param1.expression;
         }
         if(param1.prereq)
         {
            _loc2_.prereq = param1.prereq;
         }
         if(param1.battle_skip_finished)
         {
            _loc2_.battle_skip_finished = param1.battle_skip_finished;
         }
         if(param1.makesave)
         {
            _loc2_.makesave = param1.makesave;
         }
         if(param1.makesaveId)
         {
            _loc2_.makesave_id = param1.makesaveId;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ActionDefVars
      {
         var _loc3_:Object = null;
         var _loc4_:VariableKeyVars = null;
         var _loc5_:Object = null;
         var _loc6_:VariableKeyVars = null;
         var _loc7_:Parser = null;
         var _loc8_:Parser = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         type = Enum.parse(ActionType,param1.type) as ActionType;
         if(param1.prereqs)
         {
            for each(_loc3_ in param1.prereqs)
            {
               _loc4_ = new VariableKeyVars();
               _loc4_.fromJson(_loc3_,param2);
               addPrereq(_loc4_);
            }
         }
         if(param1.weights)
         {
            for each(_loc5_ in param1.weights)
            {
               _loc6_ = new VariableKeyVars();
               _loc6_.fromJson(_loc5_,param2);
               addWeight(_loc6_);
            }
         }
         battle_scenario_id = param1.battle_scenario_id;
         param = param1.param;
         url = param1.url;
         scene = param1.scene;
         varname = param1.varname;
         if(varname)
         {
            varname = StringUtil.stripSurroundingSpace(varname).replace(/ /g,"_");
         }
         happeningId = param1.happening;
         speaker = param1.speaker;
         restore_scene = BooleanVars.parse(param1.restore_scene,restore_scene);
         battle_vitalities = param1.battle_vitalities;
         expression = param1.expression;
         prereq = param1.prereq;
         battle_music = param1.battle_music;
         battle_music_override = param1.battle_music_override;
         makesave = param1.makesave;
         makesaveId = param1.makesave_id;
         also_party = BooleanVars.parse(param1.also_party,also_party);
         if(param1.varvalue != undefined)
         {
            varvalue = param1.varvalue;
         }
         if(param1.varother != undefined)
         {
            varother = param1.varother;
         }
         if(varother)
         {
            varother = StringUtil.stripSurroundingSpace(varother).replace(/ /g,"_");
         }
         if(param1.loops != undefined)
         {
            loops = param1.loops;
         }
         poppening_top = param1.poppening_top;
         war = param1.war;
         if(param1.frame != undefined)
         {
            frame = param1.frame;
         }
         id = param1.id;
         enabled = BooleanVars.parse(param1.enabled,enabled);
         msg = param1.msg;
         anchor = param1.anchor;
         subtitle = param1.subtitle;
         if(param1.time != undefined)
         {
            time = param1.time;
         }
         location = param1.location;
         instant = BooleanVars.parse(param1.instant,instant);
         bucket = param1.bucket;
         spawn_tags = param1.spawn_tags;
         board_id = param1.board_id;
         suppress_flytext = BooleanVars.parse(param1.suppress_flytext,suppress_flytext);
         assemble_heroes = BooleanVars.parse(param1.assemble_heroes,assemble_heroes);
         battle_skip_finished = param1.battle_skip_finished;
         if(expression)
         {
            _loc7_ = new Parser(expression,param2);
            exp_expression = _loc7_.exp;
            if(!exp_expression)
            {
               throw new ArgumentError("Failed to parse expression [" + expression + "] for " + this);
            }
         }
         if(prereq)
         {
            _loc8_ = new Parser(prereq,param2);
            exp_prereq = _loc8_.exp;
            if(!exp_prereq)
            {
               throw new ArgumentError("Failed to parse prereq [" + prereq + "] for " + this);
            }
         }
         return this;
      }
   }
}
